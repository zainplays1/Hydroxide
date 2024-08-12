local ScriptScanner = {}
local LocalScript = import("objects/LocalScript")

local requiredMethods = {
    ["getGc"] = true,
    ["getSenv"] = true,
    ["getProtos"] = true,
    ["getConstants"] = true,
    ["getScriptClosure"] = true,
    ["isXClosure"] = true
}

local function scan(query)
    local scripts = {}
    query = query or ""

    for _i, v in pairs(getGc()) do
        if type(v) == "function" and not isXClosure(v) then
            local success, script = pcall(function()
                local s = rawget(getfenv(v), "script")
                if typeof(s) == "Instance" and s:IsA("LocalScript") then
                    -- Attempt a basic operation to filter out problematic scripts
                    return getScriptClosure(s), s
                end
            end)

            if success and script then
                local closure, scriptInstance = script[1], script[2]
                local envSuccess = pcall(function()
                    return getsenv(scriptInstance)
                end)

                if envSuccess then
                    scripts[scriptInstance] = LocalScript.new(scriptInstance)
                end
            end
        end
    end

    return scripts
end



ScriptScanner.RequiredMethods = requiredMethods
ScriptScanner.Scan = scan
return ScriptScanner
