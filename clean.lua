-- clean.lua
local keep = {
    ["downloader.lua"] = true,
    ["rom"] = true
}


for _, file in ipairs(fs.list("")) do
    if not keep[file] then
        fs.delete(file)
        print("Deleted:", file)
    end
end

print("Cleanup complete. Only essential scripts remain.")