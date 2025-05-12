local test = require("/utils/test")
local highwayNav = require("/utils/highwayNav")
local move = require("/utils/move")
local location = require("/utils/location")

-- getFloor(z) tests
test.addTest("getFloor z = 0 -> floor 0", function()
    test.assertEquals(location.getFloor(0), 0)
end)

test.addTest("getFloor z = 9 -> floor 0", function()
    test.assertEquals(location.getFloor(9), 0)
end)

test.addTest("getFloor z = 10 -> floor 1", function()
    test.assertEquals(location.getFloor(10), 1)
end)

test.addTest("getFloor z = 17 -> floor 1", function()
    test.assertEquals(location.getFloor(17), 1)
end)

test.addTest("getFloor z = 44 -> floor 3", function()
    test.assertEquals(location.getFloor(44), 4)
end)

test.addTest("getFloor z = 45 -> floor 4", function()
    test.assertEquals(location.getFloor(45), 4)
end)

test.addTest("getFloor z = 80 -> floor 6", function()
    test.assertEquals(location.getFloor(80), 6)
end)

test.addTest("getFloor z = 119 -> floor 7", function()
    test.assertEquals(location.getFloor(119), 7)
end)

test.addTest("getFloor z = 120 -> floor 8", function()
    test.assertEquals(location.getFloor(120), 8)
end)

test.addTest("getFloor z = -1 -> floor 0", function()
    test.assertEquals(location.getFloor(-1), -1)
end)

test.addTest("getFloor z = -10 -> floor -1", function()
    test.assertEquals(location.getFloor(-10), -1)
end)

test.addTest("getFloor z = -11 -> floor -2", function()
    test.assertEquals(location.getFloor(-11), -2)
end)

test.addTest("getFloor z = -21 -> floor -3", function()
    test.assertEquals(location.getFloor(-21), -3)
end)

test.addTest("getFloor z = -79 -> floor -6", function()
    test.assertEquals(location.getFloor(-79), -6)
end)

test.addTest("getFloor z = -80 -> floor -6", function()
    test.assertEquals(location.getFloor(-80), -6)
end)

test.addTest("getFloor z = -81 -> floor -7", function()
    test.assertEquals(location.getFloor(-81), -7)
end)

-- getFloorBaseZ(floor) tests
test.addTest("getFloorBaseZ floor 0 -> z = 0", function()
    test.assertEquals(location.getFloorBaseZ(0), 0)
end)

test.addTest("getFloorBaseZ floor 1 -> z = 10", function()
    test.assertEquals(location.getFloorBaseZ(1), 10)
end)

test.addTest("getFloorBaseZ floor 2 -> z = 20", function()
    test.assertEquals(location.getFloorBaseZ(2), 20)
end)

test.addTest("getFloorBaseZ floor 5 -> z = 60", function()
    test.assertEquals(location.getFloorBaseZ(5), 60)
end)

test.addTest("getFloorBaseZ floor 6 -> z = 80", function()
    test.assertEquals(location.getFloorBaseZ(6), 80)
end)

test.addTest("getFloorBaseZ floor 7 -> z = 100", function()
    test.assertEquals(location.getFloorBaseZ(7), 100)
end)

test.addTest("getFloorBaseZ floor 8 -> z = 120", function()
    test.assertEquals(location.getFloorBaseZ(8), 120)
end)

test.addTest("getFloorBaseZ floor -1 -> z = -10", function()
    test.assertEquals(location.getFloorBaseZ(-1), -10)
end)

test.addTest("getFloorBaseZ floor -2 -> z = -20", function()
    test.assertEquals(location.getFloorBaseZ(-2), -20)
end)

test.addTest("getFloorBaseZ floor -3 -> z = -30", function()
    test.assertEquals(location.getFloorBaseZ(-3), -30)
end)

test.addTest("getFloorBaseZ floor -5 -> z = -60", function()
    test.assertEquals(location.getFloorBaseZ(-5), -60)
end)

test.addTest("getFloorBaseZ floor -6 -> z = -80", function()
    test.assertEquals(location.getFloorBaseZ(-6), -80)
end)

local INCOMING_Z = 3
local OUTGOING_Z = 2
local SWAP_Z = 0

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

test.run()