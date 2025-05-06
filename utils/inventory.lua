local inventory = {}

function inventory.runOnSlot(slot, action)
    selectedSlot = turtle.getSelectedSlot()
    turtle.select(slot)
    action()
    turtle.select(selectedSlot)
end

return inventory