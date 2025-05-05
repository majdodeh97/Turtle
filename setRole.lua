local tArgs = { ... }

if not tArgs[1] then
    print("Usage: setRole <role>")
    return
end

local role = tArgs[1]
settings.set("role", role)
settings.save()

print("Role set to:", role)