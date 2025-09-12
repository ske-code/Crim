local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GNX_S = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GNX_S")
local ZFKLF__H = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZFKLF__H")

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
    Title = 'ske.gg - Criminality',
    Center = true,
    AutoShow = true,
    Resizable = true,
    ShowCustomCursor = true,
    NotifySide = "Left",
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Ragebot = Window:AddTab('Ragebot'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local RageLeft = Tabs.Ragebot:AddLeftGroupbox('Ragebot Settings')

getgenv().RageEnabled = false
getgenv().FireRate = 5
getgenv().Prediction = true
getgenv().PredictionAmount = 0.1
getgenv().TracerColor = Color3.fromRGB(255, 0, 0)
getgenv().TracerWidth = 0.3
getgenv().TracerLifetime = 0.3
getgenv().VisibilityCheck = true
getgenv().LastShot = 0

RageLeft:AddToggle('RageEnabled', {
    Text = 'Enable Ragebot',
    Default = false,
    Callback = function(Value)
        getgenv().RageEnabled = Value
    end
})

RageLeft:AddSlider('FireRate', {
    Text = 'FireRate',
    Default = 5,
    Min = 1,
    Max = 450,
    Rounding = 0,
    Callback = function(Value)
        getgenv().FireRate = Value
    end
})

RageLeft:AddToggle('Prediction', {
    Text = 'Prediction',
    Default = true,
    Callback = function(Value)
        getgenv().Prediction = Value
    end
})

RageLeft:AddSlider('PredictionAmount', {
    Text = 'Prediction Amount',
    Default = 0.1,
    Min = 0.05,
    Max = 0.3,
    Rounding = 2,
    Callback = function(Value)
        getgenv().PredictionAmount = Value
    end
})

RageLeft:AddToggle('VisibilityCheck', {
    Text = 'Visibility Check',
    Default = true,
    Callback = function(Value)
        getgenv().VisibilityCheck = Value
    end
})


RageLeft:AddSlider('TracerWidth', {
    Text = 'Tracer Width',
    Default = 0.3,
    Min = 0.1,
    Max = 2,
    Rounding = 1,
    Callback = function(Value)
        getgenv().TracerWidth = Value
    end
})

RageLeft:AddSlider('TracerLifetime', {
    Text = 'Tracer Lifetime',
    Default = 0.3,
    Min = 0.1,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        getgenv().TracerLifetime = Value
    end
})
local LogsRight = Tabs.Ragebot:AddRightGroupbox('Hit Logs')

getgenv().HitNotifyEnabled = true
getgenv().HitNotifyDuration = 3
getgenv().HitNotifyColor = Color3.fromRGB(0, 255, 0)

LogsRight:AddToggle('HitNotifyEnabled', {
    Text = 'Hit Notify',
    Default = true,
    Callback = function(Value)
        getgenv().HitNotifyEnabled = Value
    end
})

LogsRight:AddSlider('HitNotifyDuration', {
    Text = 'Notify Duration',
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        getgenv().HitNotifyDuration = Value
    end
})

LogsRight:AddToggle('HitNotifyColorToggle', {
    Text = 'Notify Color',
    Default = false,
    Callback = function(Value) end
})

function showHitNotify(targetName, damage, hitPart)
    if not getgenv().HitNotifyEnabled then return end
    
    local partName = "Body"
    if hitPart then
        if hitPart.Name == "Head" then
            partName = "HEAD"
        elseif hitPart.Name == "Torso" then
            partName = "BODY"
        elseif hitPart.Name:find("Arm") or hitPart.Name:find("Leg") then
            partName = "LIMB"
        end
    end
    
    local message = string.format("Hit %s [%s] for %d damage", targetName, partName, damage)
    Library:Notify(message, getgenv().HitNotifyDuration)
end
function RandomString(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    local result = ""
    for i = 1, length do
        result = result .. charset:sub(math.random(1, #charset), math.random(1, #charset))
    end
    return result
end

RageLeft:AddToggle('TracerEnabled', {
    Text = 'Tracer',
    Default = false,
    Callback = function(Value)
        getgenv().TracerEnabled = Value
    end
}):AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(255, 0, 0),  
    Callback = function(Value)
        getgenv().TracerColor = Value  
    end
})

function playHitSound()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://6534948092"
    sound.Volume = 1
    sound.PlayOnRemove = true
    sound.Parent = Camera
    sound:Destroy()
end
getgenv().TracerOffset = Vector3.new(0, 0, 0)

RageLeft:AddSlider('TracerOffsetX', {
    Text = 'Tracer Offset X',
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(v)
        getgenv().TracerOffset = Vector3.new(v, getgenv().TracerOffset.Y, getgenv().TracerOffset.Z)
    end
})

RageLeft:AddSlider('TracerOffsetY', {
    Text = 'Tracer Offset Y',
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(v)
        getgenv().TracerOffset = Vector3.new(getgenv().TracerOffset.X, v, getgenv().TracerOffset.Z)
    end
})

RageLeft:AddSlider('TracerOffsetZ', {
    Text = 'Tracer Offset Z',
    Default = 0,
    Min = 0,
    Max = 50,
    Rounding = 1,
    Callback = function(v)
        getgenv().TracerOffset = Vector3.new(getgenv().TracerOffset.X, getgenv().TracerOffset.Y, v)
    end
})

function canSeeTarget(targetPart)
    if not getgenv().VisibilityCheck then return true end
    
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

local RageRight = Tabs.Ragebot:AddRightGroupbox('Target Settings')

getgenv().TargetLock = false
getgenv().LockedTarget = nil
getgenv().TargetList = {}
getgenv().Whitelist = {}

RageRight:AddToggle('TargetLock', {
    Text = 'Target Lock',
    Default = false,
    Callback = function(Value)
        getgenv().TargetLock = Value
        if not Value then
            getgenv().LockedTarget = nil
        end
    end
})

RageRight:AddDropdown('TargetList', {
    Values = {},
    Default = 1,
    Multi = true,
    Text = 'Target List',
    Callback = function(Value, Key, State)
        getgenv().TargetList = {}
        for name, selected in pairs(Options.TargetList.Value) do
            if selected then
                table.insert(getgenv().TargetList, name)
            end
        end
    end
})

RageRight:AddDropdown('Whitelist', {
    Values = {},
    Default = 1,
    Multi = true,
    Text = 'Whitelist',
    Callback = function(Value, Key, State)
        getgenv().Whitelist = {}
        for name, selected in pairs(Options.Whitelist.Value) do
            if selected then
                table.insert(getgenv().Whitelist, name)
            end
        end
    end
})

function isWhitelisted(player)
    for _, whitelistedName in pairs(getgenv().Whitelist) do
        if player.Name == whitelistedName then
            return true
        end
    end
    return false
end

function isInTargetList(player)
    if #getgenv().TargetList == 0 then return true end
    for _, targetName in pairs(getgenv().TargetList) do
        if player.Name == targetName then
            return true
        end
    end
    return false
end

function getClosest()
    local closest = nil
    local shortest = math.huge
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isWhitelisted(p) and isInTargetList(p) then
            local h = p.Character:FindFirstChild("Humanoid")
            local head = p.Character:FindFirstChild("Head")
            
            if h and h.Health > 0 and head then
                if canSeeTarget(head) then
                    local dist = (head.Position - Camera.CFrame.Position).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = head
                        if getgenv().TargetLock then
                            getgenv().LockedTarget = p
                        end
                    end
                end
            end
        end
    end
    
    return closest
end

function updatePlayerLists()
    local playerNames = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    Options.TargetList:SetValues(playerNames)
    Options.Whitelist:SetValues(playerNames)
end

updatePlayerLists()
Players.PlayerAdded:Connect(updatePlayerLists)
Players.PlayerRemoving:Connect(updatePlayerLists)
function getCurrentTool()
    if LocalPlayer.Character then
        for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
            if tool:IsA("Tool") then
                return tool
            end
        end
    end
    return nil
end
function createTracer(startPos, endPos)
    if not getgenv().TracerEnabled then return end

    local offset = getgenv().TracerOffset or Vector3.zero
    startPos = startPos + offset

    local tracerModel = Instance.new("Model")
    tracerModel.Name = "TracerBeam"

    local beam = Instance.new("Beam")
    beam.Color = ColorSequence.new(getgenv().TracerColor)
    beam.Width0 = getgenv().TracerWidth
    beam.Width1 = getgenv().TracerWidth
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
    tracerModel.Parent = Workspace

    delay(getgenv().TracerLifetime, function()
        tracerModel:Destroy()
    end)

    return tracerModel
end

function shoot(head)
    local tool = getCurrentTool()
    if not tool then return end
    
    local values = tool:FindFirstChild("Values")
    local hitMarker = tool:FindFirstChild("Hitmarker")
    if not values or not hitMarker then return end
    
    local ammo = values:FindFirstChild("SERVER_Ammo")
    local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
    if not ammo or not storedAmmo or ammo.Value <= 0 then return end
    
    local hitPosition = head.Position
    local hitDirection = (hitPosition - Camera.CFrame.Position).Unit
    
    if getgenv().Prediction then
        local velocity = head.Velocity or Vector3.zero
        hitPosition = hitPosition + velocity * getgenv().PredictionAmount
        hitDirection = (hitPosition - Camera.CFrame.Position).Unit
    end
    
    local randomKey = RandomString(30) .. "0"
    local args1 = {tick(), randomKey, tool, "FDS9I83", Camera.CFrame.Position, {hitDirection}, false}
    local args2 = {"🧈", tool, randomKey, 1, head, hitPosition, hitDirection}
    
    GNX_S:FireServer(unpack(args1))
    ZFKLF__H:FireServer(unpack(args2))
    
    ammo.Value = math.max(ammo.Value - 1, 0)
    hitMarker:Fire(head)
    storedAmmo.Value = storedAmmo.Value
    
    createTracer(Camera.CFrame.Position, hitPosition)
    playHitSound()
    
    local player = Players:GetPlayerFromCharacter(head.Parent)
    if player then
        showHitNotify(player.Name, 1, head)
    end
end

task.spawn(function()
    while true do
        local waitTime = 1 / getgenv().FireRate
        task.wait(waitTime)
        
        if getgenv().RageEnabled and tick() - getgenv().LastShot >= waitTime then
            local target = getClosest()
            if target then
                shoot(target)
                getgenv().LastShot = tick()
            end
        end
    end
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()
local VisualTab = Window:AddTab('Visuals')
local VisualLeft = VisualTab:AddLeftGroupbox('Player Modifications')

getgenv().HeadlessEnabled = false
getgenv().ForceFieldEnabled = false
getgenv().ForceFieldColor = Color3.fromRGB(255, 0, 0)
getgenv().ForceFieldTransparency = 0.5

VisualLeft:AddToggle('HeadlessEnabled', {
    Text = 'Headless',
    Default = false,
    Callback = function(Value)
        getgenv().HeadlessEnabled = Value
        applyHeadless()
    end
})

VisualLeft:AddToggle('ForceFieldEnabled', {
    Text = 'Force Field',
    Default = false,
    Callback = function(Value)
        getgenv().ForceFieldEnabled = Value
        applyForceField()
    end
})

VisualLeft:AddToggle('ForceFieldColorToggle', {
    Text = 'Force Field Color',
    Default = false,
    Callback = function(Value) end
}):AddColorPicker('ForceFieldColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        getgenv().ForceFieldColor = Value
        if getgenv().ForceFieldEnabled then
            applyForceField()
        end
    end
})

VisualLeft:AddSlider('ForceFieldTransparency', {
    Text = 'Force Field Transparency',
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        getgenv().ForceFieldTransparency = Value
        if getgenv().ForceFieldEnabled then
            applyForceField()
        end
    end
})

function applyHeadless()
    if not LocalPlayer.Character then return end
    
    local head = LocalPlayer.Character:FindFirstChild("Head")
    if head then
        head.Transparency = getgenv().HeadlessEnabled and 1 or 0
        
        if getgenv().HeadlessEnabled then
            for _, face in pairs(head:GetChildren()) do
                if face:IsA("Decal") or face:IsA("Texture") then
                    face:Destroy()
                end
            end
        else
            head.Transparency = 0
        end
    end
end

function applyForceField()
    if not LocalPlayer.Character then return end
    
    for _, part in pairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "Head" and part.Name ~= "HumanoidRootPart" then
            if getgenv().ForceFieldEnabled then
                part.Material = Enum.Material.ForceField
                part.Color = getgenv().ForceFieldColor
                part.Transparency = getgenv().ForceFieldTransparency
            else
                part.Material = Enum.Material.Plastic
                part.Transparency = 0
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Head")
    character:WaitForChild("HumanoidRootPart")
    
    if getgenv().HeadlessEnabled then
        applyHeadless()
    end
    
    if getgenv().ForceFieldEnabled then
        applyForceField()
    end
end)

if LocalPlayer.Character then
    applyHeadless()
    applyForceField()
end
local VisualRight = VisualTab:AddRightGroupbox('ESP Settings')

getgenv().ESPEnabled = false
getgenv().ESPColor = Color3.fromRGB(255, 0, 0)
getgenv().ArrowsEnabled = false
getgenv().HighlightEnabled = false
getgenv().HealthBarEnabled = false
getgenv().NameTagsEnabled = false
getgenv().ShowDisplayName = false

VisualRight:AddToggle('ESPEnabled', {
    Text = 'ESP Enabled',
    Default = false,
    Callback = function(Value)
        getgenv().ESPEnabled = Value
        updateESP()
    end
})

VisualRight:AddToggle('ESPColorToggle', {
    Text = 'ESP Color',
    Default = false,
    Callback = function(Value) end
}):AddColorPicker('ESPColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        getgenv().ESPColor = Value
        updateESP()
    end
})

