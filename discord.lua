--Dependencies

local headers = {
  ["Content-Type"] = "application/json",
  ["User-Agent"] = "MyBot (https://www.example.com, 1.0)"
}
local internet = require("internet")
local component = require("component")
local term = require("term")
local filesystem = require("filesystem") 

local serversfile = ("servers.lua")
if not filesystem.exists(serversfile) then
  local serversfile = io.open(serversfile, "w")
  serversfile:close()
end

local shortcutsfile = ("shortcuts.lua")
if not filesystem.exists(shortcutsfile) then
  local shortcutsfile = io.open(shortcutsfile, "w")
  shortcutsfile:close()
end

--Dependencies



--Main code

local json = { _version = "0.1.2" }
local encode
local escape_char_map = {
  [ "\\" ] = "\\",
  [ "\"" ] = "\"",
  [ "\b" ] = "b",
  [ "\f" ] = "f",
  [ "\n" ] = "n",
  [ "\r" ] = "r",
  [ "\t" ] = "t",
}
local escape_char_map_inv = { [ "/" ] = "/" }
for k, v in pairs(escape_char_map) do
  escape_char_map_inv[v] = k
end
local function escape_char(c)
  return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end
local function encode_nil(val)
  return "null"
end
local function encode_table(val, stack)
  local res = {}
  stack = stack or {}
  -- Circular reference?
  if stack[val] then error("circular reference") end
  stack[val] = true
  if rawget(val, 1) ~= nil or next(val) == nil then
    -- Treat as array -- check keys are valid and it is not sparse
    local n = 0
    for k in pairs(val) do
      if type(k) ~= "number" then
        error("invalid table: mixed or invalid key types")
      end
      n = n + 1
    end
    if n ~= #val then
      error("invalid table: sparse array")
    end
    -- Encode
    for i, v in ipairs(val) do
      table.insert(res, encode(v, stack))
    end
    stack[val] = nil
    return "[" .. table.concat(res, ",") .. "]"
  else
    -- Treat as an object
    for k, v in pairs(val) do
      if type(k) ~= "string" then
        error("invalid table: mixed or invalid key types")
      end
      table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
    end
    stack[val] = nil
    return "{" .. table.concat(res, ",") .. "}"
  end
end
local function encode_string(val)
  return '"' .. val:gsub('[%z\1-\31\\"]', escape_char) .. '"'
end
local function encode_number(val)
  -- Check for NaN, -inf and inf
  if val ~= val or (val <= -math.huge) or (val >= math.huge) then
    error("unexpected number value '" .. tostring(val) .. "'")
  end
  return string.format("%.14g", val)
end
local type_func_map = {
  [ "nil"     ] = encode_nil,
  [ "table"   ] = encode_table,
  [ "string"  ] = encode_string,
  [ "number"  ] = encode_number,
  [ "boolean" ] = tostring,
}
encode = function(val, stack)
  local t = type(val)
  local f = type_func_map[t]
  if f then
    return f(val, stack)
  end
  error("unexpected type '" .. t .. "'")
end
function json.encode(val)
  return ( encode(val) )
end

local gpu = component.gpu

local bootscreen = {
"   _____   __  __   _____  ",
"  / ____| |  \\/  | |  __ \\ ",
" | |      | \\  / | | |__) |",
" | |      | |\\/| | |  ___/ ",
" | |____  | |  | | | |     ",
"  \\_____| |_|  |_| |_|     "
}

local screenWidth, screenHeight = gpu.getResolution()
local centerX = math.floor(screenWidth / 2)
local centerY = math.floor(screenHeight / 2)

term.clear()

