local move = require("/utils/move")
local safe = require("/utils/safe")
local log = require("/utils/log")
local location = require("/utils/location")

---@class highwayNav
local highwayNav = {}

local baseSettings = settings.get("base")

local SWAP_Z = baseSettings.swapZ
local OUTGOING_Z = baseSettings.outgoingZ
local INCOMING_Z = baseSettings.incomingZ

local RESERVED_COLUMNS = {
    ["0,0"] = true,
    ["0,1"] = true,
    ["1,0"] = true,
    ["1,1"] = true,
}

local function getFloorIncomingZ(floor)
    local floorBaseZ = location.getFloorBaseZ(floor)

    return floorBaseZ + INCOMING_Z;
end

local function getFloorOutgoingZ(floor)
    local floorBaseZ = location.getFloorBaseZ(floor)

    return floorBaseZ + OUTGOING_Z;
end

local function getFloorSwapZ(floor)

    -- when recalibrating at the lowest floor in the base
    if(floor < location.getMinFloor()) then return location.getFloorBaseZ(location.getMinFloor()) end 

    local floorBaseZ = location.getFloorBaseZ(floor)

    return floorBaseZ + SWAP_Z;
end

-- Cannot be called when turtle is in 1,1 already (this will cause deadlock)
local function moveToIncomingZ()
    local loc = location.getLocation()

    if loc.x == 1 and loc.y == 1 then
        log.error("moveToIncomingZ cannot be called from (1,1)")
    end

    local currentFloor = location.getFloor(loc.z)
    local currentIncomingZ = getFloorIncomingZ(currentFloor)

    local stepsToMove = currentIncomingZ - loc.z

    for i = 1, stepsToMove do
        safe.execute(move.up)
    end
end

local function moveToOutgoingZ(targetFloor)
    local loc = location.getLocation()

    if loc.x ~= 0 or loc.y ~= 1 then
        log.error("moveToOutgoingZ must be called from (0,1)")
    end

    local targetOutgoingZ = getFloorOutgoingZ(targetFloor)
    local currentZ = loc.z

    if currentZ > targetOutgoingZ then
        -- Illegal move down
        -- Should theoretically never happen
        log.error("Illegal move down from moveToOutgoingZ (currentZ=" .. currentZ .. ", targetOutgoingZ=" .. targetOutgoingZ .. ")")
    end

    if currentZ == targetOutgoingZ then
        return
    end

    local stepsToMove = targetOutgoingZ - currentZ
    for _ = 1, stepsToMove do
        safe.execute(move.up)
    end
end

local function moveToSwapZ(targetFloor)
    local loc = location.getLocation()

    if loc.x ~= 1 or loc.y ~= 1 then
        log.error("moveToSwapZ must be called from (1,1)")
    end

    local currentZ = loc.z

    local function getClosestSwapZ(currentZ)
        local targetSwapZ = getFloorSwapZ(targetFloor)

        if currentZ > targetSwapZ then return targetSwapZ end

        local currentFloor = location.getFloor(currentZ)
        local currentFloorSwapZ = getFloorSwapZ(currentFloor)

        if currentFloorSwapZ > currentZ then
            return getFloorSwapZ(currentFloor - 1)
        else
            return currentFloorSwapZ
        end
    end

    local targetSwapZ = getClosestSwapZ(currentZ)

    if currentZ == targetSwapZ then
        return
    end

    local stepsToMove = currentZ - targetSwapZ
    for _ = 1, stepsToMove do
        safe.execute(move.down)
    end
end

function highwayNav.moveToXY(targetX, targetY)
    local loc = location.getLocation()
    local dx = targetX - loc.x
    local dy = targetY - loc.y

    local function moveInDirection(dir, amount)
        if(amount == 0) then return end

        safe.execute(function() return move.faceDirection(dir) end)
        for _ = 1, math.abs(amount) do
            safe.execute(move.forward)
        end
    end

    local xDir = dx >= 0 and "right" or "left"
    local yDir = dy >= 0 and "forward" or "back"

    if math.abs(dx) <= math.abs(dy) then
        moveInDirection(xDir, dx)
        moveInDirection(yDir, dy)
    else
        moveInDirection(yDir, dy)
        moveInDirection(xDir, dx)
    end
