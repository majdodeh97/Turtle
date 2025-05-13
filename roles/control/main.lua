local move = require("/utils/move")
local safe = require("/utils/safe")
local location = require("/utils/location")

print("Hi, I'm a control turtle!")

local function turnToOutputChest()
    local long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "left" or "right"

    safe.execute(move.faceDirection(dir))
end

local function turnToInputChest()
    local long = location.roomCoordsToGeoLocation()

    local dir = long == "east" and "right" or "left"

    safe.execute(move.faceDirection(dir))
end

-- todo: Controls the output and input, requests stuff from hub, gives the worker turtle what it needs