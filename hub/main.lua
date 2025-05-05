print("Hi, I'm a hub!")

sleep(10)

local scriptPath = "downloader.lua"

if fs.exists(scriptPath) then
    print("Running:", scriptPath)
    shell.run(scriptPath, ".settings")
else
    print("Error: Script not found at", scriptPath)
end

os.reboot()