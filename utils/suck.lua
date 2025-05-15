local log = require("/utils/log")

---@class suck
local suck = {}

function suck.all(suckFn)
    suckFn = suckFn or turtle.suck

    while true do
        local spaceAvailable = false
        for i = 1, 16 do
            if turtle.getItemCount(i) == 0 then
                spaceAvailable = true
                break
            end
        end

        if not spaceAvailable then
            return false
        end

        if not suckFn() then
            return true
        end
    end
end

return suck