for i, line in ipairs(bootscreen) do
  local lineX = centerX - math.floor(#line / 2)
  gpu.set(lineX, centerY - math.ceil(#bootscreen / 2) + i - 1, line)
end

local slideDelay = 1 
local slideDistance = #bootscreen + 1
os.sleep(slideDelay)
for i = 0, slideDistance do
  gpu.copy(1, i + 1, screenWidth, screenHeight - i, 0, -i)
  os.sleep(0.05)
end

term.clear()

io.write("Username:\n")

local loginusr = io.read()

local function checkPassword()
  local file = io.open("password.txt")
  
  for line in file:read("*a") do
    local salted,salt = line:match("^([^;]+);(.+)$")
    salted = component.data.decode64(salted)
    salt = component.data.decode64(salt)
    if(salted == component.data.sha256(attempt..salt)) then
      file:close()
      return true
    end
  end
  file:close()
  return false
end

if filesystem.exists("password.txt") then 
  io.write("Password:\n")
  attempt = io.read()
  

else
  
  io.write("Enter the password you want to be set:\n")
  local password = io.read()
  local file = io.open("password.txt","a")
  local salt = component.data.random(16)
  local hashed = component.data.encode64(component.data.sha256(password..salt))
  
  file:write(string.format("%s;%s\n",hashed,component.data.encode64(salt)))
  file:close()
  io.write("Password:\n")
  attempt = io.read()
end 
if checkPassword(attempt) == true then
  term.clear()  

  -- Main code

  local options = dofile("servers.lua")

  if next(options) == nil then
    local term = require "term"
    local options = dofile("servers.lua")
    
    -- function to save options to file
    local function saveOptions()
      local file = io.open("servers.lua", "w")
      file:write("return {\n")
      for i, option in ipairs(options) do
        file:write(string.format("  {name = %q, value = %q},\n", option.name, option.value))
      end
      file:write("}\n")
      file:close()
    end
    
    -- function to add a new option
    local function addOption()
      print("Enter a name for the new server:")
      io.write()
      local name = io.read()
      print("Enter a webhook link for the new server:")
      io.write()
      local value = io.read()
      table.insert(options, {name = name, value = value})
      saveOptions()
      print("Option added.")
    end
    
    -- function to remove an existing option
    local function removeOption()
      print("Enter the number of the server you want to remove:")
      for i, option in ipairs(options) do
        print(i .. ". " .. option.name)
      end
      io.write()
      local choice = tonumber(io.read())
      if choice and options[choice] then
        table.remove(options, choice)
        saveOptions()
        print("Server removed.")    
      else
        print("Invalid choice.")
      end
    end
    
    -- function to list existing options
    local function listOptions()
      print("Existing options:")
      for i, option in ipairs(options) do
        print(i .. ". " .. option.name)
      end
    end
    
    -- main loop
    while true do
      print("\n")
      print("The server list is empty, add a new server")
      print("1. Add a server")
      print("2. Remove a server")
      print("3. List existing servers")
      print("4. Exit")
      io.write()
      local choice = tonumber(io.read())
      if choice == 1 then
        term.clear()
        addOption()
      elseif choice == 2 then
        term.clear()
        removeOption()
      elseif choice == 3 then
        term.clear()
        listOptions()
      elseif choice == 4 then
        term.clear()
        break
      else
        print("Invalid choice.")
      end
    end
  end

  for i, option in ipairs(options) do
    print(i .. ". " .. option.name)

  end

  io.write()
  local choice = tonumber(io.read())

  local url = options[choice].value

  term.clear()

  local contents = {
  embeds = {  
    {
      title = "Login",
      description = loginusr .. " just logged in!",
      color = 5763719
    }
  },
  username = "CMP",
  avatar_url = "https://cdn.discordapp.com/attachments/1082257996429668395/1082722647030378607/image.png?size=4096"
  }

  internet.request(url, json.encode(contents), headers, "POST")

  io.write()

  while true do

    ::MessageStart::

    local message = io.read()

      if message == "Logout" then
        break
      
      elseif message == "Settings" then
        print("Select a setting to modify")
        print("1. Servers")
        print("2. Shortcuts")
        local setting_choice = io.read()
        
        --Servers

        if setting_choice == "1" then
          local term = require "term"
          local options = dofile("servers.lua")
          
          -- function to save options to file
          local function saveOptions()
            local file = io.open("servers.lua", "w")
            file:write("return {\n")
            for i, option in ipairs(options) do
              file:write(string.format("  {name = %q, value = %q},\n", option.name, option.value))
            end
            file:write("}\n")
            file:close()
          end
          
          -- function to add a new option
          local function addOption()
            print("Enter a name for the new server:")
            io.write()
            local name = io.read()
            print("Enter a webhook link for the new server:")
            io.write()
            local value = io.read()
            table.insert(options, {name = name, value = value})
            saveOptions()
            print("Option added.")
          end
          
          -- function to remove an existing option
          local function removeOption()
            print("Enter the number of the server you want to remove:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option.name)
            end
            io.write()
            local choice = tonumber(io.read())
            if choice and options[choice] then
              table.remove(options, choice)
              saveOptions()
              print("Server removed.")    
            else
              print("Invalid choice.")
            end
          end
          
          -- function to list existing options
          local function listOptions()
            print("Existing options:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option.name)
            end
          end
          
          -- main loop
          while true do
            print("\n")
            print("Select a subcommand:")
            print("1. Add a server")
            print("2. Remove a server")
            print("3. List existing servers")
            print("4. Exit")
            io.write()
            local choice = tonumber(io.read())
            if choice == 1 then
              term.clear()
              addOption()
            elseif choice == 2 then
              term.clear()
              removeOption()
            elseif choice == 3 then
              term.clear()
              listOptions()
            elseif choice == 4 then
              term.clear()
              break
            else
              print("Invalid choice.")
            end
          end
          goto MessageStart

        --Shortcuts

        elseif setting_choice == "2" then
          local term = require "term"
          local options = dofile("shortcuts.lua")
          
          -- function to save options to file
          local function saveOptions()
            local file = io.open("shortcuts.lua", "w")
            file:write("return {\n")
            for i, option in ipairs(options) do
              file:write(string.format("  {name = %q, value = %q},\n", option.name, option.value))
            end
            file:write("}\n")
            file:close()
          end
          
          -- function to add a new option
          local function addOption()
            print("Enter the name of the shortcut:")
            io.write()
            local name = io.read()
            print("Enter what you want it to be replaced with:")
            io.write()
            local value = io.read()
            table.insert(options, {name = name, value = value})
            saveOptions()
            print("Shortcut added.")
          end
          
          -- function to remove an existing option
          local function removeOption()
            print("Enter the number of the shortcut you want to remove:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option.name .. " => " .. option.value)
            end
            io.write()
            local choice = tonumber(io.read())
            if choice and options[choice] then
              table.remove(options, choice)
              saveOptions()
              print("Shortcut removed.")
            else
              print("Invalid choice.")
            end
          end
          
          -- function to list existing options
          local function listOptions()
            print("Existing shortcuts:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option.name)
            end
          end
          
          -- main loop
          while true do
            print("\n")
            print("Select a subcommand:")
            print("1. Add a shortcut")
            print("2. Remove a shortcut")
            print("3. List existing shortcuts")
            print("4. Exit")
            io.write()
            local choice = tonumber(io.read())
            if choice == 1 then
              term.clear()
              addOption()
            elseif choice == 2 then
              term.clear()
              removeOption()
            elseif choice == 3 then
              term.clear()
              listOptions()
            elseif choice == 4 then
              term.clear()
              break
            else
              print("Invalid choice.")
            end
          end
          goto MessageStart
        end
        io.write()
      end

    local shortcuts = dofile("shortcuts.lua")
    
    for i = 1, #shortcuts do
      if shortcuts[i].name == message then
        message = shortcuts[i].value
        break
      end
    end
      

    local contents = {
      
      content = message,
      username = "CMP" .. " - " .. loginusr,
      avatar_url = "https://cdn.discordapp.com/attachments/1082257996429668395/1082722647030378607/image.png?size=4096"
  }

    internet.request(url, json.encode(contents), headers, "POST")

    io.write()
  end

  local contents = {
  embeds = {  
    {
      title = "Logout",
      description = loginusr .. " logged out.",
      color = 15548997
    }
  },
  username = "CMP",
  avatar_url = "https://cdn.discordapp.com/attachments/1082257996429668395/1082722647030378607/image.png?size=4096"
  }

  internet.request(url, json.encode(contents), headers, "POST")

  term.clear()
  print("Logging out")
  os.execute("sleep 1")
  term.clear()
else
  term.clear()
  print("Exiting")
  os.execute("sleep 1")
  term.clear()
end


--Main code
