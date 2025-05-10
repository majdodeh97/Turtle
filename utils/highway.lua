local navigation = require("/utils/navigation")
local move = require("/utils/move")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")

local highway = {}

local function isOnRoad(x, y, roadSize)
    local half = roadSize / 2
    local min = -half + 1
    local max = half

    return (x >= min and x <= max) or
           (y >= min and y <= max)
end

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

local function getFloorZ()
    return 0
end

local function getFloor()
    return 1
end

local function getIncomingZ()

end

local function getOutgoingZ()

end

local function getSwapZ()

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
        while loc.z < INCOMING_Z do
            safe.execute(move.up)
            loc.z = loc.z + 1
        end
    
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