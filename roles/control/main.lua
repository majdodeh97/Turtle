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


local function dropRequiredItems(dropFn, cachedRequiredItems)
    cachedRequiredItems = cachedRequiredItems or {}
    local missingitems = roomInfo.countMissingItems(cachedRequiredItems)

    dropFn = dropFn or inventory.safeDrop

    local maxAllowedList = {}

    if missingitems then
        for itemName, entry in pairs(missingitems) do
            maxAllowedList[itemName] = entry.itemMaxMissing
        end
    end

    for itemName, maxAllowed in pairs(maxAllowedList) do
        local dropped = 0

        while dropped < maxAllowed do
            local success = inventory.runOnItem(function()
                local itemDetail = turtle.getItemDetail()
                local toDrop = math.min(itemDetail.count, maxAllowed - dropped)
                dropFn(toDrop)

                dropped = dropped + toDrop
                return true
            end, itemName)

            if not success then
                break -- no match, move on to next itemName
            end
        end

        print("Dropped " .. dropped .. " out of " .. maxAllowed .. " of " .. itemName)
    end
end

local function dropNonRequiredItems(dropFn, cachedRequiredItems)
    cachedRequiredItems = cachedRequiredItems or {}
    local missingitems = roomInfo.countMissingItems(cachedRequiredItems)

    dropFn = dropFn or inventory.safeDrop

    local maxAllowedLeft = {}

    if missingitems then
        for itemName, entry in pairs(missingitems) do
            maxAllowedLeft[itemName] = entry.itemMaxMissing
        end
    end

    inventory.foreach(function(slot, itemDetail)
        if itemDetail then
            local name = itemDetail.name
            local count = itemDetail.count
            local allowedLeft = maxAllowedLeft[name]

            inventory.runOnSlot(function()
                if not allowedLeft then
                    dropFn(count) -- Not a required item
                elseif allowedLeft <= 0 then
                    dropFn(count) -- Already have enough
                elseif count <= allowedLeft then
                    maxAllowedLeft[name] = allowedLeft - count
                else
                    dropFn(count - allowedLeft)
                    maxAllowedLeft[name] = 0
                end
            end, slot)
        end
    end)
end

-- === Main Loop ===
while true do

    print("Retrieving inputs")

    -- Take all items from input chest
    turnToInputChest()
    if(not suck.all()) then log.error("Couldn't empty input chest") end

    -- Wait or a worker turtle
    waitForWorkerTurtle()
    print("Waiting for worker turtle to shut down. Emptying outputs")

    -- Dump unnecessary items gievn from worker turtle
    turnToOutputChest()
    while isTurtleOn() do
        dropNonRequiredItems()
    end
    dropNonRequiredItems()

    print("Worker turtle shutdown. Preparing round")
    print("Caching required items")

    -- Count input items and cache them in input chest
    local currentRequiredItems = roomInfo.countCurrentRequiredItems()
    turnToInputChest()
    dropRequiredItems()

    print("Checking if inventory is empty")

    if(not inventory.isEmpty()) then log.error("Extra items found in inventory") end

    print("Emptying room inputs")

    turnToRoomInputChest()
    if(not suck.all()) then log.error("Couldn't empty room input chest") end

    print("Throwing unneeded items")

    turnToOutputChest()
    dropNonRequiredItems(inventory.safeDrop, currentRequiredItems)
    
    print("cacheing new required items")

    turnToInputChest()
    dropRequiredItems(inventory.safeDrop, currentRequiredItems)

    print("Checking if inventory is empty")

    if(not inventory.isEmpty()) then log.error("Extra items found in inventory") end

    print("Retrieving inputs")

    if(not suck.all()) then log.error("Couldn't empty input chest") end

    print("Can I start?")

    if(roomInfo.hasEnoughToStart()) then
        print("Starting...")
        dropRequiredItems(inventory.dropUp)
        turnOnTurtle()
    else
        print("requesting from hub...")
        local missing = roomInfo.countMissingItems()
        requestFromHub(missing)

        
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

    print("waiting 10 seconds")

    sleep(10)
end