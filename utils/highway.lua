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

local ILLEGAL_STARTING_COLUMNS = {
    ["0,0"] = true,
    ["1,0"] = true,
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

local function moveXY(targetX, targetY)
    local location = move.getLocation()
    local currX, currY = location.x, location.y

    -- Move in X axis first
    while currX ~= targetX do
        local dir = (targetX > currX) and "right" or "left"
        print("facing " .. dir)
        move.faceDirection(dir)
        os.pullEvent("key")
        local success = move.forward()
        if not success then
            print("Failed to move in X direction.")
            sleep(1)
        else
            currX = (dir == "right") and (currX + 1) or (currX - 1)
        end
    end

    -- Move in Y axis
    while currY ~= targetY do
        local dir = (targetY > currY) and "forward" or "back"
        print("facing " .. dir)
        move.faceDirection(dir)
        os.pullEvent("key")
        local success = move.forward()
        if not success then
            print("Failed to move in Y direction.")
            sleep(1)
        else
            currY = (dir == "forward") and (currY + 1) or (currY - 1)
        end
    end
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

function highway.getFloorIncomingZ(floor)
    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + INCOMING_Z;
end

function highway.getOutgoingZ(floor)
    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + OUTGOING_Z;
end

function highway.getSwapZ(floor)
    local floorBaseZ = highway.getFloorBaseZ(floor)

    return floorBaseZ + SWAP_Z;
end

function highway.moveToIncomingZ()
    local location = move.getLocation()
    local currentFloor = highway.getFloor(location.z)
    local currentIncomingZ = highway.getFloorIncomingZ(currentFloor)

    local stepsToMove = currentIncomingZ - location.z

    for i = 1, stepsToMove do
        safe.execute(move.up)
    end
end

local function moveToIncomingHighway()

end



function highway.moveTo(targetX, targetY, floor)

    -- bug if turtle is already on the incoming highway, it will still attempt to go to outgoing highway 

    local targetKey = targetX .. "," .. targetY
    if RESERVED_COLUMNS[targetKey] then
        error("Cannot use moveTo on a reserved column: " .. targetKey)
    end

    local loc = move.getLocation()

    local locationKey = loc.x .. "," .. loc.y
    if ILLEGAL_STARTING_COLUMNS[locationKey] then
        error("Cannot use moveTo from an illegal column: " .. locationKey)
    end

    if(loc.x ~= 0 or loc.y ~= 1 or loc.z ~= 1) then
        
    
        moveXY(1, 1)
        loc.x = 1
        loc.y = 1
    
        while loc.z > SWAP_Z do
            safe.execute(move.down)
            loc.z = loc.z - 1
        end
    
        moveXY(0, 1)
        loc.x = 0
        loc.y = 1
    end

    while loc.z < OUTGOING_Z do
        safe.execute(move.up)
        loc.z = loc.z + 1
    end

    moveXY(targetX, targetY)
    loc.x = targetX
    loc.y = targetY
end

return highway