local log = require("/utils/log")

---@class inventory
local inventory = {}

function inventory.runOnSlot(action, slot)
    local selectedSlot = turtle.getSelectedSlot()
    turtle.select(slot)
    local r1, r2 = action()
    turtle.select(selectedSlot)
    return r1, r2
end

function inventory.runOnItem(action, itemName)
    return inventory.runOnItemMatch(action, function(itemDetail)
        return itemDetail and itemName == itemDetail.name
    end)
end

function inventory.runOnItemMatch(action, matcherFn)
    for i = 1, 16 do
        local itemDetail = turtle.getItemDetail(i)
        if matcherFn(itemDetail) then
            return inventory.runOnSlot(action, i)
        end
    end

    return false, "No matching item found"
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



local function dropAllInternal(dropFn, startSlot, endSlot)
    dropFn = dropFn or turtle.drop
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

function inventory.dropAll(startSlot, endSlot)
    return dropAllInternal(turtle.drop, startSlot, endSlot)
end

function inventory.dropAllUp(startSlot, endSlot)
    return dropAllInternal(turtle.dropUp, startSlot, endSlot)
end

function inventory.dropAllDown(startSlot, endSlot)
    return dropAllInternal(turtle.dropDown, startSlot, endSlot)
end

local function dropInternal(dropFn, amount, slot)
    dropFn = dropFn or turtle.drop
    slot = slot or turtle.getSelectedSlot()
    amount = amount or turtle.getItemCount(slot)

    return inventory.runOnSlot(function()
        return dropFn(amount)
    end, slot)
end

function inventory.drop(amount, slot)
    return dropInternal(turtle.drop, amount, slot)
end

function inventory.dropUp(amount, slot)
    return dropInternal(turtle.dropUp, amount, slot)
end

function inventory.dropDown(amount, slot)
    return dropInternal(turtle.dropDown, amount, slot)
end

local function safeDropInternal(dropFn, amount, slot)
    dropFn = dropFn or inventory.drop
    slot = slot or turtle.getSelectedSlot()
    amount = amount or turtle.getItemCount(slot)

    return inventory.runOnSlot(function()
        local dropped = 0

        while dropped < amount do
            local count = turtle.getItemCount(slot)
            if count == 0 then
                log.error("No items left in slot " .. slot)
            end

            local toDrop = math.min(amount - dropped, count) -- Cant be 0
            dropFn(toDrop)

            local countAfter = turtle.getItemCount(slot)

            local actuallyDropped = count - countAfter

            dropped = dropped + actuallyDropped
        end

        return true
    end, slot)
end

function inventory.safeDrop(amount, slot)
    return safeDropInternal(inventory.drop, amount, slot)
end

function inventory.safeDropUp(amount, slot)
    return safeDropInternal(inventory.dropUp, amount, slot)
end

function inventory.safeDropDown(amount, slot)
    return safeDropInternal(inventory.dropDown, amount, slot)
end

function inventory.isFull()
    return inventory.all(function(i, itemDetail)
        return itemDetail ~= nil
    end)
end

function inventory.isEmpty()
    return inventory.all(function(i, itemDetail)
        return itemDetail == nil
    end)
end

function inventory.hasSpace(startSlot, endSlot)
    if startSlot and not endSlot then
        log.error("Only startSlot was defined in inventory.all")
    end
    startSlot = startSlot or 1
    endSlot = endSlot or 16

    local emptySlot = inventory.first(function (i, itemDetail)
        return itemDetail == nil
    end, startSlot, endSlot)

    return emptySlot ~= nil
end

return inventory