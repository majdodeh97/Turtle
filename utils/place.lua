local inventory = require("/utils/inventory")
local log = require("/utils/log")

local place = {}

function place.slot(placeFn, slot)
    return inventory.runOnSlot(placeFn, slot)
end

function place.item(placeFn, itemName)
    return inventory.runOnItem(placeFn, itemName)
end

function place.itemMatch(placeFn, matcherFn)
    return inventory.runOnItemMatch(placeFn, matcherFn)
end

return place