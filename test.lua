local movement = require("/utils/movement")
local navigation = require("/utils/navigation")
local inventory = require("/utils/inventory")

-- To test:
-- navigation: backtrackUntil
-- navigation: backtrack
-- inventory: foreach
-- inventory: first
-- inventory: all
-- inventory: dropAll
-- inventory: isFull
-- fuel: ensure
-- log: logging an error, terminating, and clearing the setting on startup
-- log: Invalid direction in settings (to test, do turn -> move -> turn -> move etc for all 4 directions)
-- todo: continue refactoring cobbleBot and others

function isCobblestoneInFront()
    local success, data = turtle.inspect()
    return success and data.name == "minecraft:cobblestone"
end

local tArgs = { ... }
local test1 = tonumber(tArgs[1])

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
elseif(test1 == 3) then -- bug detected
    navigation.backtrackUntil(function()
        return isCobblestoneInFront()
    end)
elseif(test1 == 4) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end)
elseif(test1 == 5) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end, 5)
elseif(test1 == 6) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end, 5, 10)
elseif(test1 == 7) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end)

    print(ti)
    print(td)
elseif(test1 == 8) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end, 5)

    print(ti)
    print(td)
elseif(test1 == 9) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end, 5, 10)

    print(ti)
    print(td)
elseif(test1 == 10) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end)

    print("success: " .. success)
elseif(test1 == 11) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end, 5)

    print("success: " .. success)
elseif(test1 == 12) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end, 5, 10)

    print("success: " .. success)
elseif(test1 == 13) then
    local success = inventory.dropAll(turtle.drop)

    print("success: " .. success)
elseif(test1 == 14) then
    local success = inventory.dropAll(turtle.drop, 5)

    print("success: " .. success)
elseif(test1 == 15) then
    local success = inventory.dropAll(turtle.drop, 5, 10)

    print("success: " .. success)
elseif(test1 == 16) then
    local isFull = inventory.isFull()

    print("isFull: " .. success)
elseif(test1 == 17) then
    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()
elseif(test1 == 18) then
    print(inventory.runOnSlot(function()
        
    end, 7))
elseif(test1 == 19) then
    print(inventory.runOnItem(function()
        movement.forward()
    end, "minecraft:cobblestone"))
elseif(test1 == 20) then
    settings.set("direction", "haha")
    settings.save()

    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()

    movement.turnRight()
    movement.forward()
end