-- Frankenstein compatibility layer (CE 7.5 exe + CE 7.7.3 support scripts)
-- Defines CE 7.6/7.7 Lua functions missing from the 7.5 build. Never overrides an existing function.

-- 1: Case-alias functions
if checkSynchronize and CheckSynchronize == nil then CheckSynchronize = checkSynchronize end
if createMenuItem and CreateMenuItem == nil then CreateMenuItem = createMenuItem end
if inputQuery and InputQuery == nil then InputQuery = inputQuery end
if messageDialog and MessageDialog == nil then MessageDialog = messageDialog end

-- 2: InjectLibrary
if InjectLibrary == nil then
  function InjectLibrary(path, skipsymbols)
    local ok, result = pcall(injectLibrary, path, skipsymbols)
    if not ok then return false, tostring(result) end
    if result == false or result == nil then return false, 'injectLibrary failed' end
    return true
  end
end

-- 3: printf
if printf == nil then
  function printf(fmt, ...)
    print(string.format(fmt, ...))
  end
end

-- 4: getSystemArchitecture
if getSystemArchitecture == nil then
  function getSystemArchitecture()
    if cheatEngineIs64Bit() then return 1 else return 0 end
  end
end

-- 5: isAdmin
if isAdmin == nil then
  function isAdmin()
    local ok, r = pcall(function()
      local a = getAddressSafe('shell32.IsUserAnAdmin', true)
      if not a then return nil end
      return executeCodeLocal(a) ~= 0
    end)
    if ok and r ~= nil then return r end
    return true
  end
end

-- 6: dbk_initialized / dbvm_initialized
local _fk_dbk = false
local _fk_dbvm = false

if dbk_initialize and dbk_initialized == nil then
  local orig_dbk_initialize = dbk_initialize
  function dbk_initialize(...)
    local r1, r2 = orig_dbk_initialize(...)
    if r1 then _fk_dbk = true end
    return r1, r2
  end
end

if dbvm_initialize and dbvm_initialized == nil then
  local orig_dbvm_initialize = dbvm_initialize
  function dbvm_initialize(...)
    local r1, r2 = orig_dbvm_initialize(...)
    if r1 then _fk_dbvm = true end
    return r1, r2
  end
end

if dbk_initialized == nil then
  function dbk_initialized()
    return _fk_dbk
  end
end

if dbvm_initialized == nil then
  function dbvm_initialized()
    return _fk_dbvm
  end
end

-- 7: getTimeStamp
if getTimeStamp == nil then
  function getTimeStamp()
    return os.date('%H:%M:%S') .. string.format('.%03d', getTickCount() % 1000)
  end
end

-- 8: getCurrentThreadObject
if getCurrentThreadObject == nil then
  local _fk_mainthread = { Name = 'Main Thread' }
  function getCurrentThreadObject()
    if inMainThread() then return _fk_mainthread else return nil end
  end
end

-- 9: getProcessAge
if getProcessAge == nil then
  function getProcessAge()
    return nil
  end
end

-- 10: getMemoryRegionInfo / getMemoryProtection
if getMemoryRegionInfo == nil then
  function getMemoryRegionInfo(address)
    local ok, result = pcall(function()
      for _, region in ipairs(enumMemoryRegions()) do
        if address >= region.BaseAddress and address < region.BaseAddress + region.RegionSize then
          return region
        end
      end
      return nil
    end)
    if ok then return result else return nil end
  end
end

if getMemoryProtection == nil then
  function getMemoryProtection(address)
    local region = getMemoryRegionInfo(address)
    if not region or region.Protect == 0 or (region.Protect & 0x01) ~= 0 then
      return {r=false, w=false, x=false}
    end
    local p = region.Protect & 0xFF
    return {r = true, w = (p & (0x04 | 0x08 | 0x40 | 0x80)) ~= 0, x = (p & 0xF0) ~= 0}
  end
end

-- 11: isPaused
local _fk_paused = false

if pause and isPaused == nil then
  local orig_pause = pause
  function pause(...)
    local r1, r2 = orig_pause(...)
    _fk_paused = true
    return r1, r2
  end
end

