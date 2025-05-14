local moveTracker = require("/utils/moveTracker")
local move = require("/utils/move")
local location = require("/utils/location")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")
local navigation = require("/utils/navigation")
local roomNav = require("/utils/roomNav")
local roomInfo = require("/utils/roomInfo")

-- To test:
-- moveTracker: backtrackUntil
-- moveTracker: backtrack
-- inventory: foreach
-- inventory: first
-- inventory: all
-- inventory: dropAll
-- inventory: isFull
-- fuel: ensure
-- log: logging an error, terminating, and clearing the setting on startup
-- log: Invalid direction in settings (to test, do turn -> move -> turn -> move etc for all 4 directions)
-- inventory.drop and dropAll with and without any params
-- location.getGpsLocation
-- roomMaker

-- todo: continue refactoring cobbleBot and others to use our utils
-- todo: work on tree.lua
-- todo: decide on how files are copied/updated. Old way via disk drive or new way with red net
-- todo: add unit tests for utils


local function isCobblestoneInFront()
    local success, data = turtle.inspect()
    return success and data.name == "minecraft:cobblestone"
end

local tArgs = { ... }
local test1 = tonumber(tArgs[1])

if(test1 == 0) then
    
elseif(test1 == 1) then
    local roomInfos = roomInfo.getRoomInfoByLocation("north", "east", 0)
    print(textutils.serialize(roomInfos))
elseif(test1 == 100) then
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
elseif(test1 == 101) then
    moveTracker.forward()
    moveTracker.forward()
    moveTracker.forward()
    moveTracker.forward()
    moveTracker.turnRight()
    moveTracker.forward()
    moveTracker.up()
    moveTracker.turnLeft()
    moveTracker.forward()
    moveTracker.forward()
    moveTracker.forward()
    move.faceDirection("left")
    moveTracker.back()
    moveTracker.back()
    moveTracker.back()
    moveTracker.back()
elseif(test1 == 102) then
    moveTracker.backtrack()
elseif(test1 == 103) then -- bug detected
    moveTracker.backtrackUntil(function()
        return isCobblestoneInFront()
    end)
elseif(test1 == 104) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end)
elseif(test1 == 105) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end, 5)
elseif(test1 == 106) then
    inventory.foreach(function(i, data)
        print("i: " .. i)
        print(data)
    end, 5, 10)
elseif(test1 == 107) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end)

    print(ti)
    print(td)
elseif(test1 == 108) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end, 5)

    print(ti)
    print(td)
elseif(test1 == 109) then
    local ti, td = inventory.first(function(i, data)
        return data and data.count == 5
    end, 5, 10)

    print(ti)
    print(td)
elseif(test1 == 110) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end)

    print("success: " .. success)
elseif(test1 == 111) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end, 5)

    print("success: " .. success)
elseif(test1 == 112) then
    local success = inventory.all(function(i, data)
        return data and data.count == 1
    end, 5, 10)

    print("success: " .. success)
elseif(test1 == 113) then
    local success = inventory.dropAll()

    print("success: " .. success)
elseif(test1 == 114) then
    local success = inventory.dropAll(5)

    print("success: " .. success)
elseif(test1 == 115) then
    local success = inventory.dropAll(5, 10)

    print("success: " .. success)
elseif(test1 == 116) then
    local isFull = inventory.isFull()

    print("isFull: " .. isFull)
elseif(test1 == 117) then
    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()

    move.turnRight()
    move.forward()
elseif(test1 == 118) then
    print(inventory.runOnSlot(function()
        
    end, 7))
elseif(test1 == 119) then
    print(inventory.runOnItem(function()
        return move.forward()
    end, "minecraft:cobblestone"))
elseif(test1 == 120) then
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