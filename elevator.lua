local navigation = require("/utils/navigation")
local move = require("/utils/move")

local floor = tonumber(arg[1])

local locationZ = move.getLocation()
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