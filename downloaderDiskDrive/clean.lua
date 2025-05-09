-- clean.lua
local keep = {
    ["disk"] = true,
    ["rom"] = true
}

for _, file in ipairs(fs.list("")) do
    if not keep[file] then
        fs.delete(file)
        print("Deleted:", file)
    end
end