VisualRight:AddToggle('ArrowsEnabled', {
    Text = 'Arrows',
    Default = false,
    Callback = function(Value)
        getgenv().ArrowsEnabled = Value
        updateESP()
    end
})

VisualRight:AddToggle('HighlightEnabled', {
    Text = 'Highlight',
    Default = false,
    Callback = function(Value)
        getgenv().HighlightEnabled = Value
        updateESP()
    end
})

VisualRight:AddToggle('HealthBarEnabled', {
    Text = 'Health Bar',
    Default = false,
    Callback = function(Value)
        getgenv().HealthBarEnabled = Value
        updateESP()
    end
})

VisualRight:AddToggle('NameTagsEnabled', {
    Text = 'Name Tags',
    Default = false,
    Callback = function(Value)
        getgenv().NameTagsEnabled = Value
        updateESP()
    end
})

VisualRight:AddToggle('ShowDisplayName', {
    Text = 'Use Display Name',
    Default = false,
    Callback = function(Value)
        getgenv().ShowDisplayName = Value
        updateESP()
    end
})

local arrows = {}
local highlights = {}
local healthBars = {}
local nameTags = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game:GetService("CoreGui")

function updateESP()
    if not getgenv().ESPEnabled then
        clearESP()
        return
    end

    local camera = workspace.CurrentCamera
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoid and humanoidRootPart and humanoid.Health > 0 then
                local head = player.Character:FindFirstChild("Head")
                if head then
                    local position, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                    
                    if onScreen then
                        -- Arrows
                        if getgenv().ArrowsEnabled then
                            if not arrows[player] then
                                createArrow(player)
                            end
                            updateArrow(player, position)
                        else
                            if arrows[player] then
                                arrows[player].Visible = false
                            end
                        end

                        -- Highlight
                        if getgenv().HighlightEnabled then
                            if not highlights[player] then
                                createHighlight(player)
                            else
                                highlights[player].FillColor = getgenv().ESPColor
                                highlights[player].Adornee = player.Character
                            end
                        else
                            if highlights[player] then
                                highlights[player].Adornee = nil
                            end
                        end

                        -- Health Bar
                        if getgenv().HealthBarEnabled then
                            if not healthBars[player] then
                                createHealthBar(player)
                            end
                            updateHealthBar(player, position)
                        else
                            if healthBars[player] then
                                healthBars[player].Visible = false
                            end
                        end

                        -- Name Tags
                        if getgenv().NameTagsEnabled then
                            if not nameTags[player] then
                                createNameTag(player)
                            end
                            updateNameTag(player, position)
                        else
                            if nameTags[player] then
                                nameTags[player].Visible = false
                            end
                        end
                    else
                        clearPlayerESP(player)
                    end
                end
            else
                clearPlayerESP(player)
            end
        else
            clearPlayerESP(player)
        end
    end
