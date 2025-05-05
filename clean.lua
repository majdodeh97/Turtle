-- clean.lua
local keep = {
    ["download.lua"] = true,
    ["clean.lua"] = true
}

for _, file in ipairs(fs.list("")) do
    if not keep[file] then
        fs.delete(file)
        print("Deleted:", file)
    end
end

print("Cleanup complete. Only essential scripts remain.")