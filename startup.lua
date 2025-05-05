-- Load role from settings

if(settings.get("error")) then
    print("Turtle shutdown unexpectidely. Please check error logs")
    settings.unset("error")
    settings.save()
    return;
end

local role = settings.get("role")

if not role then
    print("Error: 'role' setting not found.")
    return
end

local scriptPath = fs.combine(role, "main.lua")

if fs.exists(scriptPath) then
    print("Running:", scriptPath)
    shell.run(scriptPath)
else
    print("Error: Script not found at", scriptPath)
end
