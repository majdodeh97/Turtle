local moveTracker = require("/utils/moveTracker")
local safe = require("/utils/safe")
local log = require("/utils/log")
local location = require("/utils/location")

---@class roomNav
local roomNav = {}

function roomNav.forward()
    local row, col = location.getRoom()

    local dir = row == "north" and "forward" or "back"

    safe.execute(moveTracker.faceDirection(dir))
    safe.execute(moveTracker.forward())
end

function roomNav.back()
    local row, col = location.getRoom()

    local dir = row == "north" and "forward" or "back"

    safe.execute(moveTracker.faceDirection(dir))
    safe.execute(moveTracker.back())
end

return roomNav