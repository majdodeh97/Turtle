local log = require("/utils/log")

local location = {}

function location.getDirection()
    local dir = settings.get("direction")
    if not dir then
        log.error("No 'direction' defined in settings.")
    end
    if(dir ~= "forward" and dir ~= "back" and dir ~= "right" and dir ~= "left") then
        log.error("Invalid direction in settings: " .. dir)
    end
    return dir
end

function location.getOppositeDir(dir)
    dir = dir or move.getDirection()

    local opposites = {
        forward = "back", back = "forward",
        left = "right", right = "left",
        up = "down", down = "up"
    }
    return opposites[dir]
end

function location.getLocation()
    local location = settings.get("location")
    if not location then
        log.error("No 'location' defined in settings.")
    end

    return location
end

function location.getGpsLocation()
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

return location