local movement = require("/utils/movement")
local navigation = require("/utils/navigation")
local inventory = require("/utils/inventory")

-- To test:
-- navigation: backtrackUntil
-- navigation: backtrack
-- inventory: foreach, foreachInSlots
-- inventory: first, firstInSlots
-- inventory: all, allInSlots
-- inventory: isFull
-- fuel: ensure

test1 = 0

if(test1 == 1) then
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
elseif(test1 == 2)
    navigation.backtrack()
end
