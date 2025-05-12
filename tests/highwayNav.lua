local test = require("/utils/test")
local highwayNav = require("/utils/highwayNav")
local move = require("/utils/move")
local location = require("/utils/location")

-- getFloor(z) tests
test.addTest("getFloor z = 0 -> floor 0", function()
    test.assertEquals(highwayNav.getFloor(0), 0)
end)

test.addTest("getFloor z = 9 -> floor 0", function()
    test.assertEquals(highwayNav.getFloor(9), 0)
end)

test.addTest("getFloor z = 10 -> floor 1", function()
    test.assertEquals(highwayNav.getFloor(10), 1)
end)

test.addTest("getFloor z = 17 -> floor 1", function()
    test.assertEquals(highwayNav.getFloor(17), 1)
end)

test.addTest("getFloor z = 44 -> floor 3", function()
    test.assertEquals(highwayNav.getFloor(44), 4)
end)

test.addTest("getFloor z = 45 -> floor 4", function()
    test.assertEquals(highwayNav.getFloor(45), 4)
end)

test.addTest("getFloor z = 80 -> floor 6", function()
    test.assertEquals(highwayNav.getFloor(80), 6)
end)

test.addTest("getFloor z = 119 -> floor 7", function()
    test.assertEquals(highwayNav.getFloor(119), 7)
end)

test.addTest("getFloor z = 120 -> floor 8", function()
    test.assertEquals(highwayNav.getFloor(120), 8)
end)

test.addTest("getFloor z = -1 -> floor 0", function()
    test.assertEquals(highwayNav.getFloor(-1), -1)
end)

test.addTest("getFloor z = -10 -> floor -1", function()
    test.assertEquals(highwayNav.getFloor(-10), -1)
end)

test.addTest("getFloor z = -11 -> floor -2", function()
    test.assertEquals(highwayNav.getFloor(-11), -2)
end)

test.addTest("getFloor z = -21 -> floor -3", function()
    test.assertEquals(highwayNav.getFloor(-21), -3)
end)

test.addTest("getFloor z = -79 -> floor -6", function()
    test.assertEquals(highwayNav.getFloor(-79), -6)
end)

test.addTest("getFloor z = -80 -> floor -6", function()
    test.assertEquals(highwayNav.getFloor(-80), -6)
end)

test.addTest("getFloor z = -81 -> floor -7", function()
    test.assertEquals(highwayNav.getFloor(-81), -7)
end)

-- getFloorBaseZ(floor) tests
test.addTest("getFloorBaseZ floor 0 -> z = 0", function()
    test.assertEquals(highwayNav.getFloorBaseZ(0), 0)
end)

test.addTest("getFloorBaseZ floor 1 -> z = 10", function()
    test.assertEquals(highwayNav.getFloorBaseZ(1), 10)
end)

test.addTest("getFloorBaseZ floor 2 -> z = 20", function()
    test.assertEquals(highwayNav.getFloorBaseZ(2), 20)
end)

test.addTest("getFloorBaseZ floor 5 -> z = 60", function()
    test.assertEquals(highwayNav.getFloorBaseZ(5), 60)
end)

test.addTest("getFloorBaseZ floor 6 -> z = 80", function()
    test.assertEquals(highwayNav.getFloorBaseZ(6), 80)
end)

test.addTest("getFloorBaseZ floor 7 -> z = 100", function()
    test.assertEquals(highwayNav.getFloorBaseZ(7), 100)
end)

test.addTest("getFloorBaseZ floor 8 -> z = 120", function()
    test.assertEquals(highwayNav.getFloorBaseZ(8), 120)
end)

test.addTest("getFloorBaseZ floor -1 -> z = -10", function()
    test.assertEquals(highwayNav.getFloorBaseZ(-1), -10)
end)

test.addTest("getFloorBaseZ floor -2 -> z = -20", function()
    test.assertEquals(highwayNav.getFloorBaseZ(-2), -20)
end)

