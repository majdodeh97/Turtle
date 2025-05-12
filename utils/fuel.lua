local inventory = require("/utils/inventory")
local log = require("/utils/log")

---@class fuel
local fuel = {}

function fuel.ensure()
    while turtle.getFuelLevel() == 0 do
        local fuelSlot = settings.get("fuelSlot")

        if(not fuelSlot) then log.error("No 'fuelSlot' defined in settings.") end

        inventory.runOnSlot(function()
            if not turtle.refuel(1) then
                print("Out of fuel in slot " .. fuelSlot .. ". Please add more.")
                sleep(5)
            end
        end, fuelSlot)
    end
end

return fuel