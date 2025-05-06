local movement = require("/utils/movement")
local navigation = require("/utils/navigation")

test1 = true

if(test1) then
    movement.forward()
    movement.forward()
    movement.forward()
    movement.forward()
    movement.turnRight()
    movement.forward()
    movement.up()
    movement.turnLeft()
    movement.forward()
    movement.forward()
    movement.forward()
    movement.faceDirection("left")
    movement.back()
    movement.back()
    movement.back()
    movement.back()
else
    navigation.backtrack()
end
