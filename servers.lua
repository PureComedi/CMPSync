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