end

function createArrow(player)
    if arrows[player] then return end
    
    local arrow = Drawing.new("Triangle")
    arrow.Color = getgenv().ESPColor
    arrow.Filled = true
    arrow.Thickness = 1
    arrow.Visible = false
    arrows[player] = arrow
end

function updateArrow(player, position)
    local arrow = arrows[player]
    if not arrow then return end
    
    local size = 10
    arrow.PointA = Vector2.new(position.X, position.Y - size)
    arrow.PointB = Vector2.new(position.X - size, position.Y + size)
    arrow.PointC = Vector2.new(position.X + size, position.Y + size)
    arrow.Visible = true
end

function createHighlight(player)
    if highlights[player] then return end
    
    local highlight = Instance.new("Highlight")
    highlight.FillColor = getgenv().ESPColor
    highlight.FillTransparency = 0
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.OutlineTransparency = 1
    highlight.Parent = screenGui
    highlights[player] = highlight
end

function createHealthBar(player)
    if healthBars[player] then return end
    
    local bar = Drawing.new("Square")
    bar.Color = Color3.fromRGB(0, 255, 0)
    bar.Filled = true
    bar.Thickness = 1
    bar.Visible = false
    bar.Size = Vector2.new(30, 4)
    healthBars[player] = bar
end

function updateHealthBar(player, position)
    local bar = healthBars[player]
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if bar and humanoid then
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        bar.Size = Vector2.new(30 * healthPercent, 4)
        bar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
        bar.Position = Vector2.new(position.X - 15, position.Y - 30)
        bar.Visible = true
    end
