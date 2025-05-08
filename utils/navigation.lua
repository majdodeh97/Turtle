local inventory = require("/utils/inventory")
local movement = require("/utils/movement")
local log = require("/utils/log")

local navigation = {}

function navigation.getRoomCoords(row, col)

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
        y = y,
        z = 0
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

function navigation.getLocalLocation()
    local x, y, z = 0, 0, 0
    local stack = settings.get("movementStack") or {}

    for _, move in ipairs(stack) do
        if move.dir == "forward" then
            y = y + move.amount
        elseif move.dir == "back" then
            y = y - move.amount
        elseif move.dir == "right" then
            x = x + move.amount
        elseif move.dir == "left" then
            x = x - move.amount
        elseif move.dir == "up" then
            z = z + move.amount
        elseif move.dir == "down" then
            z = z - move.amount
        else
            log.error("Invalid direction in movementStack: " .. move.dir)
        end
    end

    return { x = x, y = y, z = z }
end

function navigation.backtrackUntil(conditionFn)
    local stack = settings.get("movementStack") or {}

    for i = #stack, 1, -1 do
        if(conditionFn()) then
            break
        end

        local move = stack[i]
        local dir = move.dir
        local amount = move.amount
        local oppositeDir = movement.getOppositeDir(dir)

        if dir == "up" or dir == "down" then
            local moveFn = (dir == "up") and movement.down or movement.up
            for _ = 1, amount do moveFn() end
        else
            movement.faceDirection(oppositeDir)
            for _ = 1, amount do movement.forward() end
        end
    end

    movement.faceDirection("forward");
end

function navigation.backtrack()
    navigation.backtrackUntil(function(name)
        return false
    end)
end

function navigation.getLocation()

    gpsLocation = navigation.getGpsLocation()
    location = navigation.getLocalLocation();

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
    
    return navigation.getLocation()

end

return navigation