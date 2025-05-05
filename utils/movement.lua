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
    success, reason = turtle.forward()
    if(success) then
        updateHorizontalLocation(-1)
    end

    return success, reason
end


function updateHorizontalLocation(stepAmount)
    location = settings.get("location")

    if(not location) then
        log.error("Location is not defined")
    end

    local dir = location.dir

    -- dir meanings:
    -- 1 = forward (positive y)
    -- 2 = right (positive x)
    -- 3 = back (negative y)
    -- 4 = left (negative x)

    if dir == 1 then
        location.y = location.y + stepAmount
    elseif dir == 2 then
        location.x = location.x + stepAmount
    elseif dir == 3 then
        location.y = location.y - stepAmount
    elseif dir == 4 then
        location.x = location.x - stepAmount
    else
        log.error("invalid location dir")
    end

    settings.set("location", location)
    settings.save()
end

return movement