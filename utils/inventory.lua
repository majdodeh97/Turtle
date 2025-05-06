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

return inventory