-- Extensions subfolder loader (backport of CE 7.6.6 feature)
-- Loads plugins from the Extensions folder, respecting loadorder.txt if present

local pathdelim = (getOperatingSystem() == 0) and [[\]] or [[/]]
local extensionsDir = getCheatEngineDir() .. 'Extensions' .. pathdelim

local function fileExists(path)
  local f = io.open(path, 'r')
  if f then f:close() return true end
  return false
end

local function loadLuaFile(path)
  local ok, err = pcall(dofile, path)
  if not ok then
    print('Extensions loader error loading ' .. path .. ': ' .. tostring(err))
  end
end

local function loadFolder(dir)
  -- Check for loadorder.txt
  local orderFile = dir .. 'loadorder.txt'
  if fileExists(orderFile) then
    for line in io.lines(orderFile) do
      line = line:match('^(.-)%s*#.*$') or line:match('^(.-)%s*$')
      if line and line ~= '' then
        local target = dir .. line
        if fileExists(target .. '.lua') then
          loadLuaFile(target .. '.lua')
        elseif fileExists(target) then
          -- It's a subfolder
          loadFolder(target .. pathdelim)
        end
      end
    end
  else
    -- No loadorder.txt, just load all .lua files
    -- CE's enumFiles equivalent via lua pattern
    local p = io.popen('dir /b "' .. dir .. '*.lua" 2>nul')
    if p then
      for f in p:lines() do
        loadLuaFile(dir .. f)
      end
      p:close()
    end
  end
end

-- Enumerate subdirectories in Extensions
local p = io.popen('dir /b /ad "' .. extensionsDir .. '" 2>nul')
if p then
  for subdir in p:lines() do
    loadFolder(extensionsDir .. subdir .. pathdelim)
  end
  p:close()
end
