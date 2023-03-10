local internet = require("internet")
local component = require("component")
local term = require("term")
local json = require("json")
local password = "passwordhere"
local replacements = dofile("replacements.lua")
local headers = {
      ["Content-Type"] = "application/json",
      ["User-Agent"] = "MyBot (https://www.example.com, 1.0)"
}

local gpu = component.gpu

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
 
print("Username:")
 
io.write()
 
local lusername = io.read()
 
print("Password:")
 
io.write()
 
local attempt = io.read()
 
term.clear()

if attempt == password then
 
  local options = dofile("options.lua")
 
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
        print("2. Replacements")
        local setting_choice = io.read()
        if setting_choice == "1" then
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
            print("Enter a name for the new option:")
            io.write()
            local name = io.read()
            print("Enter a value for the new option:")
            io.write()
            local value = io.read()
            table.insert(options, {name = name, value = value})
            saveOptions()
            print("Option added.")
          end
          
          -- function to remove an existing option
          local function removeOption()
            print("Enter the number of the option you want to remove:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option.name)
            end
            io.write()
            local choice = tonumber(io.read())
            if choice and options[choice] then
              table.remove(options, choice)
              saveOptions()
              print("Option removed.")    
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
            print("Select an option:")
            print("1. Add an option")
            print("2. Remove an option")
            print("3. List existing options")
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

        elseif setting_choice == "2" then
          local term = require "term"
          local options = dofile("replacements.lua")
          
          -- helper function to save options to file
          local function saveOptions()
            local file = io.open("replacements.lua", "w")
            file:write("return {\n")
            for i, option in ipairs(options) do
              file:write(string.format("  {%q, %q},\n", option[1], option[2]))
            end
            file:write("}\n")
            file:close()
          end
          
          -- function to add a new option
          local function addOption()
            print("Enter a name for the new option:")
            io.write()
            local name = io.read()
            print("Enter a value for the new option:")
            io.write()
            local value = io.read()
            table.insert(options, {name, value})
            saveOptions()
            print("Option added.")
          end
          
          -- function to remove an existing option
          local function removeOption()
            print("Enter the number of the option you want to remove:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option[1] .. " => " .. option[2])
            end
            io.write()
            local choice = tonumber(io.read())
            if choice and options[choice] then
              table.remove(options, choice)
              saveOptions()
              print("Option removed.")
            else
              print("Invalid choice.")
            end
          end
          
          -- function to list existing options
          local function listOptions()
            print("Existing options:")
            for i, option in ipairs(options) do
              print(i .. ". " .. option[1])
            end
          end
          
          -- main loop
          while true do
            print("\n")
            print("Select an option:")
            print("1. Add an option")
            print("2. Remove an option")
            print("3. List existing options")
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

    for i = 1, #replacements do
      if message == replacements[i][1] then
        message = replacements[i][2]
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
  print("Logging out")
  os.execute("sleep 2")
  term.clear()
else
 
print("Exiting")
 
end
