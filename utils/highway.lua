local move = require("/utils/move")
local safe = require("/utils/safe")
local log = require("/utils/log")

local highway = {}

local SWAP_Z = 0
local OUTGOING_Z = 2
local INCOMING_Z = 3

local RESERVED_COLUMNS = {
    ["0,0"] = true,
    ["0,1"] = true,
    ["1,0"] = true,
    ["1,1"] = true,
}

local ABOVE_FLOOR_GROUPS = {
    { count = 4, height = 10 },
    { count = 4, height = 20 },
    { count = 4, height = 30 }
}

local BELOW_FLOOR_GROUPS = {
    { count = 4, height = 10 },
    { count = 4, height = 20 }
}

function highway.getMinFloor()
    local total = 0
    for _, group in ipairs(BELOW_FLOOR_GROUPS) do
        total = total + group.count
    end
    return -total
end

function highway.getFloor(z)
    if z >= 0 then
        local currentZ = 0
        local floor = 0

        for _, group in ipairs(ABOVE_FLOOR_GROUPS) do
            for i = 1, group.count do
                local nextZ = currentZ + group.height
                if z < nextZ then
                    return floor
                end
                currentZ = nextZ
                floor = floor + 1
            end
        end

        log.error("Z too high, no floor defined at z=" .. z)
    else
        local currentZ = 0
        local floor = -1

        for _, group in ipairs(BELOW_FLOOR_GROUPS) do
            for i = 1, group.count do
                local nextZ = currentZ - group.height
                if z >= nextZ then
                    return floor
                end
                currentZ = nextZ
                floor = floor - 1
            end
        end

        log.error("Z too low, no floor defined at z=" .. z)
    end
end

function highway.getFloorBaseZ(floor)
    if floor >= 0 then
        local currentZ = 0
        local currentFloor = 0

        for _, group in ipairs(ABOVE_FLOOR_GROUPS) do
            for i = 1, group.count do
                if currentFloor == floor then
                    return currentZ
                end
                currentZ = currentZ + group.height
                currentFloor = currentFloor + 1
            end
        end
    else
        local currentZ = 0
        local currentFloor = -1

        for _, group in ipairs(BELOW_FLOOR_GROUPS) do
            for i = 1, group.count do
                if currentFloor == floor then
                    return currentZ - group.height
                end
                currentZ = currentZ - group.height
                currentFloor = currentFloor - 1
            end
        end
    end

    log.error("Floor number out of bounds: " .. floor)
end

function highway.isOnRoad(x, y, roadSize)
    local half = math.floor(roadSize / 2)
    local min = roadSize % 2 == 0 and (-half + 1) or -half
    local max = half

    return (x >= min and x <= max) or
           (y >= min and y <= max)
end

local function getFloorIncomingZ(floor)
    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + INCOMING_Z;
end

local function getFloorOutgoingZ(floor)
    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + OUTGOING_Z;
end

local function getFloorSwapZ(floor)

    -- when recalibrating at the lowest floor in the base
    if(floor < highway.getMinFloor()) then return highway.getFloorBaseZ(highway.getMinFloor()) end 

    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + SWAP_Z;
end

-- Cannot be called when turtle is in 1,1 already (this will cause deadlock)
local function moveToIncomingZ()
    local location = move.getLocation()

    if location.x == 1 and location.y == 1 then
        log.error("moveToIncomingZ cannot be called from (1,1)")
    end

    local currentFloor = highway.getFloor(location.z)
    local currentIncomingZ = getFloorIncomingZ(currentFloor)

    local stepsToMove = currentIncomingZ - location.z

    for i = 1, stepsToMove do
        safe.execute(move.up)
    end
end

local function moveToOutgoingZ(fallbackTargetX, fallbackTargetY, targetFloor)
    local location = move.getLocation()

    if location.x ~= 0 or location.y ~= 1 then
        log.error("moveToOutgoingZ must be called from (0,1)")
    end

    local targetOutgoingZ = getFloorOutgoingZ(targetFloor)
    local currentZ = location.z

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
    local location = move.getLocation()

    if location.x ~= 1 or location.y ~= 1 then
        log.error("moveToSwapZ must be called from (1,1)")
    end

    local currentZ = location.z

    local function getClosestSwapZ(currentZ)
        local targetSwapZ = getFloorSwapZ(targetFloor)

        if currentZ > targetSwapZ then return targetSwapZ end

        local currentFloor = highway.getFloor(currentZ)
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

function highway.moveToXY(targetX, targetY)
    local location = move.getLocation()
    local dx = targetX - location.x
    local dy = targetY - location.y

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

function highway.goHome(ignoreRoadCheck)
    highway.moveTo(0,0,0,ignoreRoadCheck)
end

function highway.isHome(targetX, targetY, targetFloor)
    if(targetX == 0 and targetY == 0 and targetFloor == 0) then return true end

    return false
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

    highway.moveTo(0, 0, 0)
end
    
local function recalibrate(targetFloor)
    local location = move.getLocation()
    if(location.x ~= 1 or location.y ~= 1) then
        moveToIncomingZ()
        highway.moveToXY(1,1)
    end
    
    moveToSwapZ(targetFloor)
    highway.moveToXY(0,1)
end

local function goToTarget(targetX, targetY, targetFloor)
    moveToOutgoingZ(targetX, targetY, targetFloor)

    if(highway.isHome(targetX, targetY, targetFloor)) then
        joinStack()
    else
        highway.moveToXY(targetX, targetY)
    end
end

local function canGoToTarget(targetX, targetY, targetFloor)
    local location = move.getLocation()
    local targetOutgoingZ = getFloorOutgoingZ(targetFloor)

    if(location.x == 0 and location.y == 1 and location.z <= targetOutgoingZ) then return true end

    return false
end

local function recalibrateAndGoToTarget(targetX, targetY, targetFloor)
    if(not canGoToTarget(targetX, targetY, targetFloor)) then
        recalibrate(targetFloor)
    end

    if(not canGoToTarget(targetX, targetY, targetFloor)) then log.error("Recalibration failed") end

    goToTarget(targetX, targetY, targetFloor)
end

function highway.moveTo(targetX, targetY, targetFloor, ignoreRoadCheck)
    local location = move.getLocation()

    if (not isLegalMove(targetX, targetY, targetFloor)) then 
        log.error("Illegal moveTo to a reserved column: (x=)" .. targetX .. ", y=" .. targetY .. ", floor=" .. targetFloor .. ")") 
    end

    if(not ignoreRoadCheck) then
        if (not highway.isOnRoad(location.x, location.y, 4)) then 
            log.error("Turtle must be on the road: (x=)" .. location.x .. ", y=" .. location.y .. ")") 
        end
    
        if (not highway.isOnRoad(targetX, targetY, 4)) then 
            log.error("Target must be on the road: (x=)" .. targetX .. ", y=" .. targetY .. ")") 
        end
    end

    -- Special case: turtle at (0,0)
    if(location.x == 0 and location.y == 0) then
        if(location.z == 0) then log.error("Hub turtle trying to move") end

        if (location.z > 0) then 
            if(highway.isHome(targetX, targetY, targetFloor)) then
                while (move.getLocation().z > 1) do
                    safe.execute(move.down)
                end
                return
                --os.shutdown()
            else
                highway.moveToXY(0,1) -- recalibrating without this is dangerous as we might be in the idle stack, and can't go up to incomingZ
            end
        end
    end

    recalibrateAndGoToTarget(targetX, targetY, targetFloor)
end

return highway