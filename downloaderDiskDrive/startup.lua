print("Update about to start")
print("Press any key to continue...")

---@diagnostic disable-next-line: undefined-field
os.pullEvent("key")

shell.run("/disk/clean.lua")
shell.run("/disk/downloader.lua")