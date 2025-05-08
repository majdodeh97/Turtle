local log = require("/utils/log")

local inventory = {}

function inventory.runOnSlot(action, slot)
    selectedSlot = turtle.getSelectedSlot()
    turtle.select(slot)
    local r1, r2 = action()
    turtle.select(selectedSlot)
    return r1, r2
end

function inventory.runOnItem(action, itemName)
    return inventory.runOnItemMatch(action, function(name)
        return name == itemName
    end)
end

function inventory.runOnItemMatch(action, matcherFn)
    for i = 1, 16 do
        local itemDetail = turtle.getItemDetail(i)
        if itemDetail and matcherFn(itemDetail.name) then
            return true, inventory.runOnSlot(action, i)
        end
    end

    return false, nil, nil
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

    local anySuccess = false
    inventory.foreach(function(i, itemDetail)
        if(inventory.runOnSlot(dropFn, i)) then
            anySuccess = true
        end
    end, startSlot, endSlot)

    return anySuccess
end

function inventory.isFull()
    return inventory.all(function(i, itemDetail)
        return itemDetail ~= nil
    end)
end

return inventory