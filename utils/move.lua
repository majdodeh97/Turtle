local log = require("/utils/log")
local fuel = require("/utils/fuel")
local move = {}

function move.getOppositeDir(dir)
    local opposites = {
        forward = "back", back = "forward",
        left = "right", right = "left",
        up = "down", down = "up"
    }
    return opposites[dir]
end

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

local function logMovement(dir, delta)
    if delta <= 0 then
        log.error("Tried to log a move of " .. delta .. " in the " .. dir .. " direction.")
    end

    local stack = settings.get("moveStack") or {}
    local top = stack[#stack]

    local opposite = move.getOppositeDir(dir)

    if top and top.dir == dir then
        top.amount = top.amount + delta
    elseif top and top.dir == opposite then
        top.amount = top.amount - delta
        if top.amount < 0 then
            top.dir = dir
            top.amount = -top.amount
        elseif top.amount == 0 then
            table.remove(stack)
        end
    else
        table.insert(stack, { dir = dir, amount = delta })
    end

    settings.set("moveStack", stack)
    settings.save()
end

function move.forward()
    fuel.ensure()

    local success, reason = turtle.forward()
    if success then
        local dir = move.getDirection()
        logMovement(dir, 1)
    end
    return success, reason
end

function move.back()
    fuel.ensure()
    
    local success, reason = turtle.back()
    if success then
        local dir = move.getOppositeDir(move.getDirection())
        logMovement(dir, 1)
    end
    return success, reason
end

function move.up()
    fuel.ensure()
    
    local success, reason = turtle.up()
    if success then logMovement("up", 1) end
    return success, reason
end

function move.down()
    fuel.ensure()
    
    local success, reason = turtle.down()
    if success then logMovement("down", 1) end
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