local navigation = require("/utils/navigation")
local move = require("/utils/move")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")

local highway = {}

function isOnRoad(x, y, roadSize)
    local half = roadSize // 2
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

function moveTo(targetX, targetY)
    local targetKey = targetX .. "," .. targetY
    if RESERVED_COLUMNS[targetKey] then
        error("Cannot use moveTo on a reserved column: " .. targetKey)
    end

    local loc = move.getLocation()

    local locationKey = loc.x .. "," .. loc.y
    if ILLEGAL_STARTING_COLUMNS[locationKey] then
        error("Cannot use moveTo from an illegal column: " .. locationKey)
    end

    if(loc.x ~= 0 and loc.y ~= 1 and loc.z ~= 1) then
        while loc.z < INCOMING_Z do
            safe.execute(move.up)
        end
    
        moveXY(1, 1)
    
        while loc.z > SWAP_Z do
            safe.execute(move.down)
        end
    
        moveXY(0, 1)
    end

    while loc.z < OUTGOING_Z do
        safe.execute(move.up)
    end

    moveXY(targetX, targetY)
end

return highway