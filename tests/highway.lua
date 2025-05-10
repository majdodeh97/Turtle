local test = require("/utils/test")
local highway = require("/utils/highway")

-- getFloor(z) tests
test.addTest("getFloor z = 0 -> floor 0", function()
    test.assertEquals(highway.getFloor(0), 0, "Z=0 should map to floor 0")
end)

test.addTest("getFloor z = 9 -> floor 0", function()
    test.assertEquals(highway.getFloor(9), 0)
end)

test.addTest("getFloor z = 10 -> floor 1", function()
    test.assertEquals(highway.getFloor(10), 1)
end)

test.addTest("getFloor z = 80 -> floor 6", function()
    test.assertEquals(highway.getFloor(80), 6)
end)

test.addTest("getFloor z = -10 -> floor -1", function()
    test.assertEquals(highway.getFloor(-10), -1)
end)

test.addTest("getFloor z = -80 -> floor -6", function()
    test.assertEquals(highway.getFloor(-80), -6)
end)

-- getFloorBaseZ(floor) tests
test.addTest("getFloorBaseZ floor 0 -> z = 0", function()
    test.assertEquals(highway.getFloorBaseZ(0), 0)
end)

test.addTest("getFloorBaseZ floor 1 -> z = 10", function()
    test.assertEquals(highway.getFloorBaseZ(1), 10)
end)

test.addTest("getFloorBaseZ floor 6 -> z = 80", function()
    test.assertEquals(highway.getFloorBaseZ(6), 80)
end)

test.addTest("getFloorBaseZ floor -1 -> z = -10", function()
    test.assertEquals(highway.getFloorBaseZ(-1), -10)
end)

test.addTest("getFloorBaseZ floor -6 -> z = -80", function()
    test.assertEquals(highway.getFloorBaseZ(-6), -80)
end)

test.run()