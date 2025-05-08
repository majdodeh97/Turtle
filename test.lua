local movement = require("/utils/movement")
local navigation = require("/utils/navigation")
local inventory = require("/utils/inventory")

-- To test:
-- navigation: backtrackUntil
-- navigation: backtrack
-- inventory: foreach
-- inventory: first
-- inventory: all
-- inventory: isFull
-- inventory: dropAll
-- fuel: ensure
-- log: logging an error, terminating, and clearing the setting on startup
-- log: Invalid direction in settings (to test, do turn -> move -> turn -> move etc for all 4 directions)
-- todo: continue refactoring cobbleBot and others

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
elseif(test1 == 2) then
    navigation.backtrack()
end
