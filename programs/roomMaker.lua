local height = 5
local size = 22
local withCeiling = true

local function buildWallLayer()
    for side = 1, 4 do
        for i = 1, size - 1 do
            turtle.placeDown()
            turtle.forward()
        end
        turtle.placeDown()
        turtle.turnRight()
    end
end

-- Build wall layer by layer, moving up after each ring
for level = 1, height do
    buildWallLayer()
    if level < height then
        turtle.up()
    end
end

-- Return to floor
for i = 1, height - 1 do
    turtle.down()
end