local moveTracker = require("/utils/moveTracker")
local roomNav = require("/utils/roomNav")
local navigation = require("/utils/navigation")
local location = require("/utils/location")
local roomInfo = require("/utils/roomInfo")

print("Hi, I'm a worker turtle!")

local lat,long = location.roomCoordsToGeoLocation()
local floor = location.getFloor()

local jobStartLocation = roomInfo.getRoomInfo().jobInfo.jobStartLocation

navigation.goToRoomTurtle(lat, long, floor)

if(roomInfo.hasEnoughToStart()) then
    navigation.goToRoomJobStart(lat, long, floor, jobStartLocation)
end

-- if hasStuff (or stuff isnt complete) then unloadEverything() and shutdown
-- else, organize stuff and equip what you need

-- start a round
-- repeat