local navigation = require("/utils/navigation")

fs.delete(".settings")

local fileName = ".settings"
local fileURL = "https://raw.githubusercontent.com/majdodeh97/Turtle/main/" .. fileName
local fileResponse = http.get(fileURL)

error = false

if fileResponse then
    local content = fileResponse.readAll()
    fileResponse.close()

    -- Write the file
    local file = fs.open(fileName, "w")
    file.write(content)
    file.close()
    print("Downloaded:", fileName)
else
    error = true
    print("Failed to download:", line)
    print("Cancelling reboot")
end

if(not error) then
    local gpsLocation = navigation.getGpsLocation()
    settings.set("location", gpsLocation)
    settings.save()
    os.reboot()
end