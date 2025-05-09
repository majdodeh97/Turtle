local move = require("/utils/move")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")

local size = tonumber(arg[1]) or 3
local height = tonumber(arg[2]) or 2
local withCeiling = arg[3] ~= "false"
local blockItemName = arg[4] or "minecraft:stone_bricks"
local slabItemName = arg[5] or "minecraft:stone_brick_slab"

local function buildWallLayer(item)
    for side = 1, 4 do
        for i = 1, size - 1 do
            print(safe.execute(function()
                return place.itemDown(item)
            end))
            print(safe.execute(move.forward))
        end
        safe.execute(move.turnRight)
    end
end

local function buildCeiling(item)
    local leftTurn = false

    for row = 1, size do
        for col = 1, size do
            safe.execute(function()
                return place.itemDown(item)
            end)
            if col < size then
                safe.execute(move.forward)
            end
        end

        if row < size then
            if leftTurn then
                safe.execute(move.turnLeft)
                safe.execute(move.forward)
                safe.execute(move.turnLeft)
            else
                safe.execute(move.turnRight)
                safe.execute(move.forward)
                safe.execute(move.turnRight)
            end
            leftTurn = not leftTurn
        end
    end
    
    -- return to original position

    if(not leftTurn) then
        safe.execute(move.turnRight)
        safe.execute(move.turnRight)

        for i = 1, size - 1 do
            safe.execute(move.forward)
        end
    end
    
    safe.execute(move.turnRight)

    for i = 1, size - 1 do
        safe.execute(move.forward)
    end

    safe.execute(move.turnRight)
end

for level = 1, height do
    buildWallLayer(blockItemName)
    safe.execute(move.up)
end

if(not withCeiling) then
    buildWallLayer(slabItemName)
else
    buildCeiling(blockItemName)
    safe.execute(move.up)
    buildCeiling(slabItemName)
end

