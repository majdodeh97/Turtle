local log = require("/utils/log")

---@class safe
local safe = {}

-- Cannot be used with "drop" behavior. Use inventory.safeDrop instead
function safe.execute(fn, errorMessage)
    local sleepInterval = settings.get("safeSleepInterval")

    if(not sleepInterval) then log.error("No 'safeSleepInterval' defined in settings.") end

    while true do
        local success, reason = fn()
        if success then return success, reason end

        if errorMessage then
            print(errorMessage)
        elseif reason then
            print(reason)
        end

        sleep(sleepInterval)
    end
end

return safe