local log = require("/utils/log")
local fuel = require("/utils/fuel")
local move = {}

function move.getDirection()
    local dir = settings.get("direction")
    if not dir then
        log.error("No 'direction' defined in settings.")
    end
    if(dir ~= "forward" and dir ~= "back" and dir ~= "right" and dir ~= "left") then
        log.error("Invalid direction in settings: " .. dir)
    end
    return dir
end

function move.getOppositeDir(dir)
    dir = dir or move.getDirection()

    local opposites = {
        forward = "back", back = "forward",
        left = "right", right = "left",
        up = "down", down = "up"
    }
    return opposites[dir]
end

function move.getLocation()
    local location = settings.get("location")
    if not location then
        log.error("No 'location' defined in settings.")
    end

    return location
end

function move.getGpsLocation()
    local x,y,z

    local hasModem = peripheral.find("modem") ~= nil

    if(hasModem) then
        x,y,z = gps.locate()

        return {
            x = x,
            y = y,
            z = z
        }
    end
end

local function updateLocation(dir, delta)
    if delta <= 0 then
        log.error("Tried to log a move of " .. delta .. " in the " .. dir .. " direction.")
    end

    local location = move.getLocation()

    if(dir == "forward") then location.y = location.y + 1 end
    if(dir == "back") then location.y = location.y - 1 end
    if(dir == "right") then location.x = location.x + 1 end
    if(dir == "left") then location.x = location.x - 1 end
    if(dir == "up") then location.z = location.z + 1 end
    if(dir == "down") then location.z = location.z - 1 end

    settings.set("location", location)
    settings.save()
end

function move.forward()
    fuel.ensure()

    local success, reason = turtle.forward()
    if success then
        local dir = move.getDirection()
        updateLocation(dir, 1)
    end
    return success, reason
end

function move.back()
    fuel.ensure()
    
    local success, reason = turtle.back()
    if success then
        local dir = move.getOppositeDir(move.getDirection())
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

    local dir = move.getDirection()
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

    local dir = move.getDirection()
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
    local currentDir = move.getDirection()

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