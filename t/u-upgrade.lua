local ver311 = ide.wxver >= "3.1.1"
ok(ver311 and wx.wxFileName().ShouldFollowLink or nil, "Included wxlua/wxwidgets includes wxFileName().ShouldFollowLink.")

local function waitToComplete(bid)
  while wx.wxProcess.Exists(bid) do
    wx.wxSafeYield()
    wx.wxWakeUpIdle()
    wx.wxMilliSleep(100)
  end
  wx.wxWakeUpIdle() -- wake up one more time to process messages (if any)
end

local modules = {
  ["require([[lfs]])._VERSION"] = "LuaFileSystem 1.6.3",
  ["require([[lpeg]]).version()"] = "1.0.0",
  ["require([[ssl]])._VERSION"] = "0.6",
}
local env = os.getenv('LUA_CPATH') or ""
for _, luaver in ipairs({"", "5.2", "5.3"}) do
  local clibs = ide.osclibs:gsub("clibs", "clibs"..luaver:gsub("%.",""))
  wx.wxSetEnv('LUA_CPATH', clibs..";"..env)

  for mod, modver in pairs(modules) do
    local check = function(s)
      is(s:gsub("%s+$",""), modver,
        ("Checking module version (%s) with Lua%s."):format(mod:match("%[%[(%w+)%]%]"), luaver))
    end
    local cmd = ('"%s" -e "print(%s)"'):format(ide.interpreters.luadeb:fexepath(luaver), mod)
    local pid, err = ide:ExecuteCommand(cmd, "", check)
    if pid then waitToComplete(pid) end
    if not pid then check(err) end -- show the error instead of the expected value
  end

  wx.wxSetEnv('LUA_CPATH', env)
end

is(jit.version, "LuaJIT 2.0.4", "Using LuaJIT with the expected version.")
