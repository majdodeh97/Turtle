local log = require("/utils/log")
local location = require("/utils/location")
local inventory = require("/utils/inventory")

---@class roomInfo
local roomInfo = {}

local path = "/roomInfos.json"

function roomInfo.getRoomInfoByLocation(lat, long, floor)
    if not fs.exists(path) then
        log.error("File not found: " .. path)
    end

    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()

    local data = textutils.unserializeJSON(content)
    if not data or type(data.rooms) ~= "table" then
        log.error("Invalid or missing 'rooms' data.")
    end

    for _, room in ipairs(data.rooms) do
        if room.lat == lat and room.long == long and room.floor == floor then
            return room
        end
    end

    return nil
end

function roomInfo.getRoomInfoByJob(jobName)
    if not fs.exists(path) then
        log.error("File not found: " .. path)
    end

    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()

    local data = textutils.unserializeJSON(content)
    if not data or type(data.rooms) ~= "table" then
        log.error("Invalid or missing 'rooms' data.")
    end

    for _, room in ipairs(data.rooms) do
        if room.jobInfo.jobName == jobName then
            return room
        end
    end

    return nil
end

function roomInfo.getRoomInfo()
    local lat,long = location.roomCoordsToGeoLocation()
    local floor = location.getFloor()

    return roomInfo.getRoomInfoByLocation(lat, long, floor)
end

function roomInfo.getRequiredItems()
    local info = roomInfo.getRoomInfo()

    local allItems
    if not info then log.error("Room doesn't have any info")
    else 
        allItems = info.jobInfo.items
    end

    local combined = {}

    if allItems.tools then
        for _, tool in ipairs(allItems.tools) do
            table.insert(combined, {
                itemName = tool.itemName,
                itemMinCount = 1,
                itemMaxCount = 1
            })
        end
    end

    if allItems.items then
        for _, item in ipairs(allItems.items) do
            table.insert(combined, item)
        end
    end

    return combined
end

function roomInfo.countCurrentRequiredItems(currentRequiredItems)
    local requiredItems = roomInfo.getRequiredItems()

    if (not currentRequiredItems) then
        currentRequiredItems = {}
        for _, item in ipairs(requiredItems) do
            currentRequiredItems[item.itemName] = 0
        end
    end
    
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            for _, required in ipairs(requiredItems) do
                if item.name:find(required.itemName) then
                    currentRequiredItems[required.itemName] = currentRequiredItems[required.itemName] + item.count
                end
            end
        end
    end
    return currentRequiredItems
end

function roomInfo.countMissingItems(currentRequiredItems)
    currentRequiredItems = currentRequiredItems or {}
    local requiredItems = roomInfo.getRequiredItems()

    local hasMissingItems = false
    local missing = {}
    for _, item in ipairs(requiredItems) do
        local current = currentRequiredItems[item.itemName]
        local minMissingAmount = math.max(item.itemMinCount - current, 0)
        local maxMissingAmount = math.max(item.itemMaxCount - current, 0)
        if(minMissingAmount > 0 or maxMissingAmount > 0) then
            missing[item.itemName] = { 
                itemMaxMissing = maxMissingAmount, 
                itemMinMissing = minMissingAmount 
            }
            hasMissingItems = true
        end
    end

    if(hasMissingItems) then return missing end
end

function roomInfo.hasEnoughToStart(currentRequiredItems)
    currentRequiredItems = currentRequiredItems or {}
    local missingItems = roomInfo.countMissingItems(currentRequiredItems)

    if not missingItems then return true end

    for itemName, missingAmounts in pairs(missingItems) do
        if(missingAmounts.itemMinMissing > 0) then return false end
    end

    return true
end

function roomInfo.dropRequiredItems(dropFn, currentRequiredItems)
    currentRequiredItems = currentRequiredItems or {}
    local missingitems = roomInfo.countMissingItems(currentRequiredItems)

    dropFn = dropFn or inventory.safeDrop

    local maxAllowedList = {}

    if missingitems then
        for itemName, entry in pairs(missingitems) do
            maxAllowedList[itemName] = entry.itemMaxMissing
        end
    end

    for itemName, maxAllowed in pairs(maxAllowedList) do
        local dropped = 0

        while dropped < maxAllowed do
            local success = inventory.runOnItem(function(slot, itemDetail)
                local toDrop = math.min(itemDetail.count, maxAllowed - dropped)
                dropFn(toDrop)

                dropped = dropped + toDrop
                return true
            end, itemName)

            if not success then
                break -- no match, move on to next itemName
            end
        end

        print("Dropped " .. dropped .. " out of " .. maxAllowed .. " of " .. itemName)
    end
end

function roomInfo.dropNonRequiredItems(dropFn, currentRequiredItems)
    currentRequiredItems = currentRequiredItems or {}
    local missingitems = roomInfo.countMissingItems(currentRequiredItems)

    dropFn = dropFn or inventory.safeDrop

    local maxAllowedLeft = {}

    if missingitems then
        for itemName, entry in pairs(missingitems) do
            maxAllowedLeft[itemName] = entry.itemMaxMissing
        end
    end

    inventory.foreach(function(slot, itemDetail)
        if itemDetail then
            local name = itemDetail.name
            local count = itemDetail.count
            local allowedLeft = maxAllowedLeft[name]

            inventory.runOnSlot(function()
                if not allowedLeft then
                    dropFn(count) -- Not a required item
                elseif allowedLeft <= 0 then
                    dropFn(count) -- Already have enough
                elseif count <= allowedLeft then
                    maxAllowedLeft[name] = allowedLeft - count
                else
                    dropFn(count - allowedLeft)
                    maxAllowedLeft[name] = 0
                end
            end, slot)
        end
    end)
end

return roomInfo