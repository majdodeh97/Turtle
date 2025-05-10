local test = {}

test.tests = {}

function test.assertEquals(actual, expected, message)
    if actual ~= expected then
        error("[FAIL] " .. (message or "") .. "\nExpected: " .. tostring(expected) .. "\nActual:   " .. tostring(actual), 2)
    else
        print("[PASS] " .. (message or ""))
    end
end

function test.addTest(name, fn)
    table.insert(test.tests, { name = name, fn = fn })
end

function test.run()
    print("🧪 Running " .. #test.tests .. " test(s)...\n")
    for i, t in ipairs(test.tests) do
        local success, err = pcall(t.fn)
        if success then
            print("✔ " .. t.name)
        else
            print("✖ " .. t.name .. "\n   ↳ " .. err)
        end
    end
end

return test
