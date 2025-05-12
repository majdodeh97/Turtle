local log = require("/utils/log")
local fuel = require("/utils/fuel")
local location = require("/utils/location")

---@class move
local move = {}

local function updateLocation(dir, delta)
    if delta <= 0 then
        log.error("Tried to log a move of " .. delta .. " in the " .. dir .. " direction.")
    end

    local loc = location.getLocation()

    if(dir == "forward") then loc.y = loc.y + 1 end
    if(dir == "back") then loc.y = loc.y - 1 end
    if(dir == "right") then loc.x = loc.x + 1 end
    if(dir == "left") then loc.x = loc.x - 1 end
    if(dir == "up") then loc.z = loc.z + 1 end
    if(dir == "down") then loc.z = loc.z - 1 end

    settings.set("location", loc)
    settings.save()
end

function move.forward()
    fuel.ensure()

    local success, reason = turtle.forward()
    if success then
        local dir = location.getDirection()
        updateLocation(dir, 1)
    end
    return success, reason
end

function move.back()
    fuel.ensure()
    
    local success, reason = turtle.back()
    if success then
        local dir = location.getOppositeDir()
        updateLocation(dir, 1)
    end
    return success, reason
end

function move.up()
    fuel.ensure()
    
    local success, reason = turtle.up()
    if success then updateLocation("up", 1) end
    return success, reason
end

function move.down()
    fuel.ensure()
    
    local success, reason = turtle.down()
    if success then updateLocation("down", 1) end
    return success, reason
end

function move.turnRight()
    local success, reason = turtle.turnRight()
    if not success then return success, reason end

    local dir = location.getDirection()
    local order = { "forward", "right", "back", "left" }

    for i, d in ipairs(order) do
        if d == dir then
            settings.set("direction", order[(i % 4) + 1])
            settings.save()
            break
        end
    end

    return success, reason
end

function move.turnLeft()
    local success, reason = turtle.turnLeft()
    if not success then return success, reason end

    local dir = location.getDirection()
    local order = { "forward", "right", "back", "left" }

    for i, d in ipairs(order) do
        if d == dir then
            settings.set("direction", order[((i - 2) % 4) + 1])
            settings.save()
            break
        end
    end

    return success, reason
end

function move.faceDirection(targetDir)
    local currentDir = location.getDirection()

    local directions = { "forward", "right", "back", "left" }

    local function getIndex(dir)
        for i, v in ipairs(directions) do
            if v == dir then return i end
        end
        log.error("Invalid direction: " .. dir)
    end

    local currentIndex = getIndex(currentDir)
    local targetIndex = getIndex(targetDir)
    local diff = (targetIndex - currentIndex) % 4

    if diff == 0 then
        return true -- Already facing correct direction
    elseif diff == 1 then
        return move.turnRight()
    elseif diff == 2 then
        local s1, r1 = move.turnRight()
        if not s1 then return false, r1 end

        local s2, r2 = move.turnRight()
        if not s2 then return false, r2 end
        
        return true
    elseif diff == 3 then
        return move.turnLeft()
    end
end

return move