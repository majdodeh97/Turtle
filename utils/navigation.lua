local inventory = require("/utils/inventory")
local move = require("/utils/move")
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
        local modemMatcher = function(itemDetail)
            return itemDetail.name:find("computercraft:.*modem")
        end
        
        inventory.runOnItemMatch(function()
            turtle.equipLeft()
            x,y,z = gps.locate()
            turtle.equipLeft()
        end, modemMatcher)
    end

    return {
        x = x,
        y = y,
        z = z
    }
end

function navigation.getLocalLocation()
    local x, y, z = 0, 0, 0
    local stack = settings.get("moveStack") or {}

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
            log.error("Invalid direction in moveStack: " .. move.dir)
        end
    end

    return { x = x, y = y, z = z }
end

function navigation.backtrackUntil(conditionFn)
    
    local stack = settings.get("moveStack") or {}

    local function conditionalMove(fn, condFn)
        while true do
            if condFn() then return false end
            if fn() then return true end
            print("Movement obstructed.")
            sleep(5)
        end
    end

    local function conditionalTurn(dir, condFn)
        while true do
            if condFn() then return false end
            if move.faceDirection(dir) then return true end
            print("Turning obstructed.")
            sleep(5)
        end
    end

    for i = #stack, 1, -1 do
        local move = stack[i]
        local dir = move.dir
        local amount = move.amount
        local oppositeDir = move.getOppositeDir(dir)

        if dir == "up" or dir == "down" then
            local moveFn = (dir == "up") and move.down or move.up
            for _ = 1, amount do 
                if not conditionalMove(moveFn, conditionFn) then break end
            end
        else
            if not conditionalTurn(oppositeDir, conditionFn) then break end 
            for _ = 1, amount do
                if not conditionalMove(move.forward, conditionFn) then break end
            end
        end
    end

    conditionalTurn("forward", function()
        return false
    end)
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