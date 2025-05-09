local navigation = require("/utils/navigation")
local move = require("/utils/move")

local floor = tonumber(arg[1])

local locationZ = navigation.getLocalLocation().z
local destinationZ = floor * 10

local toMove = destinationZ - locationZ
local moveFn

if(toMove > 0) then
    moveFn = move.down
elseif (toMove < 0) then
    moveFn = move.up
else
    print("You are already there")
end

for i = 1, toMove do
    moveFn()
end