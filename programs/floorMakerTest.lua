-- floorBuilder.lua
local highwayNav = require("/utils/highwayNav")
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
    local baseZ = highwayNav.getFloorBaseZ(floor)
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
    highwayNav.goHome(true)
    os.pullEvent("key")
    highwayNav.moveTo(resumeX, resumeY, floor, true)
    moveToCorrectZ()

    safe.execute(function() return move.faceDirection(resumeDir) end)
end

local function safeForward()
    if not hasEnoughFuel() then
        goToBaseAndComeBack()
        safeForward()
        return
    end

    safe.execute(move.forward)
end

local RESERVED_COLUMNS = {
    ["0,0"] = true,
    ["0,1"] = true,
    ["1,0"] = true,
    ["1,1"] = true,
    ["0,-1"] = true,
}

local placed = 0

local function safePlace()
    local slot = getBlockSlot()
    
    if not slot then
        goToBaseAndComeBack()
        safePlace()
        return
    end

    local location = move.getLocation()
    local targetKey = location.x .. "," .. location.y
    if RESERVED_COLUMNS[targetKey] then
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
    highwayNav.moveTo(startX, startY, floor, true)

    moveToCorrectZ()

    safe.execute(function() return move.faceDirection("forward") end)

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

    print("Floor completed!")
    highwayNav.goHome(true)
end


buildFloor(floor, START_X, START_Y)
