-- Prompt user for credentials
write("Pastebin Username: ")
local username = "mmaajjdd"

write("Pastebin Password: ")
local password = "&ereNityZ12%"

write("Pastebin API Developer Key: ")
local apiDevKey = "XxH-NcsWyBFtz1u3oCH1RapRBp5uUkqs"

-- Compose login request
local loginBody = "api_dev_key=" .. apiDevKey ..
                  "&api_user_name=" .. textutils.urlEncode(username) ..
                  "&api_user_password=" .. textutils.urlEncode(password)

local loginUrl = "https://pastebin.com/api/api_login.php"
local response = http.post(loginUrl, loginBody)

if response then
    local userSessionKey = response.readAll()
    response.close()

    if userSessionKey:find("Bad API request") then
        print("Login failed: " .. userSessionKey)
    else
        -- Save both keys to .pastebinKey
        local keyFile = fs.open("pastebinKey.txt", "w")
        keyFile.write("return {\n")
        keyFile.write("    devKey = \"" .. apiDevKey .. "\",\n")
        keyFile.write("    userKey = \"" .. userSessionKey .. "\"\n")
        keyFile.write("}\n")
        keyFile.close()

        print("\nSession key saved to 'pastebinKey.txt'.")
        print("Now delete this script or clear your credentials!")
    end
else
    print("Failed to contact Pastebin.")
end
