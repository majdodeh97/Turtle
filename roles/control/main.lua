local move = require("/utils/move")
local safe = require("/utils/safe")
local location = require("/utils/location")

print("Hi, I'm a control turtle!")

local function turnToOutputChest()
    local lat,long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "left" or "right"

    safe.execute(function() 
        return move.faceDirection(dir)
    end)
end

local function turnToInputChest()
    local lat,long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "right" or "left"

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

-- todo: Controls the output and input, requests stuff from hub, gives the worker turtle what it needs

-- waits for a turtle to appear above it
-- has access to an object that lists all the needed items for that room
-- for example, a tree farm would have this object:
-- {
--     "tools": [
--       {
--         "itemName": "Diamond pick"
--       }
--     ],
--     "items": [
--       {
--         "itemName": "Birtch sapling",
--         "itemMinCount": 16,
--         "itemMaxCount": 64
--       },
--       {
--         "itemName": "Charcoal",
--         "itemMinCount": 16,
--         "itemMaxCount": 64
--       }
--     ]
--   }
-- once it detects a turtle above it, it will turn to the output chest (turnToOutputChest) and start dumping anything that is not needed for that room (including excess items needed for the room)
-- this is because the worker turtle above it will be emptying its entire inventory into this control turtle's inventory
-- for this example, if its inventory has excess charcoal (meaning if it has more than the itemMaxCount), it will dump the excess in the output chest, keeping in its inventory the rest 
-- it will keep doing this until the turtle above is shutdown
-- once the turtle above is shutdown, that means the worker turtle's inventory has been emptied. the control turtle turns to the ROOM's input chest (turnToRoomInputChest) and pulls everything out from there. Turning to the output chest and throwing any excess in there just like before
-- make sure to keep doing this until the room's input chest is emptied
-- once the control turtle has cleared the room's input chest and its own inventory from uneeded items, it should be left with only items that the room requires (i.e. items in the list)
-- if these items are enough to start another worker turtle round, it will dump them back into the turtle above it and turn it on, initiating another round
-- if these items are not enough, the control turtle sends a request to the hub asking for any missing items
-- for each requested item, it should send the hub 2 numbers: how much it needs to fulfill the itemMinCount and how much it needs to fullfil the itemMaxCount
-- it then faces the input chest (turnToInputChest) and awaits then requested items
-- it keeps trying to pull every 5 seconds and once it has everything it needs, then a new worker round can be started
-- it will then dump everything into the worker turtle above it and turn it on, initiating a new round


local function cleanInventory(requiredItems)
    turnToOutputChest()

    local maxAllowed = {}
    for _, entry in ipairs(requiredItems) do
        maxAllowed[entry.itemName] = entry.itemMaxCount
    end

    local keptCounts = {}

    for slot = 1, 16 do
        turtle.select(slot)
        local detail = turtle.getItemDetail()
        if detail then
            local name = detail.name
            local matched = false
            for _, entry in ipairs(requiredItems) do
                if name:find(entry.itemName) then
                    local currentCount = keptCounts[entry.itemName] or 0
                    local allowedCount = maxAllowed[entry.itemName]
                    if currentCount < allowedCount then
                        local toKeep = math.min(allowedCount - currentCount, detail.count)
                        keptCounts[entry.itemName] = currentCount + toKeep
                        if toKeep < detail.count then
                            -- Drop the extra
                            local toDrop = detail.count - toKeep
                            turtle.transferTo(slot, toKeep)
                            while turtle.drop(toDrop) == false do
                                sleep(1)
                            end
                        end
                    else
                        -- Already have enough, dump the whole stack
                        while turtle.drop() == false do
                            sleep(1)
                        end
                    end
                    matched = true
                    break
                end
            end
            if not matched then
                while turtle.drop() == false do
                    sleep(1)
                end
            end
        end
    end
    turtle.select(1)
end


local function suckUntilFull()
    local pulledAnything = false

    while true do
        local spaceAvailable = false
        for i = 1, 16 do
            if turtle.getItemCount(i) == 0 then
                spaceAvailable = true
                break
            end
        end

        if not spaceAvailable then
            break
        end

        if turtle.suck() then
            pulledAnything = true
        else
            break
        end
    end

    return pulledAnything
