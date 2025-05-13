local log = require("/utils/log")

---@class location
local location = {}

local ABOVE_FLOOR_GROUPS = {
    { count = 4, height = 10 },
    { count = 4, height = 20 },
    { count = 4, height = 30 }
}

local BELOW_FLOOR_GROUPS = {
    { count = 4, height = 10 },
    { count = 4, height = 20 }
}

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
    dir = dir or location.getDirection()

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

function location.isOnRoad(x, y)
    x = x or location.getLocation().x
    y = y or location.getLocation().y

    local roadSize = settings.get("base").roadSize

    local half = math.floor(roadSize / 2)
    local min = roadSize % 2 == 0 and (-half + 1) or -half
    local max = half

    return (x >= min and x <= max) or
           (y >= min and y <= max)
end

function location.isHome(targetX, targetY, targetFloor)
    if(targetX == 0 and targetY == 0 and targetFloor == 0) then return true end

    return false
end

function location.roomCoordsToGeoLocation(x, y)
    x = x or location.getLocation().x
    y = y or location.getLocation().y

    if(location.isOnRoad(x, y)) then log.error("Coords are not room coords: (" .. x .. "," .. y .. ")") end
     
    local lat = y > 0 and "north" or "south"
    local long = x > 0 and "east" or "west"

    return lat, long
end

-- Returns the closest coord to (0,0)
function location.geoLocationToRoomCoords(lat, long)
    local roadSize = settings.get("base").roadSize
    local half = math.floor(roadSize / 2)

    local x = long == "east" and half + 1 or ((roadSize % 2 == 0) and -(half) or -(half + 1))
    local y = lat == "north" and half + 1 or ((roadSize % 2 == 0) and -(half) or -(half + 1))

    return x,y
end

function location.getMinFloor()
    local total = 0
    for _, group in ipairs(BELOW_FLOOR_GROUPS) do
        total = total + group.count
    end
    return -total
end

function location.getFloor(z)
    if(not z) then log.error("No z defined for getFloor") end

    if z >= 0 then
        local currentZ = 0
        local floor = 0

        for _, group in ipairs(ABOVE_FLOOR_GROUPS) do
            for i = 1, group.count do
                local nextZ = currentZ + group.height
                if z < nextZ then
                    return floor
                end
                currentZ = nextZ
                floor = floor + 1
            end
        end

        log.error("Z too high, no floor defined at z=" .. z)
    else
        local currentZ = 0
        local floor = -1

        for _, group in ipairs(BELOW_FLOOR_GROUPS) do
            for i = 1, group.count do
                local nextZ = currentZ - group.height
                if z >= nextZ then
                    return floor
                end
                currentZ = nextZ
                floor = floor - 1
            end
        end

        log.error("Z too low, no floor defined at z=" .. z)
    end
end

function location.getFloorBaseZ(floor)
    if(not floor) then log.error("No floor defined for getFloorBaseZ") end

    if floor >= 0 then
        local currentZ = 0
        local currentFloor = 0

        for _, group in ipairs(ABOVE_FLOOR_GROUPS) do
            for i = 1, group.count do
                if currentFloor == floor then
                    return currentZ
                end
                currentZ = currentZ + group.height
                currentFloor = currentFloor + 1
            end
        end
    else
        local currentZ = 0
        local currentFloor = -1

        for _, group in ipairs(BELOW_FLOOR_GROUPS) do
            for i = 1, group.count do
                if currentFloor == floor then
                    return currentZ - group.height
                end
                currentZ = currentZ - group.height
                currentFloor = currentFloor - 1
            end
        end
    end

    log.error("Floor number out of bounds: " .. floor)
end


return location