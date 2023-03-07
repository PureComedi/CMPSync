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
 
    local message = io.read()
 
      if message == "Logout" then
        break
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