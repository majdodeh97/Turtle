local log = {}

function log.error(errorMessage)
    local file = fs.open("/errorLog.txt", "w")
    file.write(errorMessage)
    file.close()

    settings.set("error", true)
    settings.save()

    error(errorMessage)
end

return log