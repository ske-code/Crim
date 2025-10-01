local PhoenixLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/ske-code/LoL/refs/heads/main/gg.lua"))()

local window = PhoenixLib:Window({Name = "ske.gg - Criminality"})
local mainPage = window:Page({Name = "Main"})
local combatSection = mainPage:Section({Name = "Ragebot", Side = "Left"})
local visualSection = mainPage:Section({Name = "Visuals", Side = "Right"})
local playerSection = mainPage:Section({Name = "Player", Side = "Left"})

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace") 
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local S = {
    Rage = {
        Enabled = false, FireRate = 5, Prediction = true, PredictionAmount = 0.1, 
        Tracer = false, TracerColor = "255, 154, 255", TracerWidth = 0.3, TracerLifetime = 0.3,
        Fov = true, FovRadius = 100, NoFovLimit = false, TargetLock = false, LockedTarget = nil,
        DownedCheck = true, NoFireRateLimit = false, LastShot = 0,
        VisibilityCheck = true, TargetList = {}, Whitelist = {}, TargetTextBox = "", WhitelistTextBox = ""
    },
    Visual = {
        Headless = false, ForceField = false, ForceFieldColor = "255, 154, 255", ForceFieldTransparency = 0.5, 
        NameTags = false, NameTagsColor = "255, 154, 255", ToolForceField = false, ToolForceFieldColor = "255, 154, 255", 
        ToolForceFieldTransparency = 0.3, Shader = false, ShaderType = "Bloom", ShaderIntensity = 1.0, ShaderColor = "255, 154, 255"
    },
    Player = {
        Stamina = false, NoFall = false, Lockpick = false, Reload = false
    }
}

local hitLogs = {}
local hitLogGui = Instance.new("ScreenGui")
hitLogGui.Name = "HitLogs"
hitLogGui.ResetOnSpawn = false
hitLogGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local function showHitNotify(targetName, damage, hitPart, targetHumanoid, hitPosition, tool)
    local distance = math.floor((Camera.CFrame.Position - hitPosition).Magnitude)
    local hp = targetHumanoid and tostring(math.floor(targetHumanoid.Health)) or "?"
    local weapon = tool and tool.Name or "Unknown"

    local box = Instance.new("Frame")
    box.Parent = hitLogGui
    box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    box.BackgroundTransparency = 0.3
    box.BorderSizePixel = 0

    local parts = {
        {"Hit target: ", Color3.fromRGB(255, 255, 255)},
        {targetName.." ", Color3.fromRGB(255, 182, 193)},
        {"["..weapon.."] ", Color3.fromRGB(255, 255, 255)},
        {"HP:", Color3.fromRGB(255, 255, 255)},
        {hp.." ", Color3.fromRGB(255, 182, 193)},
        {"Dist:"..distance, Color3.fromRGB(255, 255, 255)}
    }

    local offsetX = 6
    local totalW, maxH = 0, 0

    for _, seg in ipairs(parts) do
        local txt, col = seg[1], seg[2]
        local label = Instance.new("TextLabel")
        label.Parent = box
        label.BackgroundTransparency = 1
        label.BorderSizePixel = 0
        label.TextColor3 = col
        label.FontFace = Font.new("rbxassetid://12187371840")
        label.TextSize = 20
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Text = txt
        label.AutomaticSize = Enum.AutomaticSize.XY
        label.Position = UDim2.new(0, offsetX, 0, 0)

        offsetX = offsetX + label.TextBounds.X
        totalW = offsetX
        maxH = math.max(maxH, label.TextBounds.Y)
    end

    box.Size = UDim2.new(0, totalW + 12, 0, maxH + 8)

    table.insert(hitLogs, box)

    for i, l in ipairs(hitLogs) do
        l.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * (l.AbsoluteSize.Y + 5))
    end

    task.delay(3, function()
        for i, l in ipairs(hitLogs) do
            if l == box then
                table.remove(hitLogs, i)
                break
            end
        end
        if box then box:Destroy() end
        for i, l in ipairs(hitLogs) do
            l.Position = UDim2.new(0, 10, 0, 40 + (i - 1) * (l.AbsoluteSize.Y + 5))
        end
    end)
end

local function parseColor(colorString)
    local parts = string.split(colorString, ",")
    local r = tonumber(parts[1]) or 255
    local g = tonumber(parts[2]) or 255
    local b = tonumber(parts[3]) or 255
    return Color3.fromRGB(r, g, b)
