local move = require("/utils/move")

fs.delete(".settings")

local fileName = ".settings"
local fileURL = "https://raw.githubusercontent.com/majdodeh97/Turtle/main/" .. fileName
local fileResponse = http.get(fileURL)

local hasError = false

if fileResponse then
    local content = fileResponse.readAll()
    fileResponse.close()

    local file = fs.open(fileName, "w")
    file.write(content)
    file.close()
    print("Downloaded: ", fileName)

    settings.load()

    local gpsLocation = move.getGpsLocation()
    if gpsLocation then
        settings.set("location", gpsLocation)
        settings.save()
    else
        hasError = true
        print("Failed to get GPS location")
    end
else
    hasError = true
    print("Failed to download: ", fileName)
end

if not hasError then
    os.reboot()
else
    print("Cancelling reboot")
end