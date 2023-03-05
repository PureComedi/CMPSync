local internet = require("internet")
local term = require("term")
local json = require("json")
local password = "PWC<3"
local headers = {
      ["Content-Type"] = "application/json",
      ["User-Agent"] = "MyBot (https://www.example.com, 1.0)"
}
 
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
  avatar_url = "https://cdn.discordapp.com/attachments/795312360226947104/1078978654572396694/p.png?size=4096"
}
 
  internet.request(url, json.encode(contents), headers, "POST")
  
  io.write()
 
  while true do
 
    local message = io.read()
 
      if message == "Logout" then
        break
    end
 
      if message == ":catnod:" then
        message = "<a:catnod:1007603181083181087>"
    end
 
      if message == ":grr:" then
        message = "<:grr:964871189166182420>"
    end
 
      if message == ":clueless:" then
        message = "<:clueless:910735716894511136>"
    end
 
    local contents = {
      
      content = message,
      username = "CMP" .. " - " .. lusername,
      avatar_url = "https://cdn.discordapp.com/attachments/795312360226947104/1078978654572396694/p.png?size=4096"
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
  avatar_url = "https://cdn.discordapp.com/attachments/795312360226947104/1078978654572396694/p.png?size=4096"
}
 
  internet.request(url, json.encode(contents), headers, "POST")
 
  term.clear()
  print("Logging out")
  os.execute("sleep 2")
  term.clear()
else
 
print("Exiting")
 
end