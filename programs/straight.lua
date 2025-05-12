local move = require("/utils/move")

local distance = 0
while(move.forward()) do
    distance = distance + 1
end

print("Distance: " .. distance)

move.turnRight()
move.turnRight()

for i = 1, distance, 1 do
    move.forward()
end

move.faceDirection("forward")