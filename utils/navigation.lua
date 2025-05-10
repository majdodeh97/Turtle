local inventory = require("/utils/inventory")
local move = require("/utils/move")
local log = require("/utils/log")

local navigation = {}

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

function navigation.forward()
    local success, reason = move.forward()
    if success then
        local dir = move.getDirection()
        logMovement(dir, 1)
    end
    return success, reason
end

function navigation.back()
    local success, reason = move.back()
    if success then
        local dir = move.getOppositeDir(move.getDirection())
        logMovement(dir, 1)
    end
    return success, reason
end

function navigation.up()
    local success, reason = move.up()
    if success then logMovement("up", 1) end
    return success, reason
end

function navigation.down()
    local success, reason = move.down()
    if success then logMovement("down", 1) end
    return success, reason
end

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

function navigation.getLocation()
    local gpsLocation = navigation.getGpsLocation()
    local location = move.getLocation()

    if(location.x ~= gpsLocation.x or location.y ~= gpsLocation.y or location.z ~= gpsLocation.z) then
        local gpsLocationString = textutils.serialise(gpsLocation)
        local locationString = textutils.serialise(location)

        log.error("Location mismatch.\nGPS location: " .. gpsLocationString .. ".\nLocal location: " .. locationString)
    end

    return location
end

function navigation.getBacktrackLocation()
    local x, y, z = 0, 0, 0
    local stack = settings.get("moveStack") or {}

    for _, moveItem in ipairs(stack) do
        if moveItem.dir == "forward" then
            y = y + moveItem.amount
        elseif moveItem.dir == "back" then
            y = y - moveItem.amount
        elseif moveItem.dir == "right" then
            x = x + moveItem.amount
        elseif moveItem.dir == "left" then
            x = x - moveItem.amount
        elseif moveItem.dir == "up" then
            z = z + moveItem.amount
        elseif moveItem.dir == "down" then
            z = z - moveItem.amount
        else
            log.error("Invalid direction in moveStack: " .. moveItem.dir)
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
        local moveItem = stack[i]
        local dir = moveItem.dir
        local amount = moveItem.amount
        local oppositeDir = move.getOppositeDir(dir)

        if dir == "up" or dir == "down" then
            local moveFn = (dir == "up") and navigation.down or navigation.up
            for _ = 1, amount do 
                if not conditionalMove(moveFn, conditionFn) then break end
            end
        else
            if not conditionalTurn(oppositeDir, conditionFn) then break end 
            for _ = 1, amount do
                if not conditionalMove(navigation.forward, conditionFn) then break end
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

return navigation