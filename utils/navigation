local inventory = require("/utils/inventory")

local navigation = {}

function navigation.getCoords(row, col)

    local rowToMove = math.abs(row) - 1
    local x = rowToMove * (config.roomSize + config.streetWidth)
    local colToMove = math.abs(col) - 1
    local y = colToMove * (config.roomSize + config.streetWidth)
 
    x = x + math.floor(config.streetWidth / 2) + math.ceil(config.roomSize / 2)
    y = y + math.floor(config.streetWidth / 2)
 
    if row == 0 then x = 0 end
    if col == 0 then y = 0 end
 
    if row < 0 then x = -1 * x end
    if col < 0 then y = -1 * y end
 
    return {
        x = x,
        y = 0,
        z = z + 1 --for recalibration block
    }
end

function navigation.getCurrentLocation()

end

function navigation.isInRoom()

end

function navigation.goHome()
    
    local x,y,z

    inventory.runOnSlot(15, function()
        turtle.equipLeft()
        x,y,z = gps.locate()
        turtle.equipLeft()
    end)

end

return navigation