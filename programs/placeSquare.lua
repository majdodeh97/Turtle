local movement = require("/utils/movement")

local tArgs = { ... }
local startOffset = tonumber(tArgs[1])
local size = tonumber(tArgs[2])

if not startOffset or not size or size % 2 == 0 then
    print("Usage: PlaceRectangle <startOffset> <odd size>")
    return
end

-- Check and refuel if needed
local function ensureFuel()
    while turtle.getFuelLevel() == 0 do
        turtle.select(16)
        if not turtle.refuel(1) then
            print("Out of fuel in slot 16. Please add more.")
            sleep(2)
        end
    end
end

-- Try to move forward safely with fuel check
local function safeForward()
    ensureFuel()
    while not movement.forward() do
        turtle.dig()
        sleep(0.5)
    end
end

-- Turn around
local function turnAround()
    movement.turnLeft()
    movement.turnLeft()
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
    if not selectNextBlock() then
        print("Out of blocks to place.")
        sleep(2)
        return
    end
    turtle.placeDown()
end

-- Step 1: move forward to startOffset
print("Moving forward by", startOffset)
for i = 1, startOffset do
    safeForward()
end

-- Step 2: move to bottom-left corner of the square
local half = math.floor(size / 2)

turtle.turnLeft()
for i = 1, half do
    safeForward()
end

turtle.turnLeft()
for i = 1, half do
    safeForward()
end

turnAround()

-- Step 3: place the square line by line
local direction = true -- true = forward, false = backward

for row = 1, size do
    for col = 1, size do
        placeDown()
        if(col ~= size) then
            safeForward()
        end
    end


    if(row == size) then
        break
    end

    turnAround()

    for col = 1, size do
        if(col ~= size) then
            safeForward()
        end
    end

    movement.turnLeft()
    safeForward()
    movement.turnLeft()
end

print("Finished placing", size, "x", size, "square.")
