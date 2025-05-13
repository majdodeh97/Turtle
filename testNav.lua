local navigation = require("/utils/navigation")

-- Args: testCaseNumber, lat, long, floor
local args = { ... }

if #args < 4 then
    print("Usage: navigationTest <testCase> <lat> <long> <floor>")
    return
end

local testCase = tonumber(args[1])
local lat = args[2]
local long = args[3]
local floor = tonumber(args[4])

if not (lat and long and floor) then
    print("Invalid arguments.")
    return
end

if testCase == 1 then
    local room = navigation.getRoomInfoByLocation(lat, long, floor)
    if room then
        print("Room info found:")
        print(textutils.serialize(room))
    else
        print("Room not found.")
    end
elseif testCase == 2 then
    navigation.goToRoomTurtle(lat, long, floor)
elseif testCase == 3 then
    navigation.goToRoomOutputChest(lat, long, floor)
elseif testCase == 4 then
    navigation.goToRoomInputChest(lat, long, floor)
elseif testCase == 5 then
    local roomInfo = navigation.getRoomInfoByLocation(lat, long, floor)
    if not roomInfo then return end
    navigation.goToRoomJobStart(lat, long, floor, roomInfo.jobStartLocation)
elseif testCase == 6 then
    navigation.turnToOutputChest(long)
elseif testCase == 7 then
    navigation.turnToInputChest(long)
else
    print("Unknown test case number.")
end
