local inventory = require("/utils/inventory")
local log = require("/utils/log")

print("CobbleBot Online")
 
local totalMined = 0
local isFlashing = false
local flashCooldown = 0  
 
-- Check if cobblestone is in front
local function isCobblestoneInFront()
    local success, data = turtle.inspect()
    return success and data.name == "minecraft:cobblestone"
end
 
-- Dump inventory into chest behind the turtle
local function dumpInventory()
    local canDrop = false
    for i = 1, 16 do
        turtle.select(i)
        local beforeDrop = turtle.getItemCount(i)
        if beforeDrop > 0 then
            turtle.dropDown()
            local afterDrop = turtle.getItemCount(i)
            if afterDrop < beforeDrop then
                totalMined = totalMined + (beforeDrop - afterDrop)
                canDrop = true
            else
                -- Chest is full or blocked
                if not isFlashing then
                    isFlashing = true
                    term.clear()
                    term.setCursorPos(1, 1)
                    print("Error: Chest full! Cannot dump inventory!")
                    sleep(3)
                    term.clear()
                    term.setCursorPos(1, 1)
                end
                turtle.select(1)
                return false
            end
        end
    end
    turtle.select(1)
    if canDrop then
        print("Total cobble mined: " .. totalMined)
    end
    return true
end
 
-- Main mining loop
while true do
    if not inventory.isFull() and isCobblestoneInFront() then
        turtle.dig()
    end
    -- add the code in game that makes it turn around after each dig?
    if inventory.isFull() then
        print("Inventory full. Dumping...")
        local success = dumpInventory()
        if not success then
            print("Waiting for chest to be available...")
            sleep(3)
        end
    end
 
    if isFlashing then
        flashCooldown = flashCooldown + 1
        if flashCooldown >= 6 then -- 6 * 0.5s = 3 seconds
            isFlashing = false
            flashCooldown = 0
        end
    end
 
    sleep(0.5) -- Wait for cobble to regenerate
end