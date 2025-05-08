local log = require("/utils/log")
local fuel = require("/utils/fuel")
local movement = {}

function movement.getOppositeDir(dir)
    local opposites = {
        forward = "back", back = "forward",
        left = "right", right = "left",
        up = "down", down = "up"
    }
    return opposites[dir]
end

function movement.getDirection()
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
        log.error("Tried to log a movement of " .. delta .. " in the " .. dir .. " direction.")
    end

    local stack = settings.get("movementStack") or {}
    local top = stack[#stack]

    local opposite = movement.getOppositeDir(dir)

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

    settings.set("movementStack", stack)
    settings.save()
end

function movement.forward()
    fuel.ensure()

    local success, reason = turtle.forward()
    if success then
        local dir = movement.getDirection()
        logMovement(dir, 1)
    end
    return success, reason
end

function movement.back()
    fuel.ensure()
    
    local success, reason = turtle.back()
    if success then
        local dir = movement.getOppositeDir(getDirection())
        logMovement(dir, 1)
    end
    return success, reason
end

function movement.up()
    fuel.ensure()
    
    local success, reason = turtle.up()
    if success then logMovement("up", 1) end
    return success, reason
end

function movement.down()
    fuel.ensure()
    
    local success, reason = turtle.down()
    if success then logMovement("down", 1) end
    return success, reason
end

function movement.turnRight()
    local success, reason = turtle.turnRight()
    if not success then return success, reason end

    local dir = movement.getDirection()
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

function movement.turnLeft()
    local success, reason = turtle.turnLeft()
    if not success then return success, reason end

    local dir = movement.getDirection()
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

function movement.faceDirection(targetDir)
    local currentDir = movement.getDirection()

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

    if diff == 1 then
        movement.turnRight()
    elseif diff == 2 then
        movement.turnRight()
        movement.turnRight()
    elseif diff == 3 then
        movement.turnLeft()
    end
end

return movement