
local PhoenixLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ske-code/LoL/refs/heads/main/gg.lua"))()

local KeySystem = {
    Enabled = true,
    Authorized = false
}

local keyWindow = PhoenixLib:Window({
    Name = "ske.gg"
})

local keyPage = keyWindow:Page({Name = "Key System"})
local keySection = keyPage:Section({Name = "Enter Key", Side = "Left"})

keySection:AddLabel("Welcome to ske.gg")
keySection:AddLabel("Enter any key to continue")

local keyInput = keySection:Textbox({
    Text = "",
    Placeholder = "Enter any key...(anyevery can iuput)",
    Flag = "KeyInput",
    Callback = function(input)
        if string.len(input) > 0 then
            KeySystem.Authorized = true
            keyWindow:Close()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ske-code/kskldkdkslxococpplwqlwlwkwmnwnwwnwksizixicucyvyegegegwwbwbaxjdkd/refs/heads/main/Protected_1167235563246881.lua.txt"))()
        end
    end
})
