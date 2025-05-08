local inventory = {}

function inventory.runOnSlot(slot, action)
    selectedSlot = turtle.getSelectedSlot()
    turtle.select(slot)
    action()
    turtle.select(selectedSlot)
end

function inventory.runOnItem(itemName, action)
    return inventory.runOnItemMatch(function(name)
        return name == itemName
    end, action)
end

function inventory.runOnItemMatch(matcherFn, action)
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

function inventory.foreach(fn)
    inventory.foreachInSlots(1, 16, fn)
end

function inventory.foreachInSlots(startSlot, endSlot, fn)
    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        fn(i, itemDetail)
    end
end

function inventory.first(fn)
    inventory.firstInSlots(1, 16, fn)
end

function inventory.firstInSlots(startSlot, endSlot, fn)
    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        if fn(i, itemDetail) then
            return i, itemDetail
        end
    end
    return nil, nil
end

function inventory.all(fn)
    inventory.allInSlots(1, 16, fn)
end

function inventory.allInSlots(startSlot, endSlot, fn)
    for i = startSlot, endSlot do
        local itemDetail = turtle.getItemDetail(i)
        if not fn(i, itemDetail) then
            return false
        end
    end
    return true
end

function inventory.isFull()
    return inventory.all(function(i, itemDetail)
        return itemDetail
    end)
end

return inventory