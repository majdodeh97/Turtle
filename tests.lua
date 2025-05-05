for _, name in ipairs(settings.getNames()) do
    print(name, "=", textutils.serialize(settings.get(name)))
end