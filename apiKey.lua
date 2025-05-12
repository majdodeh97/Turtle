-- Pastebin Credentials (fill in before use)
local apiDevKey = "XxH-NcsWyBFtz1u3oCH1RapRBp5uUkqs"
local userSessionKey = "38cbf959941a686e95bea5cb703102f2"
local pasteId = "YL94Rasd"

-- Room Info to update
local floor = 0
local row = "east"
local col = "north"
local jobScript = "/jobs/farmer.lua"
local jobStartPos = { x = -10, y = 65, z = 20 }

-- Function to fetch current floor plan JSON from Pastebin
local function downloadFloorPlan(pasteId)
    local url = "https://pastebin.com/raw/" .. pasteId
    local res = http.get(url)
    if not res then return nil, "Failed to fetch paste" end

    local content = res.readAll()
    res.close()

    local data = textutils.unserializeJSON(content)
    if not data then return nil, "Failed to parse JSON" end

    if not data.rooms then
        data.rooms = {}
    end

    return data
end

-- Function to update or insert a room in the JSON
local function updateRoom(data, floor, row, col, jobScript, jobStartPos)
    for _, room in ipairs(data.rooms) do
        if room.floor == floor and room.row == row and room.col == col then
            room.jobScript = jobScript
            room.jobStartPos = jobStartPos
            return true
        end
    end

    table.insert(data.rooms, {
        floor = floor,
        row = row,
        col = col,
        jobScript = jobScript,
        jobStartPos = jobStartPos
    })

    return false
end

-- Function to upload updated JSON back to Pastebin
local function uploadToPastebin(apiDevKey, userSessionKey, pasteId, updatedJson)
    local url = "https://pastebin.com/api/api_post.php"
    local body = "api_dev_key=" .. apiDevKey ..
                 "&api_user_key=" .. userSessionKey ..
                 "&api_option=edit" ..
                 "&api_paste_code=" .. pasteId ..
                 "&api_paste_data=" .. textutils.urlEncode(updatedJson)

    local res = http.post(url, body, {
        ["Content-Type"] = "application/x-www-form-urlencoded"
    })

    if not res then return false, "Failed to reach Pastebin" end

    local result = res.readAll()
    res.close()

    if result:find("Bad API request") then
        return false, result
    else
        return true, result
    end
end

-- Main execution logic
local data, err = downloadFloorPlan(pasteId)
if not data then
    print("Error downloading floor plan: " .. err)
    return
end

local wasUpdated = updateRoom(data, floor, row, col, jobScript, jobStartPos)

local updatedJson = textutils.serializeJSON(data)
local success, result = uploadToPastebin(apiDevKey, userSessionKey, pasteId, updatedJson)

if success then
    if wasUpdated then
        print("Room updated successfully.")
    else
        print("Room added successfully.")
    end
else
    print("Error uploading to Pastebin: " .. result)
end
