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


-- todo: keep this returning the same kind of array, BUT make the actual json object aware of each slot
-- this keeps this behavior as is, but allows worker turtle to allocate fuel correctly
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
            table.insert(combined, {
                itemName = item.itemName,
                itemMinCount = item.itemMinCount,
                itemMaxCount = item.itemMaxCount
            })
        end
    end

    return combined
end

function roomInfo.countCurrentRequiredItems()
    local requiredItems = roomInfo.getRequiredItems()

    local currentRequiredItems = {}
    for _, item in ipairs(requiredItems) do
        currentRequiredItems[item.itemName] = 0
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
    currentRequiredItems = currentRequiredItems or roomInfo.countCurrentRequiredItems()
    local requiredItems = roomInfo.getRequiredItems()

    local hasMissingItems = false
    local missing = {}
    for _, item in ipairs(requiredItems) do
        local current = currentRequiredItems[item.itemName]
        current = current or 0
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

function roomInfo.hasEnoughToStart()
    local missingItems = roomInfo.countMissingItems()

    if not missingItems then return true end

    for itemName, missingAmounts in pairs(missingItems) do
        if(missingAmounts.itemMinMissing > 0) then return false end
    end

    return true
end

return roomInfo