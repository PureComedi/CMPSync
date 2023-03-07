local gpu = component.gpu
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

local screenWidth, screenHeight = gpu.getResolution()
local centerX = math.floor(screenWidth / 2)
local centerY = math.floor(screenHeight / 2)
local duration = 2 -- Define the duration of the animation in seconds
local frameRate = 60 -- Define the frame rate of the animation in frames per second
local numFrames = duration * frameRate -- Define the number of frames in the animation
local frameDelay = 1000 / frameRate -- Define the delay between frames in milliseconds
local bootscrn = {
"   _____   __  __   _____  ",
"  / ____| |  \\/  | |  __ \\ ",
" | |      | \\  / | | |__) |",
" | |      | |\\/| | |  ___/ ",
" | |____  | |  | | | |     ",
"  \\_____| |_|  |_| |_|     ",
"                            ",
"            PCmdi™          "
}

gpu.fill(1, 1, screenWidth, screenHeight, " ")

-- Define the alpha value of the art at each frame
local alphas = {}
for i = 1, numFrames do
  local alpha = 1 - (i - 1) / (numFrames - 1)
  alphas[i] = alpha
end

-- Loop over each frame of the animation
for i = 1, numFrames do
  -- Calculate the current alpha value of the art
  local alpha = alphas[i]

  -- Clear the screen
  gpu.fill(1, 1, screenWidth, screenHeight, " ")

  -- Print the boot screen logo with the current alpha value
  for j, line in ipairs(ascii) do
    local lineX = centerX - math.floor(#line / 2)
    local lineY = centerY - math.ceil(#ascii / 2) + j - 1
    gpu.setForeground(0xFFFFFF, alpha)
    gpu.set(lineX, lineY, line)
  end

  os.sleep(frameDelay / 1000)
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
