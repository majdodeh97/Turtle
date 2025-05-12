local inventory = require("/utils/inventory")

---@class place
local place = {}

local function placeSlotInternal(placeFn, slot)
    return inventory.runOnSlot(placeFn, slot)
end

function place.slot(slot)
    return placeSlotInternal(turtle.place, slot)
end

function place.slotUp(slot)
    return placeSlotInternal(turtle.placeUp, slot)
end

function place.slotDown(slot)
    return placeSlotInternal(turtle.placeDown, slot)
end

local function placeItemInternal(placeFn, itemName)
    return inventory.runOnItem(placeFn, itemName)
end

function place.item(itemName)
    return placeItemInternal(turtle.place, itemName)
end

function place.itemUp(itemName)
    return placeItemInternal(turtle.placeUp, itemName)
end

function place.itemDown(itemName)
    return placeItemInternal(turtle.placeDown, itemName)
end

local function placeItemMatchInternal(placeFn, matcherFn)
    return inventory.runOnItemMatch(placeFn, matcherFn)
end

function place.itemMatch(matcherFn)
    return placeItemMatchInternal(turtle.place, matcherFn)
end

function place.itemMatchUp(matcherFn)
    return placeItemMatchInternal(turtle.placeUp, matcherFn)
end

function place.itemMatchDown(matcherFn)
    return placeItemMatchInternal(turtle.placeDown, matcherFn)
end

return place