end

function createNameTag(player)
    if nameTags[player] then return end
    
    local nameTag = Drawing.new("Text")
    nameTag.Color = getgenv().ESPColor
    nameTag.Size = 14
    nameTag.Outline = true
    nameTag.OutlineColor = Color3.new(0, 0, 0)
    nameTag.Visible = false
    nameTags[player] = nameTag
end

function updateNameTag(player, position)
    local nameTag = nameTags[player]
    if nameTag then
        local name = getgenv().ShowDisplayName and player.DisplayName or player.Name
        nameTag.Text = name
        nameTag.Position = Vector2.new(position.X - nameTag.TextBounds.X / 2, position.Y - 45)
        nameTag.Visible = true
    end
end

function clearPlayerESP(player)
    if arrows[player] then
        arrows[player]:Destroy()
        arrows[player] = nil
    end
    if highlights[player] then
        highlights[player]:Destroy()
        highlights[player] = nil
    end
    if healthBars[player] then
        healthBars[player]:Destroy()
        healthBars[player] = nil
    end
    if nameTags[player] then
        nameTags[player]:Destroy()
        nameTags[player] = nil
    end
end

function clearESP()
    for player in pairs(arrows) do
        clearPlayerESP(player)
    end
end

task.spawn(function()
    while true do
        if getgenv().ESPEnabled then
            updateESP()
        else
            clearESP()
        end
        wait(0.1)
    end
end)

Players.PlayerAdded:Connect(function(player)
    if getgenv().ESPEnabled then
        wait(1)
        updateESP()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    clearPlayerESP(player)
end)

LocalPlayer.CharacterRemoving:Connect(function()
    if getgenv().ESPEnabled then
        clearESP()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().ESPEnabled then
        wait(1)
        updateESP()
    end
end)
