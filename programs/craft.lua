local tArgs = { ... }
local command = tArgs[1]

local isSetMode = (command == "set")
local batchSize = isSetMode and 1 or tonumber(command) or 1

local recipeFile = ".recipe"

local suckFn = turtle.suck;
local dropFn = turtle.drop;

-- Save recipe to file
local function saveRecipe(recipe)
    local file = fs.open(recipeFile, "w")
    for i = 1, 16 do
        file.writeLine(recipe[i] or "")
    end
    file.close()
end

-- Load recipe from file
local function loadRecipe()
    if not fs.exists(recipeFile) then
        return nil, "Recipe file not found. Please run: craft set"
    end
    local file = fs.open(recipeFile, "r")
    local recipe = {}
    for i = 1, 16 do
        local line = file.readLine()
        recipe[i] = (line ~= "" and line) or nil
    end
    file.close()
    return recipe
end

-- Read recipe from inventory
local function getRecipeFromInventory()
    local recipe = {}
    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        recipe[i] = item and item.name or nil
    end
    return recipe
end

-- Clear all inventory
local function clearInventory()
    for i = 1, 16 do
        turtle.select(i)
        dropFn()
    end
end

-- Refill inventory according to recipe
local function refillInventory(recipe)
    for i = 1, 16 do
        if recipe[i] then
            turtle.select(i)
            local current = turtle.getItemDetail(i)
            local count = ((current and current.name == recipe[i]) and current.count) or 0

            while count < batchSize do
                if not suckFn(batchSize - count) then
                    return false
                end
                current = turtle.getItemDetail(i)
                if not current then return false end
                if current.name ~= recipe[i] then
                    dropFn()
                    print("Wrong item pulled.")
                    return false
                end
                count = current.count
            end
        end
    end
    return true
end

-- Check if inventory is ready to craft
local function isInventoryReady(recipe)
    for i = 1, 16 do
        local expected = recipe[i]
        local actual = turtle.getItemDetail(i)
        if expected then
            if not actual or actual.name ~= expected or actual.count < batchSize then
                return false
            end
        end
    end
    return true
end

-- If setting recipe: store and exit
if command == "set" then
    local newRecipe = getRecipeFromInventory()
    saveRecipe(newRecipe)
    print("Recipe saved successfully.")
    return
end

-- Otherwise: run crafting loop
print("Batch size set to:", batchSize)
local recipe, err = loadRecipe()
if not recipe then
    print("Error: " .. err)
    return
end

print("Recipe loaded. Starting crafting loop...")

while true do
    if isInventoryReady(recipe) or refillInventory(recipe) then
        turtle.select(1)
        if turtle.craft() then
            clearInventory()
        else
            print("Crafting failed.")
            return
        end
    else
        print("Waiting for materials...")
        sleep(2)
    end
end
