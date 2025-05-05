local baseURL = "https://raw.githubusercontent.com/majdodeh97/Turtle/main/"

-- 🧹 Delete existing folder if it exists
if fs.exists(folderName) then
    print("Cleaning up old folder:", folderName)
    fs.delete(folderName)
end

-- Download the manifest file
local manifestURL = baseURL .. "manifest.txt"
local response = http.get(manifestURL)
if not response then
    print("Failed to download manifest.")
    return
end

local manifest = response.readAll()
response.close()

-- Process each line in the manifest
for line in manifest:gmatch("[^\r\n]+") do
    local fileURL = baseURL .. line
    local fileResponse = http.get(fileURL)
    if fileResponse then
        local content = fileResponse.readAll()
        fileResponse.close()

        -- Create necessary directories
        local path = fs.combine(folderName, line)
        local dir = fs.getDir(path)
        if not fs.exists(dir) then
            fs.makeDir(dir)
        end

        -- Write the file
        local file = fs.open(path, "w")
        file.write(content)
        file.close()
        print("Downloaded:", line)
    else
        print("Failed to download:", line)
    end
end