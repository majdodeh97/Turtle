local move = require("/utils/move")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")

local size = tonumber(arg[1]) or 3
local height = tonumber(arg[2]) or 2
local withCeiling = arg[3] ~= "false"
local itemName = arg[4] or "minecraft:stone_bricks"

local function buildWallLayer()
    for side = 1, 4 do
        for i = 1, size - 1 do
            print(safe.execute(function()
                return place.itemDown(itemName)
            end))
            print(safe.execute(move.forward))
        end
        safe.execute(move.turnRight)
    end
end

for level = 1, height do
    buildWallLayer()
    safe.execute(move.up)
end

if(not withCeiling) then return end

local leftTurn = false

for row = 1, size do
    for col = 1, size do
        safe.execute(function()
            return place.itemDown(itemName)
        end)
        if col < size then
            safe.execute(move.forward)
        end
    end

    if row < size then
        if leftTurn then
            move.turnLeft()
            safe.execute(move.forward)
            move.turnLeft()
        else
            move.turnRight()
            safe.execute(move.forward)
            move.turnRight()
        end
        leftTurn = not leftTurn
    end
end