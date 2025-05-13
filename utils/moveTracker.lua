local move = require("/utils/move")
local log = require("/utils/log")
local location = require("/utils/location")

---@class moveTracker
local moveTracker = {}

local function logMovement(dir, delta)
    if delta <= 0 then
        log.error("Tried to log a move of " .. delta .. " in the " .. dir .. " direction.")
    end

    local stack = settings.get("moveStack") or {}
    local top = stack[#stack]

    local opposite = location.getOppositeDir(dir)

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

function moveTracker.forward()
    local success, reason = move.forward()
    if success then
        local dir = location.getDirection()
        logMovement(dir, 1)
    end
    return success, reason
end

function moveTracker.back()
    local success, reason = move.back()
    if success then
        local dir = location.getOppositeDir()
        logMovement(dir, 1)
    end
    return success, reason
end

function moveTracker.up()
    local success, reason = move.up()
    if success then logMovement("up", 1) end
    return success, reason
end

function moveTracker.down()
    local success, reason = move.down()
    if success then logMovement("down", 1) end
    return success, reason
end

function moveTracker.turnRight()
    return move.turnRight()
end

function moveTracker.turnLeft()
    return move.turnLeft()
end

function moveTracker.canBacktrack()
    local stack = settings.get("moveStack") or {}

    return type(stack) == "table" and next(stack) ~= nil
end

function moveTracker.getBacktrackLocation()
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

function moveTracker.backtrackUntil(conditionFn)
    
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
        local oppositeDir = location.getOppositeDir(dir)

        if dir == "up" or dir == "down" then
            local moveFn = (dir == "up") and moveTracker.down or moveTracker.up
            for _ = 1, amount do 
                if not conditionalMove(moveFn, conditionFn) then break end
            end
        else
            if not conditionalTurn(oppositeDir, conditionFn) then break end 
            for _ = 1, amount do
                if not conditionalMove(moveTracker.forward, conditionFn) then break end
            end
        end
    end

    conditionalTurn("forward", function()
        return false
    end)
end

function moveTracker.backtrack()
    moveTracker.backtrackUntil(function(name)
        return false
    end)
end

return moveTracker