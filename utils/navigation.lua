local log = require("/utils/log")
local moveTracker = require("/utils/moveTracker")
local location = require("/utils/location")
local highwayNav = require("/utils/highwayNav")
local safe = require("/utils/safe")
local roomNav = require("/utils/roomNav")

---@class navigation
local navigation = {}

local outgoingZ = settings.get("base").outgoingZ

local function tryToBacktrack()
    local loc = location.getLocation()

    if(not location.isOnRoad(loc.x, loc.y)) then
        if(moveTracker.canBacktrack()) then moveTracker.backtrack() 
        else log.error("Turtle in the room cannot backtrack") end
    else
        if(moveTracker.canBacktrack()) then log.error("Turtle on the road can backtrack") end
    end

    return true
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

    tryToBacktrack()

    local turtleX, turtleY = getRoomTurtleLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == turtleX and loc.y == turtleY and loc.z == location.getFloorBaseZ(floor) + outgoingZ) then
        print("Already at turtle")
        return
    end

    return highwayNav.moveTo(turtleX, turtleY, floor)
end

function navigation.goToRoomOutputChest(lat, long, floor)
    
    tryToBacktrack()

    local outputChestX, outputChestY = getRoomOutputChestLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == outputChestX and loc.y == outputChestY and loc.z == location.getFloorBaseZ(floor) + outgoingZ) then
        print("Already at output chest")
        return
    end

    return highwayNav.moveTo(outputChestX, outputChestY, floor)
end

function navigation.goToRoomInputChest(lat, long, floor)

    tryToBacktrack()

    local inputChestX, inputChestY = getRoomInputChestLocation(lat, long)
    local loc = location.getLocation()

    if(loc.x == inputChestX and loc.y == inputChestY and loc.z == location.getFloorBaseZ(floor) + outgoingZ) then
        print("Already at input chest")
        return
    end

    return highwayNav.moveTo(inputChestX, inputChestY, floor)
end

function navigation.goToRoomJobStart(lat, long, floor, jobStartLocation)
    navigation.goToRoomTurtle(lat, long, floor)

    safe.execute(function() 
        return roomNav.faceDirection("forward")
    end)

    safe.execute(moveTracker.forward)
    safe.execute(moveTracker.forward)

    safe.execute(function()
        return roomNav.moveToXYZ(jobStartLocation.x, jobStartLocation.y, jobStartLocation.z)
    end)

    safe.execute(function()
        roomNav.faceDirection("forward")
    end)
end

return navigation