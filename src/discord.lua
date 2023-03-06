local internet = require("internet")
local term = require("term")
local json = require("json")
local password = "PWC<3"
local replacements = dofile("replacements.lua")
local headers = {
      ["Content-Type"] = "application/json",
      ["User-Agent"] = "MyBot (https://www.example.com, 1.0)"
}

term.clear()

print("Username:")

io.write()

local lusername = io.read()

print("Password:")

io.write()

local attempt = io.read()

term.clear()

if !(attempt == password) then
    return print("Exiting")
end

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

    local args = {}
    for index in string.gmatch(message, "%S+") do
        table.insert(args, index)
    end

    for index, value in pairs(args) do
        for i = 1, #replacements do
            if value == replacements[i][1] then
                args[index] = replacements[i][2]
            end
        end
    end

    if args[1] == "Logout" then
        break
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