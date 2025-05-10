local navigation = require("/utils/navigation")
local move = require("/utils/move")
local place = require("/utils/place")
local safe = require("/utils/safe")
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
-- inventory.drop and dropAll with and without any params
-- navigation.getGpsLocation
-- roomMaker

-- todo: continue refactoring cobbleBot and others to use our utils
-- todo: work on tree.lua
-- todo: decide on how files are copied/updated. Old way via disk drive or new way with red net
--

print(textutils.serialise(navigation.getGpsLocation()))

os.pullEvent("key")

print(place.slotUp(1))

os.pullEvent("key")

print(inventory.dropAllUp(7,8))

os.pullEvent("key")

print(inventory.dropAll(10))

os.pullEvent("key")

turtle.select(2)
print(inventory.dropAll())

os.pullEvent("key")

turtle.select(3)
print(inventory.drop())

os.pullEvent("key")

turtle.select(4)
print(inventory.drop(1))

os.pullEvent("key")

turtle.select(5)
print(inventory.drop(1, 6))

os.pullEvent("key")
os.pullEvent("key")
os.pullEvent("key")
os.pullEvent("key")
os.pullEvent("key")

function isCobblestoneInFront()
    local success, data = turtle.inspect()
    return success and data.name == "minecraft:cobblestone"
end

local tArgs = { ... }
local test1 = tonumber(tArgs[1])

if(test1 == 0) then
    move.forward()
    move.forward()
    move.forward()
    move.forward()
    move.turnRight()
    move.forward()
    move.up()
    move.turnLeft()
    move.forward()
    move.forward()
    move.forward()
    move.faceDirection("left")
    move.back()
    move.back()
    move.back()
    move.back()
elseif(test1 == 1) then
    navigation.forward()
    navigation.forward()
    navigation.forward()
    navigation.forward()
    navigation.turnRight()
    navigation.forward()
    navigation.up()
    navigation.turnLeft()
    navigation.forward()
    navigation.forward()
    navigation.forward()
    navigation.faceDirection("left")
    navigation.back()
    navigation.back()
    navigation.back()
    navigation.back()
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
    local success = inventory.dropAll()

    print("success: " .. success)
elseif(test1 == 14) then
    local success = inventory.dropAll(5)

    print("success: " .. success)
elseif(test1 == 15) then
    local success = inventory.dropAll(5, 10)

    print("success: " .. success)
elseif(test1 == 16) then
    local isFull = inventory.isFull()

    print("isFull: " .. success)
elseif(test1 == 17) then
    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()
elseif(test1 == 18) then
    print(inventory.runOnSlot(function()
        
    end, 7))
elseif(test1 == 19) then
    print(inventory.runOnItem(function()
        return move.forward()
    end, "minecraft:cobblestone"))
elseif(test1 == 20) then
    settings.set("direction", "haha")
    settings.save()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()
end