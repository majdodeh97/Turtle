local move = require("/utils/move")

local tArgs = { ... }
local zOffset = tonumber(tArgs[1])
local size = tonumber(tArgs[2])

if not zOffset or not size then
    print("Usage: PlaceRectangle2 <startOffset> <size>")
    return
end

-- Check and refuel if needed
local function ensureFuel()
    while turtle.getFuelLevel() == 0 do
        turtle.select(16)
        if not turtle.refuel(1) then
            print("Out of fuel in slot 16. Please add more.")
            sleep(5)
        end
    end
end

-- Try to move forward safely with fuel check
local function safeForward()
    ensureFuel()
    while not move.forward() do
        turtle.dig()
    end
end

-- Turn around
local function turnAround()
    move.turnLeft()
    move.turnLeft()
end

-- Get a block to place
local function selectNextBlock()
    for i = 1, 15 do
        if turtle.getItemCount(i) > 0 then
            turtle.select(i)
            return true
        end
    end
    return false
end

-- Place a block beneath
local function placeDown()
    while not selectNextBlock() do
        print("Out of blocks to place.")
        sleep(5)
    end
    turtle.digDown()
    turtle.placeDown()
end

-- Step 3: place the square line by line (zigzag)
local leftTurn = false

for i = 1, zOffset do
    move.up()
end

for row = 1, size do
    for col = 1, size do
        placeDown()
        if col < size then
            safeForward()
        end
    end

    if row < size then
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

print("Finished placing", size, "x", size, "square.")
