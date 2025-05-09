local log = require("/utils/log")

local safe = {}

function safe.execute(fn, errorMessage)
    local sleepInterval = settings.get("safeSleepInterval")

    if(not sleepInterval) then log.error("No 'sleepInterval' defined in settings.") end

    while not fn() do
        sleep(sleepInterval)
        if(errorMessage) then
            print(errorMessage)
        end
    end
end

return safe