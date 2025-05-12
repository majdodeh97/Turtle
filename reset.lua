local move = require("/utils/move")
local location = require("/utils/location")

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

    local gpsLocation = location.getGpsLocation()
    if gpsLocation then
        settings.set("location", gpsLocation)
        settings.save()
    else
        print("Failed to get GPS location")
        return
    end
else
    print("Failed to download: ", fileName)
    return
end