local log = require("/utils/log")
local moveTracker = require("/utils/moveTracker")
local move = require("/utils/move")
local location = require("/utils/location")
local place = require("/utils/place")
local safe = require("/utils/safe")
local inventory = require("/utils/inventory")
local highwayNav = require("/utils/highwayNav")

---@class navigation
local navigation = {}

local path = "/roomJobInfos.json"

function navigation.getRoomJobInfo(long, lat, floor)
    if not fs.exists(path) then
        log.error("File not found: " .. path)
    end

    local file = fs.open(path, "r")
    local content = file.readAll()
    file.close()

    local data = textutils.unserializeJSON(content)
    if not data or type(data.rooms) ~= "table" then
        log.error("Invalid or missing 'rooms' data.")
    end

    for _, room in ipairs(data.rooms) do
        if room.long == long and room.lat == lat and room.floor == floor then
            return room
        end
    end

    return nil
end

local function getRoomTurtleLocation(long, lat)
    -- return x,y
end

local function moveToWithBacktrack(x, y, floor)
    local loc = location.getLocation()

    if(location.isOnRoad(loc.x, loc.y)) then
        if(moveTracker.canBacktrack()) then log.error("Turtle on the road has a moveStack") end
    else
        if(moveTracker.canBacktrack()) then moveTracker.backtrack() end
    end

    return highwayNav.moveTo(x, y, floor)
end

function navigation.goToRoomOutputChest()

end

function navigation.goToRoomInputChest()

end

function navigation.goToRoomTurtle()

end

function navigation.goToRoomJobStart()
    navigation.goToRoomTurtle()
    -- move into the room and to job start (care for long and lat)
end

-- handles:
-- moving to room entrance via highwayNav
-- move into the room, utilizing location.getRoom(x, y) to move correctly
-- moving to room start position using moveTracker
-- shopuld I have wrappers for basic move functions? Maybe just faceDirection? Idk think more about this structure. 
-- Need to decide if room scripts will use this alone, or if it will use a mix of this and moveTracker

local function getRoomDoorCoords()

end

local function getRoomCoords(row, col)

    -- local rowToMove = math.abs(row) - 1
    -- local x = rowToMove * (config.roomSize + config.streetWidth)
    -- local colToMove = math.abs(col) - 1
    -- local y = colToMove * (config.roomSize + config.streetWidth)
 
    -- x = x + math.floor(config.streetWidth / 2) + math.ceil(config.roomSize / 2)
    -- y = y + math.floor(config.streetWidth / 2)
 
    -- if row == 0 then x = 0 end
    -- if col == 0 then y = 0 end
 
    -- if row < 0 then x = -1 * x end
    -- if col < 0 then y = -1 * y end
 
    -- return {
    --     x = x,
    --     y = y,
    --     z = 0
    -- }
end

return navigation