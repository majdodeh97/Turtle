local log = require("/utils/log")

local movement = {}

function movement.forward()
    success, reason = turtle.forward()
    if(success) then
        updateHorizontalLocation(1)
    end

    return success, reason
end

function movement.back()
    success, reason = turtle.back()
    if(success) then
        updateHorizontalLocation(-1)
    end

    return success, reason
end

function movement.up()
    success, reason = turtle.up()
    if(success) then
        updateVerticalLocation(1)
    end

    return success, reason
end

function movement.down()
    success, reason = turtle.down()
    if(success) then
        updateVerticalLocation(-1)
    end

    return success, reason
end

function movement.turnRight()
    success, reason = turtle.turnRight()
    local location = settings.get("location")

    if(not location) then
        log.error("Location is not defined")
    end

    location.dir = (location.dir + 1) % 4
    settings.set("location", location)
    settings.save()

    return success, reason
end

function movement.turnLeft()
    success, reason = turtle.turnLeft()
    local location = settings.get("location")

    if(not location) then
        log.error("Location is not defined")
    end

    location.dir = (location.dir - 1) % 4
    settings.set("location", location)
    settings.save()

    return success, reason
end

function updateHorizontalLocation(stepAmount)
    location = settings.get("location")

    if(not location) then
        log.error("Location is not defined")
    end

    local dir = location.dir

    -- dir meanings:
    -- 0 = forward (positive y)
    -- 1 = right (positive x)
    -- 2 = back (negative y)
    -- 3 = left (negative x)

    if dir == 0 then
        location.y = location.y + stepAmount
    elseif dir == 1 then
        location.x = location.x + stepAmount
    elseif dir == 2 then
        location.y = location.y - stepAmount
    elseif dir == 3 then
        location.x = location.x - stepAmount
    else
        log.error("Invalid location dir")
    end

    settings.set("location", location)
    settings.save()
end

function updateVerticalLocation(stepAmount)
    location = settings.get("location")

    if(not location) then
        log.error("Location is not defined")
    end

    location.z = location.z + stepAmount
    
    settings.set("location", location)
    settings.save()
end

return movement