test.addTest("getFloorBaseZ floor -3 -> z = -30", function()
    test.assertEquals(highwayNav.getFloorBaseZ(-3), -30)
end)

test.addTest("getFloorBaseZ floor -5 -> z = -60", function()
    test.assertEquals(highwayNav.getFloorBaseZ(-5), -60)
end)

test.addTest("getFloorBaseZ floor -6 -> z = -80", function()
    test.assertEquals(highwayNav.getFloorBaseZ(-6), -80)
end)

local roadSizeOdd = 5 -- range: [-2, 2]
local roadSizeEven = 4 -- range: [-1, 2]

-- ODD roadSize = 5
test.addTest("roadSize 5: x = 0, y = 2 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(0, 2, roadSizeOdd), true)
end)

test.addTest("roadSize 5: x = -2, y = 0 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(-2, 0, roadSizeOdd), true)
end)

test.addTest("roadSize 5: x = 3, y = 0 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(3, 0, roadSizeOdd), true)
end)

test.addTest("roadSize 5: x = 0, y = -3 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(0, -3, roadSizeOdd), true)
end)

test.addTest("roadSize 5: x = 1, y = 1 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(1, 1, roadSizeOdd), true)
end)

test.addTest("roadSize 5: x = -3, y = -3 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(-3, -3, roadSizeOdd), false)
end)

-- EVEN roadSize = 4
test.addTest("roadSize 4: x = 0, y = 2 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(0, 2, roadSizeEven), true)
end)

test.addTest("roadSize 4: x = -1, y = 0 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(-1, 0, roadSizeEven), true)
end)

test.addTest("roadSize 4: x = 3, y = 0 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(3, 0, roadSizeEven), true)
end)

test.addTest("roadSize 4: x = 0, y = -2 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(0, -2, roadSizeEven), true)
end)

test.addTest("roadSize 4: x = 2, y = 2 -> true", function()
    test.assertEquals(highwayNav.isOnRoad(2, 2, roadSizeEven), true)
end)

test.addTest("roadSize 4: x = -2, y = -2 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(-2, -2, roadSizeEven), false)
end)

test.addTest("roadSize 4: x = 5, y = 4 -> false", function()
    test.assertEquals(highwayNav.isOnRoad(5, 4, roadSizeEven), false)
end)


local INCOMING_Z = 3
local OUTGOING_Z = 2
local SWAP_Z = 0

-- getFloorIncomingZ(floor) tests
test.addTest("getFloorIncomingZ floor 0", function()
    test.assertEquals(highwayNav.getFloorIncomingZ(0), highwayNav.getFloorBaseZ(0) + INCOMING_Z)
end)

test.addTest("getFloorIncomingZ floor -2", function()
    test.assertEquals(highwayNav.getFloorIncomingZ(-2), highwayNav.getFloorBaseZ(-2) + INCOMING_Z)
end)

-- getFloorOutgoingZ(floor) tests
test.addTest("getOutgoingZ floor 0", function()
    test.assertEquals(highwayNav.getFloorOutgoingZ(0), highwayNav.getFloorBaseZ(0) + OUTGOING_Z)
end)

test.addTest("getOutgoingZ floor -2", function()
    test.assertEquals(highwayNav.getFloorOutgoingZ(-2), highwayNav.getFloorBaseZ(-2) + OUTGOING_Z)
end)

-- getFloorSwapZ(floor) tests
test.addTest("getSwapZ floor 0", function()
    test.assertEquals(highwayNav.getFloorSwapZ(0), highwayNav.getFloorBaseZ(0) + SWAP_Z)
end)

test.addTest("getSwapZ floor -2", function()
    test.assertEquals(highwayNav.getFloorSwapZ(-2), highwayNav.getFloorBaseZ(-2) + SWAP_Z)
end)

-- moveToIncomingZ
test.addTest("moveToIncomingZ: already at incomingZ", function()
    -- Set location.z to incomingZ manually
    local floor = 0
    local incomingZ = highwayNav.getFloorIncomingZ(floor)

    settings.set("location", { x = 2, y = 2, z = incomingZ })
    settings.save()

    -- Should not move at all
    local before = settings.get("location").z
    highwayNav.moveToIncomingZ()
    local after = settings.get("location").z

    test.assertEquals(after, before)
end)