if unpause and isPaused == nil then
  local orig_unpause = unpause
  function unpause(...)
    local r1, r2 = orig_unpause(...)
    _fk_paused = false
    return r1, r2
  end
end

if isPaused == nil then
  function isPaused()
    return _fk_paused
  end
end

-- 12: loadNewSymbols
if loadNewSymbols == nil then
  function loadNewSymbols()
    reinitializeSymbolhandler(false)
  end
end

-- 13: mono_log
if mono_log == nil then
  function mono_log(...)
    if type(monolog) == 'function' then
      monolog(...)
    end
  end
end

-- 14: forEachAndFutureForm
if forEachAndFutureForm == nil then
  function forEachAndFutureForm(classname, func)
    for i=0,getFormCount()-1 do
      local f = getForm(i)
      if f.ClassName==classname then func(f) end
    end
    registerFormAddNotification(function(f)
      if classname==f.ClassName then
        f.registerFirstShowCallback(function() func(f) end)
      end
    end)
  end
end

-- 15: Settings options
local _fk_settingdefs = {}

local function _fk_settings()
  return getSettings('Frankenstein\\Options')
end

if createSettingsOption == nil then
  function createSettingsOption(name, description, ctype, category, unused, default)
    _fk_settingdefs[name] = {description=description, type=ctype, category=category, default=default}
  end
end

if getSettingsOption == nil then
  function getSettingsOption(name)
    local ok, s = pcall(function()
      local settings = _fk_settings().Value[name]
      if settings == nil or settings == '' then
        local def = _fk_settingdefs[name]
        if def then
          if def.type == 0 then
            return def.default == nil and false or def.default
          else
            return def.default
          end
        else
          return nil
        end
      else
        local def = _fk_settingdefs[name]
        if def and def.type == 0 then
          return settings == 'true'
        elseif tonumber(settings) ~= nil and def and def.type ~= 0 then
          return tonumber(settings)
        else
          return settings
        end
      end
    end)
    if ok then return s else
      local def = _fk_settingdefs[name]
      if def then
        if def.type == 0 then
          return def.default == nil and false or def.default
        else
          return def.default
        end
      else
        return nil
      end
    end
  end
end

if setSettingsOption == nil then
  function setSettingsOption(name, value)
    local ok = pcall(function()
      _fk_settings().Value[name] = tostring(value)
    end)
    if not ok then return end
  end
end

-- 16: Table options
local _fk_tabledefs = {}

if createTableOption == nil then
  function createTableOption(name, description, ctype)
    _fk_tabledefs[name] = {description=description, type=ctype}
  end
end

local function _fk_readTableOptions()
  local ok, result = pcall(function()
    local tf = findTableFile('FrankensteinTableOptions')
    if not tf then return {} end
    local st = tf.getData()
    st.Position = 0
    local txt = st.readString(st.Size)
    local t = {}
    for line in txt:gmatch("[^\r\n]+") do
      local name, value = line:match("([^=]+)=(.*)")
      if name and value then
        t[name] = value
      end
    end
    return t
  end)
  if ok then return result else return {} end
end

local function _fk_writeTableOptions(t)
  local ok, result = pcall(function()
    local text = ""
    local keys = {}
    for k in pairs(t) do
      table.insert(keys, k)
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
      text = text .. k .. "=" .. t[k] .. "\n"
    end
    local tf = findTableFile('FrankensteinTableOptions')
    if tf then tf.delete() end
    tf = createTableFile('FrankensteinTableOptions')
    local st = tf.getData()
    st.Size = 0
    st.Position = 0
    st.writeString(text)
  end)
  return ok
end

if getTableOption == nil then
  function getTableOption(name)
    local t = _fk_readTableOptions()
    local v = t[name]
    if not v then
      local def = _fk_tabledefs[name]
      if not def or def.type == 0 then
        return false
      else
        return nil
      end
    else
      local def = _fk_tabledefs[name]
      if def and def.type == 0 then
        return v == 'true'
      else
        return tonumber(v) or v
      end
    end
  end
end

if setTableOption == nil then
  function setTableOption(name, value)
    local t = _fk_readTableOptions()
    t[name] = tostring(value)
    _fk_writeTableOptions(t)
  end
end