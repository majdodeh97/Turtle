local log = require("/utils/log")
local location = require("/utils/location")

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

function roomInfo.countRequiredItems()
    local requiredItems = roomInfo.getRequiredItems()

    local counts = {}
    for _, item in ipairs(requiredItems) do
        counts[item.itemName] = 0
    end
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            for _, required in ipairs(requiredItems) do
                if item.name:find(required.itemName) then
                    counts[required.itemName] = counts[required.itemName] + item.count
                end
            end
        end
    end
    return counts
end

function roomInfo.countMissingItems()
    local requiredItems = roomInfo.getRequiredItems()
    local currentRequiredItems = roomInfo.countRequiredItems()

    local hasMissingItems = false
    local missing = {}
    for _, item in ipairs(requiredItems) do
        local current = currentRequiredItems[item.itemName]
        local missingAmount = item.itemMinCount - current
        if(missingAmount > 0) then
            missing[item.itemName] = item.itemMaxCount - current
            hasMissingItems = true
        end
    end

    if(hasMissingItems) then return missing end
end

function roomInfo.hasEnoughToStart(counts, requiredItems)
    return roomInfo.countMissingItems() == nil
end

return roomInfo