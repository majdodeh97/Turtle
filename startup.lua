-- Load role from settings

if(settings.get("error")) then
    print("Turtle encountered an error. Please check error logs")
    print("Press any key to continue...")
    os.pullEvent("key")
    settings.unset("error")
    settings.save()
    return;
end

if(settings.get("warning")) then
    print("Turtle encountered a warning. Please check warning logs")
    print("Press any key to continue...")
    os.pullEvent("key")
    settings.unset("warning")
    settings.save()
    return;
end

local role = settings.get("role")

if not role then
    print("This is an idle turtle. Assign it a role with setRole")
    return
end

local scriptPath = fs.combine(role, "main.lua")

if fs.exists(scriptPath) then
    print("Running:", scriptPath)
    shell.run(scriptPath)
else
    print("Error: Script not found at", scriptPath)
end
