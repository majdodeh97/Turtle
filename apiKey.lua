-- 🎯 USER CONFIGURATION — Fill in these:
local apiDevKey = "XxH-NcsWyBFtz1u3oCH1RapRBp5uUkqs"
local username = "your_pastebin_username"
local password = "your_pastebin_password"
local pasteId = "YL94Rasd"

-- 🎯 The room info to add or update:
local floor = 0
local row = "east"
local col = "north"
local jobScript = "/jobs/farmer.lua"
local jobStartPos = { x = -10, y = 65, z = 20 }

-- 🔐 Step 1: Get a user session key from Pastebin
local loginUrl = "https://pastebin.com/api/api_login.php"
local loginBody = "api_dev_key=" .. apiDevKey ..
                  "&api_user_name=" .. textutils.urlEncode(username) ..
                  "&api_user_password=" .. textutils.urlEncode(password)

local loginRes = http.post(loginUrl, loginBody)
if not loginRes then
    print("Failed to contact Pastebin login API.")
    return
end

local userSessionKey = loginRes.readAll()
loginRes.close()

if userSessionKey:find("Bad API request") then
    print("Login failed: " .. userSessionKey)
    return
end

-- ✅ Step 2: Download current JSON
local rawUrl = "https://pastebin.com/raw/" .. pasteId
local res = http.get(rawUrl)
if not res then
    print("Failed to download existing floor plan.")
    return
end

local content = res.readAll()
res.close()

local data = textutils.unserializeJSON(content)
if not data then
    print("Failed to parse downloaded JSON.")
    return
end

-- 🛠️ Step 3: Update or add the room info
if not data.rooms then
    data.rooms = {}
end

local found = false
for _, room in ipairs(data.rooms) do
    if room.floor == floor and room.row == row and room.col == col then
        room.jobScript = jobScript
        room.jobStartPos = jobStartPos
        found = true
        break
    end
end

if not found then
    table.insert(data.rooms, {
        floor = floor,
        row = row,
        col = col,
        jobScript = jobScript,
        jobStartPos = jobStartPos
    })
end

-- 🧼 Step 4: Serialize updated JSON
local newJson = textutils.serializeJSON(data)

-- 🔁 Step 5: Upload back to Pastebin
local editUrl = "https://pastebin.com/api/api_post.php"
local postBody = "api_dev_key=" .. apiDevKey ..
                 "&api_user_key=" .. userSessionKey ..
                 "&api_option=edit" ..
                 "&api_paste_code=" .. pasteId ..
                 "&api_paste_data=" .. textutils.urlEncode(newJson)

local editRes = http.post(editUrl, postBody, {
    ["Content-Type"] = "application/x-www-form-urlencoded"
})

if not editRes then
    print("Failed to update the paste.")
    return
end

local editResult = editRes.readAll()
editRes.close()

if editResult:find("Bad API request") then
    print("Pastebin error: " .. editResult)
else
    print("Paste updated successfully!")
end
