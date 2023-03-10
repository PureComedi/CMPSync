local internet = require("internet")
local component = require("component")
local term = require("term")
local shortcuts = require("shortcuts")
local password = "passwordhere"
local headers = {
      ["Content-Type"] = "application/json",
      ["User-Agent"] = "MyBot (https://www.example.com, 1.0)"
}

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

local function ExitButton()
  local ButtonWidth = 5
  local ButtonHeight = 5
  local ButtonX = screenWidth - ButtonWidth + 1
  local ButtonY = 1

  gpu.set(ButtonX, ButtonY, "X")
  gpu.fill(ButtonX + 1, ButtonY + 1, ButtonWidth - 2, ButtonHeight - 2, " ")

  -- Wait for the user to click on the X button
  repeat
    local _, _, x, y = event.pull()
  until x >= ButtonX and x <= ButtonX + ButtonWidth - 1 and y >= ButtonY and y <= ButtonY + ButtonHeight - 1

  -- Clean up the screen by redrawing the X button
  gpu.fill(ButtonX, ButtonY, ButtonWidth, ButtonHeight, " ")
  end




local ascii = {
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
ExitButton()

for i, line in ipairs(ascii) do
  local lineX = centerX - math.floor(#line / 2)
  gpu.set(lineX, centerY - math.ceil(#ascii / 2) + i - 1, line)
end

local slideDelay = 1 
local slideDistance = #ascii + 1
os.sleep(slideDelay)
for i = 0, slideDistance do
  gpu.copy(1, i + 1, screenWidth, screenHeight - i, 0, -i)
  os.sleep(0.05)
end

term.clear()
ExitButton()


print("Username:")
 
io.write()
 
local lusername = io.read()
 
print("Password:")
 
io.write()
 
local attempt = io.read()
 
term.clear()
ExitButton()

if attempt == password then

  local options = dofile("options.lua")

  if next(options) == nil then
    local term = require "term"
    local options = dofile("options.lua")
     
    -- helper function to save options to file
    local function saveOptions()
      local file = io.open("options.lua", "w")
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
      print("4. Back")
      io.write()
      local choice = tonumber(io.read())
      if choice == 1 then
        term.clear()
ExitButton()
        addOption()
      elseif choice == 2 then
        term.clear()
ExitButton()
        removeOption()
      elseif choice == 3 then
        term.clear()
ExitButton()
        listOptions()
      elseif choice == 4 then
        term.clear()
ExitButton()
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
ExitButton()
 
  local contents = {
  embeds = {  
    {
      title = "Login",
      description = lusername .. " just logged in!",
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
        if setting_choice == "1" or (FTS == true) then
          local term = require "term"
          local options = dofile("options.lua")
           
          -- helper function to save options to file
          local function saveOptions()
            local file = io.open("options.lua", "w")
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
            print("4. Back")
            io.write()
            local choice = tonumber(io.read())
            if choice == 1 then
              term.clear()
ExitButton()
              addOption()
            elseif choice == 2 then
              term.clear()
ExitButton()
              removeOption()
            elseif choice == 3 then
              term.clear()
ExitButton()
              listOptions()
            elseif choice == 4 then
              term.clear()
ExitButton()
              break
            else
              print("Invalid choice.")
            end
          end
          goto MessageStart

        elseif setting_choice == "2" then
          local term = require "term"
          local options = dofile("shortcuts.lua")
          
          -- helper function to save options to file
          local function saveOptions()
            local file = io.open("shortcuts.lua", "w")
            file:write("return {\n")
            for i, option in ipairs(options) do
              file:write(string.format("  {%q, %q},\n", option[1], option[2]))
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
            table.insert(options, {name, value})
            saveOptions()
            print("Shortcut added.")
          end
          
          -- function to remove an existing option
          local function removeOption()
            print("Enter the number of the shortcut you want to remove:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option[1] .. " => " .. option[2])
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
              print(i .. ". " .. option[1])
            end
          end
          
          -- main loop
          while true do
            print("\n")
            print("Select an option:")
            print("1. Add a shortcut")
            print("2. Remove a shortcut")
            print("3. List existing shortcuts")
            print("4. Back")
            io.write()
            local choice = tonumber(io.read())
            if choice == 1 then
              term.clear()
ExitButton()
              addOption()
            elseif choice == 2 then
              term.clear()
ExitButton()
              removeOption()
            elseif choice == 3 then
              term.clear()
ExitButton()
              listOptions()
            elseif choice == 4 then
              term.clear()
ExitButton()
              break
            else
              print("Invalid choice.")
            end
          end
          goto MessageStart
        end
        io.write()
      end

    for i = 1, #shortcuts do
      if message == shortcuts[i][1] then
        message = shortcuts[i][2]
      end
    end
 
    local contents = {
      
      content = message,
      username = "CMP" .. " - " .. lusername,
      avatar_url = "https://cdn.discordapp.com/attachments/1082257996429668395/1082722647030378607/image.png?size=4096"
}
 
    internet.request(url, json.encode(contents), headers, "POST")
 
    io.write()
  end
 
  local contents = {
  embeds = {  
    {
      title = "Logout",
      description = lusername .. " logged out.",
      color = 15548997
    }
  },
  username = "CMP",
  avatar_url = "https://cdn.discordapp.com/attachments/1082257996429668395/1082722647030378607/image.png?size=4096"
}
 
  internet.request(url, json.encode(contents), headers, "POST")
 
  term.clear()
ExitButton()
  print("Logging out")
  os.execute("sleep 2")
  term.clear()
ExitButton()
else
 
print("Exiting")
 
end
