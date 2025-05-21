local moveTracker = require("/utils/moveTracker")
local roomNav = require("/utils/roomNav")
local navigation = require("/utils/navigation")
local location = require("/utils/location")
local roomInfo = require("/utils/roomInfo")
local inventory = require("/utils/inventory")

local function organizeInventory(jobInfoItems) -- 

    local tool1 = jobInfoItems.tools[1]
    local tool2 = jobInfoItems.tools[2]

    if(tool1) then
        inventory.runOnItem(function()
            turtle.equipRight()
        end, tool1.itemName)
    end

    if(tool2) then
        inventory.runOnItem(function()
            turtle.equipRight()
        end, tool2.itemName)
    end

    inventory.runOnSlot(function()
        turtle.transferTo(2)
    end, 1)
end


print("Hi, I'm a worker turtle!")

organizeInventory()

os.pullEvent("key")

local lat,long = location.roomCoordsToGeoLocation()
local floor = location.getFloor()

local jobStartLocation = roomInfo.getRoomInfo().jobInfo.jobStartLocation
local jobScript = roomInfo.getRoomInfo().jobInfo.jobScript
local jobParams = roomInfo.getRoomInfo().jobInfo.jobParams

navigation.goToRoomTurtle(lat, long, floor)

if(roomInfo.hasEnoughToStart()) then
    navigation.goToRoomJobStart(lat, long, floor, jobStartLocation)
    shell.run(jobScript .. " " .. jobParams)
    navigation.goToRoomTurtle(lat, long, floor)
end


inventory.safeDropAllDown()
turtle.equipLeft()
inventory.safeDropDown()
turtle.equipRight()
inventory.safeDropDown()
os.shutdown()

-- if hasStuff (or stuff isnt complete) then unloadEverything() and shutdown
-- else, organize stuff and equip what you need

-- start a round
-- repeat