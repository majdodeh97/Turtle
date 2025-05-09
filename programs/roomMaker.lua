local move = require("/utils/move")
local place = require("/utils/place")

local height = 5
local size = 22
local withCeiling = true
local itemName = "minecraft:cobblestone"

local function buildWallLayer()
    for side = 1, 4 do
        for i = 1, size - 1 do
            place.itemDown(itemName)
            move.forward()
        end
        place.itemDown(itemName)
        move.turnRight()
    end
end

-- Build wall layer by layer, moving up after each ring
for level = 1, height do
    buildWallLayer()
    turtle.up()
end

local leftTurn = false

for row = 1, size do
    for col = 1, size do
        placeDown()
        if col < size then
            safeForward()
        end
    end

    if row < size then
        if leftTurn then
            move.turnLeft()
            safeForward()
            move.turnLeft()
        else
            move.turnRight()
            safeForward()
            move.turnRight()
        end
        leftTurn = not leftTurn
    end
end

-- Return to floor
for i = 1, height - 1 do
    turtle.down()
end