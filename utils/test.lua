local test = {}

test.tests = {}

function test.assertEquals(actual, expected, message)
    if actual ~= expected then
        error("[FAIL] " .. (message or "") .. "\nExpected: " .. tostring(expected) .. "\nActual:   " .. tostring(actual), 2)
    end
end

function test.addTest(name, fn)
    table.insert(test.tests, { name = name, fn = fn })
end

function test.run(interrupt)
    print("Running " .. #test.tests .. " test(s)...\n")
    for i, t in ipairs(test.tests) do
        local success, err = pcall(t.fn)
        if not success then
            print("[FAIL] " .. t.name .. "\n   > " .. err)
        elseif interrupt then
            print("[PASS] " .. t.name)
        end

        if(interrupt) then os.pullEvent("key") end
    end

    test.tests = {}
end

return test
