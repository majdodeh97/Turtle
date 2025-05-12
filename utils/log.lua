---@class log
local log = {}

function log.error(errorMessage)
    local file = fs.open("/errorLog.txt", "w")
    file.write(errorMessage)
    file.close()

    settings.set("error", true)
    settings.save()

    error(errorMessage)
end

function log.warning(warningMessage)
    local file = fs.open("/warningLog.txt", "w")
    file.write(warningMessage)
    file.close()

    settings.set("warning", true)
    settings.save()

    print("Warning: " .. warningMessage)
end

return log