local log = require("/utils/log")
local moveTracker = require("/utils/moveTracker")
local move = require("/utils/move")
local location = require("/utils/location")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")
local highwayNav = require("/utils/highwayNav")

---@class navigation
local navigation = {}

local incomingZ = settings.get("base").incomingZ
local path = "/roomInfos.json"

function navigation.getRoomInfoByLocation(lat, long, floor)
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

function navigation.getRoomInfoByJob(jobName)
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

local function moveToWithBacktrack(x, y, floor)
    local loc = location.getLocation()

    if(location.isOnRoad(loc.x, loc.y)) then
        if(moveTracker.canBacktrack()) then log.error("Turtle on the road has a moveStack") end
    else
        if(moveTracker.canBacktrack()) then moveTracker.backtrack() end
    end

    return highwayNav.moveTo(x, y, floor)
end

local function addToMagnitude(number, delta)
    local sign = number >= 0 and 1 or -1
    local magnitude = math.abs(number)
    local newMagnitude = magnitude + delta

    if newMagnitude == 0 then
        return 0
    elseif newMagnitude > 0 then
        return sign * newMagnitude
    else
        return -sign * math.abs(newMagnitude)
    end
end

local function getRoomDoorLocation(lat, long)
    if(not lat or not long) then log.error("both lat and long need to be defined") end

    local baseX,baseY = location.geoLocationToRoomCoords(lat, long)
    local roomSize = settings.get("base").roomSize

    local deltaX = math.ceil(roomSize/2)

    return addToMagnitude(baseX, deltaX), baseY
end

local function getRoomTurtleLocation(lat, long)
    local doorX,doorY = getRoomDoorLocation(lat, long)

    return addToMagnitude(doorX, -3), addToMagnitude(doorY, -1)
end

local function getRoomOutputChestLocation(lat, long)
    local doorX,doorY = getRoomDoorLocation(lat, long)

    return addToMagnitude(doorX, -4), addToMagnitude(doorY, -1)
end

local function getRoomInputChestLocation(lat, long)
    local doorX,doorY = getRoomDoorLocation(lat, long)

    return addToMagnitude(doorX, -2), addToMagnitude(doorY, -1)
end

function navigation.goToRoomTurtle(lat, long, floor)
    local turtleX, turtleY = getRoomTurtleLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == turtleX and loc.y == turtleY and loc.z == location.getFloorBaseZ(floor) + incomingZ) then
        print("Already at turtle")
        return
    end

    return moveToWithBacktrack(turtleX, turtleY, floor)
end

function navigation.goToRoomOutputChest(lat, long, floor)
    local outputChestX, outputChestY = getRoomOutputChestLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == outputChestX and loc.y == outputChestY and loc.z == location.getFloorBaseZ(floor) + incomingZ) then
        print("Already at output chest")
        return
    end

    return moveToWithBacktrack(outputChestX, outputChestY, floor)
end

function navigation.goToRoomInputChest(lat, long, floor)
    local inputChestX, inputChestY = getRoomInputChestLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == inputChestX and loc.y == inputChestY and loc.z == location.getFloorBaseZ(floor) + incomingZ) then
        print("Already at input chest")
        return
    end

    return moveToWithBacktrack(inputChestX, inputChestY, floor)
end

function navigation.moveToXYZ(targetX, targetY, targetZ)
    while true do
        local loc = location.getLocation()
        if loc.x == targetX and loc.y == targetY and loc.z == targetZ then
            break
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
                move.faceDirection("forward")
                if moveTracker.forward() then break end
            elseif loc.y > targetY then
                move.faceDirection("back")
                if moveTracker.forward() then break end
            end

            -- X movement
            if loc.x < targetX then
                move.faceDirection("right")
                if moveTracker.forward() then break
                else -- Y and Z either completed or failed to move
                    print("Navigation unsuccessful. Please make way")
                    sleep(5)
                end
            elseif loc.x > targetX then
                move.faceDirection("left")
                if moveTracker.forward() then break
                else -- Y and Z either completed or failed to move
                    print("Navigation unsuccessful. Please make way")
                    sleep(5)
                end
            end
        until true
    end
end

function navigation.faceDirection(targetDir)
    if(targetDir == "left" or targetDir == "right") then
        return move.faceDirection(targetDir)
    end

    local lat = location.roomCoordsToGeoLocation()

    local dir = lat == "north" and targetDir or location.getOppositeDir(targetDir)

    return move.faceDirection(dir)
end

function navigation.goToRoomJobStart(lat, long, floor, jobStartLocation)
    navigation.goToRoomTurtle(lat, long, floor)

    navigation.faceDirection("forward")

    moveTracker.forward()
    moveTracker.forward()

    navigation.moveToXYZ(jobStartLocation.x, jobStartLocation.y, jobStartLocation.z)

    navigation.faceDirection("forward")
end

function navigation.turnToOutputChest(long)
    local dir = long == "east" and "left" or "right"

    move.faceDirection(dir)
end

function navigation.turnToInputChest(long)
    local dir = long == "east" and "right" or "left"

    move.faceDirection(dir)
end

return navigation