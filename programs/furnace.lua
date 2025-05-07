local movement = require("/utils/movement") -- optional
local tArgs = { ... }

local length = tonumber(tArgs[1])
local mode = tArgs[2]

if not length or not ({ loader = true, emptier = true, fueler = true })[mode] then
    print("Usage: FurnaceLine <length> <loader|emptier|fueler>")
    return
end

-- === Utility ===

local function ensureFuel()
    while turtle.getFuelLevel() == 0 do
        turtle.select(16)
        if not turtle.refuel(1) then
            print("Out of fuel in slot 16. Please add more.")
            sleep(2)
        end
    end
end

local function safeForward()
    ensureFuel()
    while not turtle.forward() do
        print("Movement obstructed! Please make way.")
        sleep(2)
    end
end

local function moveBackToStart()
    turtle.turnLeft()
    turtle.turnLeft()
    for _ = 1, length - 1 do
        safeForward()
    end
end

local function fillFurnace()
    for slot = 1, 15 do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.dropDown()
        end
    end
end

local function emptyFurnace()
    for slot = 1, 15 do
        turtle.select(slot)
        turtle.suckUp()
    end
end

local function depositToChest()
    for slot = 1, 15 do
        if turtle.getItemCount(slot) > 0 then
            turtle.select(slot)
            turtle.drop()
        end
    end
end

local function loadFromChest()
    for slot = 1, 15 do
        turtle.select(slot)
        turtle.suck()
    end
end

local function countFuelSlots()
    local totalFuel = 0
    for i = 1, 15 do
        local item = turtle.getItemDetail(i)
        if item then
            totalFuel = totalFuel + item.count
        end
    end
    return totalFuel
end

local function distributeFuelEvenly(furnaceCount, fuelPerFurnace)
    for i = 1, furnaceCount do
        local remaining = fuelPerFurnace
        for slot = 1, 15 do
            local count = turtle.getItemCount(slot)
            if count > 0 then
                turtle.select(slot)
                local toDrop = math.min(count, remaining)
                turtle.turnLeft()
                turtle.drop(toDrop)
                turtle.turnRight()
                remaining = remaining - toDrop
            end
            if remaining <= 0 then break end
        end
        if i < furnaceCount then
            safeForward()
        end
    end
end

-- === Main Loop ===

print("Starting furnace " .. mode .. " on " .. length .. " furnaces...")

while true do
    if mode == "loader" then
        loadFromChest()
        turtle.turnLeft()
        turtle.turnLeft()
        for i = 1, length do
            fillFurnace()
            if i < length then safeForward() end
        end
        moveBackToStart()

    elseif mode == "emptier" then
        turtle.turnLeft()
        turtle.turnLeft()
        for i = 1, length do
            emptyFurnace()
            if i < length then safeForward() end
        end
        moveBackToStart()
        depositToChest()

    elseif mode == "fueler" then
        loadFromChest()

        turtle.turnLeft()
        turtle.turnLeft()

        local totalFuel = countFuelSlots()
        local fuelPerFurnace = math.floor(totalFuel / length)

        print("Total fuel:", totalFuel)
        print("Fuel per furnace:", fuelPerFurnace)

        distributeFuelEvenly(length, fuelPerFurnace)
        moveBackToStart()
    end

    sleep(60)
end