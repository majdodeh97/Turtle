print("Hi, I'm a hub!")

local scriptPath = "downloader.lua"

if fs.exists(scriptPath) then
    print("Running:", scriptPath)
    shell.run(scriptPath)
else
    print("Error: Script not found at", scriptPath)
end

os.reboot()