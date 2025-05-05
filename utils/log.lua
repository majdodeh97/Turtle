local log = {}

function log.error(error)
    local file = fs.open("/errorLog.txt", "w")
    file.write(error)
    file.close()

    settings.set("error", true)
    settings.save()

    os.shutdown()
end

return log