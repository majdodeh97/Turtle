local inventory = require("/utils/inventory")
local movement = require("/utils/movement")
local log = require("/utils/log")

local navigation = {}

function navigation.getCoords(row, col)

    local rowToMove = math.abs(row) - 1
    local x = rowToMove * (config.roomSize + config.streetWidth)
    local colToMove = math.abs(col) - 1
    local y = colToMove * (config.roomSize + config.streetWidth)
 
    x = x + math.floor(config.streetWidth / 2) + math.ceil(config.roomSize / 2)
    y = y + math.floor(config.streetWidth / 2)
 
    if row == 0 then x = 0 end
    if col == 0 then y = 0 end
 
    if row < 0 then x = -1 * x end
    if col < 0 then y = -1 * y end
 
    return {
        x = x,
        y = 0,
        z = z + 1 --for recalibration block
    }
end

function navigation.getGpsLocation()
    local x,y,z

    local hasModem = peripheral.find("modem") ~= nil

    if(hasModem) then
        x,y,z = gps.locate()
    else
        local modemMatcher = function(name)
            return name:find("computercraft:.*modem")
        end
        
        inventory.runOnItemMatch(modemMatcher, function()
            turtle.equipLeft()
            x,y,z = gps.locate()
            turtle.equipLeft()
        end)
    end

    return {
        x = x,
        y = y,
        z = z
    }
end

function navigation.getCurrentLocation()

    gpsLocation = navigation.getGpsLocation()
    location = movement.getLocation();

    if(not location or location.x ~= gpsLocation.x or location.y ~= gpsLocation.y or location.z ~= gpsLocation.z) then
        gpsLocationString = textutils.serialise(gpsLocation)
        locationString = textutils.serialise(location)

        log.error("Location mismatch.\nGPS location: " .. gpsLocationString .. ".\nLocal location: " .. locationString)
    end

    return location
end

function navigation.isInRoom()

end

function navigation.goHome()
    
    return navigation.getCurrentLocation()

end

return navigation