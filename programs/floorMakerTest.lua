-- floorBuilder.lua
local highway = require("/utils/highway")
local move = require("/utils/move")
local safe = require("/utils/safe")
local log = require("/utils/log")

-- Constants
local BLOCK_SLOTS = 15
local FUEL_SLOT = 16
local LOW_FUEL_THRESHOLD = 10
local FLOOR_SIZE = 48
local START_X = -23
local START_Y = -23

-- Entrypoint
local args = {...}
if not args[1] then
    log.error("Usage: floorBuilder <floor_number>")
end

local floor = tonumber(args[1])

-- Block and fuel check
local function getBlockSlot()
    for i = 1, BLOCK_SLOTS do
        if turtle.getItemCount(i) > 0 then return i end
    end
    return nil
end

local function hasEnoughFuel()
    return turtle.getItemCount(FUEL_SLOT) > LOW_FUEL_THRESHOLD
end

local function moveToCorrectZ()
    local baseZ = highway.getFloorBaseZ(floor)
    local targetZ = baseZ + 1

     -- Adjust to correct Z level
     while move.getLocation().z > targetZ do
        safe.execute(move.down)
    end
end

local function goToBaseAndComeBack()
    local location = move.getLocation()

    print("Returning to hub.")
    local resumeX, resumeY = location.x, location.y
    local resumeDir = move.getDirection()
    highway.goHome()
    os.pullEvent("key")
    highway.moveTo(resumeX, resumeY, floor)
    moveToCorrectZ()

    safe.execute(function() return move.faceDirection(resumeDir) end)
end

local function safeForward()
    local slot = getBlockSlot()
    
    if not hasEnoughFuel() or not slot then
        goToBaseAndComeBack()
        safeForward()
        return
    end

    safe.execute(move.forward)
end

local placed = 0

local function safePlace()
    local slot = getBlockSlot()
    
    if not hasEnoughFuel() or not slot then
        goToBaseAndComeBack()
        safePlace()
        return
    end

    turtle.select(slot)
    turtle.placeDown()

    placed = placed + 1
    print("Placed: " .. placed)
end

-- Main build logic
local function buildFloor(floor, startX, startY)
    -- Move to start location
    highway.moveTo(startX, startY, floor, true)

    moveToCorrectZ()

    local direction = move.getDirection()

    local leftTurn = false

    for row = 1, FLOOR_SIZE do
        for col = 1, FLOOR_SIZE do
            safePlace()
            if col < FLOOR_SIZE then
                safeForward()
            end
        end
    
        if row < FLOOR_SIZE then
            if leftTurn then
                move.turnLeft()
                safeForward()
                move.turnLeft()
            else
                move.turnRight()
                safeForward()
                move.turnRight()
            end
            leftTurn = not leftTurn
        end
    end

    log.info("Floor completed!")
end


buildFloor(floor, START_X, START_Y)
