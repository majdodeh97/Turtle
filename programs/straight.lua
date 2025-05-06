local movement = require("/utils/movement")
local navigation = require("/utils/navigation")

local distance = 0
while(movement.forward()) do
    distance = distance + 1
end

print("Distance going" .. distance)

movement.turnRight()
movement.turnRight()

for i = 1, distance, 1 do
    movement.forward()
end