local tArgs = { ... }

local length = tonumber(tArgs[1])
local mode = tArgs[2]

local version = 1

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

local function loadFromChest()
    local ct = math.min(15, length)
    for slot = 1, ct do
        turtle.select(slot)
        turtle.suck()
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

local function emptyFurnace()
    for slot = 1, 15 do
        turtle.select(slot)
        turtle.suckUp()
    end
end

local function countTotalItems()
    local total = 0
    for i = 1, 15 do
        local item = turtle.getItemDetail(i)
        if item then
            total = total + item.count
        end
    end
    return total
end

local function distributeEvenly(furnaceCount, itemsPerFurnace, dropFn)
    for i = 1, furnaceCount do
        local remaining = itemsPerFurnace
        for slot = 1, 15 do
            local count = turtle.getItemCount(slot)
            if count > 0 then
                turtle.select(slot)
                local toDrop = math.min(count, remaining)
                dropFn(toDrop)
                remaining = remaining - toDrop
            end
            if remaining <= 0 then break end
        end
        if i < furnaceCount then safeForward() end
    end
end

local function dropAmount(amount, startSlot, endSlot, dropFn)
    local remaining = amount

    for slot = startSlot, endSlot do
        local count = turtle.getItemCount(slot)
        if count > 0 then
            turtle.select(slot)
            local toDrop = math.min(count, remaining)
            dropFn(toDrop)
            remaining = remaining - toDrop
        end

        if remaining <= 0 then
            break
        end
    end

    return amount - remaining
end

-- === Main Loop ===

print("Starting furnace " .. mode .. " on " .. length .. " furnaces...")

while true do
    if mode == "loader" then
        loadFromChest()
        local totalItems = countTotalItems()
        local itemsPerFurnace = math.floor(totalItems / length)

        turtle.turnLeft()
        turtle.turnLeft()

        for i = 1, length do
            dropAmount(itemsPerFurnace, 1, 15, turtle.dropDown)

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
        local totalFuel = countTotalItems()
        local fuelPerFurnace = math.floor(totalFuel / length)

        turtle.turnLeft()
        turtle.turnLeft()

        for i = 1, length do
            local toDrop = math.min(fuelPerFurnace, 10)

            turtle.turnLeft()
            dropAmount(toDrop, 1, 15, turtle.drop)
            turtle.turnRight()

            if i < length then safeForward() end
        end

        moveBackToStart()

        depositToChest()
    end

    sleep(60)
end