end

local function isLegalMove(targetX, targetY, targetFloor)
    if(targetX == 0 and targetY == 0 and targetFloor == 0) then return true end

    local targetKey = targetX .. "," .. targetY
    if RESERVED_COLUMNS[targetKey] then
        return false
    end

    return true
end

function highwayNav.goHome(ignoreRoadCheck)
    highwayNav.moveTo(0,0,0,ignoreRoadCheck)
end

local function joinStack()
    safe.execute(function() return move.faceDirection("back") end)

    while(true) do
        if(turtle.inspect()) then
            safe.execute(move.up)
        end

        -- dont use safe in case race condition (i.e. inspect noticed slot is free, but a turtle moved in that spot a split second later)
        if(move.forward()) then 
            break
        end
    end

    highwayNav.moveTo(0, 0, 0)
end
    
local function recalibrate(targetFloor)
    local loc = location.getLocation()
    if(loc.x ~= 1 or loc.y ~= 1) then
        moveToIncomingZ()
        highwayNav.moveToXY(1,1)
    end
    
    moveToSwapZ(targetFloor)
    highwayNav.moveToXY(0,1)
end

local function goToTarget(targetX, targetY, targetFloor)
    moveToOutgoingZ(targetFloor)

    if(location.isHome(targetX, targetY, targetFloor)) then
        joinStack()
    else
        highwayNav.moveToXY(targetX, targetY)
    end
end

local function canGoToTarget(targetFloor)
    local loc = location.getLocation()
    local targetOutgoingZ = getFloorOutgoingZ(targetFloor)

    if(loc.x == 0 and loc.y == 1 and loc.z <= targetOutgoingZ) then return true end

    return false
end

local function recalibrateAndGoToTarget(targetX, targetY, targetFloor)
    if(not canGoToTarget(targetFloor)) then
        recalibrate(targetFloor)
    end

    if(not canGoToTarget(targetFloor)) then log.error("Recalibration failed") end

    goToTarget(targetX, targetY, targetFloor)
end

-- Warning: Cannot reliably be used to move to a location directly behind the idle stack
-- Current implementation moves along the shortest axis first (in this example, the x axis)
-- Then it will turn and move from (0,1) to the negative y direction
-- If the idle stack is tall enough, this will cause deadlock

function highwayNav.moveTo(targetX, targetY, targetFloor, ignoreRoadCheck)
    local loc = location.getLocation()

    if (not isLegalMove(targetX, targetY, targetFloor)) then 
        log.error("Illegal moveTo to a reserved column: (x=)" .. targetX .. ", y=" .. targetY .. ", floor=" .. targetFloor .. ")") 
    end

    if(not ignoreRoadCheck) then
        if (not location.isOnRoad(loc.x, loc.y)) then 
            log.error("Turtle must be on the road: (x=)" .. loc.x .. ", y=" .. loc.y .. ")") 
        end
    
        if (not location.isOnRoad(targetX, targetY)) then 
            log.error("Target must be on the road: (x=)" .. targetX .. ", y=" .. targetY .. ")") 
        end
    end

    -- Special case: turtle at (0,0)
    if(loc.x == 0 and loc.y == 0) then
        if(loc.z == 0) then log.error("Hub turtle trying to move") end

        if (loc.z > 0) then 
            if(location.isHome(targetX, targetY, targetFloor)) then
                while (location.getLocation().z > 1) do
                    safe.execute(move.down)
                end
                return
                --os.shutdown()
            else
                highwayNav.moveToXY(0,1) -- recalibrating without this is dangerous as we might be in the idle stack, and can't go up to incomingZ
            end
        end
    end

    recalibrateAndGoToTarget(targetX, targetY, targetFloor)
end

return highwayNav