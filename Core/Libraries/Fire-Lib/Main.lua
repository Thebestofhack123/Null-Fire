local function getGlobalTable()
    return typeof(getgenv) == "function" and typeof(getgenv()) == "table" and getgenv() or _G
end

local t = getGlobalTable()

if t._FIRELIB then
    return t._FIRELIB
end

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Fire-Hub/main/Core/Libraries/Fire-Lib/Library.lua"))()
if not lib and not t._FIRELIB then error("Fatal error while loading UI library: Loadstring did not return anything!") end
lib = lib or t._FIRELIB

t._FIRELIB = t._FIRELIB or lib
if t.FireHubLoaded and not t.EAGLEEEEE then
    t.EAGLEEEEE = true
    local f = loadstring(game:HttpGet("https://raw.githubusercontent.com/InfernusScripts/Fire-Hub/main/Core/Libraries/Fire-Lib/Fire-Hub%20Only%20page.lua"))
    coroutine.wrap(function()
        repeat task.wait() until t._FHCW
        f()
    end)()
    local mw = lib.MakeWindow
    lib.MakeWindow = function(...)
        local window = mw(...)
        getGlobalTable()._FHCW = window
        return window
    end
end

return lib