test.addTest("moveToIncomingZ: 2 steps up", function()
    local floor = 0
    local incomingZ = highwayNav.getFloorIncomingZ(floor)

    -- Simulate being 2 steps below
    settings.set("location", { x = 0, y = 0, z = incomingZ - 2 })
    settings.save()

    local before = settings.get("location").z
    highwayNav.moveToIncomingZ()
    local after = settings.get("location").z

    test.assertEquals(after, before + 2)
end)

test.addTest("moveToIncomingZ: above incomingZ", function()
    local floor = 0
    local incomingZ = highwayNav.getFloorIncomingZ(floor)

    -- Simulate being 2 steps above
    settings.set("location", { x = 0, y = 0, z = incomingZ + 2 })
    settings.save()

    local before = settings.get("location").z
    highwayNav.moveToIncomingZ()
    local after = settings.get("location").z

    test.assertEquals(after, before)
end)

-- moveToXY
test.addTest("moveToXY: (0,0) to (2,1)", function()
    settings.set("location", { x = 0, y = 0, z = 0 })
    settings.set("direction", "forward")
    settings.save()

    highwayNav.moveToXY(2, 1)

    local loc = location.getLocation()
    test.assertEquals(loc.x, 2)
    test.assertEquals(loc.y, 1)
end)

test.addTest("moveToXY: (3,3) to (0,0)", function()
    settings.set("location", { x = 3, y = 3, z = 0 })
    settings.set("direction", "forward")
    settings.save()

    highwayNav.moveToXY(0, 0)

    local loc = location.getLocation()
    test.assertEquals(loc.x, 0)
    test.assertEquals(loc.y, 0)
end)

test.addTest("moveToXY: (1,1) to (1,1) (no movement)", function()
    settings.set("location", { x = 1, y = 1, z = 0 })
    settings.set("direction", "forward")
    settings.save()

    highwayNav.moveToXY(1, 1)

    local loc = location.getLocation()
    test.assertEquals(loc.x, 1)
    test.assertEquals(loc.y, 1)
end)

test.addTest("moveToXY: (2,0) to (-1,4)", function()
    settings.set("location", { x = 2, y = 0, z = 0 })
    settings.set("direction", "forward")
    settings.save()

    highwayNav.moveToXY(-1, 4)

    local loc = location.getLocation()
    test.assertEquals(loc.x, -1)
    test.assertEquals(loc.y, 4)
end)

-- moveToSwapZ
test.addTest("moveToSwapZ: from incomingZ to swapZ", function()
    local floor = 0
    local incomingZ = highwayNav.getFloorIncomingZ(floor)
    local swapZ = highwayNav.getFloorSwapZ(floor)

    settings.set("location", { x = 1, y = 1, z = incomingZ })
    settings.save()


    local before = settings.get("location").z
    highwayNav.moveToSwapZ()
    local after = settings.get("location").z

    test.assertEquals(after, before - (incomingZ - swapZ))
end)

test.addTest("moveToSwapZ: already at swapZ", function()
    local floor = 0
    local swapZ = highwayNav.getFloorSwapZ(floor)

    settings.set("location", { x = 1, y = 1, z = swapZ })
    settings.save()

    local before = settings.get("location").z
    highwayNav.moveToSwapZ()
    local after = settings.get("location").z

    test.assertEquals(after, before)
end)

test.addTest("moveToSwapZ: below swapZ (should not move)", function()
    local floor = 0
    local swapZ = highwayNav.getFloorSwapZ(floor)

    settings.set("location", { x = 1, y = 1, z = swapZ - 1 })
    settings.save()

    local before = settings.get("location").z
    highwayNav.moveToSwapZ()
    local after = settings.get("location").z

    test.assertEquals(after, before)
end)

test.run()