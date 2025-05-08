local inventory = require("/utils/inventory")
local log = require("/utils/log")

local fuel = {}

function ensure()
    while turtle.getFuelLevel() == 0 do
        local fuelSlot = settings.get("fuelSlot")

        if(not fuelSlot) then log.error("No 'fuelSlot' defined in settings.") end

        inventory.runOnSlot(fuelSlot, function()
            turtle.select(fuelSlot)
            if not turtle.refuel(1) then
                print("Out of fuel in slot " .. fuelSlot .. ". Please add more.")
                sleep(5)
            end
        end)
    end
end

return fuel