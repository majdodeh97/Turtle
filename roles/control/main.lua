local move = require("/utils/move")
local safe = require("/utils/safe")
local location = require("/utils/location")
local log = require("/utils/log")
local suck = require("/utils/suck")
local inventory = require("/utils/inventory")
local roomInfo = require("/utils/roomInfo")

print("Hi, I'm a control turtle!")

local function turnToOutputChest()
    local lat,long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "right" or "left"

    safe.execute(function() 
        return move.faceDirection(dir)
    end)
end

local function turnToInputChest()
    local lat,long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "left" or "right"

    safe.execute(function() 
        return move.faceDirection(dir)
    end)
end

local function turnToRoomInputChest()
    local lat = location.roomCoordsToGeoLocation()

    local dir = lat == "north" and "forward" or "back"

    safe.execute(function() 
        return move.faceDirection(dir)
    end)
end

local function isWorkerTurtlePresent()
    local success, data = turtle.inspectUp()
    return success and data.name:find("turtle")
end

local function turnOnTurtle()
    local turtlePeripheral = peripheral.wrap("top")
    if turtlePeripheral and turtlePeripheral.turnOn then
        turtlePeripheral.turnOn()
    else
        error("No turtle detected above or turtle is not a valid peripheral.")
    end
end

local function isTurtleOn()
    local turtlePeripheral = peripheral.wrap("top")
    if turtlePeripheral and turtlePeripheral.isOn then
        return turtlePeripheral.isOn()
    else
        log.error("No turtle detected above or turtle is not a valid peripheral.")
    end
end

local function waitForWorkerTurtle()
    print("Waiting for worker turtle...")
    while not isWorkerTurtlePresent() do sleep(5) end
    print("Worker turtle detected.")
end

local function requestFromHub(missingCounts)
    print("Requesting items from hub...")
    print(textutils.serialize(missingCounts))
    -- rednet.open("left")
    -- rednet.send("hub", { type = "requestItems", data = missingCounts }, "logistics")
end

-- === Main Loop ===
while true do

    print("Retrieving inputs")
    os.pullEvent("key")

    -- Take all items from input chest
    turnToInputChest()
    if(not suck.all()) then log.error("Couldn't empty input chest") end

    -- Wait or a worker turtle
    waitForWorkerTurtle()
    print("Waiting for worker turtle to shut down. Emptying outputs")
    os.pullEvent("key")

    -- Dump unnecessary items gievn from worker turtle
    turnToOutputChest()
    while isTurtleOn() do
        roomInfo.dropNonRequiredItems()
    end
    roomInfo.dropNonRequiredItems()

    print("Worker turtle shutdown. Preparing round")
    print("Caching required items")
    os.pullEvent("key")

    -- Count input items and cache them in input chest
    local currentRequiredItems = roomInfo.countCurrentRequiredItems()
    turnToInputChest()
    roomInfo.dropRequiredItems()

    print("Checking if inventory is empty")
    os.pullEvent("key")

    if(not inventory.isEmpty()) then log.error("Extra items found in inventory") end

    print("Emptying room inputs")
    os.pullEvent("key")

    turnToRoomInputChest()
    if(not suck.all()) then log.error("Couldn't empty room input chest") end

    print("Throwing unneeded items")
    os.pullEvent("key")

    turnToOutputChest()
    roomInfo.dropNonRequiredItems(inventory.safeDrop, currentRequiredItems)
    
    print("cacheing new required items")
    os.pullEvent("key")

    turnToInputChest()
    roomInfo.dropRequiredItems(inventory.safeDrop, currentRequiredItems)

    print("Checking if inventory is empty")
    os.pullEvent("key")

    if(not inventory.isEmpty()) then log.error("Extra items found in inventory") end

    print("Retrieving inputs")
    os.pullEvent("key")

    if(not suck.all()) then log.error("Couldn't empty input chest") end

    print("Can I start?")
    os.pullEvent("key")

    if(roomInfo.hasEnoughToStart()) then
        print("Starting...")
        os.pullEvent("key")
        roomInfo.dropRequiredItems(inventory.dropUp)
        turnOnTurtle()
    else
        print("requesting from hub...")
        os.pullEvent("key")
        local missing = roomInfo.countMissingItems()
        requestFromHub(missing)

        print("waiting 10 seconds")

        sleep(10)
        -- while(true) do
        --     turnToInputChest()
        --     suck.all()

        --     dumpExcessAndUnneededItems(items)
        --     counts = countRequiredItems(items)
        --     if hasEnoughToStart(counts, items) then
        --         prepareWorkerRound(items)
        --     else
        --         print("Still missing items. Retrying in 10 seconds")
        --         sleep(10)
        --     end
        -- end
    end
end