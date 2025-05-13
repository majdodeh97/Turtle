local moveTracker = require("/utils/moveTracker")
local log = require("/utils/log")
local location = require("/utils/location")
local move = require("/utils/move")

---@class roomNav
local roomNav = {}

local path = "/roomInfos.json"

function roomNav.getRoomInfoByLocation(lat, long, floor)
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

function roomNav.getRoomInfoByJob(jobName)
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
        if room.jobName == jobName then
            return room
        end
    end

    return nil
end

function roomNav.moveToXYZ(targetX, targetY, targetZ)
    while true do
        local loc = location.getLocation()
        if loc.x == targetX and loc.y == targetY and loc.z == targetZ then
            return true
        end

        repeat -- To simulate "continue"
            -- Z movement
            if loc.z < targetZ then
                if moveTracker.up() then break end
            elseif loc.z > targetZ then
                if moveTracker.down() then break end
            end

            -- Y movement
            if loc.y < targetY then
                roomNav.faceDirection("forward")
                if moveTracker.forward() then break end
            elseif loc.y > targetY then
                roomNav.faceDirection("back")
                if moveTracker.forward() then break end
            end

            -- X movement
            if loc.x < targetX then
                roomNav.faceDirection("right")
                if moveTracker.forward() then break
                else -- Y and Z either completed or failed to move
                    return false
                end
            elseif loc.x > targetX then
                roomNav.faceDirection("left")
                if moveTracker.forward() then break
                else -- Y and Z either completed or failed to move
                    return false
                end
            end
        until true
    end
end

function roomNav.faceDirection(targetDir)
    if(targetDir == "left" or targetDir == "right") then
        return move.faceDirection(targetDir)
    end

    local lat = location.roomCoordsToGeoLocation()

    local dir = lat == "north" and targetDir or location.getOppositeDir(targetDir)

    return move.faceDirection(dir)
end

return roomNav