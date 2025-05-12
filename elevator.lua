local move = require("/utils/move")

local floor = tonumber(arg[1])

local function moveToFloor(floor)
    local locationZ = move.getLocation().z
    local destinationZ = floor * 10
    
    local toMove = destinationZ - locationZ
    local moveFn

    if(toMove > 0) then
        moveFn = move.up
    elseif (toMove < 0) then
        moveFn = move.down
    else
        print("You are already there")
        return
    end
    
    toMove = math.abs(toMove)
    
    for i = 1, toMove do
        moveFn()
    end
end

moveToFloor(floor)
if(move.getLocation().z ~= 0) then
    sleep(10)
    moveToFloor(0)
end