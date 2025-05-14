local log = require("/utils/log")

---@class suck
local suck = {}

function suck.all(fn)
    -- keeps sucking until suck returns false or inventory is full
    -- returns true if the suck returns false
    -- return false if inv is full (so that safe can keep trying)
    -- must check if inventory is full before sucking
end

return suck