end

local function isWorkerTurtlePresent()
    local success, data = turtle.inspectUp()
    return success and data.name:find("turtle")
end

local function waitForWorkerTurtle()
    print("Waiting for worker turtle...")
    while not isWorkerTurtlePresent() do sleep(5) end
    print("Worker turtle detected.")
end

local function dumpExcessAndUnneededItems(requiredItems)
    turnToOutputChest()
    cleanInventory(requiredItems)
end

local function collectRoomInput(requiredItems)
    while true do
        turnToRoomInputChest()
        local success = suckUntilFull()
        if not success then return end
        dumpExcessAndUnneededItems(requiredItems)
    end
end

local function countRequiredItems(requiredItems)
    local counts = {}
    for _, item in ipairs(requiredItems) do
        counts[item.itemName] = 0
    end
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            for _, required in ipairs(requiredItems) do
                if item.name:find(required.itemName) then
                    counts[required.itemName] = counts[required.itemName] + item.count
                end
            end
        end
    end
    return counts
end

local function getRequiredObjects()
    return {
        tools = {
            { itemName = "minecraft:diamond_pickaxe" }
        },
        items = {
            {
                itemName = "minecraft:birch_sapling",
                itemMinCount = 2,
                itemMaxCount = 64
            },
            {
                itemName = "minecraft:charcoal",
                itemMinCount = 2,
                itemMaxCount = 64
            }
        }
    }
end

local items = getRequiredObjects().items

local function requestFromHub(missingCounts)
    print("Requesting items from hub...")
    -- rednet.open("left")
    -- rednet.send("hub", { type = "requestItems", data = missingCounts }, "logistics")
end

local function pullFromInputChest()
    turnToInputChest()
    while true do
        local success = suckUntilFull()
        if success then return end
        sleep(5)
    end
end

local function hasEnoughToStart(counts, requiredItems)
    for _, item in ipairs(requiredItems) do
        if counts[item.itemName] < item.itemMinCount then
            return false
        end
    end
    return true
end

local function turnOnTurtle()
    local turtlePeripheral = peripheral.wrap("top")
    if turtlePeripheral and turtlePeripheral.turnOn then
        turtlePeripheral.turnOn()
    else
        error("No turtle detected above or turtle is not a valid peripheral.")
    end
end

local function isTurtleOff()
    local turtlePeripheral = peripheral.wrap("top")
    if turtlePeripheral and turtlePeripheral.isOn then
        return not turtlePeripheral.isOn()
    else
        error("No turtle detected above or turtle is not a valid peripheral.")
    end
end

local function prepareWorkerRound(requiredItems)
    -- Dump valid items to the worker turtle
    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item then
            for _, required in ipairs(requiredItems) do
                if item.name:find(required.itemName) then
                    turtle.select(slot)
                    turtle.dropUp()
                    break
                end
            end
        end
    end
    -- Power on worker turtle
    turnOnTurtle()
end

-- === Main Loop ===
while true do
    waitForWorkerTurtle()
    dumpExcessAndUnneededItems(items)
    print("Waiting for worker turtle to shut down...")
    while not isTurtleOff() do sleep(1) end
    print("Worker turtle finished round.")

    collectRoomInput(items)
    dumpExcessAndUnneededItems(items)

    local counts = countRequiredItems(items)
    if hasEnoughToStart(counts, items) then
        prepareWorkerRound(items)
    else
        local missing = {}
        for _, item in ipairs(items) do
            local current = counts[item.itemName]
            table.insert(missing, {
                itemName = item.itemName,
                neededMin = math.max(item.itemMinCount - current, 0),
                neededMax = math.max(item.itemMaxCount - current, 0)
            })
        end
        requestFromHub(missing)

        while(true) do
            pullFromInputChest()
            dumpExcessAndUnneededItems(items)
            counts = countRequiredItems(items)
            if hasEnoughToStart(counts, items) then
                prepareWorkerRound(items)
            else
                print("Still missing items. Retrying in 10 seconds")
                sleep(10)
            end
        end
    end
end