end

local function RandomString(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #charset)
        result = result .. string.sub(charset, randIndex, randIndex)
    end
    return result
end

local function applyHeadless()
    if LocalPlayer.Character then
        local head = LocalPlayer.Character:FindFirstChild("Head")
        if head then
            head.Transparency = S.Visual.Headless and 1 or 0
            if S.Visual.Headless then 
                for _, f in pairs(head:GetChildren()) do 
                    if f:IsA("Decal") then f:Destroy() end 
                end 
            end
        end
    end
end

local function applyForceField()
    if LocalPlayer.Character then
        local color = parseColor(S.Visual.ForceFieldColor)
        for _, p in pairs(LocalPlayer.Character:GetChildren()) do
            if p:IsA("BasePart") then
                if S.Visual.ForceField then
                    p.Material = Enum.Material.ForceField
                    p.Color = color
                    p.Transparency = S.Visual.ForceFieldTransparency
                else
                    p.Material = Enum.Material.Plastic
                    p.Transparency = 0
                end
            end
        end
    end
end

local toolMats = {}
local toolColors = {}
local toolTrans = {}

local function applyToolForceField()
    if LocalPlayer.Character then
        local color = parseColor(S.Visual.ToolForceFieldColor)
        for _, t in pairs(LocalPlayer.Character:GetChildren()) do
            if t:IsA("Tool") then
                if not toolMats[t] then 
                    toolMats[t] = {} 
                    toolColors[t] = {} 
                    toolTrans[t] = {} 
                end
                for _, p in pairs(t:GetDescendants()) do
                    if p:IsA("BasePart") then
                        if not toolMats[t][p] then
                            toolMats[t][p] = p.Material
                            toolColors[t][p] = p.Color
                            toolTrans[t][p] = p.Transparency
                        end
                        p.Material = Enum.Material.ForceField
                        p.Color = color
                        p.Transparency = S.Visual.ToolForceFieldTransparency
                    end
                end
            end
        end
    end
end

local function restoreTools()
    for t, parts in pairs(toolMats) do
        if t and t.Parent then
            for p, om in pairs(parts) do
                if p and p.Parent then
                    p.Material = om
                    p.Color = toolColors[t][p]
                    p.Transparency = toolTrans[t][p]
                end
            end
        end
    end
    toolMats = {} 
    toolColors = {} 
    toolTrans = {}
end

local currentShader = nil

local function updateShader()
    if currentShader then 
        currentShader:Destroy() 
        currentShader = nil 
    end
    if not S.Visual.Shader then return end
    
    local lighting = game:GetService("Lighting")
    local color = parseColor(S.Visual.ShaderColor)
    
    if S.Visual.ShaderType == "Bloom" then
        local b = Instance.new("BloomEffect")
        b.Intensity = S.Visual.ShaderIntensity * 0.5
        b.Size = 24
        b.Threshold = 0.95
        b.Parent = lighting
        currentShader = b
    elseif S.Visual.ShaderType == "Blur" then
        local b = Instance.new("BlurEffect")
        b.Size = S.Visual.ShaderIntensity * 10
        b.Parent = lighting
        currentShader = b
    elseif S.Visual.ShaderType == "ColorCorrection" then
        local c = Instance.new("ColorCorrectionEffect")
        c.Brightness = S.Visual.ShaderIntensity * 0.1
        c.Contrast = S.Visual.ShaderIntensity * 0.1
        c.Saturation = S.Visual.ShaderIntensity * 0.1
        c.TintColor = color
        c.Parent = lighting
        currentShader = c
    elseif S.Visual.ShaderType == "SunRays" then
        local s = Instance.new("SunRaysEffect")
        s.Intensity = S.Visual.ShaderIntensity * 0.05
        s.Spread = 1
        s.Parent = lighting
        currentShader = s
    elseif S.Visual.ShaderType == "DepthOfField" then
        local d = Instance.new("DepthOfFieldEffect")
        d.FarIntensity = S.Visual.ShaderIntensity * 0.5
        d.FocusDistance = 50
        d.InFocusRadius = 30
        d.NearIntensity = 0.5
        d.Parent = lighting
        currentShader = d
    end
end

local function getCurrentTool()
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end
    return nil
end

local function canSeeTarget(targetPart)
    if not S.Rage.VisibilityCheck then return true end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local startPos = Camera.CFrame.Position
    local endPos = targetPart.Position
    local direction = (endPos - startPos)
    local distance = direction.Magnitude
    
    local raycastResult = workspace:Raycast(startPos, direction.Unit * distance, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart and hitPart.CanCollide then
            local model = hitPart:FindFirstAncestorOfClass("Model")
            if model then
                local humanoid = model:FindFirstChild("Humanoid")
                if humanoid then
                    return true
                end
            end
            return false
        end
    end
    return true
end

local function isPlayerDowned(player)
    if not S.Rage.DownedCheck then return false end
    if not player.Character then return true end
    
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if not humanoid then return true end
    
    local head = player.Character:FindFirstChild("Head")
    if not head then return true end
    
    return humanoid.Health <= 0
end

local function isWhitelisted(player)
    for _, name in ipairs(S.Rage.Whitelist) do
        if player.Name == name then
            return true
        end
    end
    return false
end

local function isInTargetList(player)
    if #S.Rage.TargetList == 0 then return true end
    for _, name in ipairs(S.Rage.TargetList) do
        if player.Name == name then
            return true
        end
    end
    return false
end
local hitSounds = {
    Default = "rbxassetid://6534948092",
    Metal = "rbxassetid://140792940",
    Punch = "rbxassetid://2780622092",
    Sword = "rbxassetid://544612629"
}

S.Rage.HitSound = "Default"
S.Rage.HitSoundVolume = 1

combatSection:Dropdown({
    Text = "Hit Sound",
    Options = {"Default", "Metal", "Punch", "Sword", "Weapon", "Custom"},
    Default = 1,
    Flag = "HitSound",
    Callback = function(value)
        S.Rage.HitSound = value
    end
})

combatSection:Textbox({
    Text = "rbxassetid://",
    Placeholder = "Custom Sound ID",
    Flag = "CustomHitSound",
    Callback = function(text)
        if S.Rage.HitSound == "Custom" then
            hitSounds.Custom = text
        end
    end
})

combatSection:Slider({
    Text = "Hit Sound Volume",
    Min = 0,
    Max = 1,
    Default = 1,
    Flag = "HitSoundVolume",
    Callback = function(value)
        S.Rage.HitSoundVolume = value
    end
})
local function playHitSound()
    local soundId = hitSounds.Default
    
    if S.Rage.HitSound == "Weapon" then
        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                if tool:IsA("Tool") then
                    for _, child in ipairs(tool:GetDescendants()) do
                        if child:IsA("Sound") and child.Name == "FireSound1" then
                            local soundClone = child:Clone()
                            soundClone.Parent = Camera
                            soundClone:Play()
                            game:GetService("Debris"):AddItem(soundClone, soundClone.TimeLength)
                            return
                        end
                    end
                end
            end
        end
    elseif S.Rage.HitSound == "Custom" then
        soundId = hitSounds.Custom or hitSounds.Default
    elseif hitSounds[S.Rage.HitSound] then
        soundId = hitSounds[S.Rage.HitSound]
    end
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = S.Rage.HitSoundVolume
    sound.PlayOnRemove = true
    sound.Parent = Camera
    sound:Destroy()
end

local function getClosestPlayer()
    if S.Rage.TargetLock and S.Rage.LockedTarget and S.Rage.LockedTarget.Character then
        local head = S.Rage.LockedTarget.Character:FindFirstChild("Head")
        local h = S.Rage.LockedTarget.Character:FindFirstChild("Humanoid")
        if head and h and h.Health > 0 and canSeeTarget(head) and not isPlayerDowned(S.Rage.LockedTarget) then
            return head
        end
    end

    local closest = nil
    local shortest = math.huge
    local camera = workspace.CurrentCamera

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isPlayerDowned(p) then
            local h = p.Character:FindFirstChild("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            if h and h.Health > 0 and head and canSeeTarget(head) then

                if not S.Rage.NoFovLimit and S.Rage.Fov then
                    local screenPoint, onScreen = camera:WorldToViewportPoint(head.Position)
                    if onScreen then
                        local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                        local mousePos = Vector2.new(screenPoint.X, screenPoint.Y)
                        local distance = (mousePos - center).Magnitude
                        
                        if distance > S.Rage.FovRadius then
                            continue
                        end
                    else
                        continue
                    end
                end

                if isWhitelisted(p) then continue end

                if not isInTargetList(p) then continue end

                local dist = (head.Position - camera.CFrame.Position).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = head
                    if S.Rage.TargetLock then
                        S.Rage.LockedTarget = p
                    end
                end
            end
        end
    end

    return closest
end

local function createTracer(startPos, endPos)
    if not S.Rage.Tracer then return end

    local tracerModel = Instance.new("Model")
    tracerModel.Name = "TracerBeam"

    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(parseColor(S.Rage.TracerColor))
    beam.Width0 = S.Rage.TracerWidth
    beam.Width1 = S.Rage.TracerWidth
    beam.Texture = "rbxassetid://7136858729"
    beam.TextureSpeed = 1
    beam.Brightness = 5
    beam.LightEmission = 3
    beam.FaceCamera = true

    local a0 = Instance.new("Attachment")
    local a1 = Instance.new("Attachment")
    a0.WorldPosition = startPos
    a1.WorldPosition = endPos

    beam.Attachment0 = a0
    beam.Attachment1 = a1

    beam.Parent = tracerModel
    a0.Parent = tracerModel
    a1.Parent = tracerModel
    tracerModel.Parent = workspace

    delay(S.Rage.TracerLifetime, function()
        if tracerModel then tracerModel:Destroy() end
    end)
end

local function shoot(head)
    local tool = getCurrentTool()
    if not tool then return end
    
    local values = tool:FindFirstChild("Values")
    local hitMarker = tool:FindFirstChild("Hitmarker")
    if not values or not hitMarker then return end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
    if not ammo or not storedAmmo then return end
    
    if ammo.Value <= 0 then return end
    
    local localHead = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
    local shootPosition = localHead and (localHead.Position + Vector3.new(0, 10, 0)) or Camera.CFrame.Position
    local hitPosition = head.Position
    local hitDirection = (hitPosition - shootPosition).Unit
    
    if getgenv().Prediction then
        local velocity = head.Velocity or Vector3.zero
        hitPosition = hitPosition + velocity * getgenv().PredictionAmount
        hitDirection = (hitPosition - shootPosition).Unit
    end
    
    local VisualPosition = Camera.CFrame.Position
    local randomKey = RandomString(30) .. "0"
    local args1 = {tick(), randomKey, tool, "FDS9I83", shootPosition, {hitDirection}, false}
    local args2 = {"🧈", tool, randomKey, 1, head, hitPosition, hitDirection}
    
    local GNX_S = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GNX_S")
    local ZFKLF__H = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZFKLF__H")
    
    GNX_S:FireServer(unpack(args1))
    ZFKLF__H:FireServer(unpack(args2))
    
    ammo.Value = math.max(ammo.Value - 1, 0)
    hitMarker:Fire(head)
    storedAmmo.Value = storedAmmo.Value
    
    createTracer(VisualPosition, hitPosition)
    playHitSound()
    
    local player = Players:GetPlayerFromCharacter(head.Parent)
    if player then
        local humanoid = head.Parent:FindFirstChildOfClass("Humanoid")
        showHitNotify(player.Name, 1, head, humanoid, hitPosition, tool)
    end
end
local function setupPlayerFunctions()
    local function findModule()
        for i, v in pairs(game:GetService("StarterPlayer").StarterPlayerScripts:GetDescendants()) do
            if v:IsA("ModuleScript") and v.Name == "XIIX" then
                return v
            end
        end
    end

    local moduleScript = findModule()
    if not moduleScript then return end
    
    local success, module = pcall(require, moduleScript)
    if not success then return end
    
    local ac = module["XIIX"]
    if not ac then return end
    
    local glob = getfenv(ac)["_G"]
    if not glob then return end
    
    local S_Check = glob["S_Check"]
    if not S_Check then return end
    
    local upvals = debug.getupvalues(S_Check)
    if #upvals < 2 then return end
    
    local secondUpval = upvals[2]
    local secondUpvalUpvals = debug.getupvalues(secondUpval)
    if #secondUpvalUpvals < 1 then return end
    
    local stamina = secondUpvalUpvals[1]
    
    if stamina ~= nil then
        hookfunction(stamina, function()
            return 100, 100
        end)
    end
end

local function autoReloadL()
    local RS = game:GetService("ReplicatedStorage")
    local PLR = game:GetService("Players").LocalPlayer
    local remote = RS:FindFirstChild("Events"):FindFirstChild("GNX_R")
    local KEY = "KLWE89U0"

    while S.Player.Reload do
        if PLR.Character then
            for _, tool in pairs(PLR.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("IsGun") then
                    local values = tool:FindFirstChild("Values")
                    if values then
                        local ammo = values:FindFirstChild("SERVER_Ammo")
                        local reserve = values:FindFirstChild("SERVER_StoredAmmo")
                        if ammo and reserve and ammo.Value <= 0 and reserve.Value > 0 then
                            remote:FireServer(tick(), KEY, tool)
                        end
                    end
                end
            end
        end
        wait(0.5)
    end
end

local controls = {
    {section = combatSection, type = "Checkbox", text = "Enable Ragebot", flag = "RageEnabled", default = false, callback = function(s) S.Rage.Enabled = s end},
    {section = combatSection, type = "Slider", text = "FireRate", flag = "FireRate", min = 1, max = 1000, default = 5, callback = function(v) S.Rage.FireRate = v end},
    {section = combatSection, type = "Checkbox", text = "Prediction", flag = "Prediction", default = true, callback = function(s) S.Rage.Prediction = s end},
    {section = combatSection, type = "Slider", text = "Prediction Amount", flag = "PredictionAmount", min = 0.05, max = 0.3, default = 0.1, callback = function(v) S.Rage.PredictionAmount = v end},
    {section = combatSection, type = "Checkbox", text = "Tracer", flag = "TracerEnabled", default = false, callback = function(s) S.Rage.Tracer = s end},
    {section = combatSection, type = "Textbox", text = "255,0,0", placeholder = "Tracer Color (R,G,B)", flag = "TracerColor", callback = function(t) S.Rage.TracerColor = t end},
    {section = combatSection, type = "Slider", text = "Tracer Width", flag = "TracerWidth", min = 0.1, max = 2, default = 0.3, callback = function(v) S.Rage.TracerWidth = v end},
    {section = combatSection, type = "Slider", text = "Tracer Lifetime", flag = "TracerLifetime", min = 0.1, max = 100, default = 0.3, callback = function(v) S.Rage.TracerLifetime = v end},
    {section = combatSection, type = "Checkbox", text = "FOV Circle", flag = "FovEnabled", default = true, callback = function(s) S.Rage.Fov = s end},
    {section = combatSection, type = "Slider", text = "FOV Radius", flag = "FovRadius", min = 10, max = 1500, default = 100, callback = function(v) S.Rage.FovRadius = v end},
    {section = combatSection, type = "Checkbox", text = "No FOV Limit", flag = "NoFovLimit", default = false, callback = function(s) S.Rage.NoFovLimit = s end},
    {section = combatSection, type = "Checkbox", text = "No FOV Limit", flag = "NoFovLimit", default = false, callback = function(s) S.Rage.NoFovLimit = s end},
    {section = combatSection, type = "Checkbox", text = "Target Lock", flag = "TargetLock", default = false, callback = function(s) S.Rage.TargetLock = s if not s then S.Rage.LockedTarget = nil end end},
    {section = combatSection, type = "Textbox", text = "", placeholder = "Target Lock (Player Name)", flag = "TargetTextBox", callback = function(t) S.Rage.TargetTextBox = t end},
    {section = combatSection, type = "Textbox", text = "", placeholder = "Whitelist (Player Name)", flag = "WhitelistTextBox", callback = function(t) S.Rage.WhitelistTextBox = t end},
    {section = combatSection, type = "Checkbox", text = "Downed Check", flag = "DownedCheck", default = true, callback = function(s) S.Rage.DownedCheck = s end},
    {section = combatSection, type = "Checkbox", text = "Visibility Check", flag = "VisibilityCheck", default = true, callback = function(s) S.Rage.VisibilityCheck = s end},
    {section = combatSection, type = "Checkbox", text = "No Fire Rate Limit", flag = "NoFireRateLimit", default = false, callback = function(s) S.Rage.NoFireRateLimit = s end},
    
    {section = visualSection, type = "Checkbox", text = "Headless", flag = "HeadlessEnabled", default = false, callback = function(s) S.Visual.Headless = s applyHeadless() end},
    {section = visualSection, type = "Checkbox", text = "Force Field", flag = "ForceFieldEnabled", default = false, callback = function(s) S.Visual.ForceField = s applyForceField() end},
    {section = visualSection, type = "Textbox", text = "255,0,0", placeholder = "Force Field Color (R,G,B)", flag = "ForceFieldColor", callback = function(t) S.Visual.ForceFieldColor = t if S.Visual.ForceField then applyForceField() end end},
    {section = visualSection, type = "Slider", text = "Force Field Transparency", flag = "ForceFieldTransparency", min = 0, max = 1, default = 0.5, callback = function(v) S.Visual.ForceFieldTransparency = v if S.Visual.ForceField then applyForceField() end end},
    {section = visualSection, type = "Checkbox", text = "Name Tags", flag = "NameTagsEnabled", default = false, callback = function(s) S.Visual.NameTags = s end},
    {section = visualSection, type = "Textbox", text = "255,255,255", placeholder = "Name Tags Color (R,G,B)", flag = "NameTagsColor", callback = function(t) S.Visual.NameTagsColor = t end},
    {section = visualSection, type = "Checkbox", text = "Tool Force Field", flag = "ToolForceField", default = false, callback = function(s) S.Visual.ToolForceField = s if s then applyToolForceField() else restoreTools() end end},
    {section = visualSection, type = "Textbox", text = "0,255,255", placeholder = "Tool Force Field Color (R,G,B)", flag = "ToolForceFieldColor", callback = function(t) S.Visual.ToolForceFieldColor = t if S.Visual.ToolForceField then applyToolForceField() end end},
    {section = visualSection, type = "Slider", text = "Tool Force Field Transparency", flag = "ToolForceFieldTransparency", min = 0, max = 1, default = 0.3, callback = function(v) S.Visual.ToolForceFieldTransparency = v if S.Visual.ToolForceField then applyToolForceField() end end},
    {section = visualSection, type = "Checkbox", text = "Rich Shader", flag = "ShaderEnabled", default = false, callback = function(s) S.Visual.Shader = s updateShader() end},
    {section = visualSection, type = "Dropdown", text = "Shader Type", options = {"Bloom", "Blur", "ColorCorrection", "SunRays", "DepthOfField"}, default = 1, flag = "ShaderType", callback = function(v) S.Visual.ShaderType = v if S.Visual.Shader then updateShader() end end},
    {section = visualSection, type = "Slider", text = "Shader Intensity", flag = "ShaderIntensity", min = 0.1, max = 5.0, default = 1.0, callback = function(v) S.Visual.ShaderIntensity = v if S.Visual.Shader then updateShader() end end},
    {section = visualSection, type = "Textbox", text = "255,255,255", placeholder = "Shader Color (R,G,B)", flag = "ShaderColor", callback = function(t) S.Visual.ShaderColor = t if S.Visual.Shader then updateShader() end end},
    
    {section = playerSection, type = "Checkbox", text = "Infinite Stamina", flag = "InfiniteStamina", default = false, callback = function(s) S.Player.Stamina = s if s then setupPlayerFunctions() end end},
    {section = playerSection, type = "Checkbox", text = "No Fall Damage", flag = "NoFallDamage", default = false, callback = function(s) S.Player.NoFall = s end},
    {section = playerSection, type = "Checkbox", text = "Auto Lockpick", flag = "AutoLockpick", default = false, callback = function(s) S.Player.Lockpick = s end},
    {section = playerSection, type = "Checkbox", text = "Auto Reload", flag = "AutoReload", default = false, callback = function(s) S.Player.Reload = s if s then task.spawn(autoReloadL) end end}
}

for _, c in ipairs(controls) do
    if c.type == "Checkbox" then
        c.section:Checkbox({Text = c.text, Default = c.default, Flag = c.flag, Callback = c.callback})
    elseif c.type == "Slider" then
        c.section:Slider({Text = c.text, Min = c.min, Max = c.max, Default = c.default, Flag = c.flag, Callback = c.callback})
    elseif c.type == "Textbox" then
        c.section:Textbox({Text = c.text, Placeholder = c.placeholder, Flag = c.flag, Callback = c.callback})
    elseif c.type == "Dropdown" then
        c.section:Dropdown({Text = c.text, Options = c.options, Default = c.default, Flag = c.flag, Callback = c.callback})
    end
end

task.spawn(function()
    while true do
        local waitTime = S.Rage.NoFireRateLimit and 0 or (1 / S.Rage.FireRate)
        wait(waitTime)
        
        if S.Rage.Enabled and tick() - S.Rage.LastShot >= waitTime then
            local target = getClosestPlayer()
            if target then
                shoot(target)
                S.Rage.LastShot = tick()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(c)
    c:WaitForChild("Head")
    if S.Visual.Headless then applyHeadless() end
    if S.Visual.ForceField then applyForceField() end
    if S.Visual.ToolForceField then applyToolForceField() end
end)

RunService.Heartbeat:Connect(function()
    if S.Visual.ToolForceField and LocalPlayer.Character then applyToolForceField() end
end)

if LocalPlayer.Character then
    applyHeadless()
    applyForceField()
    if S.Visual.ToolForceField then applyToolForceField() end
end
local originalEquipValues = {}

local function applyNoEquipTime()
    local gcObjects = getgc(true)
    for i, v in pairs(gcObjects) do
        if type(v) == "table" then
            if rawget(v, "EquipTime") then
                if not originalEquipValues[v] then
                    originalEquipValues[v] = {
                        EquipTime = v.EquipTime,
                        EquipAnimSpeed = v.EquipAnimSpeed
                    }
                end
                v.EquipTime = 0
            end
            if rawget(v, "EquipAnimSpeed") then 
                if not originalEquipValues[v] then
                    originalEquipValues[v] = {
                        EquipTime = v.EquipTime,
                        EquipAnimSpeed = v.EquipAnimSpeed
                    }
                end
                v.EquipAnimSpeed = 999
            end
        end
    end
end

local function restoreEquipTime()
    for table, originalValues in pairs(originalEquipValues) do
        if table and type(table) == "table" then
            if rawget(table, "EquipTime") then
                table.EquipTime = originalValues.EquipTime
            end
            if rawget(table, "EquipAnimSpeed") then
                table.EquipAnimSpeed = originalValues.EquipAnimSpeed
            end
        end
    end
    originalEquipValues = {}
end

S.Player.NoEquipTime = false

playerSection:Checkbox({
    Text = "No Equip Time",
    Default = false,
    Flag = "NoEquipTime",
    Callback = function(state)
        S.Player.NoEquipTime = state
        if state then
            applyNoEquipTime()
        else
            restoreEquipTime()
        end
    end
})



local Players = game:GetService("Players")
local Library = {}
Library.Open = true
Library.Accent = Color3.fromRGB(255, 154, 255)
Library.ScreenGUI = Instance.new("ScreenGui", game:GetService("CoreGui"))
Library.UIFont = Font.new("rbxassetid://12187371840")

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Stats = {}
do
    local lastTime = tick()
    local frameCount = 0
    RunService.RenderStepped:Connect(function()
        frameCount += 1
        local now = tick()
        if now - lastTime >= 1 then
            Stats.FPS = frameCount
            frameCount = 0
            lastTime = now
        end
    end)
end

function Stats:GetPing()
    return math.floor(LocalPlayer:GetNetworkPing() * 1000)
end

local ClientID = "Client-" .. LocalPlayer.UserId

function Library:Watermark(Properties)
    local Watermark = { Name = Properties.Name or "ske.gg" }

    local Outline = Instance.new("Frame", Library.ScreenGUI)
    Outline.Name = "Outline"
    Outline.AutomaticSize = Enum.AutomaticSize.X
    Outline.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Outline.Position = UDim2.new(0.01, 0, 0.02, 0)
    Outline.Size = UDim2.new(0, 0, 0, 18)
    Outline.Visible = true

    local Inline = Instance.new("Frame", Outline)
    Inline.Name = "Inline"
    Inline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Inline.Position = UDim2.new(0, 1, 0, 1)
    Inline.Size = UDim2.new(1, -2, 1, -2)

    local Value = Instance.new("TextLabel", Inline)
    Value.Name = "Value"
    Value.FontFace = Library.UIFont
    Value.Text = Watermark.Name
    Value.TextColor3 = Color3.fromRGB(255, 255, 255)
    Value.TextSize = 14
    Value.TextXAlignment = Enum.TextXAlignment.Left
    Value.AutomaticSize = Enum.AutomaticSize.X
    Value.BackgroundTransparency = 1
    Value.Size = UDim2.new(0, 0, 1, 0)

    local UIPadding = Instance.new("UIPadding", Value)
    UIPadding.PaddingLeft = UDim.new(0, 5)
    UIPadding.PaddingRight = UDim.new(0, 5)
    UIPadding.PaddingTop = UDim.new(0, 1)

    local Accent = Instance.new("Frame", Outline)
    Accent.Name = "Accent"
    Accent.BackgroundColor3 = Library.Accent
    Accent.Size = UDim2.new(1, 0, 0, 1)

    RunService.RenderStepped:Connect(function()
        Value.Text = string.format(
            "%s | fps: %d | ping: %d ms | client: %s",
            Watermark.Name,
            Stats.FPS or 0,
            Stats:GetPing(),
            ClientID
        )
    end)

    function Watermark:SetVisible(State)
        Outline.Visible = State
    end

    return Watermark
end

local MyWatermark = Library:Watermark({ Name = "ske.gg" })
MyWatermark:SetVisible(true)
warn("ske.gg loaded")
local ConfigSystem = {
    CurrentConfig = "default",
    Configs = {},
    AutoLoad = false
}

local function SaveConfig(name)
    if not name or name == "" then name = "default" end
    
    local configData = {
        Rage = S.Rage,
        Visual = S.Visual, 
        Player = S.Player
    }
    
    if writefile then
        writefile("ske_gg_" .. name .. ".json", game:GetService("HttpService"):JSONEncode(configData))
        warn("Config saved: " .. name)
    end
end

local function LoadConfig(name)
    if not name or name == "" then name = "default" end
    
    if readfile then
        local success, data = pcall(function()
            return readfile("ske_gg_" .. name .. ".json")
        end)
        
        if success then
            local configData = game:GetService("HttpService"):JSONDecode(data)
            
            S.Rage = configData.Rage or S.Rage
            S.Visual = configData.Visual or S.Visual
            S.Player = configData.Player or S.Player
            
            if S.Player.NoEquipTime then
                applyNoEquipTime()
            else
                restoreEquipTime()
            end
            
            if S.Visual.Headless then applyHeadless() end
            if S.Visual.ForceField then applyForceField() end
            if S.Visual.ToolForceField then applyToolForceField() else restoreTools() end
            if S.Visual.Shader then updateShader() end
            
            warn("Config loaded: " .. name)
        else
            warn("Config not found: " .. name)
        end
    end
end

local function DeleteConfig(name)
    if not name or name == "" then name = "default" end
    
    if delfile then
        local success = pcall(function()
            delfile("ske_gg_" .. name .. ".json")
        end)
        
        if success then
            warn("Config deleted: " .. name)
            UpdateConfigList()
        else
            warn("Config not found: " .. name)
        end
    end
end

local function UpdateConfigList()
    if listfiles then
        ConfigSystem.Configs = {}
        local success, files = pcall(function()
            return listfiles("")
        end)
        
        if success then
            for _, file in ipairs(files) do
                if string.find(file, "ske_gg_") then
                    local configName = string.gsub(file, "ske_gg_", "")
                    configName = string.gsub(configName, ".json", "")
                    table.insert(ConfigSystem.Configs, configName)
                end
            end
        end
    end
end

local configSection = uiSettingsTab:AddLeftGroupbox('Configuration')

configSection:AddLabel("Config Management")

local configNameInput = configSection:Textbox({
    Text = "default",
    Placeholder = "Config Name",
    Flag = "ConfigName",
    Callback = function(text)
        ConfigSystem.CurrentConfig = text
    end
})

configSection:Button({
    Text = "Save Config",
    Func = function()
        SaveConfig(ConfigSystem.CurrentConfig)
        UpdateConfigList()
    end
})

configSection:Button({
    Text = "Load Config",
    Func = function()
        LoadConfig(ConfigSystem.CurrentConfig)
    end
})

configSection:Button({
    Text = "Delete Config",
    Func = function()
        DeleteConfig(ConfigSystem.CurrentConfig)
    end
})

configSection:AddLabel("Available Configs:")

local configLabels = {}

local function RefreshConfigDisplay()
    for _, label in ipairs(configLabels) do
        label:Remove()
    end
    configLabels = {}
    
    for i, configName in ipairs(ConfigSystem.Configs) do
        local label = configSection:AddLabel(configName)
        table.insert(configLabels, label)
    end
end

configSection:Button({
    Text = "Refresh List",
    Func = function()
        UpdateConfigList()
        RefreshConfigDisplay()
    end
})

configSection:Checkbox({
    Text = "Auto Load",
    Default = false,
    Flag = "AutoLoad",
    Callback = function(state)
        ConfigSystem.AutoLoad = state
        if state then
            LoadConfig("default")
        end
    end
})

task.spawn(function()
    wait(1)
    UpdateConfigList()
    RefreshConfigDisplay()
    
    if ConfigSystem.AutoLoad then
        LoadConfig("default")
    end
end)
