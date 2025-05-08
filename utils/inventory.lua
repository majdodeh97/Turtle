local log = require("/utils/log")

local inventory = {}

function inventory.runOnSlot(action, slot)
    selectedSlot = turtle.getSelectedSlot()
    turtle.select(slot)
    action()
    turtle.select(selectedSlot)
end

function inventory.runOnItem(action, itemName)
    return inventory.runOnItemMatch(action, function(name)
        return name == itemName
    end)
end

function inventory.runOnItemMatch(action, matcherFn)
    local selectedSlot = turtle.getSelectedSlot()

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)
        if item and matcherFn(item.name) then
            turtle.select(slot)
            action()
            turtle.select(selectedSlot)
            return true
        end
    end

    turtle.select(selectedSlot)
    return false
end

function inventory.foreach(fn, startSlot, endSlot)
    if startSlot and not endSlot then
        log.error("Only startSlot was defined in inventory.foreach")
    end
    startSlot = startSlot or 1
    endSlot = endSlot or 16

    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        fn(i, itemDetail)
    end
end

function inventory.first(fn, startSlot, endSlot)
    if startSlot and not endSlot then
        log.error("Only startSlot was defined in inventory.first")
    end
    startSlot = startSlot or 1
    endSlot = endSlot or 16

    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        if fn(i, itemDetail) then
            return i, itemDetail
        end
    end
    return nil, nil
end

function inventory.all(fn, startSlot, endSlot)
    if startSlot and not endSlot then
        log.error("Only startSlot was defined in inventory.all")
    end
    startSlot = startSlot or 1
    endSlot = endSlot or 16

    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        if not fn(i, itemDetail) then
            return false
        end
    end
    return true
end

function inventory.dropAll(dropFn, startSlot, endSlot)
    if startSlot and not endSlot then
        endSlot = startSlot -- Treat single slot as a range of one
    end
    startSlot = startSlot or 1
    endSlot = endSlot or 16

    inventory.foreach(function(i, itemDetail)
        inventory.runOnSlot(dropFn, i)
    end, startSlot, endSlot)
end

function inventory.isFull()
    return inventory.all(function(i, itemDetail)
        return itemDetail ~= nil
    end)
end

return inventory