local repo = 'https://raw.githubusercontent.com/yourmakerqkeso/EverloseLib/main/'

Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

Window = Library:CreateWindow({
    Title = "LQN.CC",
    Center = true,
    AutoShow = true,
    TabPadding = 4,
    MenuFadeTime = 0.2
})

Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Infection = Window:AddTab('Infection'),
    Farm = Window:AddTab('Farm'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings')
}

plrs = game:GetService("Players")
me = plrs.LocalPlayer
run = game:GetService("RunService")
input = game:GetService("UserInputService")
camera = workspace.CurrentCamera
tween = game:GetService("TweenService")
functions = {}
remotes = {}

-- 🧹 Runtime AutoCleaner — вставлен сюда
if not shared._RuntimeCleanerStarted then
    shared._RuntimeCleanerStarted = true
    shared._RuntimeGarbage = {}

    function shared._TrackRuntime(obj)
        table.insert(shared._RuntimeGarbage, obj)
        return obj
    end

    task.spawn(function()
        while true do
            task.wait(1)
            for i, v in ipairs(shared._RuntimeGarbage) do
                local ok, err = pcall(function()
                    if typeof(v) == "RBXScriptConnection" and v.Connected then
                        v:Disconnect()
                    elseif typeof(v) == "thread" and coroutine.status(v) ~= "dead" then
                        coroutine.close(v)
                    elseif typeof(v) == "Instance" and v.Destroy then
                        v:Destroy()
                    end
                end)
                shared._RuntimeGarbage[i] = nil
            end
        end
    end)
end

-- 👇 Твой дальнейший код продолжается как есть:
SectionSettings = {
    SilentAim = {
        DrawSize = 50,
        TargetPart = "Head",
        CheckWhitelist = false,
        CheckWall = false,
        UseHitChance = false,
        HitChance = 80,
        CheckTeam = false,
        DrawCircle = false,
        DrawColor = Color3.fromRGB(255, 0, 0),
        HighlightEnabled = false,
        HighlightColor = Color3.fromRGB(255, 0, 0)
    },
    MeleeAura = {
        ShowAnim = true,
        Distance = 1,
        TargetPart = {"Head"},
        CheckWhitelist = false,
        CheckTeam = false,
        HighlightEnabled = false,
        HighlightColor = Color3.fromRGB(255, 0, 0),
        SortMethod = "Distance",
        CheckDowned = false,
    },
    Ragebot = {
        CheckWhitelist = false,
        CheckTarget = false,
        CheckTeam = false,
        DownedCheck = true,
        HighlightEnabled = false,
        HighlightColor = Color3.fromRGB(255, 0, 0)
    },
    AimBot = {
        Draw = false,
        DrawSize = 50,
        DrawColor = Color3.fromRGB(255, 0, 0),
        TargetPart = "Head",
        CheckWall = false,
        CheckTeam = false,
        CheckWhitelist = false,
        Smooth = false,
        SmoothSize = 0.5,
        Velocity = false
    },
    PepperSprayAura = {
        CheckWhitelist = false
    }
}

ValidAimbotTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ValidSilentTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ValidMeleeTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
ValidMeleeReachTargetParts = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
remote1 = game:GetService("ReplicatedStorage").Events["XMHH.2"]
remote2 = game:GetService("ReplicatedStorage").Events["XMHH2.2"]

CombatLeft = Tabs.Combat:AddLeftGroupbox('Whitelist & Target')
CombatLeft5 = Tabs.Combat:AddLeftGroupbox('Heat Vision')
CombatLeft1 = Tabs.Combat:AddLeftGroupbox('MeleeAura')
CombatRight4 = Tabs.Combat:AddRightGroupbox('MeleeReach')
CombatRight = Tabs.Combat:AddRightGroupbox('Aimbot')
CombatLeft2 = Tabs.Combat:AddLeftGroupbox('Silent Aim')
CombatRight2 = Tabs.Combat:AddRightGroupbox('Ragebot')
CombatLeft3 = Tabs.Combat:AddLeftGroupbox('Control c4, rocket')
CombatRight3 = Tabs.Combat:AddRightGroupbox('PepperSpray settings (Guns)')
CombatLeft4 = Tabs.Combat:AddLeftGroupbox('Gun Mods')

GlobalWhiteList = {}
GlobalTarget = {}
HighlightStorage = {}

function UpdateHighlight(player, isWhitelisted, isTargeted, whitelistColor, targetColor)
    if not player.Character then return end
    if HighlightStorage[player] then
        HighlightStorage[player]:Destroy()
        HighlightStorage[player] = nil
    end
    if isWhitelisted or isTargeted then
        highlight = Instance.new("Highlight")
        highlight.Adornee = player.Character
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.FillColor = isTargeted and targetColor or whitelistColor
        highlight.OutlineColor = isTargeted and targetColor or whitelistColor
        highlight.Parent = player.Character
        HighlightStorage[player] = highlight
    end
end

function UpdateAllHighlights()
    whitelistColor = (Options.WhitelistColorPicker and Options.WhitelistColorPicker.Value) or Color3.new(0, 1, 0)
    targetColor = (Options.TargetColorPicker and Options.TargetColorPicker.Value) or Color3.new(1, 0, 0)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        isWhitelisted = false
        isTargeted = false
        for name, _ in pairs(GlobalWhiteList) do
            if name == player.Name then isWhitelisted = true end
        end
        for name, _ in pairs(GlobalTarget) do
            if name == player.Name then isTargeted = true end
        end
        UpdateHighlight(player, isWhitelisted, isTargeted, whitelistColor, targetColor)
    end
end

CombatLeft:AddDropdown('GlobalWhiteListDropdown', {
    SpecialType = 'Player',
    Multi = true,
    Text = 'Whitelist Players',
    Callback = function(Value)
        GlobalWhiteList = Value
        task.wait()
        UpdateAllHighlights()
    end
})

CombatLeft:AddDropdown('GlobalTargetDropdown', {
    SpecialType = 'Player',
    Multi = true,
    Text = 'Target Players',
    Callback = function(Value)
        GlobalTarget = Value
        task.wait()
        UpdateAllHighlights()
    end
})

CombatLeft:AddLabel('Whitelist Color'):AddColorPicker('WhitelistColorPicker', {
    Default = Color3.new(0, 1, 0),
    Title = 'Whitelist Highlight',
    Transparency = 0,
    Callback = function()
        task.wait()
        UpdateAllHighlights()
    end
})

CombatLeft:AddLabel('Target Color'):AddColorPicker('TargetColorPicker', {
    Default = Color3.new(1, 0, 0),
    Title = 'Target Highlight',
    Transparency = 0,
    Callback = function()
        task.wait()
        UpdateAllHighlights()
    end
})

game:GetService("Players").PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait()
        UpdateAllHighlights()
    end)
end)

game:GetService("Players").PlayerRemoving:Connect(function(player)
    if HighlightStorage[player] then
        HighlightStorage[player]:Destroy()
        HighlightStorage[player] = nil
    end
end)

game:GetService("RunService").Heartbeat:Connect(function()
    if Options.WhitelistColorPicker and Options.TargetColorPicker then
        UpdateAllHighlights()
        return
    end
end)

HighlightMelee = Instance.new("BillboardGui")
HighlightMelee.Size = UDim2.new(4, 0, 6, 0)
HighlightMelee.AlwaysOnTop = true
HighlightMelee.Enabled = false
HighlightMelee.Parent = game.CoreGui
BoxMelee = Instance.new("Frame", HighlightMelee)
BoxMelee.Size = UDim2.new(1, 0, 1, 0)
BoxMelee.BackgroundColor3 = SectionSettings.MeleeAura.HighlightColor
BoxMelee.BackgroundTransparency = 0.7
BoxMelee.BorderSizePixel = 2

HighlightSilent = Instance.new("BillboardGui")
HighlightSilent.Size = UDim2.new(4, 0, 6, 0)
HighlightSilent.AlwaysOnTop = true
HighlightSilent.Enabled = false
HighlightSilent.Parent = game.CoreGui
BoxSilent = Instance.new("Frame", HighlightSilent)
BoxSilent.Size = UDim2.new(1, 0, 1, 0)
BoxSilent.BackgroundColor3 = SectionSettings.SilentAim.HighlightColor
BoxSilent.BackgroundTransparency = 0.7
BoxSilent.BorderSizePixel = 2

HighlightRage = Instance.new("BillboardGui")
HighlightRage.Size = UDim2.new(4, 0, 6, 0)
HighlightRage.AlwaysOnTop = true
HighlightRage.Enabled = false
HighlightRage.Parent = game.CoreGui
BoxRage = Instance.new("Frame", HighlightRage)
BoxRage.Size = UDim2.new(1, 0, 1, 0)
BoxRage.BackgroundColor3 = SectionSettings.Ragebot.HighlightColor
BoxRage.BackgroundTransparency = 0.7
BoxRage.BorderSizePixel = 2

function UpdateHighlightMelee(target)
    HighlightMelee.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
    HighlightMelee.Enabled = functions.meleeauraF and SectionSettings.MeleeAura.HighlightEnabled and target ~= nil
    BoxMelee.BackgroundColor3 = SectionSettings.MeleeAura.HighlightColor
end

function UpdateHighlightSilent(target)
    HighlightSilent.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
    HighlightSilent.Enabled = functions.silentaimF and SectionSettings.SilentAim.HighlightEnabled and target ~= nil
    BoxSilent.BackgroundColor3 = SectionSettings.SilentAim.HighlightColor
end

function UpdateHighlightRage(target)
    HighlightRage.Adornee = target and target:FindFirstChild("HumanoidRootPart") or nil
    HighlightRage.Enabled = RagebotF and SectionSettings.Ragebot.HighlightEnabled and target ~= nil
    BoxRage.BackgroundColor3 = SectionSettings.Ragebot.HighlightColor
end

CombatLeft1:AddToggle('MeleeAuraToggle', {
    Text = 'Melee Aura',
    Default = false,
    Callback = function(Value)
        functions.meleeauraF = Value
        if Value then
            LastTick = tick()
            AttachTick = tick()
            AttachCD = {["Fists"] = .35, ["BBaton"] = .5, ["__ZombieFists1"] = .35, ["__ZombieFists2"] = .37, ["__ZombieFists3"] = .22, ["__ZombieFists4"] = .4, ["__XFists"] = .35, ["Balisong"] = .3, ["Bat"] = 1.2, ["Bayonet"] = .6, ["BlackBayonet"] = .6, ["CandyCrowbar"] = 2.5, ["Chainsaw"] = 3, ["Crowbar"] = 1.2, ["Clippers"] = .6, ["CursedDagger"] = .8, ["DELTA-X04"] = .6, ["ERADICATOR"] = 2, ["ERADICATOR-II"] = 2, ["Fire-Axe"] = 1.6, ["GoldenAxe"] = .75, ["Golfclub"] = 1.2, ["Hatchet"] = .7, ["Katana"] = .6, ["Knuckledusters"] = .5, ["Machete"] = .7, ["Metal-Bat"] = 1.3, ["Nunchucks"] = .3, ["PhotonBlades"] = .8, ["Rambo"] = .8, ["ReforgedKatana"] = .85, ["Rendbreaker"] = 1.5, ["RoyalBroadsword"] = 1, ["Sabre"] = .7, ["Scythe"] = 1.2, ["Shiv"] = .5, ["Shovel"] = 2.5, ["SlayerSword"] = 1.5, ["Sledgehammer"] = 2.2, ["Taiga"] = .7, ["Tomahawk"] = .85, ["Wrench"] = .6, ["_BFists"] = .35, ["_FallenBlade"] = 1.3, ["_Sledge"] = 2.2, ["new_oldSlayerSword"] = 1.5}
            if not remotes.MeleeAuraTask then
                remotes.MeleeAuraTask = task.spawn(function()
                    currentSlash = 1
                    function Attack(target)
                        if not (target and target:FindFirstChild("Head")) then return end
                        if not me.Character then return end
                        TOOL = me.Character:FindFirstChildOfClass("Tool")
                        if not TOOL then return end
                        attachcd = AttachCD[TOOL.Name] or 0.5
                        if tick() - AttachTick >= attachcd then
                            result = remote1:InvokeServer("🍞", tick(), TOOL, "43TRFWX", "Normal", tick(), true)
                            if SectionSettings.MeleeAura.ShowAnim then
                                animFolder = TOOL:FindFirstChild("AnimsFolder")
                                if animFolder then
                                    animName = "Slash" .. currentSlash
                                    anim = animFolder:FindFirstChild(animName)
                                    if anim then
                                        animator = me.Character:FindFirstChildOfClass("Humanoid"):FindFirstChild("Animator")
                                        if animator then
                                            animator:LoadAnimation(anim):Play(0.1, 1, 1.3)
                                            currentSlash = currentSlash + 1
                                            if not animFolder:FindFirstChild("Slash" .. currentSlash) then
                                                currentSlash = 1
                                            end
                                        end
                                    end
                                end
                            end
                            task.wait(0.3 + math.random() * 0.2)
                            Handle = TOOL:FindFirstChild("WeaponHandle") or TOOL:FindFirstChild("Handle") or me.Character:FindFirstChild("Left Arm")
                            if TOOL then
                                targetPartName = #SectionSettings.MeleeAura.TargetPart > 0 and SectionSettings.MeleeAura.TargetPart[math.random(1, #SectionSettings.MeleeAura.TargetPart)] or ValidMeleeTargetParts[math.random(1, #ValidMeleeTargetParts)]
                                targetPart = target:FindFirstChild(targetPartName)
                                if not targetPart then
                                    targetPart = target:FindFirstChild(ValidMeleeTargetParts[math.random(1, #ValidMeleeTargetParts)])
                                end
                                if not targetPart then return end
                                arg2 = {
                                    "🍞",
                                    tick(),
                                    TOOL,
                                    "2389ZFX34",
                                    result,
                                    true,
                                    Handle,
                                    targetPart,
                                    target,
                                    me.Character.HumanoidRootPart.Position,
                                    targetPart.Position
                                }
                                if TOOL.Name == "Chainsaw" then
                                    for i = 1, 15 do remote2:FireServer(unpack(arg2)) end
                                else
                                    remote2:FireServer(unpack(arg2))
                                end
                                AttachTick = tick()
                            end
                            UpdateHighlightMelee(target)
                        end
                    end
                    function DownedCheck(Character)
                        PlayerName = Character.Name
                        if not game:GetService("ReplicatedStorage").CharStats:FindFirstChild(PlayerName) then return true end
                        downed = game:GetService("ReplicatedStorage").CharStats[PlayerName].Downed.Value
                        health = Character:FindFirstChildOfClass("Humanoid").Health
                        return downed or health <= 15
                    end
                    while functions.meleeauraF do
                        mychar = me.Character or me.CharacterAdded:Wait()
                        if mychar and mychar:FindFirstChild("HumanoidRootPart") then
                            myhrp = mychar.HumanoidRootPart
                            targets = {}
                            for _, a in ipairs(plrs:GetPlayers()) do
                                if a ~= me and a.Character and a.Character:FindFirstChild("HumanoidRootPart") then
                                    PlayerName = a.Name
                                    hrp = a.Character.HumanoidRootPart
                                    distance = (myhrp.Position - hrp.Position).Magnitude
                                    if distance < SectionSettings.MeleeAura.Distance then
                                        hasForceField = false
                                        for _, child in ipairs(a.Character:GetChildren()) do
                                            if child:IsA("ForceField") then
                                                hasForceField = true
                                                break
                                            end
                                        end
                                        if hasForceField then continue end
                                        if SectionSettings.MeleeAura.CheckWhitelist and GlobalWhiteList[PlayerName] then continue end
                                        if SectionSettings.MeleeAura.CheckTeam and a.Team == me.Team then continue end
                                        if SectionSettings.MeleeAura.CheckDowned and DownedCheck(a.Character) then continue end
                                        table.insert(targets, {Player = a, Distance = distance, Health = a.Character:FindFirstChildOfClass("Humanoid").Health})
                                    end
                                end
                            end
                            if SectionSettings.MeleeAura.SortMethod == "Health" then
                                table.sort(targets, function(a, b) return a.Health < b.Health end)
                            else
                                table.sort(targets, function(a, b) return a.Distance < b.Distance end)
                            end
                            if #targets > 0 then
                                Attack(targets[1].Player.Character)
                            end
                        end
                        run.Heartbeat:Wait()
                    end
                end)
            end
        elseif not Value then
            if remotes.MeleeAuraTask then
                task.cancel(remotes.MeleeAuraTask)
                remotes.MeleeAuraTask = nil
            end
            UpdateHighlightMelee(nil)
        end
    end,
}):AddKeyPicker('MeleeAuraKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Melee Aura',
    Callback = function() end,
})

CombatLeft1:AddToggle('MeleeAuraAnimToggle', {
    Text = 'Melee Aura Animation',
    Default = true,
    Callback = function(Value)
        SectionSettings.MeleeAura.ShowAnim = Value
    end,
})

CombatLeft1:AddToggle('MeleeAuraHighlightToggle', {
    Text = 'Box MeleeAuraTarget',
    Default = false,
    Callback = function(Value)
        SectionSettings.MeleeAura.HighlightEnabled = Value
        UpdateHighlightMelee(nil)
    end
}):AddColorPicker('MeleeAuraHighlightColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Text = 'Box Color',
    Callback = function(Value)
        SectionSettings.MeleeAura.HighlightColor = Value
    end
})

CombatLeft1:AddToggle('MeleeAuraCheckDowned', {
    Text = 'Check Downed',
    Default = false,
    Callback = function(Value)
        SectionSettings.MeleeAura.CheckDowned = Value
    end
})

CombatLeft1:AddToggle('MeleeAuraCheckWhitelist', {
    Text = 'Check Whitelist',
    Default = false,
    Callback = function(Value)
        SectionSettings.MeleeAura.CheckWhitelist = Value
    end
})

CombatLeft1:AddToggle('MeleeAuraCheckTeam', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        SectionSettings.MeleeAura.CheckTeam = Value
    end
})

CombatLeft1:AddSlider('MeleeAuraDistance', {
    Text = 'Melee Aura Distance',
    Default = 1,
    Min = 1,
    Max = 20,
    Rounding = 0,
    Callback = function(Value)
        SectionSettings.MeleeAura.Distance = Value
    end
})

CombatLeft1:AddDropdown('MeleeAuraTargetPart', {
    Values = {'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
    Default = {'Head'},
    Multi = true,
    Text = 'Hit Parts',
    Callback = function(Value)
        SectionSettings.MeleeAura.TargetPart = Value
    end
})

CombatLeft1:AddDropdown('MeleeAuraSortMethod', {
    Values = {'Distance', 'Health'},
    Default = 'Distance',
    Multi = false,
    Text = 'Sort Method',
    Callback = function(Value)
        SectionSettings.MeleeAura.SortMethod = Value
    end
})

AimbotEnabled = false
Pressed = false
AimTarget = nil
CanUsing = false
FirstPerson = true
Predict = 15
Part = nil
LastRandomTick = tick()
AimbotCircle = nil
AimbotCirclePos = nil
AimbotMode = "Hold"

CombatRight:AddToggle('AimbotToggle', {
    Text = 'Aimbot',
    Default = false,
    Callback = function(Value)
        AimbotEnabled = Value
        if not Value then
            if AimbotCircle then AimbotCircle:Remove(); AimbotCircle = nil end
            if AimbotCirclePos then AimbotCirclePos:Disconnect(); AimbotCirclePos = nil end
        else
            RunAimbot()
        end
    end
}):AddKeyPicker('AimbotKeyPicker', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Hold',
    Text = 'Aimbot',
    Callback = function(Value)
        AimbotEnabled = Value
    end
})

DrawToggle = CombatRight:AddToggle('DrawToggle', {
    Text = 'Draw Circle',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.Draw = Value
    end
})

DrawToggle:AddColorPicker('DrawColorPicker', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'Circle Color',
    Callback = function(Value)
        SectionSettings.AimBot.DrawColor = Value
        if AimbotCircle then
            AimbotCircle.Color = Value
        end
    end
})

CombatRight:AddToggle('SmoothToggle', {
    Text = 'Smooth Aiming',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.Smooth = Value
    end
})

CombatRight:AddToggle('VelocityToggle', {
    Text = 'Use Velocity',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.Velocity = Value
    end
})

CombatRight:AddToggle('CheckWallToggle', {
    Text = 'Check Walls',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.CheckWall = Value
    end
})

CombatRight:AddToggle('CheckTeamToggle', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.CheckTeam = Value
    end
})

CombatRight:AddToggle('CheckWhitelistToggle', {
    Text = 'Check Whitelist',
    Default = false,
    Callback = function(Value)
        SectionSettings.AimBot.CheckWhitelist = Value
    end
})

CombatRight:AddDropdown('TargetPartDropdown', {
    Values = ValidAimbotTargetParts,
    Default = 1,
    Multi = false,
    Text = 'Target Part',
    Callback = function(Value)
        SectionSettings.AimBot.TargetPart = Value
    end
})

CombatRight:AddDropdown('AimbotModeDropdown', {
    Values = {'Hold', 'Toggle'},
    Default = 1,
    Multi = false,
    Text = 'Activation Mode',
    Callback = function(Value)
        AimbotMode = Value
        Options.AimbotKeyPicker:SetValue({'V', Value})
    end
})

CombatRight:AddSlider('DrawSizeSlider', {
    Text = 'FOV Size',
    Default = 50,
    Min = 10,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        SectionSettings.AimBot.DrawSize = Value
        if AimbotCircle then
            AimbotCircle.Radius = Value
        end
    end
})

CombatRight:AddSlider('SmoothSizeSlider', {
    Text = 'Smoothness Level',
    Default = 0.5,
    Min = 0.1,
    Max = 1,
    Rounding = 1,
    Callback = function(Value)
        SectionSettings.AimBot.SmoothSize = Value
    end
})

local WallCheckCache = {}
local CurrentTargetDist = math.huge
local SwitchThreshold = 20
local TargetLostTimeout = 0.3
local WallCheckInterval = 1.5 -- увеличил для кеша, меньше фризов

local targetLostSince = 0

function IsTargetVisible(player)
    if not SectionSettings.AimBot.CheckWall then return true end

    local now = tick()
    local cache = WallCheckCache[player]

    if not cache or (now - cache.time > WallCheckInterval) then
        local camera = workspace.CurrentCamera
        local localPlayer = game.Players.LocalPlayer
        local Ignore = {camera}
        if localPlayer.Character then table.insert(Ignore, localPlayer.Character) end
        if player.Character then table.insert(Ignore, player.Character) end
        if player.Parent ~= workspace then table.insert(Ignore, player.Parent) end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local obstruct = camera:GetPartsObscuringTarget({hrp.Position}, Ignore)
        WallCheckCache[player] = {time = now, visible = (#obstruct == 0)}
        cache = WallCheckCache[player]
    end

    return cache.visible
end

function GetClosestTarget()
    local camera = workspace.CurrentCamera
    local localPlayer = game.Players.LocalPlayer
    local mousePos = game.UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = SectionSettings.AimBot.DrawSize or 100

    local players = game.Players:GetPlayers()
    for i = 1, #players do
        local player = players[i]
        if player ~= localPlayer and player.Character then
            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if SectionSettings.AimBot.CheckTeam and player.Team == localPlayer.Team then continue end
                if SectionSettings.AimBot.CheckWhitelist and GlobalWhiteList and GlobalWhiteList[player.Name] then continue end
                if not IsTargetVisible(player) then continue end

                local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                if not onScreen then continue end

                local distScreen = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                if distScreen < closestDist then
                    closest = player
                    closestDist = distScreen
                end
            end
        end
    end

    return closest, closestDist
end

function RunAimbot()
    local Pressed = false
    local AimTarget = nil
    local CurrentTargetDist = math.huge
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")
    local Camera = workspace.CurrentCamera

    UIS.InputBegan:Connect(function(input)
        if not UIS:GetFocusedTextBox() and input.UserInputType == Enum.UserInputType.MouseButton2 then
            Pressed = true

            local target, dist = GetClosestTarget()
            if SectionSettings.AimBot.CheckWalls and (not target or not IsTargetVisible(target)) then
                AimTarget, CurrentTargetDist = nil, math.huge
            else
                AimTarget, CurrentTargetDist = target, dist
            end
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if not UIS:GetFocusedTextBox() and input.UserInputType == Enum.UserInputType.MouseButton2 then
            Pressed = false
            AimTarget = nil
            CurrentTargetDist = math.huge
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not AimbotEnabled then return end

        local Magnitude = (Camera.Focus.Position - Camera.CFrame.Position).Magnitude
        local CanUsing = Magnitude <= 1.5

        if Pressed then
            local validTarget = AimTarget and AimTarget.Character
            if validTarget then
                local Humanoid = AimTarget.Character:FindFirstChild("Humanoid")
                validTarget = Humanoid and Humanoid.Health > 0
            end

            if SectionSettings.AimBot.CheckWalls then
                validTarget = validTarget and IsTargetVisible(AimTarget)
            end

            if not validTarget then
                AimTarget = nil
                CurrentTargetDist = math.huge

                local newTarget, newDist = GetClosestTarget()
                if newTarget and (not SectionSettings.AimBot.CheckWalls or IsTargetVisible(newTarget)) then
                    AimTarget, CurrentTargetDist = newTarget, newDist
                end
            else
                local newTarget, newDist = GetClosestTarget()
                if newTarget and newTarget ~= AimTarget and newDist < CurrentTargetDist then
                    if not SectionSettings.AimBot.CheckWalls or IsTargetVisible(newTarget) then
                        AimTarget, CurrentTargetDist = newTarget, newDist
                    end
                end
            end

            if AimTarget then
                local hrp = AimTarget.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local _, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    if not onScreen then
                        AimTarget = nil
                        CurrentTargetDist = math.huge
                    end
                else
                    AimTarget = nil
                    CurrentTargetDist = math.huge
                end
            end
        else
            AimTarget = nil
            CurrentTargetDist = math.huge
        end

        if Pressed and AimTarget and AimTarget.Character and CanUsing then
            local Humanoid = AimTarget.Character:FindFirstChild("Humanoid")
            if Humanoid and Humanoid.Health > 0 then
                local PartName = SectionSettings.AimBot.TargetPart or "HumanoidRootPart"
                local TargetPart = AimTarget.Character:FindFirstChild(PartName)
                if TargetPart then
                    local TargetPosition = TargetPart.Position
                    if SectionSettings.AimBot.Velocity then
                        TargetPosition = TargetPosition + (TargetPart.Velocity or Vector3.zero) / Predict
                    end
                    if SectionSettings.AimBot.Smooth then
                        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, TargetPosition), SectionSettings.AimBot.SmoothSize)
                    else
                        Camera.CFrame = CFrame.new(Camera.CFrame.Position, TargetPosition)
                    end
                end
            end
        end

        if SectionSettings.AimBot.Draw then
            if not AimbotCircle then
                AimbotCircle = Drawing.new("Circle")
                AimbotCircle.Color = SectionSettings.AimBot.DrawColor
                AimbotCircle.Thickness = 2
                AimbotCircle.Radius = SectionSettings.AimBot.DrawSize
                AimbotCircle.Filled = false
                AimbotCircle.Visible = true

                if not AimbotCirclePos then
                    AimbotCirclePos = RunService.Heartbeat:Connect(function()
                        local mousePos = UIS:GetMouseLocation()
                        AimbotCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
                    end)
                end
            end
        else
            if AimbotCircle then AimbotCircle:Remove() AimbotCircle = nil end
            if AimbotCirclePos then AimbotCirclePos:Disconnect() AimbotCirclePos = nil end
        end
    end)
end

circle = Drawing.new("Circle")
circle.Visible = false
circle.Transparency = 1
circle.Thickness = 1.5
circle.Color = SectionSettings.SilentAim.DrawColor
circle.Filled = false
circle.Radius = SectionSettings.SilentAim.DrawSize

renderConnection = nil
function UpdateCircle()
    if renderConnection then renderConnection:Disconnect() end
    if functions.silentaimF and SectionSettings.SilentAim.DrawCircle then
        renderConnection = game:GetService("RunService").RenderStepped:Connect(function()
            circle.Position = Vector2.new(game:GetService("UserInputService"):GetMouseLocation().X, game:GetService("UserInputService"):GetMouseLocation().Y)
            circle.Visible = true
            circle.Radius = SectionSettings.SilentAim.DrawSize
            circle.Color = SectionSettings.SilentAim.DrawColor
        end)
    else
        circle.Visible = false
    end
end

function UrTargetFunc()
    if not functions.silentaimF then return nil end
    closestPlayer = nil
    minDistance = SectionSettings.SilentAim.DrawSize
    mousePos = game:GetService("UserInputService"):GetMouseLocation()
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player == game:GetService("Players").LocalPlayer or not player.Character or player.Character:FindFirstChildOfClass("ForceField") then continue end
        if SectionSettings.SilentAim.CheckWhitelist and GlobalWhiteList[player.Name] then continue end
        if SectionSettings.SilentAim.CheckTeam and player.Team == game:GetService("Players").LocalPlayer.Team then continue end
        targetPart = nil
        if SectionSettings.SilentAim.TargetPart == "Closest" then
            minPartDistance = math.huge
            for _, partName in ipairs(ValidSilentTargetParts) do
                part = player.Character:FindFirstChild(partName)
                if part then
                    screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        distance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                        if distance < minPartDistance then
                            minPartDistance = distance
                            targetPart = part
                        end
                    end
                end
            end
        else
            targetPart = SectionSettings.SilentAim.TargetPart == "Random" and player.Character:FindFirstChild(ValidSilentTargetParts[math.random(1, #ValidSilentTargetParts)]) or player.Character:FindFirstChild(SectionSettings.SilentAim.TargetPart or "Head")
        end
        if targetPart then
            if SectionSettings.SilentAim.CheckWall and #workspace.CurrentCamera:GetPartsObscuringTarget({targetPart.Position}, {workspace.CurrentCamera, game:GetService("Players").LocalPlayer.Character, player.Character}) > 0 then continue end
            screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetPart.Position)
            if onScreen and (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude < minDistance then
                minDistance = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                closestPlayer = player
            end
        end
    end
    if closestPlayer and SectionSettings.SilentAim.UseHitChance then
        if math.random(1, 100) > SectionSettings.SilentAim.HitChance then
            return nil
        end
    end
    UpdateHighlightSilent(closestPlayer and closestPlayer.Character or nil)
    return closestPlayer
end

CombatLeft2:AddToggle('SilentAimToggle', {
    Text = 'Silent Aim',
    Default = false,
    Callback = function(Value)
        functions.silentaimF = Value
        UpdateCircle()

        if not Value then
            currentTarget = nil
            if remotes.SilentAimTask then
                task.cancel(remotes.SilentAimTask)
                remotes.SilentAimTask = nil
            end
            if visualizeConnection then
                visualizeConnection:Disconnect()
                visualizeConnection = nil
            end
            UpdateHighlightSilent(nil)
            return
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local Camera = workspace.CurrentCamera
        local LocalPlayer = Players.LocalPlayer

        VisualizeEvent = ReplicatedStorage:WaitForChild("Events2"):WaitForChild("Visualize")
        DamageEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("ZFKLF__H")

        remotes.SilentAimTask = task.spawn(function()
            while functions.silentaimF do
                local nextTarget = UrTargetFunc()
                if currentTarget ~= nextTarget then
                    currentTarget = nextTarget
                    UpdateHighlightSilent(currentTarget)
                end
                task.wait(0.1)
            end
        end)

        visualizeConnection = VisualizeEvent.Event:Connect(function(_, ShotCode, _, Gun, _, StartPos, BulletsPerShot)
            if not (functions.silentaimF and Gun and currentTarget and currentTarget.Character) then return end
            if currentTarget.Character:FindFirstChildOfClass("ForceField") then return end

            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if not tool or Gun ~= tool then return end

            local HitPart
            local targetPartSetting = SectionSettings.SilentAim.TargetPart

            if targetPartSetting == "Closest" then
                local minDist = math.huge
                for _, partName in ipairs(ValidSilentTargetParts) do
                    local part = currentTarget.Character:FindFirstChild(partName)
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist < minDist then
                                minDist = dist
                                HitPart = part
                            end
                        end
                    end
                end
            else
                local partName = targetPartSetting == "Random"
                    and ValidSilentTargetParts[math.random(1, #ValidSilentTargetParts)]
                    or targetPartSetting or "Head"
                HitPart = currentTarget.Character:FindFirstChild(partName)
            end

            if not HitPart then return end

            local HitPos = HitPart.Position
            local bulletCount = math.clamp(#BulletsPerShot, 1, 100)
            local lookVector = CFrame.new(StartPos, HitPos).LookVector
            local Bullets = table.create(bulletCount, lookVector)

            task.wait() -- буфер кадра

            for i = 1, bulletCount do
                DamageEvent:FireServer("🧈", Gun, ShotCode, i, HitPart, HitPos, Bullets[i])
            end

            if Gun:FindFirstChild("Hitmarker") then
                Gun.Hitmarker:Fire(HitPart)
                if HitPart.Name == "Head" then
                    PlayHeadshotSound()
                end
            end
        end)
    end
}):AddKeyPicker('SilentAimKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Silent Aim'
})

CombatLeft2:AddToggle('SilentAimDrawCircle', {
    Text = 'Draw Circle',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawCircle = Value
        UpdateCircle()
    end
})

CombatLeft2:AddToggle('SilentAimUseHitChance', {
    Text = 'HitChance',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.UseHitChance = Value
    end
})

CombatLeft2:AddToggle('SilentAimHighlightToggle', {
    Text = 'Box SilentTarget',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.HighlightEnabled = Value
        UpdateHighlightSilent(nil)
    end
}):AddColorPicker('SilentAimHighlightColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Text = 'Box Color',
    Callback = function(Value)
        SectionSettings.SilentAim.HighlightColor = Value
    end
})

CombatLeft2:AddToggle('SilentAimCheckWhitelist', {
    Text = 'Check Whitelist',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckWhitelist = Value
    end
})

CombatLeft2:AddToggle('SilentAimCheckWall', {
    Text = 'Check Wall',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckWall = Value
    end
})

CombatLeft2:AddToggle('SilentAimCheckTeam', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        SectionSettings.SilentAim.CheckTeam = Value
    end
})

CombatLeft2:AddSlider('SilentAimFOV', {
    Text = 'FOV',
    Default = 50,
    Min = 10,
    Max = 250,
    Rounding = 0,
    Callback = function(Value)
        SectionSettings.SilentAim.DrawSize = Value
        circle.Radius = Value
    end
})

CombatLeft2:AddSlider('SilentAimHitChance', {
    Text = 'HitChance',
    Default = 80,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        SectionSettings.SilentAim.HitChance = Value
    end
})

CombatLeft2:AddDropdown('SilentAimTargetPart', {
    Values = {'Closest', 'Random', 'Head', 'Torso', 'Left Arm', 'Right Arm', 'Left Leg', 'Right Leg'},
    Default = 3,
    Multi = false,
    Text = 'Hit Part',
    Callback = function(Value)
        SectionSettings.SilentAim.TargetPart = Value
    end
})

RagebotF = false
me = game.Players.LocalPlayer
plrs = game:GetService("Players")
camera = workspace.CurrentCamera
RagebotTask = nil

CombatRight2:AddToggle('RagebotToggle', {
    Text = 'RageBot',
    Default = false,
    Callback = function(Value)
        RagebotF = Value
        if Value then
            if not RagebotTask then
                RagebotTask = task.spawn(RageBotLoop)
            end
        else
            if RagebotTask then
                task.cancel(RagebotTask)
                RagebotTask = nil
            end
            UpdateHighlightRage(nil)
        end
    end
}):AddKeyPicker('RagebotKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'RageBot',
    Callback = function() end
})

CombatRight2:AddToggle('DownedCheck', {
    Text = 'Downed Check',
    Default = true,
    Callback = function(Value)
        SectionSettings.Ragebot.DownedCheck = Value
    end
})

CombatRight2:AddToggle('RagebotHighlightToggle', {
    Text = 'Box RagebotTarget',
    Default = false,
    Callback = function(Value)
        SectionSettings.Ragebot.HighlightEnabled = Value
        UpdateHighlightRage(nil)
    end
}):AddColorPicker('RagebotHighlightColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Text = 'Box Color',
    Callback = function(Value)
        SectionSettings.Ragebot.HighlightColor = Value
    end
})

CombatRight2:AddToggle('RagebotCheckWhitelist', {
    Text = 'Check Whitelist',
    Default = false,
    Callback = function(Value)
        SectionSettings.Ragebot.CheckWhitelist = Value
    end
})

CombatRight2:AddToggle('RagebotCheckTarget', {
    Text = 'Check Target',
    Default = false,
    Callback = function(Value)
        SectionSettings.Ragebot.CheckTarget = Value
    end
})

CombatRight2:AddToggle('RagebotCheckTeam', {
    Text = 'Check Team',
    Default = false,
    Callback = function(Value)
        SectionSettings.Ragebot.CheckTeam = Value
    end
})

function RandomString(length)
    res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

function GetClosestEnemy()
    if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then return nil end
    closestEnemy = nil
    shortestDistance = 100
    for _, player in pairs(plrs:GetPlayers()) do
        if player == me then continue end
        character = player.Character
        humanoid = character and character:FindFirstChildOfClass("Humanoid")
        rootPart = character and character:FindFirstChild("HumanoidRootPart")
        forceField = character and character:FindFirstChildOfClass("ForceField")
        if character and rootPart and humanoid and not forceField then
            if (not SectionSettings.Ragebot.DownedCheck or humanoid.Health > 15) then
                distance = (rootPart.Position - me.Character.HumanoidRootPart.Position).Magnitude
                if distance > 100 then continue end
                if SectionSettings.Ragebot.CheckWhitelist and GlobalWhiteList[player.Name] then continue end
                if SectionSettings.Ragebot.CheckTarget and not GlobalTarget[player.Name] then continue end
                if SectionSettings.Ragebot.CheckTeam and player.Team == me.Team then continue end
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = player
                end
            end
        end
    end
    UpdateHighlightRage(closestEnemy and closestEnemy.Character or nil)
    return closestEnemy
end

function Shoot(target)
    if not target or not target.Character then return end
    head = target.Character:FindFirstChild("Head")
    if not head then return end
    tool = me.Character and me.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    values = tool:FindFirstChild("Values")
    hitMarker = tool:FindFirstChild("Hitmarker")
    if not values or not hitMarker then return end
    ammo = values:FindFirstChild("SERVER_Ammo")
    storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")
    if not ammo or not storedAmmo or ammo.Value <= 0 then return end
    hitPosition = head.Position
    hitDirection = (hitPosition - camera.CFrame.Position).unit
    randomKey = RandomString(30) .. "0"
    game:GetService("ReplicatedStorage").Events.GNX_S:FireServer(
        tick(),
        randomKey,
        tool,
        "FDS9I83",
        camera.CFrame.Position,
        {hitDirection},
        false
    )
    game:GetService("ReplicatedStorage").Events["ZFKLF__H"]:FireServer(
        "🧈",
        tool,
        randomKey,
        1,
        head,
        hitPosition,
        hitDirection
    )
    ammo.Value = math.max(ammo.Value - 1, 0)
    hitMarker:Fire(head)
    PlayHeadshotSound()
    storedAmmo.Value = values:FindFirstChild("SERVER_StoredAmmo").Value
end

function RageBotLoop()
    while RagebotF and me.Character and me.Character:FindFirstChild("HumanoidRootPart") do
        if me.Character:FindFirstChildOfClass("Tool") then
            target = GetClosestEnemy()
            if target then
                Shoot(target)
            end
        end
        task.wait(0.2)
    end
end

Debris = workspace:WaitForChild("Debris")
VParts = Debris:WaitForChild("VParts")
Forward = 0
Sideways = 0
Break = false
plrs = game:GetService("Players")
me = plrs.LocalPlayer
tween = game:GetService("TweenService")
input = game:GetService("UserInputService")
run = game:GetService("RunService")
camera = game.Workspace.CurrentCamera

c4Enabled = false
c4Speed = 200

CombatLeft3:AddToggle("C4Toggle", {
    Text = "C4 Control",
    Default = false,
    Callback = function(value)
        c4Enabled = value
        if not value and me.Character then
            Forward = 0
            Sideways = 0
            Break = false
            if me.Character.HumanoidRootPart then
                me.Character.HumanoidRootPart.Anchored = false
            end
            camera.CameraSubject = me.Character.Humanoid
        end
    end,
}):AddKeyPicker("C4Key", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "C4 Control",
    Callback = function() end,
})

CombatLeft3:AddSlider('C4Speed', {
    Text = 'C4 Speed',
    Default = 200,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        c4Speed = value
    end
})

VParts.ChildAdded:Connect(function(Projectile)
    if not c4Enabled then return end
    
    task.wait()
    if Projectile.Name == "TransIgnore" then
        if not me.Character then return end
        
        if not me.Character:FindFirstChild("C4") then 
            return 
        end

        camera.CameraSubject = Projectile
        if me.Character.HumanoidRootPart then
            me.Character.HumanoidRootPart.Anchored = true
        end

        pcall(function()
            if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
            if Projectile:FindFirstChild("BodyAngularVelocity") then Projectile.BodyAngularVelocity:Destroy() end
            if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
        end)

        BV = Instance.new("BodyVelocity", Projectile)
        BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        BV.Velocity = Vector3.new()

        BG = Instance.new("BodyGyro", Projectile)
        BG.P = 9e4
        BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)

        task.spawn(function()
            while Projectile and Projectile.Parent and c4Enabled do
                run.RenderStepped:Wait()
                tween:Create(BV, TweenInfo.new(0), {Velocity = ((camera.CFrame.LookVector * Forward) + (camera.CFrame.RightVector * Sideways)) * c4Speed}):Play()
                BG.CFrame = camera.CoordinateFrame
                targetCFrame = Projectile.CFrame * CFrame.new(0, 1, 1)
                camera.CFrame = camera.CFrame:Lerp(targetCFrame + Vector3.new(0, 5, 0), 0.1)
                if Break then
                    Break = false
                    break
                end
            end
            if me.Character then
                camera.CameraSubject = me.Character.Humanoid
                if me.Character.HumanoidRootPart then
                    me.Character.HumanoidRootPart.Anchored = false
                end
            end
        end)
    end
end)

input.InputBegan:Connect(function(Key)
    if Key.KeyCode == Enum.KeyCode.W then
        Forward = 1
    elseif Key.KeyCode == Enum.KeyCode.S then
        Forward = -1
    elseif Key.KeyCode == Enum.KeyCode.D then
        Sideways = 1
    elseif Key.KeyCode == Enum.KeyCode.A then
        Sideways = -1
    end
end)

input.InputEnded:Connect(function(Key)
    if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.S then
        Forward = 0
    elseif Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.A then
        Sideways = 0
    end
end)

Debris.ChildAdded:Connect(function(Result)
    task.wait()
    if not me.Character then return end
    pcall(function()
        if me.Character:FindFirstChild("C4") and (Result.Name == "C4Explosion") then
            Break = true
            task.wait(1)
            Break = false
        end
    end)
end)

Debris = workspace:WaitForChild("Debris")
VParts = Debris:WaitForChild("VParts")
Forward = 0
Sideways = 0
Break = false
plrs = game:GetService("Players")
me = plrs.LocalPlayer
tween = game:GetService("TweenService")
input = game:GetService("UserInputService")
run = game:GetService("RunService")
camera = game.Workspace.CurrentCamera

rocketEnabled = false
rocketSpeed = 200

CombatLeft3:AddToggle("RocketToggle", {
    Text = "Rocket Control",
    Default = false,
    Callback = function(value)
        rocketEnabled = value
        if not value and me.Character then
            Forward = 0
            Sideways = 0
            Break = false
            if me.Character.HumanoidRootPart then
                me.Character.HumanoidRootPart.Anchored = false
            end
            camera.CameraSubject = me.Character.Humanoid
        end
    end,
}):AddKeyPicker("RocketKey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Rocket Control",
    Callback = function() end,
})

CombatLeft3:AddSlider('RocketSpeed', {
    Text = 'Rocket Speed',
    Default = 200,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(value)
        rocketSpeed = value
    end
})

VParts.ChildAdded:Connect(function(Projectile)
    if not rocketEnabled then return end
    
    task.wait()
    if Projectile.Name == "RPG_Rocket" or Projectile.Name == "GrenadeLauncherGrenade" or 
       Projectile.Name == "SBL_Rocket" or Projectile.Name == "Hallows_Rocket3" or 
       Projectile.Name == "Hallows_Rocket2" or Projectile.Name == "FireworkLauncher_Rocket" or 
       Projectile.Name == "Hallows_Rocket" or Projectile.Name == "AT4_Rocket" or 
       Projectile.Name == "Rpg18" then
        if not me.Character then return end
        
        if (Projectile.Name == "RPG_Rocket" and not (me.Character:FindFirstChild("RPG-7") or me.Character:FindFirstChild("RPG-29"))) or
           (Projectile.Name == "GrenadeLauncherGrenade" and not (me.Character:FindFirstChild("M320-1") or me.Character:FindFirstChild("SCAR-H-X"))) or
           (Projectile.Name == "SBL_Rocket" and not me.Character:FindFirstChild("SBL-MK3")) or
           (Projectile.Name == "Hallows_Rocket3" and not me.Character:FindFirstChild("HL-MK3")) or
           (Projectile.Name == "Hallows_Rocket2" and not me.Character:FindFirstChild("HL-MK2")) or
           (Projectile.Name == "FireworkLauncher_Rocket" and not me.Character:FindFirstChild("FireworkLauncher")) or
           (Projectile.Name == "Hallows_Rocket" and not me.Character:FindFirstChild("HallowsLauncher")) or
           (Projectile.Name == "AT4_Rocket" and not me.Character:FindFirstChild("AT4")) or
           (Projectile.Name == "Rpg18" and not me.Character:FindFirstChild("RPG-18")) then
            return
        end

        camera.CameraSubject = Projectile
        if me.Character.HumanoidRootPart then
            me.Character.HumanoidRootPart.Anchored = true
        end

        pcall(function()
            if Projectile.Name == "RPG_Rocket" or Projectile.Name == "SBL_Rocket" or 
               Projectile.Name == "Hallows_Rocket3" or Projectile.Name == "Hallows_Rocket2" or 
               Projectile.Name == "FireworkLauncher_Rocket" or Projectile.Name == "Hallows_Rocket" or 
               Projectile.Name == "AT4_Rocket" or Projectile.Name == "Rpg18" then
                if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
                if Projectile:FindFirstChild("RotPart") and Projectile.RotPart:FindFirstChild("BodyAngularVelocity") then 
                    Projectile.RotPart.BodyAngularVelocity:Destroy() 
                end
                if Projectile:FindFirstChild("BodyAngularVelocity") then Projectile.BodyAngularVelocity:Destroy() end
                if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
            elseif Projectile.Name == "GrenadeLauncherGrenade" then
                if Projectile:FindFirstChild("BodyForce") then Projectile.BodyForce:Destroy() end
                if Projectile:FindFirstChild("BodyAngularVelocity") then Projectile.BodyAngularVelocity:Destroy() end
                if Projectile:FindFirstChild("Sound") then Projectile.Sound:Destroy() end
            end
        end)

        BV = Instance.new("BodyVelocity", Projectile)
        BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        BV.Velocity = Vector3.new()

        BG = Instance.new("BodyGyro", Projectile)
        BG.P = 9e4
        BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)

        task.spawn(function()
            while Projectile and Projectile.Parent and rocketEnabled and me.Character and me.Character.HumanoidRootPart do
                run.RenderStepped:Wait()
                tween:Create(BV, TweenInfo.new(0), {Velocity = ((camera.CFrame.LookVector * Forward) + (camera.CFrame.RightVector * Sideways)) * rocketSpeed}):Play()
                BG.CFrame = camera.CoordinateFrame
                targetCFrame = Projectile.CFrame * CFrame.new(0, 1, 1)
                if targetCFrame and camera.CFrame then
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame + Vector3.new(0, 5, 0), 0.1)
                end
                if Break or not Projectile.Parent then
                    Break = false
                    break
                end
            end
            if me.Character and me.Character.Humanoid then
                camera.CameraSubject = me.Character.Humanoid
                if me.Character.HumanoidRootPart then
                    me.Character.HumanoidRootPart.Anchored = false
                end
            end
        end)
    end
end)

input.InputBegan:Connect(function(Key)
    if Key.KeyCode == Enum.KeyCode.W then
        Forward = 1
    elseif Key.KeyCode == Enum.KeyCode.S then
        Forward = -1
    elseif Key.KeyCode == Enum.KeyCode.D then
        Sideways = 1
    elseif Key.KeyCode == Enum.KeyCode.A then
        Sideways = -1
    end
end)

input.InputEnded:Connect(function(Key)
    if Key.KeyCode == Enum.KeyCode.W or Key.KeyCode == Enum.KeyCode.S then
        Forward = 0
    elseif Key.KeyCode == Enum.KeyCode.D or Key.KeyCode == Enum.KeyCode.A then
        Sideways = 0
    end
end)

Debris.ChildAdded:Connect(function(Result)
    task.wait()
    if not me.Character then return end
    pcall(function()
        if me.Character:FindFirstChild("RPG-7") and (Result.Name == "RPG_Explosion_Long" or Result.Name == "RPG_Explosion_Short") then
            Break = true
            task.wait(1)
            Break = false
        elseif (me.Character:FindFirstChild("M320-1") or me.Character:FindFirstChild("SCAR-H-X")) and (Result.Name == "GL_Explosion_Long" or Result.Name == "GL_Explosion_Short") then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("SBL-MK3") and Result.Name == "SBL_Explosion" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("HL-MK3") and (Result.Name == "Hallows_Explosion2_Long" or Result.Name == "Hallows_Explosion2_Short") then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("HL-MK2") and Result.Name == "Hallows_Explosion" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("FireworkLauncher") and Result.Name == "Firework_Explosion" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("HallowsLauncher") and Result.Name == "Hallows_Explosion" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("RPG-G") and Result.Name == "VortexExplosion" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("AT4") and (Result.Name == "Panzer_Explosion_Long" or Result.Name == "Panzer_Explosion_Short") then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("RPG-18") and Result.Name == "BigExplosion2" then
            Break = true
            task.wait(1)
            Break = false
        elseif me.Character:FindFirstChild("RPG-29") and (Result.Name == "Panzer_Explosion_Long" or Result.Name == "Panzer_Explosion_Short") then
            Break = true
            task.wait(1)
            Break = false
        end
        if Break then
            if me.Character and me.Character.Humanoid then
                camera.CameraSubject = me.Character.Humanoid
                if me.Character.HumanoidRootPart then
                    me.Character.HumanoidRootPart.Anchored = false
                end
            end
        end
    end)
end)

pepperEnabled = false

PepperToggle = CombatRight3:AddToggle('InfinitePepper', {
    Text = "Infinite Pepper Spray",
    Default = false,
    Callback = function(Value)
        pepperEnabled = Value
    end
})

function pepper(obj)
    if pepperEnabled then
        obj:FindFirstChild("Ammo").MinValue = 100
        obj:FindFirstChild("Ammo").Value = 100
    else
        obj:FindFirstChild("Ammo").MinValue = 0
    end
end

game:GetService("RunService").RenderStepped:Connect(function()
    Pepper = game.Players.LocalPlayer.Character:FindFirstChild("Pepper-spray")
    if Pepper then
        pepper(Pepper)
    end
end)

PepperSprayAura_Enabled = false

PepperAuraToggle = CombatRight3:AddToggle('PepperAura', {
    Text = "PepperSpray Aura",
    Default = false,
    Callback = function(State)
        PepperSprayAura_Enabled = State
        if PepperSprayAura_Enabled then
            task.spawn(function()
                while PepperSprayAura_Enabled do
                    game:GetService("RunService").RenderStepped:Wait()
                    player = game.Players.LocalPlayer
                    char = player.Character
                    if char and char:FindFirstChild("Pepper-spray") then
                        for _, v in pairs(game.Players:GetPlayers()) do
                            if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                                if SectionSettings.PepperSprayAura.CheckWhitelist and GlobalWhiteList[v.Name] then continue end
                                dist = (char:FindFirstChild("HumanoidRootPart").Position - v.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude
                                if dist < 15 then
                                    char["Pepper-spray"].RemoteEvent:FireServer("Spray", true)
                                    char["Pepper-spray"].RemoteEvent:FireServer("Hit", v.Character)
                                else
                                    char["Pepper-spray"].RemoteEvent:FireServer("Spray", false)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
}):AddKeyPicker('PepperSprayKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'PepperSpray Aura'
})

CombatRight3:AddToggle('PepperSprayCheckWhitelist', {
    Text = 'Check Whitelist',
    Default = false,
    Callback = function(Value)
        SectionSettings.PepperSprayAura.CheckWhitelist = Value
    end
})

Settings = {
    Enabled = false,
    Color = Color3.fromRGB(255, 0, 0),
    Transparency = 0
}

wallbangEnabled = false
functions = {}
functions.instant_reloadF = false
activeTracers = {}
maxTracers = 10
originalValues = {}
gunModulesCache = {}

safeGet = function(obj, path, default)
    current = obj
    for _, key in ipairs(path) do
        if not current or not current[key] then
            return default
        end
        current = current[key]
    end
    return current
end

local instantReloadRunning = false

CombatLeft4:AddToggle('InstantReload', {
    Text = "Instant Reload",
    Default = false,
    Tooltip = "Reloads weapon instantly",
    Callback = function(Value)
        functions.instant_reloadF = Value
        if Value and not instantReloadRunning then
            task.spawn(instantreloadL)
        end
    end
})

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local hvkillauraEnabled = false
local remote4 = nil
local isPlayerAlive = false
local HeatAuraRadius = 10
local HeatAuraMode = "Single"

local function disableHvKillaura()
	if not remote4 then return end
	pcall(function()
		remote4:InvokeServer("ToggleEyes", false)
	end)
	pcall(function()
		remote4:InvokeServer("ToggleLaser", false, false)
	end)
end

local function hasCompoundXVision()
	local character = LocalPlayer.Character
	local success, result = pcall(function()
		return character and character:FindFirstChild("_CompoundXVision") and character._CompoundXVision:FindFirstChild("RemoteFunction")
	end)
	return success and result or nil
end

local function checkPlayerAlive()
	local character = LocalPlayer.Character
	local humanoid = character and character:FindFirstChild("Humanoid")
	isPlayerAlive = character and humanoid and humanoid.Health > 0
	return isPlayerAlive
end

local function getAllTargets()
	local localCharacter = LocalPlayer.Character
	local localCharacterName = localCharacter and localCharacter.Name or ""
	local targets = {}

	for _, character in ipairs(Workspace.Characters:GetChildren()) do
		if character.Name ~= localCharacterName and character:FindFirstChild("Head") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			local rootPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
			if (character.Head.Position - rootPos).Magnitude <= HeatAuraRadius then
				table.insert(targets, character)
			end
		end
	end

	if HeatAuraMode == "Single" then
		return targets[1] and { targets[1] } or {}
	elseif HeatAuraMode == "Multi" then
		local limited = {}
		for i = 1, math.min(10, #targets) do
			table.insert(limited, targets[i])
		end
		return limited
	end
	return {}
end

local function fireHvKillaura(targets)
	if not remote4 or #targets == 0 then
		return false
	end

	local allSuccess = true
	local coroutines = {}

	for _, target in ipairs(targets) do
		if target and target.Parent and target:FindFirstChild("Head") and target:FindFirstChild("Humanoid") and target.Humanoid.Health > 0 then
			local head = target.Head
			local position = head.Position
			local normal = Vector3.new(0, 1, 0)

			table.insert(coroutines, coroutine.create(function()
				local success

				success = pcall(function()
					remote4:InvokeServer("UpdateLaser", {
						Normal = normal,
						Material = Enum.Material.Air,
						Position = position
					}, {}, 0.1)
				end)
				if not success then allSuccess = false; return end

				success = pcall(function()
					local rootPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or position
					local direction = (position - rootPos).Unit
					remote4:InvokeServer("Hit", 100, head, position, direction, Enum.Material.Plastic)
				end)
				if not success then allSuccess = false end
			end))
		end
	end

	for _, co in ipairs(coroutines) do
		coroutine.resume(co)
	end

	return allSuccess
end

CombatLeft5:AddToggle('HeatAura', {
	Text = "Heat Vision Aura",
	Default = false,
	Tooltip = "NEEDS HEAT VISION TOOL EQUIPPED - Blows up all peoples head at radius",
	Callback = function(state)
		hvkillauraEnabled = state

		if state then
			remote4 = hasCompoundXVision()
			if not remote4 then
				hvkillauraEnabled = false
				return
			end
			checkPlayerAlive()
			pcall(function()
				remote4:InvokeServer("ToggleEyes", true)
			end)
			pcall(function()
				remote4:InvokeServer("ToggleLaser", true, {
					Normal = Vector3.new(0, 1, 0),
					Material = Enum.Material.Air,
					RayLength = HeatAuraRadius,
					Position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
				}, {}, 0.1)
			end)
		else
			disableHvKillaura()
		end
	end
})
:AddKeyPicker('HeatAuraKey', {
	Default = 'None',
	SyncToggleState = true,
	Mode = 'Toggle',
	Text = 'Heat Vision Aura Key'
})

CombatLeft5:AddDropdown('HeatAuraModeDropdown', {
	Values = { 'Single', 'Multi' },
	Default = 1,
	Text = 'Heat Aura Mode',
	Callback = function(value)
		HeatAuraMode = value
	end
})

CombatLeft5:AddSlider('HeatAuraRadiusSlider', {
    Text = "Heat Vision Radius",
    Default = HeatAuraRadius,
    Min = 10,
    Max = 125,
    Rounding = 0,
    Callback = function(value)
        HeatAuraRadius = value
    end
})

LocalPlayer.CharacterAdded:Connect(function()
	isPlayerAlive = true
	if hvkillauraEnabled then
		remote4 = hasCompoundXVision()
		if remote4 then
			pcall(function()
				remote4:InvokeServer("ToggleEyes", true)
			end)
			pcall(function()
				remote4:InvokeServer("ToggleLaser", true, {
					Normal = Vector3.new(0, 1, 0),
					Material = Enum.Material.Air,
					RayLength = HeatAuraRadius,
					Position = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
				}, {}, 0.1)
			end)
		end
	end
end)

LocalPlayer.CharacterRemoving:Connect(function()
	isPlayerAlive = false
	if hvkillauraEnabled then
		disableHvKillaura()
	end
end)

Workspace.Characters.ChildAdded:Connect(function()
	if hvkillauraEnabled and isPlayerAlive then
		remote4 = hasCompoundXVision()
	end
end)

checkPlayerAlive()

spawn(function()
	while true do
		if hvkillauraEnabled then
			checkPlayerAlive()
			if remote4 and isPlayerAlive then
				local targets = getAllTargets()
				if #targets > 0 then
					fireHvKillaura(targets)
					wait(0.02)
				else
					wait(0.3)
				end
			else
				wait(0.4)
			end
		else
			wait(0.5)
		end
	end
end)

instantreloadL = function()
    if instantReloadRunning then return end
    instantReloadRunning = true

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local LocalPlayer = Players.LocalPlayer
    local gunR_remote = ReplicatedStorage:WaitForChild("Events"):WaitForChild("GNX_R")
    local INSTANT_KEY = "KLWE89U0"

    local connections = {}
    local toolConn, charConn

    local function cleanupConnections()
        for _, conn in ipairs(connections) do
            if conn.Connected then
                conn:Disconnect()
            end
        end
        connections = {}

        if toolConn and toolConn.Connected then
            toolConn:Disconnect()
            toolConn = nil
        end

        if charConn and charConn.Connected then
            charConn:Disconnect()
            charConn = nil
        end
    end

    local function setupTool(tool)
        if not tool or not tool:FindFirstChild("IsGun") then return end

        local values = tool:FindFirstChild("Values")
        if not values then return end

        local serverAmmo = values:FindFirstChild("SERVER_Ammo")
        local storedAmmo = values:FindFirstChild("SERVER_StoredAmmo")

        if storedAmmo then
            local conn1 = storedAmmo:GetPropertyChangedSignal("Value"):Connect(function()
                if functions.instant_reloadF and storedAmmo.Value ~= 0 then
                    gunR_remote:FireServer(tick(), INSTANT_KEY, tool)
                end
            end)
            table.insert(connections, conn1)

            if storedAmmo.Value ~= 0 and functions.instant_reloadF then
                gunR_remote:FireServer(tick(), INSTANT_KEY, tool)
            end
        end

        if serverAmmo then
            local conn2 = serverAmmo:GetPropertyChangedSignal("Value"):Connect(function()
                if functions.instant_reloadF and storedAmmo and storedAmmo.Value ~= 0 then
                    gunR_remote:FireServer(tick(), INSTANT_KEY, tool)
                end
            end)
            table.insert(connections, conn2)
        end
    end

    local function setupCharacter(char)
        cleanupConnections()
        setupTool(char:FindFirstChildOfClass("Tool"))

        toolConn = char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") and obj:FindFirstChild("IsGun") then
                setupTool(obj)
            end
        end)
    end

    if LocalPlayer.Character then
        setupCharacter(LocalPlayer.Character)
    end

    charConn = LocalPlayer.CharacterAdded:Connect(function(char)
        setupCharacter(char)
    end)

    -- Wait for disable
    while functions.instant_reloadF do
        task.wait(0.1)
    end

    cleanupConnections()
    instantReloadRunning = false
end

local lastScanTime = 0
local scanCooldown = 5
local initializedModules = {}
local gunModulesCache = {}
local originalValues = {}

task.spawn(function()
    while true do
        task.wait(scanCooldown)
        GunModules() 
    end
end)

GunModules = function()
    local shouldScan = Toggles and Toggles.NoRecoil and Toggles.NoRecoil.Value
    if shouldScan and tick() - lastScanTime > scanCooldown then
        lastScanTime = tick()

        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "EquipTime") then
                if not gunModulesCache[v] then
                    gunModulesCache[v] = true

                    if not originalValues[v] then
                        originalValues[v] = {
                            Recoil = v.Recoil or 0,
                            AngleX_Min = v.AngleX_Min or 0,
                            AngleX_Max = v.AngleX_Max or 0,
                            AngleY_Min = v.AngleY_Min or 0,
                            AngleY_Max = v.AngleY_Max or 0,
                            AngleZ_Min = v.AngleZ_Min or 0,
                            AngleZ_Max = v.AngleZ_Max or 0,
                            Spread = v.Spread or 0,
                            EquipTime = v.EquipTime or 0.5,
                            AimSpeed = (v.AimSettings and v.AimSettings.AimSpeed) or 1,
                            ChargeTime = v.ChargeTime or 0,
                            SlowDown = v.SlowDown or 0,
                            FireModeSettings = type(v.FireModeSettings) == "table" and table.clone(v.FireModeSettings) or v.FireModeSettings
                        }
                    end
                end
            end
        end
    end

    task.defer(function()
        for v in pairs(gunModulesCache) do
            local orig = originalValues[v]
            if not orig then continue end

            local isNoRecoil = Toggles and Toggles.NoRecoil and Toggles.NoRecoil.Value

            v.Recoil = isNoRecoil and 0 or orig.Recoil
            v.AngleX_Min = isNoRecoil and 0 or orig.AngleX_Min
            v.AngleX_Max = isNoRecoil and 0 or orig.AngleX_Max
            v.AngleY_Min = isNoRecoil and 0 or orig.AngleY_Min
            v.AngleY_Max = isNoRecoil and 0 or orig.AngleY_Max
            v.AngleZ_Min = isNoRecoil and 0 or orig.AngleZ_Min
            v.AngleZ_Max = isNoRecoil and 0 or orig.AngleZ_Max

            v.Spread = (Toggles and Toggles.Spread and Toggles.Spread.Value) and 0 or orig.Spread
            v.EquipTime = (Toggles and Toggles.EquipAnimSpeed and Toggles.EquipAnimSpeed.Value)
                and safeGet(Options, {"EquipTimeAmount", "Value"}, 0)
                or orig.EquipTime

            if v.AimSettings and v.SniperSettings then
                local aimSpeed = (Toggles and Toggles.AimAnimSpeed and Toggles.AimAnimSpeed.Value)
                    and safeGet(Options, {"AimSpeedAmount", "Value"}, 0)
                    or orig.AimSpeed

                v.AimSettings.AimSpeed = aimSpeed
                v.SniperSettings.AimSpeed = aimSpeed
            end
        end
    end)
end

CombatLeft4:AddToggle('NoRecoil', {
    Text = 'No Recoil',
    Default = false,
    Tooltip = 'Removes weapon recoil',
    Callback = function(Value)
        GunModules()
    end
})

CombatLeft4:AddToggle('Spread', {
    Text = 'No Spread',
    Default = false,
    Tooltip = 'Eliminates bullet spread',
    Callback = function(Value)
        GunModules()
    end
})

BulletTracer = CombatLeft4:AddToggle('BulletTracerToggle', {
    Text = 'Bullet Tracer',
    Default = false,
    Callback = function(Value)
        Settings.Enabled = Value
        if not Value then
            for _, tracerData in pairs(activeTracers) do
                if tracerData.tracer and tracerData.tracer:IsDescendantOf(game) then
                    tracerData.tracer:Destroy()
                end
            end
            activeTracers = {}
        end
    end
})

BulletTracer:AddColorPicker('BulletColorPicker', {
    Default = Settings.Color,
    Title = 'BulletTracer Color',
    Callback = function(Value)
        Settings.Color = Value
    end
})

createTracer = function(startPos, endPos)
    if not Settings.Enabled then return end
    if not startPos or not endPos then return end
    while #activeTracers >= maxTracers do
        oldestTracer = table.remove(activeTracers, 1)
        if oldestTracer and oldestTracer.tracer:IsDescendantOf(game) then
            oldestTracer.tracer:Destroy()
        end
    end
    tracer = Instance.new("Part")
    tracer.Anchored = true
    tracer.CanCollide = false
    tracer.Material = Enum.Material.Neon
    tracer.Color = Settings.Color
    tracer.Transparency = Settings.Transparency
    tracer.Shape = Enum.PartType.Cylinder
    distance = (startPos - endPos).Magnitude
    tracer.Size = Vector3.new(distance, 0.2, 0.2)
    tracer.CFrame = CFrame.new((startPos + endPos) / 2, endPos) * CFrame.Angles(0, math.pi/2, 0)
    particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxassetid://243098098"
    particleEmitter.Color = ColorSequence.new(Settings.Color)
    particleEmitter.Size = NumberSequence.new(0.05)
    particleEmitter.Speed = NumberRange.new(1, 2)
    particleEmitter.SpreadAngle = Vector2.new(-3, 3)
    particleEmitter.Lifetime = NumberRange.new(0.1, 0.15)
    particleEmitter.Rate = 8
    particleEmitter.Drag = 5
    particleEmitter.Enabled = true
    particleEmitter.EmissionDirection = Enum.NormalId.Top
    particleEmitter.Parent = tracer
    tracer.Parent = game:GetService("Workspace")
    tracerData = {tracer = tracer, startTime = tick()}
    table.insert(activeTracers, tracerData)
    animCoroutine = coroutine.create(function()
        wait(1)
        for t = 0, 1, 0.025 do
            if tracer and tracer.Parent then
                tracer.Transparency = t
            end
            if particleEmitter and particleEmitter.Parent then
                particleEmitter.Rate = math.max(0, 8 - t * 8)
            end
            wait(0.025)
        end
        for i, activeTracer in ipairs(activeTracers) do
            if activeTracer.tracer == tracer then
                table.remove(activeTracers, i)
                break
            end
        end
        if particleEmitter and particleEmitter.Parent then
            particleEmitter:Destroy()
        end
        if tracer and tracer.Parent then
            tracer:Destroy()
        end
    end)
    coroutine.resume(animCoroutine)
    game:GetService("Debris"):AddItem(tracer, 1.5)
end

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Workspace = game:GetService("Workspace")

Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
playerName = Players.LocalPlayer.Name
weaponHandle = nil
isShooting = false
lastShotTime = 0
shotCooldown = 0.05
lastRaycastTime = 0
lastBulletHoleTime = 0

findWeaponHandle = function(characterFolder)
    if not characterFolder then return nil end
    for _, weapon in pairs(characterFolder:GetChildren()) do
        if weapon:IsA("Model") and weapon:FindFirstChild("WeaponHandle") then
            return weapon.WeaponHandle
        end
    end
    return nil
end

characterFolder = Workspace.Characters:FindFirstChild(playerName)
if characterFolder then
    weaponHandle = findWeaponHandle(characterFolder)
end

if childAddedConn then
    childAddedConn:Disconnect()
end
childAddedConn = Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and child:FindFirstChild("IsGun") then
        GunModules()
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = true
        lastShotTime = tick()
        if not Character then
            Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        end
        characterFolder = Workspace.Characters:FindFirstChild(playerName)
        if not characterFolder then return end
        weaponHandle = findWeaponHandle(characterFolder)
        if not weaponHandle then return end
        startPos = weaponHandle.Position
        mouse = Players.LocalPlayer:GetMouse()
        endPos = mouse.Hit.Position
        if wallbangEnabled then
            createTracer(startPos, endPos)
            lastRaycastTime = tick()
        else
            ray = Ray.new(startPos, (endPos - startPos).Unit * 1000)
            raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            raycastResult = Workspace:Raycast(startPos, (endPos - startPos).Unit * 1000, raycastParams)
            if raycastResult and (tick() - lastRaycastTime > 0.05) then
                endPos = raycastResult.Position
                if raycastResult.Instance.Parent:FindFirstChild("Humanoid") or raycastResult.Instance.Name == "BulletHole" then
                    createTracer(startPos, endPos)
                    lastRaycastTime = tick()
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isShooting = false
    end
end)

if debrisConn then
    debrisConn:Disconnect()
end
debrisConn = Workspace.Debris.ChildAdded:Connect(function(child)
    if not Settings.Enabled then return end
    if child.ClassName == "Part" and child.Name == "BulletHole" then
        if not isShooting and (tick() - lastShotTime > shotCooldown) then return end
        if tick() - lastBulletHoleTime < shotCooldown then return end
        if not Character then
            Character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
        end
        characterFolder = Workspace.Characters:FindFirstChild(playerName)
        if not characterFolder then return end
        weaponHandle = findWeaponHandle(characterFolder)
        if not weaponHandle then return end
        startPos = weaponHandle.Position
        endPos = child.Position
        if (startPos - endPos).Magnitude < 1000 then
            createTracer(startPos, endPos)
            lastBulletHoleTime = tick()
            lastShotTime = tick()
        end
    end
end)

if characterAddedConn then
    characterAddedConn:Disconnect()
end
characterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    playerName = Players.LocalPlayer.Name
    characterFolder = Workspace.Characters:FindFirstChild(playerName)
    if characterFolder then
        weaponHandle = findWeaponHandle(characterFolder)
    end
    GunModules()
    if childAddedConn then
        childAddedConn:Disconnect()
    end
    childAddedConn = newCharacter.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child:FindFirstChild("IsGun") then
            GunModules()
        end
    end)
end)

VisualsLeft = Tabs.Visuals:AddLeftGroupbox('Player esp')
VisualsRight = Tabs.Visuals:AddRightGroupbox('Extra esp')
VisualsLeft2 = Tabs.Visuals:AddLeftGroupbox('Other')

ESPEnabled = false
ShowNameDist = false
ShowHealth = false
ShowWeapon = false
ShowInventory = false
ShowWeaponImage = false
TeamCheck = false
ShowLookDirection = false
ShowHealthBar = false
ShowSkeleton = false
ShowHeadDot = false
ShowTracer = false
ShowChinaHat = false
LookDirectionColor = Color3.fromRGB(255, 203, 138)
SkeletonColor = Color3.fromRGB(255, 255, 255)
HeadDotColor = Color3.fromRGB(255, 0, 0)
TracerColor = Color3.fromRGB(0, 255, 0)
ChinaHatColor = Color3.fromRGB(255, 105, 180)
ESPObjects = {}
TextObjectPool = {}
ImageObjectPool = {}
PlayerData = {}
ESPDistance = 100
LookLines = {}
SkeletonLines = {}
HeadDots = {}
Tracers = {}
ChinaHats = {}
WeaponImageSize = 25
HealthBarObjects = {}
LastUpdateTime = 0
UpdateInterval = 0.2
LastWhiteList = {}
ChamsToggle = false
VisibleColor = Color3.fromRGB(255, 0, 0)
OccludedColor = Color3.fromRGB(255, 255, 255)
HighlightsToggle = false
FillColor = Color3.fromRGB(0, 0, 0)
OutlineColor = Color3.fromRGB(0, 0, 0)
SelfHighlightToggle = false
SelfFillColor = Color3.fromRGB(0, 255, 0)
SelfOutlineColor = Color3.fromRGB(0, 255, 0)
PlayerAdornments = {}
SelfHighlight = Instance.new("Highlight")
SelfHighlight.Parent = game:GetService("CoreGui")
SelfHighlight.Enabled = false

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Camera = workspace.CurrentCamera
LocalPlayer = Players.LocalPlayer

Arrows = {
    Radius = 150,
    Size = UDim2.new(0, 32, 0, 32),
    Image = "rbxassetid://282305485",
    Color = Color3.fromRGB(255, 255, 255),
    Enabled = false,
    TeamCheck = false,
    IgnoreSelf = true,
    UseTeamColor = false,
    Folder = "_Arrows",
    NameLabel = false,
    DistanceLabel = false,
}

_ArrowsFolder = Instance.new("Folder")
_ArrowsFolder.Name = Arrows.Folder
_ArrowsFolder.Parent = game:GetService("CoreGui")

gui = Instance.new("ScreenGui")
gui.Name = "Arrows"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Enabled = Arrows.Enabled
gui.Parent = _ArrowsFolder

arrows = {}

weaponImages = {
    ["3-CBSTM"] = "rbxassetid://18760010762",
    ["725"] = "rbxassetid://9102738327",
    ["A-FW-L"] = "rbxassetid://13935966109",
    ["A-HL-MK3"] = "rbxassetid://7814455445",
    ["A-HL-MK4"] = "rbxassetid://97324964134388",
    ["AJM-9"] = "rbxassetid://107851948154232",
    ["AKM"] = "rbxassetid://9102820314",
    ["AKS-74U"] = "rbxassetid://9102819847",
    ["AKS-74U-X"] = "rbxassetid://9102819847",
    ["AKS-74UN"] = "rbxassetid://13702487395",
    ["AR2"] = "rbxassetid://5861388895",
    ["AT4"] = "rbxassetid://15443704781",
    ["AWM"] = "rbxassetid://125032277496004",
    ["AWM2"] = "rbxassetid://125032277496004",
    ["AccurateGoldM4A1-1"] = "rbxassetid://9102820013",
    ["AdminRadio"] = "rbxassetid://4570279137",
    ["Adrenaline"] = "rbxassetid://12397895006",
    ["Airstrike"] = "rbxassetid://9840093037",
    ["Antidote"] = "rbxassetid://8053009872",
    ["B2Bomber"] = "rbxassetid://12534067603",
    ["BBaton"] = "rbxassetid://6924217957",
    ["BFG-1"] = "rbxassetid://9830716358",
    ["BFSTM-1-X"] = "rbxassetid://18851296364",
    ["Balisong"] = "rbxassetid://6964386496",
    ["BanHammer"] = "rbxassetid://4813866018",
    ["Bandage"] = "rbxassetid://5514211963",
    ["Barrett"] = "rbxassetid://6963257084",
    ["BarrettM98B"] = "rbxassetid://93157227131515",
    ["Bat"] = "rbxassetid://8968282830",
    ["Bayonet"] = "rbxassetid://8983371826",
    ["Beretta"] = "rbxassetid://9102539745",
    ["Beretta-X"] = "rbxassetid://9102539745",
    ["BlackBayonet"] = "rbxassetid://99715117337681",
    ["C16"] = "rbxassetid://9102351832",
    ["C4"] = "rbxassetid://9102351832",
    ["COLA-M4A1"] = "rbxassetid://109825110338129",
    ["CS-Grenade"] = "rbxassetid://9102351695",
    ["CUTE_ODEN"] = "rbxassetid://6155344967",
    ["CandyCrowbar"] = "rbxassetid://15697515092",
    ["Chainsaw"] = "rbxassetid://9102350595",
    ["ChaosBlade"] = "rbxassetid://18591095662",
    ["ChaoticBlaster"] = "rbxassetid://18591106489",
    ["Chips_1"] = "rbxassetid://11257408161",
    ["Chips_2"] = "rbxassetid://11257408071",
    ["ChocBar_1"] = "rbxassetid://11257408219",
    ["ChocBar_2"] = "rbxassetid://11257408295",
    ["Clippers"] = "rbxassetid://15697249177",
    ["Coal"] = "rbxassetid://6129469758",
    ["Cola_1"] = "rbxassetid://11257407940",
    ["Cola_2"] = "rbxassetid://11257408000",
    ["CollisionStrike"] = "rbxassetid://91962789",
    ["ContrabandDealerCompass"] = "rbxassetid://14657127",
    ["CopeCoin"] = "rbxassetid://16942686084",
    ["Corruptis"] = "rbxassetid://15679016910",
    ["CoupleAirstrike"] = "rbxassetid://7791398884",
    ["Crowbar"] = "rbxassetid://9102983786",
    ["CursedDagger"] = "rbxassetid://7814402466",
    ["DELTA-X04"] = "rbxassetid://17042483483",
    ["DRam"] = "rbxassetid://4570281614",
    ["DarkRage"] = "rbxassetid://66343245",
    ["Deagle"] = "rbxassetid://9102540529",
    ["Decimator"] = "rbxassetid://17552865871",
    ["DixieGun"] = "rbxassetid://5190533956",
    ["Duskbringer_Detonator"] = "rbxassetid://11522216069",
    ["ERADICATOR"] = "rbxassetid://6963273879",
    ["ERADICATOR-II"] = "rbxassetid://16942337080",
    ["FN-FAL"] = "rbxassetid://9102820160",
    ["FN-FAL-S"] = "rbxassetid://9102820160",
    ["FNP-45"] = "rbxassetid://7675763870",
    ["FakeC4"] = "rbxassetid://9102351832",
    ["Fire-Axe"] = "rbxassetid://8968282648",
    ["FireworkLauncher"] = "rbxassetid://13935966109",
    ["Fists"] = "rbxassetid://1568022303",
    ["FlareGun"] = "rbxassetid://17151576709",
    ["Flashbang"] = "rbxassetid://9102351131",
    ["Flashbang+"] = "rbxassetid://9102351131",
    ["ForceChoke"] = "rbxassetid://109002724",
    ["ForgeRecipeBrowser"] = "rbxassetid://17384003899",
    ["FurryPotion"] = "rbxassetid://16529662289",
    ["G-17"] = "rbxassetid://9102539923",
    ["G-18"] = "rbxassetid://9102540084",
    ["G-18-X"] = "rbxassetid://9102540084",
    ["G36V"] = "rbxassetid://17700222135",
    ["G36V-S"] = "rbxassetid://17700222135",
    ["GALIL_ACE_11"] = "rbxassetid://18389896403",
    ["GUS_GRENADE"] = "rbxassetid://11360961772",
    ["GoldPrecisionStrike"] = "rbxassetid://18909851387",
    ["GoldenAxe"] = "rbxassetid://56749982",
    ["GoldenCoal"] = "rbxassetid://110397438647808",
    ["Golfclub"] = "rbxassetid://6964427940",
    ["Grenade"] = "rbxassetid://9102350734",
    ["Grimace"] = "rbxassetid://11257407940",
    ["HL-MK2"] = "rbxassetid://7814455445",
    ["HL-MK3"] = "rbxassetid://116417854764460",
    ["HallowsBlade"] = "rbxassetid://17272703938",
    ["HallowsLauncher"] = "rbxassetid://7270966410",
    ["Hammer"] = "rbxassetid://5455126855",
    ["Handcuffs"] = "rbxassetid://4570280480",
    ["Hatchet"] = "rbxassetid://18328032363",
    ["Hawkeye"] = "rbxassetid://15072162118",
    ["HealSerum"] = "rbxassetid://16291625893",
    ["HeatVision"] = "rbxassetid://11218881806",
    ["HunterPotion"] = "rbxassetid://44410267",
    ["Incendiary-Grenade"] = "rbxassetid://9102351525",
    ["Invis_AdminRadio"] = "rbxassetid://4570279137",
    ["Ithaca-37"] = "rbxassetid://9102738529",
    ["KS-23"] = "rbxassetid://17273780539",
    ["Katana"] = "rbxassetid://4570280610",
    ["Knuckledusters"] = "rbxassetid://8968178686",
    ["LaserMusket"] = "rbxassetid://9830716358",
    ["LegacyBlackBayonet"] = "rbxassetid://5861388627",
    ["LegacyWitchesBrew"] = "rbxassetid://15178997701",
    ["Lockpick"] = "rbxassetid://5514211600",
    ["M1911"] = "rbxassetid://9102540281",
    ["M1911-CONVERTION-1"] = "rbxassetid://9102540281",
    ["M320-1"] = "rbxassetid://9102881853",
    ["M320-2"] = "rbxassetid://9102881853",
    ["M4A1-1"] = "rbxassetid://9102820013",
    ["M4A1-S"] = "rbxassetid://9102820013",
    ["M60"] = "rbxassetid://15433985807",
    ["MAC-10"] = "rbxassetid://9102647474",
    ["MAC-10-S"] = "rbxassetid://9102647474",
    ["MGL"] = "rbxassetid://4570281022",
    ["MP5"] = "rbxassetid://107889520195061",
    ["MP7"] = "rbxassetid://9102648114",
    ["MP7-S"] = "rbxassetid://9102648114",
    ["MS-Grenade"] = "rbxassetid://5958375836",
    ["Machete"] = "rbxassetid://8983371702",
    ["Magnum"] = "rbxassetid://9102647029",
    ["Mare"] = "rbxassetid://9102881727",
    ["Mare-C"] = "rbxassetid://17381352933",
    ["Medkit"] = "rbxassetid://5021810486",
    ["Metal-Bat"] = "rbxassetid://8968283096",
    ["Minigun"] = "rbxassetid://94096757996557",
    ["Missilestrike"] = "rbxassetid://21501695",
    ["Molotov"] = "rbxassetid://9102350984",
    ["MonsterMash"] = "rbxassetid://15260887122",
    ["Musket"] = "rbxassetid://18324292478",
    ["MutantMagnum"] = "rbxassetid://9102647029",
    ["NeckSnap"] = "rbxassetid://3116861802",
    ["NevermoreDagger"] = "rbxassetid://6115281038",
    ["NewBloxyCola"] = "rbxassetid://10472127",
    ["NewHealingPotion"] = "rbxassetid://11418339",
    ["Nunchucks"] = "rbxassetid://8968283371",
    ["ODEN-1"] = "rbxassetid://6155344967",
    ["ODEN-S"] = "rbxassetid://6155344967",
    ["OLD_MARE"] = "rbxassetid://5190533956",
    ["OldMinigun"] = "rbxassetid://15902141317",
    ["P-ODEN-1"] = "rbxassetid://6155344967",
    ["P-RCU_FNP-45"] = "rbxassetid://7675763870",
    ["PK-500"] = "rbxassetid://18914582686",
    ["Panzerfaust-3"] = "rbxassetid://6963297260",
    ["Pepper-spray"] = "rbxassetid://4689462559",
    ["PhotonAccelerator"] = "rbxassetid://16596788618",
    ["PhotonBlades"] = "rbxassetid://15749911617",
    ["Plasma-Rocket-Launcher"] = "rbxassetid://15342196794",
    ["Plasma-UTS-1"] = "rbxassetid://15341643471",
    ["PrecisionStrike"] = "rbxassetid://91962789",
    ["ProjectileSpawner"] = "rbxassetid://18864756695",
    ["PublicAirstrike"] = "rbxassetid://9840093037",
    ["PublicPrecisionStrike"] = "rbxassetid://15697337306",
    ["RCU_Bandage"] = "rbxassetid://6153585607",
    ["RCU_FNP-45"] = "rbxassetid://7675763870",
    ["RCU_RiotShield"] = "rbxassetid://6153585055",
    ["RPG-18"] = "rbxassetid://14800109869",
    ["RPG-29"] = "rbxassetid://120257671394968",
    ["RPG-7"] = "rbxassetid://9102881989",
    ["RPG-G"] = "rbxassetid://83859163267055",
    ["RR_Radio"] = "rbxassetid://4763575350",
    ["RSh-12"] = "rbxassetid://18836420529",
    ["Radio"] = "rbxassetid://5056238850",
    ["Rage-potion"] = "rbxassetid://66343245",
    ["Rambo"] = "rbxassetid://8968135333",
    ["RayGun"] = "rbxassetid://11601851755",
    ["Redeemer"] = "rbxassetid://17538033225",
    ["ReforgedKatana"] = "rbxassetid://14800098028",
    ["Relic"] = "rbxassetid://16312443687",
    ["Rendbreaker"] = "rbxassetid://135920281356606",
    ["RiftWaker"] = "rbxassetid://17505438479",
    ["RiotShield"] = "rbxassetid://6153585055",
    ["RoyalBroadsword"] = "rbxassetid://92143102502281",
    ["SB-Launcher"] = "rbxassetid://6128465213",
    ["SB-Minigun"] = "rbxassetid://6131053699",
    ["SBL-MK2"] = "rbxassetid://9240332756",
    ["SBL-MK3"] = "rbxassetid://15687904518",
    ["SCAR-H-1"] = "rbxassetid://13379814638",
    ["SCAR-H-X"] = "rbxassetid://13379814638",
    ["SKS"] = "rbxassetid://9322303767",
    ["SKS-X"] = "rbxassetid://9322303767",
    ["Sabre"] = "rbxassetid://18327959432",
    ["Savage"] = "rbxassetid://16221658019",
    ["Sawn-Off"] = "rbxassetid://9102738327",
    ["ScopelessBFGWithASilencer"] = "rbxassetid://9830716358",
    ["Scout"] = "rbxassetid://9830716753",
    ["Scythe"] = "rbxassetid://11329574230",
    ["SelfDetonator"] = "rbxassetid://11522216069",
    ["Shiv"] = "rbxassetid://8983371530",
    ["Shovel"] = "rbxassetid://8968283214",
    ["SillyGuitar"] = "rbxassetid://55735329",
    ["Skyfall T.A.G."] = "rbxassetid://17199195221",
    ["SlayerSword"] = "rbxassetid://9214967819",
    ["Sledgehammer"] = "rbxassetid://13379814837",
    ["Smoke-Grenade"] = "rbxassetid://5002850714",
    ["Snowball"] = "rbxassetid://6128391694",
    ["SoulVial"] = "rbxassetid://18167588657",
    ["Splint"] = "rbxassetid://7371337380",
    ["SquidwardC4"] = "rbxassetid://16934136003",
    ["Stun-Grenade"] = "rbxassetid://9102351313",
    ["Super-Shorty"] = "rbxassetid://9102755894",
    ["TEC-9"] = "rbxassetid://9102540386",
    ["Taco"] = "rbxassetid://14846949",
    ["Taiga"] = "rbxassetid://8983372577",
    ["Taser"] = "rbxassetid://9102539923",
    ["TeddyBloxpin"] = "rbxassetid://12218172",
    ["Termination"] = "rbxassetid://189841509",
    ["TeslaCannon"] = "rbxassetid://140296347775236",
    ["TheCure"] = "rbxassetid://7814615388",
    ["Thermal-Katana"] = "rbxassetid://15508052260",
    ["Tomahawk"] = "rbxassetid://14800096968",
    ["Tommy"] = "rbxassetid://9102647830",
    ["Tommy-S"] = "rbxassetid://9102647830",
    ["TripleAirstrike"] = "rbxassetid://4570279329",
    ["TurkeyLeg"] = "rbxassetid://13073604",
    ["UMP-45"] = "rbxassetid://9102648280",
    ["UMP-45-S"] = "rbxassetid://9102648280",
    ["URM_Deagle"] = "rbxassetid://4570279967",
    ["URM_MGL"] = "rbxassetid://4570281022",
    ["USP"] = "rbxassetid://17553427120",
    ["UTS-15"] = "rbxassetid://4570282766",
    ["UTS-S"] = "rbxassetid://4570282766",
    ["Uzi"] = "rbxassetid://9102647258",
    ["Uzi-S"] = "rbxassetid://9102647258",
    ["VirusPotion"] = "rbxassetid://17561012740",
    ["W-ChocBar_1"] = "rbxassetid://11257408219",
    ["Whistle"] = "rbxassetid://128121687",
    ["WitchesBrew"] = "rbxassetid://15178997701",
    ["Wrench"] = "rbxassetid://8968178496",
    ["X13"] = "rbxassetid://17108176074",
    ["X24"] = "rbxassetid://13939003452",
    ["X31"] = "rbxassetid://18289871778",
    ["_AKM-S"] = "rbxassetid://9102820314",
    ["_AKS-74UN"] = "rbxassetid://9351598417",
    ["_BFists"] = "rbxassetid://17557986776",
    ["_CompoundXVision"] = "rbxassetid://8600869433",
    ["_CompoundXVision0.5"] = "rbxassetid://8600869433",
    ["_CompoundXVision2"] = "rbxassetid://8600869433",
    ["_FM1911"] = "rbxassetid://117258732953458",
    ["_FallenBlade"] = "rbxassetid://15665357297",
    ["_Fist"] = "rbxassetid://17297138255",
    ["_G-17-S"] = "rbxassetid://9102539923",
    ["_M4"] = "rbxassetid://9102820013",
    ["_OLD_SlayerSword"] = "rbxassetid://6128392041",
    ["_PurpleGuysAxe"] = "rbxassetid://4898859361",
    ["_Sledge"] = "rbxassetid://10478994695",
    ["__AKM-N"] = "rbxassetid://9102820314",
    ["__InfantryRadioBlue"] = "rbxassetid://4763575350",
    ["__InfantryRadioRed"] = "rbxassetid://4763575350",
    ["__RiotShield"] = "rbxassetid://6153585055",
    ["__Spitball"] = "rbxassetid://9789474866",
    ["__TestDeagle"] = "rbxassetid://4570279967",
    ["__XFists"] = "rbxassetid://12737447569",
    ["__ZombieFists1"] = "rbxassetid://1568022303",
    ["__ZombieFists2"] = "rbxassetid://1568022303",
    ["__ZombieFists3"] = "rbxassetid://1568022303",
    ["__ZombieFists4"] = "rbxassetid://1568022303",
    ["___devorak_HealSerum"] = "rbxassetid://16291625893",
    ["key_Blue"] = "rbxassetid://16910400691",
    ["key_Red"] = "rbxassetid://16910341157",
    ["legacyUTS-15"] = "rbxassetid://4570282766",
    ["legacyUTS-S"] = "rbxassetid://4570282766",
    ["new_oldSlayerSword"] = "rbxassetid://6128392041",
    ["notmen"] = "rbxassetid://11146000563",
    ["val_Battery"] = "rbxassetid://11146000563",
    ["val_Blueprint"] = "rbxassetid://11146001576",
    ["val_Cloth"] = "rbxassetid://11145999977",
    ["val_Documents"] = "rbxassetid://11146001054",
    ["val_Dogtag"] = "rbxassetid://11146001318",
    ["val_FloppyDrive"] = "rbxassetid://11146002677",
    ["val_Jerrycan"] = "rbxassetid://11146002055",
    ["val_Keytool"] = "rbxassetid://11146002888",
    ["val_Lighter"] = "rbxassetid://11147971879",
    ["val_MilitaryCable"] = "rbxassetid://11146001759",
    ["val_PlasmaAcid"] = "rbxassetid://14385011909",
    ["val_SkullRing"] = "rbxassetid://11146003198",
    ["val_VenomVial"] = "rbxassetid://17146007521",
    ["val_Watch"] = "rbxassetid://11146002388",
    ["val_WeaponParts"] = "rbxassetid://11145999491",
    ["val_Wires"] = "rbxassetid://11146000815"
}

function CreateTextESP(parent, text, offset)
    BillboardGui = table.remove(TextObjectPool) or Instance.new("BillboardGui")
    TextLabel = BillboardGui:FindFirstChild("TextLabel") or Instance.new("TextLabel")
    BillboardGui.Parent = parent
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, 200, 0, 50)
    BillboardGui.StudsOffset = offset
    BillboardGui.MaxDistance = 1000
    BillboardGui.LightInfluence = 0
    TextLabel.Parent = BillboardGui
    TextLabel.BackgroundTransparency = 1
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.Text = text
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.SourceSans
    return BillboardGui
end

function CreateWeaponImageESP(parent, weaponName)
    BillboardGui = table.remove(ImageObjectPool) or Instance.new("BillboardGui")
    ImageLabel = BillboardGui:FindFirstChild("ImageLabel") or Instance.new("ImageLabel")
    BillboardGui.Parent = parent
    BillboardGui.AlwaysOnTop = true
    BillboardGui.Size = UDim2.new(0, WeaponImageSize, 0, WeaponImageSize)
    BillboardGui.StudsOffset = Vector3.new(0, -3, 0)
    BillboardGui.MaxDistance = 1000
    BillboardGui.LightInfluence = 0
    ImageLabel.Parent = BillboardGui
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Size = UDim2.new(1, 0, 1, 0)
    ImageLabel.Image = weaponImages[weaponName] or ""
    return BillboardGui
end

function CreateHealthBarESP(parent, humanoid, distance)
    if HealthBarObjects[parent] then
        HealthBarObjects[parent]:Destroy()
        HealthBarObjects[parent] = nil
    end

    BillboardGui = Instance.new("BillboardGui")
    Frame = Instance.new("Frame")
    HealthFrame = Instance.new("Frame")

    BillboardGui.Parent = parent
    BillboardGui.Name = "HealthBar"
    ScaleFactor = math.clamp((ESPDistance * 0.2) / (distance + ESPDistance * 0.05), 0.5, 1.5)
    BillboardGui.Size = UDim2.new(0.5 * ScaleFactor, 0, 5 * ScaleFactor, 0)
    BillboardGui.StudsOffset = Vector3.new(-2 * ScaleFactor, 0, 0)
    BillboardGui.AlwaysOnTop = true
    BillboardGui.MaxDistance = ESPDistance
    BillboardGui.LightInfluence = 0

    Frame.Size = UDim2.new(1, 0, 1, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = BillboardGui

    HealthFrame.Name = "Health"
    HealthFrame.Size = UDim2.new(1, 0, 1, 0)
    HealthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    HealthFrame.BorderSizePixel = 0
    HealthFrame.AnchorPoint = Vector2.new(0, 1)
    HealthFrame.Position = UDim2.new(0, 0, 1, 0)
    HealthFrame.Parent = Frame

    UpdateHealth = function()
        HealthPercent = humanoid.Health / humanoid.MaxHealth
        HealthFrame.Size = UDim2.new(1, 0, HealthPercent, 0)
        if HealthPercent > 0.5 then
            HealthFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        elseif HealthPercent > 0.3 then
            HealthFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
        else
            HealthFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    humanoid:GetPropertyChangedSignal("Health"):Connect(UpdateHealth)
    humanoid.Died:Connect(function()
        if HealthBarObjects[parent] then
            HealthBarObjects[parent]:Destroy()
            HealthBarObjects[parent] = nil
        end
    end)

    UpdateHealth()
    HealthBarObjects[parent] = BillboardGui
    return BillboardGui
end

function CreateChinaHat(character)
    if ChinaHats[character] then
        ChinaHats[character]:Destroy()
        ChinaHats[character] = nil
    end

    head = character:FindFirstChild("Head")
    if not head then return end

    cone = Instance.new("Part")
    cone.Size = Vector3.new(1, 1, 1)
    cone.BrickColor = BrickColor.new("White")
    cone.Transparency = 0.3
    cone.Anchored = false
    cone.CanCollide = false

    mesh = Instance.new("SpecialMesh", cone)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7, 1.1, 1.7)

    weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = cone
    weld.C0 = CFrame.new(0, 0.9, 0)

    cone.Parent = character
    weld.Parent = cone

    highlight = Instance.new("Highlight", cone)
    highlight.FillColor = ChinaHatColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = ChinaHatColor
    highlight.OutlineTransparency = 0

    ChinaHats[character] = cone
end

function CreateAdornments(part)
    Adornments = {}
    for vis = 1, 2 do
        if part.Name == "Head" then
            Adornments[vis] = Instance.new("CylinderHandleAdornment")
            Adornments[vis].Height = 1.2
            Adornments[vis].Radius = 0.78
            Adornments[vis].CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0))
            if vis == 1 then
                Adornments[vis].Radius = Adornments[vis].Radius - 0.15
                Adornments[vis].Height = Adornments[vis].Height - 0.15
            end
        else
            Adornments[vis] = Instance.new("BoxHandleAdornment")
            Adornments[vis].Size = part.Size + Vector3.new(0.2, 0.2, 0.2)
            if vis == 1 then
                Adornments[vis].Size = Adornments[vis].Size - Vector3.new(0.15, 0.15, 0.15)
            end
        end
        Adornments[vis].Parent = game:GetService("CoreGui")
        Adornments[vis].Adornee = part
        Adornments[vis].Name = vis == 1 and "Invisible" or "Visible"
        Adornments[vis].ZIndex = vis == 1 and 2 or 1
        Adornments[vis].AlwaysOnTop = vis == 1
    end
    return Adornments
end

function GetPlayerData(player)
    if not PlayerData[player] then
        PlayerData[player] = {Weapon = "", Inventory = {}, Health = 100}
    end
    return PlayerData[player]
end

function ClearESP()
    for _, obj in pairs(ESPObjects) do
        obj.Parent = nil
        if obj:FindFirstChild("TextLabel") then
            table.insert(TextObjectPool, obj)
        elseif obj:FindFirstChild("ImageLabel") then
            table.insert(ImageObjectPool, obj)
        end
    end
    ESPObjects = {}
    for _, obj in pairs(HealthBarObjects) do
        obj:Destroy()
    end
    HealthBarObjects = {}
    for player, line in pairs(LookLines) do
        line:Remove()
    end
    LookLines = {}
    for player, lines in pairs(SkeletonLines) do
        for _, line in pairs(lines) do
            line:Remove()
        end
    end
    SkeletonLines = {}
    for player, dot in pairs(HeadDots) do
        dot:Remove()
    end
    HeadDots = {}
    for player, tracer in pairs(Tracers) do
        tracer:Remove()
    end
    Tracers = {}
    for character, hat in pairs(ChinaHats) do
        hat:Destroy()
    end
    ChinaHats = {}
    for _, player in pairs(PlayerAdornments) do
        player.Highlight.Enabled = false
        player.Highlight.Adornee = nil
        for _, adornmentsTable in pairs(player.Adornments) do
            for _, adornment in pairs(adornmentsTable) do
                adornment.Visible = false
            end
        end
    end
    SelfHighlight.Enabled = false
    SelfHighlight.Adornee = nil
end

function CountItems(items)
    Counted = {}
    for _, item in pairs(items) do
        if item:IsA("Tool") then
            Counted[item.Name] = (Counted[item.Name] or 0) + 1
        end
    end
    Result = ""
    for name, count in pairs(Counted) do
        if count > 1 then
            Result = Result .. name .. " (" .. count .. "), "
        else
            Result = Result .. name .. ", "
        end
    end
    return Result ~= "" and Result:sub(1, -3) or ""
end

function UpdateESP()
    CurrentTime = tick()
    if CurrentTime - LastUpdateTime < UpdateInterval then
        return
    end
    LastUpdateTime = CurrentTime

    if not ESPEnabled then
        ClearESP()
        return
    end
    
    for _, obj in pairs(ESPObjects) do
        obj.Parent = nil
        if obj:FindFirstChild("TextLabel") then
            table.insert(TextObjectPool, obj)
        elseif obj:FindFirstChild("ImageLabel") then
            table.insert(ImageObjectPool, obj)
        end
    end
    ESPObjects = {}
    
    LocalPlayer = game.Players.LocalPlayer
    LocalTeam = LocalPlayer.Team
    LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not LocalRoot then return end
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            RootPart = player.Character.HumanoidRootPart
            Humanoid = player.Character.Humanoid
            Distance = (RootPart.Position - LocalRoot.Position).Magnitude
            
            if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam and player ~= LocalPlayer) then
                if HealthBarObjects[RootPart] then
                    HealthBarObjects[RootPart]:Destroy()
                    HealthBarObjects[RootPart] = nil
                end
                continue
            end
            
            if player ~= LocalPlayer then
                Data = GetPlayerData(player)
                Tool = player.Character:FindFirstChildOfClass("Tool")
                Backpack = player:FindFirstChild("Backpack")
                
                if ShowNameDist or ShowWeapon or ShowHealth then
                    Text = ""
                    if ShowNameDist then
                        Text = player.Name .. " | " .. math.floor(Distance) .. " studs"
                    end
                    if ShowWeapon and Tool then
                        Text = Text .. (Text ~= "" and " | " or "") .. Tool.Name
                    end
                    if ShowHealth then
                        Text = Text .. (Text ~= "" and " | " or "") .. math.floor(Humanoid.Health)
                    end
                    if Text ~= "" then
                        table.insert(ESPObjects, CreateTextESP(RootPart, Text, Vector3.new(0, 3, 0)))
                    end
                end
                
                if ShowInventory and Backpack then
                    Items = CountItems(Backpack:GetChildren())
                    if Items ~= "" then
                        table.insert(ESPObjects, CreateTextESP(RootPart, Items, Vector3.new(0, -2, 0)))
                    end
                end
                
                if ShowWeaponImage and Tool and weaponImages[Tool.Name] then
                    table.insert(ESPObjects, CreateWeaponImageESP(RootPart, Tool.Name))
                end
                
                if ShowHealthBar then
                    table.insert(ESPObjects, CreateHealthBarESP(RootPart, Humanoid, Distance))
                elseif HealthBarObjects[RootPart] then
                    HealthBarObjects[RootPart]:Destroy()
                    HealthBarObjects[RootPart] = nil
                end
            end
        else
            if player.Character then
                RootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if RootPart and HealthBarObjects[RootPart] then
                    HealthBarObjects[RootPart]:Destroy()
                    HealthBarObjects[RootPart] = nil
                end
                if player.Character and ChinaHats[player.Character] then
                    ChinaHats[player.Character]:Destroy()
                    ChinaHats[player.Character] = nil
                end
            end
        end
    end
end

function UpdateDynamicESP()
    if not ESPEnabled then
        for player, lines in pairs(SkeletonLines) do
            for _, line in pairs(lines) do
                line.Visible = false
            end
        end
        for player, dot in pairs(HeadDots) do
            dot.Visible = false
        end
        for player, tracer in pairs(Tracers) do
            tracer.Visible = false
        end
        return
    end

    LocalPlayer = game.Players.LocalPlayer
    LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not LocalRoot then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            RootPart = player.Character.HumanoidRootPart
            Humanoid = player.Character.Humanoid
            Distance = (RootPart.Position - LocalRoot.Position).Magnitude
            LocalTeam = LocalPlayer.Team

            if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam) then
                if SkeletonLines[player] then
                    for _, line in pairs(SkeletonLines[player]) do
                        line.Visible = false
                    end
                end
                if HeadDots[player] then
                    HeadDots[player].Visible = false
                end
                if Tracers[player] then
                    Tracers[player].Visible = false
                end
                continue
            end

            if ShowSkeleton and Humanoid.Health > 0 then
                head = player.Character:FindFirstChild("Head")
                torso = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
                leftArm = player.Character:FindFirstChild("Left Arm") or player.Character:FindFirstChild("LeftUpperArm")
                rightArm = player.Character:FindFirstChild("Right Arm") or player.Character:FindFirstChild("RightUpperArm")
                leftLeg = player.Character:FindFirstChild("Left Leg") or player.Character:FindFirstChild("LeftUpperLeg")
                rightLeg = player.Character:FindFirstChild("Right Leg") or player.Character:FindFirstChild("RightUpperLeg")

                if head and torso and leftArm and rightArm and leftLeg and rightLeg then
                    if not SkeletonLines[player] then
                        SkeletonLines[player] = {
                            HeadToTorso = Drawing.new("Line"),
                            TorsoToLeftArm = Drawing.new("Line"),
                            LeftArmToHand = Drawing.new("Line"),
                            TorsoToRightArm = Drawing.new("Line"),
                            RightArmToHand = Drawing.new("Line"),
                            TorsoToLeftLeg = Drawing.new("Line"),
                            LeftLegToFoot = Drawing.new("Line"),
                            TorsoToRightLeg = Drawing.new("Line"),
                            RightLegToFoot = Drawing.new("Line"),
                        }
                        for _, line in pairs(SkeletonLines[player]) do
                            line.Color = SkeletonColor
                            line.Thickness = 1
                            line.Transparency = 1
                        end
                    end

                    function updateLine(line, part1, part2)
                        pos1, onScreen1 = game.Workspace.CurrentCamera:WorldToViewportPoint(part1.Position)
                        pos2, onScreen2 = game.Workspace.CurrentCamera:WorldToViewportPoint(part2.Position)
                        line.Visible = onScreen1 and onScreen2
                        if line.Visible then
                            line.From = Vector2.new(pos1.X, pos1.Y)
                            line.To = Vector2.new(pos2.X, pos2.Y)
                        end
                    end

                    updateLine(SkeletonLines[player].HeadToTorso, head, torso)
                    updateLine(SkeletonLines[player].TorsoToLeftArm, torso, leftArm)
                    updateLine(SkeletonLines[player].LeftArmToHand, leftArm, leftArm)
                    updateLine(SkeletonLines[player].TorsoToRightArm, torso, rightArm)
                    updateLine(SkeletonLines[player].RightArmToHand, rightArm, rightArm)
                    updateLine(SkeletonLines[player].TorsoToLeftLeg, torso, leftLeg)
                    updateLine(SkeletonLines[player].LeftLegToFoot, leftLeg, leftLeg)
                    updateLine(SkeletonLines[player].TorsoToRightLeg, torso, rightLeg)
                    updateLine(SkeletonLines[player].RightLegToFoot, rightLeg, rightLeg)
                else
                    if SkeletonLines[player] then
                        for _, line in pairs(SkeletonLines[player]) do
                            line.Visible = false
                        end
                    end
                end
            elseif SkeletonLines[player] then
                for _, line in pairs(SkeletonLines[player]) do
                    line.Visible = false
                end
            end

            if ShowHeadDot and player.Character:FindFirstChild("Head") and Humanoid.Health > 0 then
                head = player.Character:FindFirstChild("Head")
                if not HeadDots[player] then
                    HeadDots[player] = Drawing.new("Circle")
                    HeadDots[player].Color = HeadDotColor
                    HeadDots[player].Thickness = 3
                    HeadDots[player].NumSides = 12
                    HeadDots[player].Radius = 1.2
                    HeadDots[player].Filled = true
                end
                headScreen, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(head.Position)
                HeadDots[player].Visible = onScreen
                if onScreen then
                    baseRadius = 1.2
                    fov = 70
                    scale = (game.Workspace.CurrentCamera.ViewportSize.Y / 2) / (math.tan(math.rad(fov / 2)) * Distance)
                    HeadDots[player].Radius = math.clamp(baseRadius * scale * 0.3, 1, 3)
                    HeadDots[player].Position = Vector2.new(headScreen.X, headScreen.Y)
                end
            elseif HeadDots[player] then
                HeadDots[player].Visible = false
            end

            if ShowTracer and Humanoid.Health > 0 then
                rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if not Tracers[player] then
                    Tracers[player] = Drawing.new("Line")
                    Tracers[player].Color = TracerColor
                    Tracers[player].Thickness = 1
                    Tracers[player].Transparency = 1
                end
                rootScreen, onScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(rootPart.Position)
                Tracers[player].Visible = onScreen
                if onScreen then
                    Tracers[player].From = Vector2.new(game.Workspace.CurrentCamera.ViewportSize.X / 2, game.Workspace.CurrentCamera.ViewportSize.Y / 2)
                    Tracers[player].To = Vector2.new(rootScreen.X, rootScreen.Y)
                end
            elseif Tracers[player] then
                Tracers[player].Visible = false
            end
        else
            if SkeletonLines[player] then
                for _, line in pairs(SkeletonLines[player]) do
                    line.Visible = false
                end
            end
            if HeadDots[player] then
                HeadDots[player].Visible = false
            end
            if Tracers[player] then
                Tracers[player].Visible = false
            end
        end
    end
end

function UpdateLookDirection()
    if not ESPEnabled or not ShowLookDirection then
        for player, line in pairs(LookLines) do
            line:Remove()
            LookLines[player] = nil
        end
        return
    end

    LocalPlayer = game.Players.LocalPlayer
    LocalTeam = LocalPlayer.Team
    LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not LocalRoot then return end

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
            RootPart = player.Character.HumanoidRootPart
            Humanoid = player.Character.Humanoid
            Distance = (RootPart.Position - LocalRoot.Position).Magnitude

            if Distance > ESPDistance or (TeamCheck and LocalTeam and player.Team == LocalTeam) then
                if LookLines[player] then
                    LookLines[player]:Remove()
                    LookLines[player] = nil
                end
                continue
            end

            if player.Character:FindFirstChild("Head") and Humanoid.Health > 0 then
                if not LookLines[player] then
                    LookLines[player] = Drawing.new("Line")
                    LookLines[player].Color = LookDirectionColor
                    LookLines[player].Thickness = 1
                    LookLines[player].Transparency = 1
                end
                HeadPos, OnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(player.Character.Head.Position)
                if OnScreen then
                    LookVector = player.Character.Head.CFrame.LookVector
                    EndPos = player.Character.Head.Position + LookVector * 15
                    EndPosScreen, Visible = game.Workspace.CurrentCamera:WorldToViewportPoint(EndPos)
                    LookLines[player].From = Vector2.new(HeadPos.X, HeadPos.Y)
                    LookLines[player].To = Vector2.new(EndPosScreen.X, EndPosScreen.Y)
                    LookLines[player].Visible = Visible
                    LookLines[player].Thickness = math.clamp(1 / Distance * ESPDistance, 0.1, 3)
                else
                    LookLines[player].Visible = false
                end
            elseif LookLines[player] then
                LookLines[player]:Remove()
                LookLines[player] = nil
            end
        else
            if LookLines[player] then
                LookLines[player]:Remove()
                LookLines[player] = nil
            end
        end
    end
end

function UpdateChinaHat()
    if not ShowChinaHat then
        for character, hat in pairs(ChinaHats) do
            hat:Destroy()
            ChinaHats[character] = nil
        end
        return
    end

    LocalPlayer = game.Players.LocalPlayer
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") then
            Humanoid = player.Character.Humanoid
            if Humanoid.Health > 0 then
                ShouldShowHat = (player == LocalPlayer) or IsWhitelisted
                if ShouldShowHat then
                    if not ChinaHats[player.Character] then
                        CreateChinaHat(player.Character)
                    else
                        highlight = ChinaHats[player.Character]:FindFirstChildOfClass("Highlight")
                        if highlight then
                            highlight.FillColor = ChinaHatColor
                            highlight.OutlineColor = ChinaHatColor
                        end
                    end
                elseif ChinaHats[player.Character] then
                    ChinaHats[player.Character]:Destroy()
                    ChinaHats[player.Character] = nil
                end
            elseif ChinaHats[player.Character] then
                ChinaHats[player.Character]:Destroy()
                ChinaHats[player.Character] = nil
            end
        elseif player.Character and ChinaHats[player.Character] then
            ChinaHats[player.Character]:Destroy()
            ChinaHats[player.Character] = nil
        end
    end
end

function UpdateVisuals()
    if not ESPEnabled then
        for _, player in pairs(PlayerAdornments) do
            player.Highlight.Enabled = false
            player.Highlight.Adornee = nil
            for _, adornmentsTable in pairs(player.Adornments) do
                for _, adornment in pairs(adornmentsTable) do
                    adornment.Visible = false
                end
            end
        end
        SelfHighlight.Enabled = false
        SelfHighlight.Adornee = nil
        return
    end

    LocalPlayer = game.Players.LocalPlayer
    LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not LocalRoot then 
        SelfHighlight.Enabled = false
        SelfHighlight.Adornee = nil
        return 
    end

    if SelfHighlightToggle and ESPEnabled and LocalPlayer.Character then
        SelfHighlight.Adornee = LocalPlayer.Character
        SelfHighlight.Enabled = true
        SelfHighlight.FillColor = SelfFillColor
        SelfHighlight.OutlineColor = SelfOutlineColor
        SelfHighlight.FillTransparency = 0
        SelfHighlight.OutlineTransparency = 0
    else
        SelfHighlight.Enabled = false
        SelfHighlight.Adornee = nil
    end

    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player == LocalPlayer then continue end

        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            if PlayerAdornments[player] then
                PlayerAdornments[player].Highlight.Enabled = false
                PlayerAdornments[player].Highlight.Adornee = nil
                for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
                    for _, adornment in pairs(adornmentsTable) do
                        adornment.Visible = false
                    end
                end
            end
            continue
        end

        Distance = (player.Character.HumanoidRootPart.Position - LocalRoot.Position).Magnitude
        if Distance > ESPDistance or (TeamCheck and LocalPlayer.Team and player.Team == LocalPlayer.Team) then
            if PlayerAdornments[player] then
                PlayerAdornments[player].Highlight.Enabled = false
                PlayerAdornments[player].Highlight.Adornee = nil
                for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
                    for _, adornment in pairs(adornmentsTable) do
                        adornment.Visible = false
                    end
                end
            end
            continue
        end

        if not PlayerAdornments[player] then
            PlayerAdornments[player] = {
                Highlight = Instance.new("Highlight"),
                Adornments = {},
                NeedsUpdate = true,
                LastUpdate = 0
            }
            PlayerAdornments[player].Highlight.Parent = game:GetService("CoreGui")
            PlayerAdornments[player].Highlight.Enabled = false
        end

        if HighlightsToggle and ESPEnabled then
            PlayerAdornments[player].Highlight.Enabled = true
            PlayerAdornments[player].Highlight.FillColor = FillColor
            PlayerAdornments[player].Highlight.OutlineColor = OutlineColor
            PlayerAdornments[player].Highlight.FillTransparency = 0
            PlayerAdornments[player].Highlight.OutlineTransparency = 0
            PlayerAdornments[player].Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            PlayerAdornments[player].Highlight.Adornee = player.Character
        else
            PlayerAdornments[player].Highlight.Enabled = false
            PlayerAdornments[player].Highlight.Adornee = nil
        end

        if ChamsToggle then
            if PlayerAdornments[player].NeedsUpdate or (tick() - PlayerAdornments[player].LastUpdate > 30) then
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") and table.find({"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}, part.Name) then
                        if not PlayerAdornments[player].Adornments[part] then
                            PlayerAdornments[player].Adornments[part] = CreateAdornments(part)
                        end
                        PlayerAdornments[player].Adornments[part][1].Visible = true
                        PlayerAdornments[player].Adornments[part][1].Color3 = OccludedColor
                        PlayerAdornments[player].Adornments[part][1].Transparency = 0
                        PlayerAdornments[player].Adornments[part][2].Visible = true
                        PlayerAdornments[player].Adornments[part][2].Color3 = VisibleColor
                        PlayerAdornments[player].Adornments[part][2].Transparency = 0.5
                        PlayerAdornments[player].Adornments[part][2].AlwaysOnTop = false
                        PlayerAdornments[player].Adornments[part][2].ZIndex = 1
                    end
                end
                PlayerAdornments[player].NeedsUpdate = false
                PlayerAdornments[player].LastUpdate = tick()
            end
        else
            for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
                for _, adornment in pairs(adornmentsTable) do
                    adornment.Visible = false
                end
            end
        end
    end
end

function createArrow()
    container = Instance.new("Frame")
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 100, 0, 70)
    container.Name = "ArrowContainer"
    container.ZIndex = 10
    container.Visible = Arrows.Enabled
    container.Parent = gui

    arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.AnchorPoint = Vector2.new(0.5, 0)
    arrow.BackgroundTransparency = 1
    arrow.Size = Arrows.Size
    arrow.Image = Arrows.Image
    arrow.ZIndex = 10
    arrow.Position = UDim2.new(0.5, 0, 0, 0)
    arrow.Parent = container

    nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 0)
    nameLabel.Position = UDim2.new(0.5, 0, 0, Arrows.Size.Y.Offset + 2)
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Font = Enum.Font.Code
    nameLabel.TextSize = 17
    nameLabel.Text = ""
    nameLabel.Visible = Arrows.NameLabel
    nameLabel.ZIndex = 10
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Parent = container

    distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "Distance"
    distanceLabel.AnchorPoint = Vector2.new(0.5, 0)
    distanceLabel.Position = UDim2.new(0.5, 0, 0, Arrows.Size.Y.Offset + 24)
    distanceLabel.Size = UDim2.new(1, 0, 0, 18)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0.5
    distanceLabel.Font = Enum.Font.Code
    distanceLabel.TextSize = 16
    distanceLabel.Text = ""
    distanceLabel.Visible = Arrows.DistanceLabel
    distanceLabel.ZIndex = 10
    distanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    distanceLabel.Parent = container

    return container
end

ESPEnabledToggle = VisualsLeft:AddToggle('ESPEnabled', {
    Text = "Enable ESP",
    Default = false,
    Callback = function(Value)
        ESPEnabled = Value
        if Value then
            ChamsToggle = false
            SelfHighlightToggle = false
            HighlightsToggle = false
            for _, player in pairs(PlayerAdornments) do
                player.Highlight.Enabled = false
                player.Highlight.Adornee = nil
                for _, adornmentsTable in pairs(player.Adornments) do
                    for _, adornment in pairs(adornmentsTable) do
                        adornment.Visible = false
                    end
                end
            end
            SelfHighlight.Enabled = false
            SelfHighlight.Adornee = nil
        else
            ClearESP()
            ChamsToggle = false
            SelfHighlightToggle = false
            HighlightsToggle = false
            for _, player in pairs(PlayerAdornments) do
                player.Highlight.Enabled = false
                player.Highlight.Adornee = nil
                for _, adornmentsTable in pairs(player.Adornments) do
                    for _, adornment in pairs(adornmentsTable) do
                        adornment.Visible = false
                    end
                end
            end
            SelfHighlight.Enabled = false
            SelfHighlight.Adornee = nil
        end
        UpdateESP()
        UpdateVisuals()
    end
})

TeamCheckToggle = VisualsLeft:AddToggle('TeamCheck', {
    Text = "Team Check",
    Default = false,
    Callback = function(Value)
        TeamCheck = Value
        Arrows.TeamCheck = Value
        UpdateESP()
        UpdateVisuals()
    end
})

ShowNameDistToggle = VisualsLeft:AddToggle('ShowNameDist', {
    Text = "Show Name & Distance",
    Default = false,
    Callback = function(Value)
        ShowNameDist = Value
        UpdateESP()
    end
})

ShowHealthToggle = VisualsLeft:AddToggle('ShowHealth', {
    Text = "Show Health",
    Default = false,
    Callback = function(Value)
        ShowHealth = Value
        UpdateESP()
    end
})

ShowHealthBarToggle = VisualsLeft:AddToggle('ShowHealthBar', {
    Text = "Show HealthBar",
    Default = false,
    Callback = function(Value)
        ShowHealthBar = Value
        UpdateESP()
    end
})

ShowWeaponToggle = VisualsLeft:AddToggle('ShowWeapon', {
    Text = "Show Weapon",
    Default = false,
    Callback = function(Value)
        ShowWeapon = Value
        UpdateESP()
    end
})

ShowWeaponImageToggle = VisualsLeft:AddToggle('ShowWeaponImage', {
    Text = "Show Weapon Image",
    Default = false,
    Callback = function(Value)
        ShowWeaponImage = Value
        UpdateESP()
    end
})

ShowInventoryToggle = VisualsLeft:AddToggle('ShowInventory', {
    Text = "Show Inventory",
    Default = false,
    Callback = function(Value)
        ShowInventory = Value
        UpdateESP()
    end
})

ShowLookDirectionToggle = VisualsLeft:AddToggle('ShowLookDirection', {
    Text = "Show Look Direction",
    Default = false,
    Callback = function(Value)
        ShowLookDirection = Value
        if not Value then
            for player, line in pairs(LookLines) do
                line:Remove()
                LookLines[player] = nil
            end
        end
        UpdateLookDirection()
    end
}):AddColorPicker('LookDirectionColor', {
    Default = Color3.fromRGB(255, 203, 138),
    Title = "Look Direction Color",
    Callback = function(Value)
        LookDirectionColor = Value
        for _, line in pairs(LookLines) do
            line.Color = Value
        end
    end
})

ArrowToggle = VisualsLeft:AddToggle('ShowArrows', {
    Text = 'Show Arrows',
    Default = false,
    Callback = function(Value)
        Arrows.Enabled = Value
        gui.Enabled = Value
        for _, arrow in pairs(arrows) do
            if arrow and arrow:IsA("Frame") then
                arrow.Visible = Value
            end
        end
    end
})

ArrowToggle:AddColorPicker('ArrowColorPicker', {
    Default = Color3.new(1, 1, 1),
    Title = 'Arrow Color',
    Transparency = 0,
    Callback = function(Value)
        Arrows.Color = Value
    end
})

VisualsLeft:AddToggle('ShowNameArrow', {
    Text = 'Show Name in Arrows',
    Default = false,
    Callback = function(Value)
        Arrows.NameLabel = Value
        for _, arrow in pairs(arrows) do
            local nameLabel = arrow and arrow:IsA("Frame") and arrow:FindFirstChild("Name")
            if nameLabel then
                nameLabel.Visible = Value
            end
        end
    end
})

VisualsLeft:AddToggle('ShowDistanceArrow', {
    Text = 'Show Distance in Arrows',
    Default = false,
    Callback = function(Value)
        Arrows.DistanceLabel = Value
        for _, arrow in pairs(arrows) do
            local distanceLabel = arrow and arrow:IsA("Frame") and arrow:FindFirstChild("Distance")
            if distanceLabel then
                distanceLabel.Visible = Value
            end
        end
    end
})

ShowSkeletonToggle = VisualsLeft:AddToggle('ShowSkeleton', {
    Text = "Show Skeleton ESP",
    Default = false,
    Callback = function(Value)
        ShowSkeleton = Value
        UpdateDynamicESP()
    end
}):AddColorPicker('SkeletonColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Skeleton Color",
    Callback = function(Value)
        SkeletonColor = Value
        for player, lines in pairs(SkeletonLines) do
            for _, line in pairs(lines) do
                line.Color = Value
            end
        end
    end
})

ShowHeadDotToggle = VisualsLeft:AddToggle('ShowHeadDot', {
    Text = "Show Head Dot",
    Default = false,
    Callback = function(Value)
        ShowHeadDot = Value
        UpdateDynamicESP()
    end
}):AddColorPicker('HeadDotColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Head Dot Color",
    Callback = function(Value)
        HeadDotColor = Value
        for player, dot in pairs(HeadDots) do
            dot.Color = Value
        end
    end
})

ShowTracerToggle = VisualsLeft:AddToggle('ShowTracer', {
    Text = "Show Tracer",
    Default = false,
    Callback = function(Value)
        ShowTracer = Value
        UpdateDynamicESP()
    end
}):AddColorPicker('TracerColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Tracer Color",
    Callback = function(Value)
        TracerColor = Value
        for player, tracer in pairs(Tracers) do
            tracer.Color = Value
        end
    end
})

ShowChinaHatToggle = VisualsLeft:AddToggle('ShowChinaHat', {
    Text = "Show China Hat",
    Default = false,
    Callback = function(Value)
        ShowChinaHat = Value
        UpdateChinaHat()
    end
}):AddColorPicker('ChinaHatColor', {
    Default = Color3.fromRGB(255, 105, 180),
    Title = "China Hat Color",
    Callback = function(Value)
        ChinaHatColor = Value
        for character, hat in pairs(ChinaHats) do
            highlight = hat:FindFirstChildOfClass("Highlight")
            if highlight then
                highlight.FillColor = Value
                highlight.OutlineColor = Value
            end
        end
    end
})

ChamsToggle = VisualsLeft:AddToggle('ChamsToggle', {
    Text = "Show Chams",
    Default = false,
    Callback = function(Value)
        ChamsToggle = Value
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if PlayerAdornments[player] then
                PlayerAdornments[player].NeedsUpdate = true
            end
        end
        UpdateVisuals()
    end
})

ChamsToggle:AddColorPicker('VisibleColor', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = "Visible Color",
    Transparency = 0.5,
    Callback = function(Value)
        VisibleColor = Value
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if PlayerAdornments[player] then
                PlayerAdornments[player].NeedsUpdate = true
            end
        end
        UpdateVisuals()
    end
})

ChamsToggle:AddColorPicker('OccludedColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = "Occluded Color",
    Transparency = 0,
    Callback = function(Value)
        OccludedColor = Value
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if PlayerAdornments[player] then
                PlayerAdornments[player].NeedsUpdate = true
            end
        end
        UpdateVisuals()
    end
})

HighlightsToggle:AddColorPicker('FillColor', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = "Fill Color",
    Transparency = 0,
    Callback = function(Value)
        FillColor = Value
        UpdateVisuals()
    end
})

HighlightsToggle:AddColorPicker('OutlineColor', {
    Default = Color3.fromRGB(0, 0, 0),
    Title = "Outline Color",
    Transparency = 0,
    Callback = function(Value)
        OutlineColor = Value
        UpdateVisuals()
    end
})

SelfHighlightToggle = VisualsLeft:AddToggle('SelfHighlightToggle', {
    Text = "Show Self Highlight",
    Default = false,
    Callback = function(Value)
        SelfHighlightToggle = Value
        SelfHighlight.Enabled = false
        SelfHighlight.Adornee = nil
        UpdateVisuals()
    end
})

SelfHighlightToggle:AddColorPicker('SelfFillColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Self Fill Color",
    Transparency = 0,
    Callback = function(Value)
        SelfFillColor = Value
        SelfHighlight.FillColor = Value
        SelfHighlight.FillTransparency = 0
        UpdateVisuals()
    end
})

SelfHighlightToggle:AddColorPicker('SelfOutlineColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = "Self Outline Color",
    Transparency = 0,
    Callback = function(Value)
        SelfOutlineColor = Value
        SelfHighlight.OutlineColor = Value
        SelfHighlight.OutlineTransparency = 0
        UpdateVisuals()
    end
})

ESPDistanceSlider = VisualsLeft:AddSlider('ESPDistance', {
    Text = "ESP Distance (Studs)",
    Default = 100,
    Min = 1,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        ESPDistance = Value
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if PlayerAdornments[player] then
                PlayerAdornments[player].NeedsUpdate = true
            end
        end
        UpdateESP()
        UpdateLookDirection()
        UpdateDynamicESP()
        UpdateVisuals()
    end
})

WeaponImageSizeSlider = VisualsLeft:AddSlider('WeaponImageSize', {
    Text = "Weapon Image Size",
    Default = 25,
    Min = 10,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        WeaponImageSize = Value
        UpdateESP()
    end
})

RunService.RenderStepped:Connect(function()
    UpdateLookDirection()
    UpdateDynamicESP()
    if ESPEnabled then
        UpdateESP()
    end
    UpdateChinaHat()
    UpdateVisuals()
    screenSize = Camera.ViewportSize
    center = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if Arrows.IgnoreSelf and player == LocalPlayer then
            if arrows[player] then arrows[player].Visible = false end
            continue
        end
        if Arrows.TeamCheck and player.Team == LocalPlayer.Team then
            if arrows[player] then arrows[player].Visible = false end
            continue
        end
        character = player.Character
        hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if arrows[player] then arrows[player].Visible = false end
            continue
        end
        if not arrows[player] then
            arrows[player] = createArrow()
            if not arrows[player] then continue end
        end
        container = arrows[player]
        if not container:IsA("Frame") then continue end
        arrow = container:FindFirstChild("Arrow")
        nameLabel = container:FindFirstChild("Name")
        distanceLabel = container:FindFirstChild("Distance")

        if not arrow then continue end

        hrpPos = hrp.Position
        cameraPos = Camera.CFrame.Position
        cameraLookVector = Camera.CFrame.LookVector
        toPlayerVec = (hrpPos - cameraPos)
        toPlayerDir = toPlayerVec.Unit
        dot = cameraLookVector:Dot(toPlayerDir)

        screenPos, onScreen = Camera:WorldToViewportPoint(hrpPos)
        dir = Vector2.new(screenPos.X - center.X, screenPos.Y - center.Y)
        if dir.Magnitude == 0 then
            dir = Vector2.new(0, 1)
        end
        dirNorm = dir.Unit

        if dot >= 0 then
            arrowPos = center + dirNorm * Arrows.Radius
        else
            arrowPos = center - dirNorm * Arrows.Radius
        end

        arrowPos = Vector2.new(
            math.clamp(arrowPos.X, 0, screenSize.X),
            math.clamp(arrowPos.Y, 0, screenSize.Y)
        )

        angle = math.atan2(dirNorm.Y, dirNorm.X)
        if dot < 0 then
            arrow.Rotation = math.deg(angle) + 90 + 180
        else
            arrow.Rotation = math.deg(angle) + 90 + 180
        end

        container.Position = UDim2.new(0, arrowPos.X - container.Size.X.Offset/2, 0, arrowPos.Y - Arrows.Size.Y.Offset)

        if Arrows.UseTeamColor and player.Team then
            arrow.ImageColor3 = player.TeamColor.Color
            nameLabel.TextColor3 = player.TeamColor.Color
            distanceLabel.TextColor3 = player.TeamColor.Color
        else
            arrow.ImageColor3 = Arrows.Color
            nameLabel.TextColor3 = Color3.new(1,1,1)
            distanceLabel.TextColor3 = Color3.new(1,1,1)
        end

        nameLabel.Text = player.Name
        distanceLabel.Text = tostring(math.floor(toPlayerVec.Magnitude)) .. " studs"

        container.Visible = Arrows.Enabled
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if LookLines[player] then
        LookLines[player]:Remove()
        LookLines[player] = nil
    end
    if SkeletonLines[player] then
        for _, line in pairs(SkeletonLines[player]) do
            line:Remove()
        end
        SkeletonLines[player] = nil
    end
    if HeadDots[player] then
        HeadDots[player]:Remove()
        HeadDots[player] = nil
    end
    if Tracers[player] then
        Tracers[player]:Remove()
        Tracers[player] = nil
    end
    if PlayerAdornments[player] then
        PlayerAdornments[player].Highlight:Destroy()
        for _, adornmentsTable in pairs(PlayerAdornments[player].Adornments) do
            for _, adornment in pairs(adornmentsTable) do
                adornment:Destroy()
            end
        end
        PlayerAdornments[player] = nil
    end
    if arrows[player] then
        arrows[player]:Destroy()
        arrows[player] = nil
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        if PlayerAdornments[player] then
            PlayerAdornments[player].NeedsUpdate = true
        end
        UpdateESP()
        UpdateVisuals()
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    UpdateESP()
    UpdateVisuals()
end)

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer

ESP_Settings = {CashDrop = false, PilesGift = false, Tools = false, ATM = false, Dealer = false, Safe = false, Crates = false, VendingMachine = false}
MaxDistance = 50
ActiveESP = {}
TextSize = 8
CheckLimit = 10
CheckCounter = 0

CreateESP = function(obj, text)
    if not ActiveESP[obj] then
        gui = Instance.new("BillboardGui")
        gui.Name = "ESP"
        gui.Adornee = obj
        gui.Size = UDim2.new(0, 70, 0, 25)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.AlwaysOnTop = true
        label = Instance.new("TextLabel", gui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.BackgroundTransparency = 1
        label.TextScaled = false
        label.TextSize = TextSize
        gui.Parent = obj
        ActiveESP[obj] = gui
    else
        ActiveESP[obj].TextLabel.Text = text
    end
end

IsInRange = function(position)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return (LocalPlayer.Character.HumanoidRootPart.Position - position).Magnitude <= MaxDistance
    end
    return false
end

ScanForESP = function()
    for obj, esp in pairs(ActiveESP) do
        part = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
        shouldRemove = true
        if part and part.Parent then
            if ESP_Settings.CashDrop and obj.Name == "CashDrop1" and obj.Parent == workspace.Filter:FindFirstChild("SpawnedBread") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.PilesGift and obj.Parent == workspace.Filter:FindFirstChild("SpawnedPiles") and (obj.Name == "P" or obj.Name == "S1" or obj.Name == "S2") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.Tools and obj.Parent == workspace.Filter:FindFirstChild("SpawnedTools") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.ATM and obj.Name == "ATM" and obj.Parent == workspace.Map:FindFirstChild("ATMz") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.Dealer and obj.Parent == workspace.Map:FindFirstChild("Shopz") and (obj.Name == "Dealer" or obj.Name == "ArmoryDealer") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.Safe and obj.Parent == workspace.Map:FindFirstChild("BredMakurz") then
                broken = obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Broken")
                if (obj.Name:match("SmallSafe") or obj.Name:match("MediumSafe") or obj.Name:match("Register")) and broken and not broken.Value then
                    shouldRemove = not IsInRange(part.Position)
                end
            elseif ESP_Settings.Crates and obj.Parent == workspace.Filter:FindFirstChild("SpawnedPiles") and (obj.Name == "C1" or obj.Name == "C2" or obj.Name == "C3") then
                shouldRemove = not IsInRange(part.Position)
            elseif ESP_Settings.VendingMachine and obj.Name == "VendingMachine" and obj.Parent == workspace.Map:FindFirstChild("VendingMachines") then
                broken = obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Broken")
                if broken and not broken.Value then
                    stuck = obj:FindFirstChild("Values") and obj.Values:FindFirstChild("Stuck")
                    if ActiveESP[obj] then
                        ActiveESP[obj].TextLabel.Text = stuck and stuck.Value and "Vending Machine | Stuck" or "Vending Machine"
                    end
                    shouldRemove = not IsInRange(part.Position)
                end
            end
        end
        if shouldRemove then
            esp:Destroy()
            ActiveESP[obj] = nil
        end
    end

    CheckCounter = 0

    if ESP_Settings.CashDrop then
        folder = workspace.Filter:FindFirstChild("SpawnedBread")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("MeshPart") and v.Name == "CashDrop1" and not ActiveESP[v] then
                    if IsInRange(v.Position) then CreateESP(v, "CashDrop") end
                    CheckCounter = CheckCounter + 1
                end
            end
        end
    end

    if ESP_Settings.PilesGift then
        folder = workspace.Filter:FindFirstChild("SpawnedPiles")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and (v.Name == "P" or v.Name == "S1" or v.Name == "S2") and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part and IsInRange(part.Position) then CreateESP(v, v.Name == "P" and "Gift" or "Piles") end
                    CheckCounter = CheckCounter + 1
                end
            end
        end
    end

    if ESP_Settings.Tools then
        folder = workspace.Filter:FindFirstChild("SpawnedTools")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part and IsInRange(part.Position) then CreateESP(v, "Tool") end
                    CheckCounter = CheckCounter + 1
                end
            end
        end
    end

    if ESP_Settings.ATM then
        folder = workspace.Map:FindFirstChild("ATMz")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and v.Name == "ATM" and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part and IsInRange(part.Position) then CreateESP(v, "ATM") end
                    CheckCounter = CheckCounter + 1
                end
            end
        end
    end

    if ESP_Settings.Dealer then
        folder = workspace.Map:FindFirstChild("Shopz")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and (v.Name == "Dealer" or v.Name == "ArmoryDealer") and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part and value and IsInRange(part.Position) then CreateESP(v, v.Name == "Dealer" and "Dealer" or "Armory Dealer") end
                    CheckCounter = CheckCounter + 1
                end
            end
        end
    end

    if ESP_Settings.Safe then
        folder = workspace.Map:FindFirstChild("BredMakurz")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    broken = v:FindFirstChild("Values") and v.Values:FindFirstChild("Broken")
                    if part and (v.Name:match("SmallSafe") or v.Name:match("MediumSafe") or v.Name:match("Register")) and broken and not broken.Value and IsInRange(part.Position) then
                        CreateESP(v, v.Name:match("Register") and "Register" or (v.Name:match("SmallSafe") and "Small Safe" or "Medium Safe"))
                        CheckCounter = CheckCounter + 1
                    end
                end
            end
        end
    end

    if ESP_Settings.Crates then
        folder = workspace.Filter:FindFirstChild("SpawnedPiles")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and (v.Name == "C1" or v.Name == "C2" or v.Name == "C3") and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    if part and IsInRange(part.Position) then
                        text = "Crate"
                        if v.Name == "C1" then
                            particle = v:FindFirstChild("MeshPart") and v.MeshPart:FindFirstChild("Particle")
                            if particle and particle.Color then
                                keypoints = particle.Color.Keypoints
                                if #keypoints >= 2 then
                                    c1 = keypoints[1].Value
                                    c2 = keypoints[2].Value
                                    if math.abs(c1.R - 0) < 0.01 and math.abs(c1.G - 0.184314) < 0.01 and math.abs(c1.B - 1) < 0.01 and
                                       math.abs(c2.R - 0) < 0.01 and math.abs(c2.G - 1) < 0.01 and math.abs(c2.B - 0.184314) < 0.01 then
                                        text = "Crate (rarity low)"
                                    elseif math.abs(c1.R - 0) < 0.01 and math.abs(c1.G - 1) < 0.01 and math.abs(c1.B - 0.184314) < 0.01 and
                                           math.abs(c2.R - 0.184314) < 0.01 and math.abs(c2.G - 0) < 0.01 and math.abs(c2.B - 1) < 0.01 then
                                        text = "Crate (rarity mid)"
                                    end
                                end
                            end
                        end
                        CreateESP(v, text)
                        CheckCounter = CheckCounter + 1
                    end
                end
            end
        end
    end

    if ESP_Settings.VendingMachine then
        folder = workspace.Map:FindFirstChild("VendingMachines")
        if folder then
            for _, v in pairs(folder:GetChildren()) do
                if CheckCounter >= CheckLimit then break end
                if v:IsA("Model") and v.Name == "VendingMachine" and not ActiveESP[v] then
                    part = v.PrimaryPart or v:FindFirstChildWhichIsA("BasePart")
                    broken = v:FindFirstChild("Values") and v.Values:FindFirstChild("Broken")
                    stuck = v:FindFirstChild("Values") and v.Values:FindFirstChild("Stuck")
                    if part and broken and not broken.Value and IsInRange(part.Position) then
                        CreateESP(v, stuck and stuck.Value and "Vending Machine | Stuck" or "Vending Machine")
                        CheckCounter = CheckCounter + 1
                    end
                end
            end
        end
    end
end

spawn(function()
    while true do
        ScanForESP()
        wait(1)
    end
end)

CashDropToggle = VisualsRight:AddToggle('CashDropCashDropESP', {
    Text = "CashDrop ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.CashDrop = Value
    end
})

PilesGiftToggle = VisualsRight:AddToggle('PilesGiftESP', {
    Text = "Piles & Gift ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.PilesGift = Value
    end
})

ToolsToggle = VisualsRight:AddToggle('ToolsESP', {
    Text = "Tools ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.Tools = Value
    end
})

ATMToggle = VisualsRight:AddToggle('ATMESP', {
    Text = "ATM ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.ATM = Value
    end
})

DealerToggle = VisualsRight:AddToggle('DealerESP', {
    Text = "Dealer ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.Dealer = Value
    end
})

SafeToggle = VisualsRight:AddToggle('SafeESP', {
    Text = "Safes and Registers ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.Safe = Value
    end
})

CratesToggle = VisualsRight:AddToggle('CratesESP', {
    Text = "Crates ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.Crates = Value
    end
})

VendingMachineToggle = VisualsRight:AddToggle('VendingMachineESP', {
    Text = "Vending Machine ESP",
    Default = false,
    Callback = function(Value)
        ESP_Settings.VendingMachine = Value
    end
})

ESPDistanceSliderExtra = VisualsRight:AddSlider('ESPDistanceExtra', {
    Text = "ESP Distance",
    Default = 50,
    Min = 10,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        MaxDistance = Value
    end
})

ESPTextSizeSlider = VisualsRight:AddSlider('ESPTextSize', {
    Text = "ESP Text Size",
    Default = 8,
    Min = 8,
    Max = 50,
    Rounding = 0,
    Callback = function(Value)
        TextSize = Value
        for _, esp in pairs(ActiveESP) do
            if esp and esp:FindFirstChild("TextLabel") then
                esp.TextLabel.TextSize = TextSize
            end
        end
    end
})

TrailDuration = 2

TrailTransparency = NumberSequence.new(0.5)

TrailColor = Color3.fromRGB(255, 0, 0)

function CreateTrail(attachment0, attachment1)
    if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
    Trail = Instance.new("Trail")
    Trail.Attachment0 = attachment0
    Trail.Attachment1 = attachment1
    Trail.Lifetime = TrailDuration
    Trail.Color = ColorSequence.new(TrailColor)
    Trail.Transparency = TrailTransparency
    Trail.WidthScale = NumberSequence.new(1.5)
    Trail.Parent = game.Workspace
end

game:GetService("RunService").Heartbeat:Connect(function()
    if TrailEnabled and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        rootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
        if not Attach0 then
            Attach0 = Instance.new("Attachment")
            Attach0.Parent = rootPart
            Attach1 = Instance.new("Attachment")
            Attach1.Position = Vector3.new(0, -0.5, 0)
            Attach1.Parent = rootPart
            CreateTrail(Attach0, Attach1)
        end
        Attach0.Position = Vector3.new(0, 0, 0)
        Attach1.Position = Vector3.new(0, -0.5, 0)
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    game.Players.LocalPlayer.Character = newCharacter
    if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
    if Attach0 then Attach0:Destroy() end
    if Attach1 then Attach1:Destroy() end
    Attach0 = nil
    Attach1 = nil
    Trail = nil
end)

Players = game:GetService('Players')
LocalPlayer = Players.LocalPlayer
Camera = workspace.CurrentCamera

HUD = {
    Enabled = false,
    Style = 'Compact',
    Color = Color3.fromRGB(255, 0, 0),
    Font = Enum.Font.Gotham,
    Target = nil,
    GUI = nil,
    Frame = nil,
    NameLabel = nil,
    HealthBar = nil,
    HealthBarFill = nil,
    HealthLabel = nil,
    DistanceLabel = nil,
    LastUpdate = 0,
    MousePos = nil,
    Ray = nil,
    RaycastParams = nil,
    RaycastResult = nil,
    HitPart = nil,
    Character = nil,
    Player = nil,
    OnScreen = false,
    CameraCFrame = nil,
    CameraPos = nil,
    CameraForward = nil,
    TargetPos = nil,
    VectorToTarget = nil,
    Distance = nil,
    Angle = nil,
    ClosestPlayer = nil,
    MinDistance = math.huge,
    ViewModel = nil,
    Tool = nil,
    Hitmarker = nil,
    HitmarkerConnection = nil,
    HitPlayer = nil,
    Sound = nil,
    CenterX = nil,
    CenterY = nil,
    Horizontal = nil,
    Vertical = nil,
    Cam = nil,
    CurrentLookVector = nil,
    LastLookVector = nil,
    RotationSpeed = nil,
    BlurConnection = nil,
    IsFirstPerson = false,
    FOVAngle = math.rad(35 / 2),
    OnScreenRoot = false,
    OnScreenHead = false,
    OnScreenTorso = false,
    OnScreenUpperTorso = false,
    OnScreenLowerTorso = false,
    RigType = nil,
    BoundingBoxPoints = {}
}

ViewmodelSettings = {Enabled = false, Color = Color3.new(1, 1, 1), ClockTime = 12}
CrosshairParts = {}
HeadshotSettings = {Enabled = false, SoundId = 5650646664, Volume = 1}
CustomFOV = Camera.FieldOfView

HitmarkerSounds = {
    Boink = 5451260445,
    TF2 = 5650646664,
    Rust = 5043539486,
    CSGO = 8679627751,
    Hitmarker = 160432334,
    Fortnite = 296102734
}

function ClearHUD()
    if HUD.GUI and HUD.GUI:IsA('ScreenGui') then
        HUD.GUI:Destroy()
    end
    HUD.GUI = nil
    HUD.Frame = nil
    HUD.NameLabel = nil
    HUD.HealthBar = nil
    HUD.HealthBarFill = nil
    HUD.HealthLabel = nil
    HUD.DistanceLabel = nil
end

function CreateCompactHUD(player)
    ClearHUD()
    if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

    HUD.GUI = Instance.new('ScreenGui')
    HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
    HUD.GUI.IgnoreGuiInset = true
    HUD.GUI.Parent = LocalPlayer.PlayerGui
    for i = 1, 10 do
        if HUD.GUI then break end
        task.wait(0.05)
    end
    if not HUD.GUI then return end

    HUD.Frame = Instance.new('Frame', HUD.GUI)
    for i = 1, 10 do
        if HUD.Frame then break end
        task.wait(0.05)
    end
    if not HUD.Frame then return end
    HUD.Frame.Size = UDim2.new(0, 200, 0, 100)
    HUD.Frame.Position = UDim2.new(0.5, -100, 0.75, -50)
    HUD.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HUD.Frame.BackgroundTransparency = 0.2
    HUD.Frame.Rotation = 0
    Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
    Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(50, 50, 50))
    Instance.new('UIGradient', HUD.Frame).Rotation = 45
    Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
    Instance.new('UIStroke', HUD.Frame).Thickness = 3
    game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.4}):Play()

    HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.NameLabel then break end
        task.wait(0.05)
    end
    if not HUD.NameLabel then return end
    HUD.NameLabel.Size = UDim2.new(0.85, 0, 0.25, 0)
    HUD.NameLabel.Position = UDim2.new(0.075, 0, 0.05, 0)
    HUD.NameLabel.Text = player.Name
    HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.NameLabel.BackgroundTransparency = 1
    HUD.NameLabel.TextScaled = true
    HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.NameLabel.Font = HUD.Font

    HUD.HealthBar = Instance.new('Frame', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthBar then break end
        task.wait(0.05)
    end
    if not HUD.HealthBar then return end
    HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
    HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
    HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    HUD.HealthBar.ClipsDescendants = true
    HUD.HealthBar.Rotation = 0
    Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

    HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
    for i = 1, 10 do
        if HUD.HealthBarFill then break end
        task.wait(0.05)
    end
    if not HUD.HealthBarFill then return end
    HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
    HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
    HUD.HealthBarFill.BorderSizePixel = 0
    HUD.HealthBarFill.Rotation = 0
    Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
    game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

    HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthLabel then break end
        task.wait(0.05)
    end
    if not HUD.HealthLabel then return end
    HUD.HealthLabel.Size = UDim2.new(0.85, 0, 0.2, 0)
    HUD.HealthLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
    HUD.HealthLabel.Text = string.format('HP: %.1f', player.Character.Humanoid.Health)
    HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.HealthLabel.BackgroundTransparency = 1
    HUD.HealthLabel.TextScaled = true
    HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.HealthLabel.Font = HUD.Font

    HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.DistanceLabel then break end
        task.wait(0.05)
    end
    if not HUD.DistanceLabel then return end
    HUD.DistanceLabel.Size = UDim2.new(0.85, 0, 0.15, 0)
    HUD.DistanceLabel.Position = UDim2.new(0.075, 0, 0.85, 0)
    HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
    HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.DistanceLabel.BackgroundTransparency = 1
    HUD.DistanceLabel.TextScaled = true
    HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.DistanceLabel.Font = HUD.Font
end

function CreateModernHUD(player)
    ClearHUD()
    if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

    HUD.GUI = Instance.new('ScreenGui')
    HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
    HUD.GUI.IgnoreGuiInset = true
    HUD.GUI.Parent = LocalPlayer.PlayerGui
    for i = 1, 10 do
        if HUD.GUI then break end
        task.wait(0.05)
    end
    if not HUD.GUI then return end

    HUD.Frame = Instance.new('Frame', HUD.GUI)
    for i = 1, 10 do
        if HUD.Frame then break end
        task.wait(0.05)
    end
    if not HUD.Frame then return end
    HUD.Frame.Size = UDim2.new(0, 220, 0, 110)
    HUD.Frame.Position = UDim2.new(0.5, -110, 0.75, -55)
    HUD.Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HUD.Frame.BackgroundTransparency = 0.3
    HUD.Frame.Rotation = 0
    Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(50, 100, 255))
    Instance.new('UIGradient', HUD.Frame).Rotation = 135
    Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 50)
    Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
    Instance.new('UIStroke', HUD.Frame).Thickness = 4
    game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.3}):Play()

    HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.NameLabel then break end
        task.wait(0.05)
    end
    if not HUD.NameLabel then return end
    HUD.NameLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
    HUD.NameLabel.Position = UDim2.new(0.2, 0, 0.05, 0)
    HUD.NameLabel.Text = player.Name
    HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.NameLabel.BackgroundTransparency = 1
    HUD.NameLabel.TextScaled = true
    HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.NameLabel.Font = HUD.Font

    HUD.HealthBar = Instance.new('Frame', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthBar then break end
        task.wait(0.05)
    end
    if not HUD.HealthBar then return end
    HUD.HealthBar.Size = UDim2.new(0.35, 0, 0.35, 0)
    HUD.HealthBar.Position = UDim2.new(0.325, 0, 0.3, 0)
    HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    HUD.HealthBar.ClipsDescendants = true
    HUD.HealthBar.Rotation = 0
    Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(1, 0)

    HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
    for i = 1, 10 do
        if HUD.HealthBarFill then break end
        task.wait(0.05)
    end
    if not HUD.HealthBarFill then return end
    HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
    HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
    HUD.HealthBarFill.BorderSizePixel = 0
    HUD.HealthBarFill.Rotation = 0
    Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(1, 0)
    game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

    HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthLabel then break end
        task.wait(0.05)
    end
    if not HUD.HealthLabel then return end
    HUD.HealthLabel.Size = UDim2.new(0.6, 0, 0.2, 0)
    HUD.HealthLabel.Position = UDim2.new(0.2, 0, 0.7, 0)
    HUD.HealthLabel.Text = string.format('HP: %.1f%%', (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth) * 100)
    HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.HealthLabel.BackgroundTransparency = 1
    HUD.HealthLabel.TextScaled = true
    HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.NameLabel.Font = HUD.Font

    HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.DistanceLabel then break end
        task.wait(0.05)
    end
    if not HUD.DistanceLabel then return end
    HUD.DistanceLabel.Size = UDim2.new(0.6, 0, 0.15, 0)
    HUD.DistanceLabel.Position = UDim2.new(0.2, 0, 0.85, 0)
    HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
    HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.DistanceLabel.BackgroundTransparency = 1
    HUD.DistanceLabel.TextScaled = true
    HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.DistanceLabel.Font = HUD.Font
end

function CreateMinimalHUD(player)
    ClearHUD()
    if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

    HUD.GUI = Instance.new('ScreenGui')
    HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
    HUD.GUI.IgnoreGuiInset = true
    HUD.GUI.Parent = LocalPlayer.PlayerGui
    for i = 1, 10 do
        if HUD.GUI then break end
        task.wait(0.05)
    end
    if not HUD.GUI then return end

    HUD.Frame = Instance.new('Frame', HUD.GUI)
    for i = 1, 10 do
        if HUD.Frame then break end
        task.wait(0.05)
    end
    if not HUD.Frame then return end
    HUD.Frame.Size = UDim2.new(0, 240, 0, 90)
    HUD.Frame.Position = UDim2.new(0.5, -120, 0.75, -45)
    HUD.Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    HUD.Frame.BackgroundTransparency = 0.7
    HUD.Frame.Rotation = 0
    Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
    Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
    Instance.new('UIStroke', HUD.Frame).Thickness = 3
    Instance.new('UIStroke', HUD.Frame).Transparency = 0.5
    game:GetService('TweenService'):Create(HUD.Frame, TweenInfo.new(0.3), {BackgroundTransparency = 0.7}):Play()

    HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.NameLabel then break end
        task.wait(0.05)
    end
    if not HUD.NameLabel then return end
    HUD.NameLabel.Size = UDim2.new(0.5, 0, 0.25, 0)
    HUD.NameLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
    HUD.NameLabel.Text = player.Name
    HUD.NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.NameLabel.BackgroundTransparency = 1
    HUD.NameLabel.TextScaled = true
    HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    HUD.NameLabel.Font = HUD.Font

    HUD.HealthBar = Instance.new('Frame', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthBar then break end
        task.wait(0.05)
    end
    if not HUD.HealthBar then return end
    HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
    HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
    HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    HUD.HealthBar.ClipsDescendants = true
    HUD.HealthBar.Rotation = 0
    Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

    HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
    for i = 1, 10 do
        if HUD.HealthBarFill then break end
        task.wait(0.05)
    end
    if not HUD.HealthBarFill then return end
    HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
    HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 0), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
    HUD.HealthBarFill.BorderSizePixel = 0
    HUD.HealthBarFill.Rotation = 0
    Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
    game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

    HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthLabel then break end
        task.wait(0.05)
    end
    if not HUD.HealthLabel then return end
    HUD.HealthLabel.Size = UDim2.new(0.45, 0, 0.25, 0)
    HUD.HealthLabel.Position = UDim2.new(0.05, 0, 0.65, 0)
    HUD.HealthLabel.Text = string.format('HP: %.1f', player.Character.Humanoid.Health)
    HUD.HealthLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.HealthLabel.BackgroundTransparency = 1
    HUD.HealthLabel.TextScaled = true
    HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Left
    HUD.HealthLabel.Font = HUD.Font

    HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.DistanceLabel then break end
        task.wait(0.05)
    end
    if not HUD.DistanceLabel then return end
    HUD.DistanceLabel.Size = UDim2.new(0.45, 0, 0.25, 0)
    HUD.DistanceLabel.Position = UDim2.new(0.5, 0, 0.65, 0)
    HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
    HUD.DistanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HUD.DistanceLabel.BackgroundTransparency = 1
    HUD.DistanceLabel.TextScaled = true
    HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    HUD.DistanceLabel.Font = HUD.Font
end

function CreateHolographicHUD(player)
    ClearHUD()
    if not HUD.Enabled or not player or not player.Character or not player.Character:FindFirstChild('Humanoid') then return end

    HUD.GUI = Instance.new('ScreenGui')
    HUD.GUI.Name = 'TargetHUD_' .. math.random(1000, 9999)
    HUD.GUI.IgnoreGuiInset = true
    HUD.GUI.Parent = LocalPlayer.PlayerGui
    for i = 1, 10 do
        if HUD.GUI then break end
        task.wait(0.05)
    end
    if not HUD.GUI then return end

    HUD.Frame = Instance.new('Frame', HUD.GUI)
    for i = 1, 10 do
        if HUD.Frame then break end
        task.wait(0.05)
    end
    if not HUD.Frame then return end
    HUD.Frame.Size = UDim2.new(0, 230, 0, 110)
    HUD.Frame.Position = UDim2.new(0.5, -115, 0.75, -55)
    HUD.Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    HUD.Frame.BackgroundTransparency = 0.8
    HUD.Frame.Rotation = 0
    Instance.new('UIGradient', HUD.Frame).Color = ColorSequence.new(HUD.Color, Color3.fromRGB(0, 200, 255))
    Instance.new('UIGradient', HUD.Frame).Rotation = 90
    Instance.new('UICorner', HUD.Frame).CornerRadius = UDim.new(0, 14)
    Instance.new('UIStroke', HUD.Frame).Color = HUD.Color
    Instance.new('UIStroke', HUD.Frame).Thickness = 4
    Instance.new('UIStroke', HUD.Frame).Transparency = 0.3
    game:GetService('TweenService'):Create(Instance.new('UIStroke', HUD.Frame), TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.6}):Play()

    HUD.NameLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.NameLabel then break end
        task.wait(0.05)
    end
    if not HUD.NameLabel then return end
    HUD.NameLabel.Size = UDim2.new(0.85, 0, 0.25, 0)
    HUD.NameLabel.Position = UDim2.new(0.075, 0, 0.05, 0)
    HUD.NameLabel.Text = player.Name
    HUD.NameLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
    HUD.NameLabel.BackgroundTransparency = 1
    HUD.NameLabel.TextScaled = true
    HUD.NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.NameLabel.Font = HUD.Font

    HUD.HealthBar = Instance.new('Frame', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthBar then break end
        task.wait(0.05)
    end
    if not HUD.HealthBar then return end
    HUD.HealthBar.Size = UDim2.new(0.85, 0, 0.3, 0)
    HUD.HealthBar.Position = UDim2.new(0.075, 0, 0.35, 0)
    HUD.HealthBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    HUD.HealthBar.BackgroundTransparency = 0.8
    HUD.HealthBar.ClipsDescendants = true
    HUD.HealthBar.Rotation = 0
    Instance.new('UICorner', HUD.HealthBar).CornerRadius = UDim.new(0, 10)

    HUD.HealthBarFill = Instance.new('Frame', HUD.HealthBar)
    for i = 1, 10 do
        if HUD.HealthBarFill then break end
        task.wait(0.05)
    end
    if not HUD.HealthBarFill then return end
    HUD.HealthBarFill.Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)
    HUD.HealthBarFill.BackgroundColor3 = HUD.Color:Lerp(Color3.fromRGB(0, 255, 255), player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth)
    HUD.HealthBarFill.BorderSizePixel = 0
    HUD.HealthBarFill.Rotation = 0
    Instance.new('UICorner', HUD.HealthBarFill).CornerRadius = UDim.new(0, 10)
    game:GetService('TweenService'):Create(HUD.HealthBarFill, TweenInfo.new(0.2), {Size = UDim2.new(player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth, 0, 1, 0)}):Play()

    HUD.HealthLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.HealthLabel then break end
        task.wait(0.05)
    end
    if not HUD.HealthLabel then return end
    HUD.HealthLabel.Size = UDim2.new(0.85, 0, 0.2, 0)
    HUD.HealthLabel.Position = UDim2.new(0.075, 0, 0.7, 0)
    HUD.HealthLabel.Text = string.format('HP: %.1f%%', (player.Character.Humanoid.Health / player.Character.Humanoid.MaxHealth) * 100)
    HUD.HealthLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
    HUD.HealthLabel.BackgroundTransparency = 1
    HUD.HealthLabel.TextScaled = true
    HUD.HealthLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.HealthLabel.Font = HUD.Font

    HUD.DistanceLabel = Instance.new('TextLabel', HUD.Frame)
    for i = 1, 10 do
        if HUD.DistanceLabel then break end
        task.wait(0.05)
    end
    if not HUD.DistanceLabel then return end
    HUD.DistanceLabel.Size = UDim2.new(0.85, 0, 0.15, 0)
    HUD.DistanceLabel.Position = UDim2.new(0.075, 0, 0.85, 0)
    HUD.DistanceLabel.Text = string.format('Dist: %.1f', (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('HumanoidRootPart') and (LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude) or 0)
    HUD.DistanceLabel.TextColor3 = Color3.fromRGB(200, 255, 255)
    HUD.DistanceLabel.BackgroundTransparency = 1
    HUD.DistanceLabel.TextScaled = true
    HUD.DistanceLabel.TextXAlignment = Enum.TextXAlignment.Center
    HUD.DistanceLabel.Font = HUD.Font
end

function UpdateHUD(player)
    if not player then
        ClearHUD()
        return
    end
    if HUD.Style == 'Compact' then
        CreateCompactHUD(player)
    elseif HUD.Style == 'Modern' then
        CreateModernHUD(player)
    elseif HUD.Style == 'Minimal' then
        CreateMinimalHUD(player)
    elseif HUD.Style == 'Holographic' then
        CreateHolographicHUD(player)
    end
end

function GetTargetPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild('HumanoidRootPart') then return nil end

    HUD.IsFirstPerson = (Camera.CFrame.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude < 2
    HUD.MousePos = game:GetService('UserInputService'):GetMouseLocation()
    HUD.Ray = Camera:ScreenPointToRay(HUD.MousePos.X, HUD.MousePos.Y)
    HUD.RayOrigin = Camera.CFrame.Position
    HUD.RayDirection = HUD.Ray.Direction * 10000

    HUD.RaycastParams = RaycastParams.new()
    HUD.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    HUD.RaycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    HUD.RaycastParams.IgnoreWater = true
    HUD.RaycastResult = workspace:Raycast(HUD.RayOrigin, HUD.RayDirection, HUD.RaycastParams)

    if HUD.RaycastResult then
        HUD.HitPart = HUD.RaycastResult.Instance
        if HUD.HitPart and (HUD.HitPart.CanCollide or HUD.HitPart.Transparency < 0.5) then
            HUD.Character = HUD.HitPart:FindFirstAncestorOfClass('Model')
            if HUD.Character and HUD.Character:FindFirstChild('Humanoid') and HUD.Character:FindFirstChild('HumanoidRootPart') and HUD.Character.Humanoid.Health > 0 then
                HUD.Player = Players:GetPlayerFromCharacter(HUD.Character)
                if HUD.Player and HUD.Player ~= LocalPlayer then
                    HUD.RigType = HUD.Character.Humanoid.RigType
                    HUD.OnScreenRoot, _ = Camera:WorldToViewportPoint(HUD.Character.HumanoidRootPart.Position)
                    HUD.OnScreenHead = HUD.Character:FindFirstChild('Head') and select(1, Camera:WorldToViewportPoint(HUD.Character.Head.Position)) or false
                    if HUD.RigType == Enum.HumanoidRigType.R15 then
                        HUD.OnScreenUpperTorso = HUD.Character:FindFirstChild('UpperTorso') and select(1, Camera:WorldToViewportPoint(HUD.Character.UpperTorso.Position)) or false
                        HUD.OnScreenLowerTorso = HUD.Character:FindFirstChild('LowerTorso') and select(1, Camera:WorldToViewportPoint(HUD.Character.LowerTorso.Position)) or false
                        HUD.OnScreenTorso = false
                    else
                        HUD.OnScreenTorso = HUD.Character:FindFirstChild('Torso') and select(1, Camera:WorldToViewportPoint(HUD.Character.Torso.Position)) or false
                        HUD.OnScreenUpperTorso = false
                        HUD.OnScreenLowerTorso = false
                    end
                    HUD.BoundingBoxPoints = {
                        HUD.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0),
                        HUD.Character.HumanoidRootPart.Position + Vector3.new(0, -2, 0),
                        HUD.Character.HumanoidRootPart.Position + Vector3.new(1, 0, 0),
                        HUD.Character.HumanoidRootPart.Position + Vector3.new(-1, 0, 0)
                    }
                    HUD.OnScreen = false
                    for _, point in ipairs(HUD.BoundingBoxPoints) do
                        if select(1, Camera:WorldToViewportPoint(point)) then
                            HUD.OnScreen = true
                            break
                        end
                    end
                    if HUD.OnScreen or HUD.OnScreenRoot or HUD.OnScreenHead or HUD.OnScreenTorso or HUD.OnScreenUpperTorso or HUD.OnScreenLowerTorso then
                        return HUD.Player
                    end
                end
            end
        end
    end

    HUD.CameraCFrame = Camera.CFrame
    HUD.CameraPos = HUD.CameraCFrame.Position
    HUD.CameraForward = HUD.CameraCFrame.LookVector
    HUD.ClosestPlayer = nil
    HUD.MinDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer or not player.Character or not player.Character:FindFirstChild('HumanoidRootPart') or not player.Character:FindFirstChild('Humanoid') or player.Character.Humanoid.Health <= 0 then
            continue
        end

        HUD.TargetPos = player.Character.HumanoidRootPart.Position
        HUD.VectorToTarget = HUD.TargetPos - HUD.CameraPos
        HUD.Distance = HUD.VectorToTarget.Magnitude
        HUD.Angle = math.acos(HUD.VectorToTarget.Unit:Dot(HUD.CameraForward))

        if HUD.Angle <= HUD.FOVAngle then
            HUD.RigType = player.Character.Humanoid.RigType
            HUD.OnScreenRoot, _ = Camera:WorldToViewportPoint(HUD.TargetPos)
            HUD.OnScreenHead = player.Character:FindFirstChild('Head') and select(1, Camera:WorldToViewportPoint(player.Character.Head.Position)) or false
            if HUD.RigType == Enum.HumanoidRigType.R15 then
                HUD.OnScreenUpperTorso = player.Character:FindFirstChild('UpperTorso') and select(1, Camera:WorldToViewportPoint(player.Character.UpperTorso.Position)) or false
                HUD.OnScreenLowerTorso = player.Character:FindFirstChild('LowerTorso') and select(1, Camera:WorldToViewportPoint(player.Character.LowerTorso.Position)) or false
                HUD.OnScreenTorso = false
            else
                HUD.OnScreenTorso = player.Character:FindFirstChild('Torso') and select(1, Camera:WorldToViewportPoint(player.Character.Torso.Position)) or false
                HUD.OnScreenUpperTorso = false
                HUD.OnScreenLowerTorso = false
            end
            HUD.BoundingBoxPoints = {
                HUD.TargetPos + Vector3.new(0, 2, 0),
                HUD.TargetPos + Vector3.new(0, -2, 0),
                HUD.TargetPos + Vector3.new(1, 0, 0),
                HUD.TargetPos + Vector3.new(-1, 0, 0)
            }
            HUD.OnScreen = false
            for _, point in ipairs(HUD.BoundingBoxPoints) do
                if select(1, Camera:WorldToViewportPoint(point)) then
                    HUD.OnScreen = true
                    break
                end
            end
            if (HUD.OnScreen or HUD.OnScreenRoot or HUD.OnScreenHead or HUD.OnScreenTorso or HUD.OnScreenUpperTorso or HUD.OnScreenLowerTorso) and HUD.Distance < HUD.MinDistance then
                HUD.MinDistance = HUD.Distance
                HUD.ClosestPlayer = player
            end
        end
    end

    return HUD.ClosestPlayer
end

function UpdateViewmodel()
    if ViewmodelSettings.Enabled then
        HUD.ViewModel = Camera:FindFirstChild("ViewModel")
        if HUD.ViewModel then
            if HUD.ViewModel:FindFirstChild("Left Arm") then
                HUD.ViewModel["Left Arm"].Material = Enum.Material.ForceField
                HUD.ViewModel["Left Arm"].Color = ViewmodelSettings.Color
            end
            if HUD.ViewModel:FindFirstChild("Right Arm") then
                HUD.ViewModel["Right Arm"].Material = Enum.Material.ForceField
                HUD.ViewModel["Right Arm"].Color = ViewmodelSettings.Color
            end
        end
    else
        HUD.ViewModel = Camera:FindFirstChild("ViewModel")
        if HUD.ViewModel then
            if HUD.ViewModel:FindFirstChild("Left Arm") then
                HUD.ViewModel["Left Arm"].Material = Enum.Material.Plastic
            end
            if HUD.ViewModel:FindFirstChild("Right Arm") then
                HUD.ViewModel["Right Arm"].Material = Enum.Material.Plastic
            end
        end
    end
    game:GetService("Lighting").ClockTime = ViewmodelSettings.ClockTime
end

function EnableCrosshair()
    if next(CrosshairParts) == nil then
        HUD.CenterX = Camera.ViewportSize.X / 2
        HUD.CenterY = Camera.ViewportSize.Y / 2
        HUD.Horizontal = Drawing.new("Line")
        HUD.Horizontal.Visible = true
        HUD.Horizontal.Color = Options.CrosshairColor.Value
        HUD.Horizontal.Thickness = 2
        HUD.Horizontal.Transparency = 1
        HUD.Horizontal.From = Vector2.new(HUD.CenterX - 10, HUD.CenterY)
        HUD.Horizontal.To = Vector2.new(HUD.CenterX + 10, HUD.CenterY)
        CrosshairParts.Horizontal = HUD.Horizontal
        HUD.Vertical = Drawing.new("Line")
        HUD.Vertical.Visible = true
        HUD.Vertical.Color = Options.CrosshairColor.Value
        HUD.Vertical.Thickness = 2
        HUD.Vertical.Transparency = 1
        HUD.Vertical.From = Vector2.new(HUD.CenterX, HUD.CenterY - 10)
        HUD.Vertical.To = Vector2.new(HUD.CenterX, HUD.CenterY + 10)
        CrosshairParts.Vertical = HUD.Vertical
    end
end

function DisableCrosshair()
    for _, line in pairs(CrosshairParts) do
        line:Remove()
    end
    CrosshairParts = {}
end

function UpdateCrosshairColor(color)
    for _, line in pairs(CrosshairParts) do
        line.Color = color
    end
end

function PlayHeadshotSound()
    if HeadshotSettings.Enabled then
        HUD.Sound = Instance.new("Sound")
        HUD.Sound.SoundId = "rbxassetid://" .. HeadshotSettings.SoundId
        HUD.Sound.Volume = HeadshotSettings.Volume
        HUD.Sound.Parent = workspace
        HUD.Sound:Play()
        game:GetService("Debris"):AddItem(HUD.Sound, 2)
    end
end

function SetupHitmarkerForTool(tool)
    if HUD.HitmarkerConnection then
        HUD.HitmarkerConnection:Disconnect()
        HUD.HitmarkerConnection = nil
    end
    HUD.Hitmarker = tool:FindFirstChild("Hitmarker")
    if HUD.Hitmarker then
        HUD.HitmarkerConnection = HUD.Hitmarker.Event:Connect(function(hitPart)
            if hitPart and hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") then
                HUD.HitPlayer = Players:GetPlayerFromCharacter(hitPart.Parent)
                if HUD.HitPlayer and HUD.HitPlayer ~= LocalPlayer and hitPart.Name == "Head" then
                    PlayHeadshotSound()
                end
            end
        end)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid")
    HUD.Tool = character:FindFirstChildOfClass("Tool")
    if HUD.Tool then
        SetupHitmarkerForTool(HUD.Tool)
    end
    UpdateViewmodel()
end)

LocalPlayer.Character.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        SetupHitmarkerForTool(child)
    end
end)

LocalPlayer.Character.ChildRemoved:Connect(function(child)
    if child:IsA("Tool") and HUD.HitmarkerConnection then
        HUD.HitmarkerConnection:Disconnect()
        HUD.HitmarkerConnection = nil
    end
end)

game:GetService('RunService').RenderStepped:Connect(function()
    HUD.Player = LocalPlayer
    if HUD.Player.Character and HUD.Player.Character:FindFirstChild("Humanoid") and HUD.Player.Character.Humanoid.Health > 0 then
        UpdateViewmodel()
        Camera.FieldOfView = CustomFOV
    end
end)

local connection
function StartUpdateLoop()
    if connection then connection:Disconnect() end
    connection = game:GetService('RunService').Heartbeat:Connect(function()
        if not HUD.Enabled then
            ClearHUD()
            return
        end
        if tick() - HUD.LastUpdate < 0.2 then return end
        HUD.LastUpdate = tick()

        HUD.NewTarget = GetTargetPlayer()
        if HUD.NewTarget then
            HUD.Target = HUD.NewTarget
            UpdateHUD(HUD.Target)
        else
            HUD.Target = nil
            UpdateHUD(nil)
        end
    end)
end

VisualsLeft2:AddButton({
    Text = "FullBright",
    Func = function()
        game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
        game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
        game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
        if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
            game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy()
        end
        game:GetService("Lighting").LightingChanged:Connect(function()
            game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
            game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
            game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
        end)
        LocalPlayer.CharacterAdded:Connect(function(character)
            character:WaitForChild("HumanoidRootPart")
            game:GetService("Lighting").Ambient = Color3.new(1, 1, 1)
            game:GetService("Lighting").ColorShift_Bottom = Color3.new(1, 1, 1)
            game:GetService("Lighting").ColorShift_Top = Color3.new(1, 1, 1)
            if game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere") then
                game:GetService("Lighting"):FindFirstChildOfClass("Atmosphere"):Destroy()
            end
        end)
        game:GetService("Lighting").ChildAdded:Connect(function(child)
            if child:IsA("Atmosphere") then
                task.wait(0.1)
                child:Destroy()
            end
        end)
    end
})

VisualsLeft2:AddButton({
    Text = "Noclip Camera",
    Func = function()
        LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
    end
})

HUDToggle = VisualsLeft2:AddToggle('HUDToggle', {
    Text = 'Target HUD',
    Default = false,
    Callback = function(Value)
        HUD.Enabled = Value
        if Value then
            StartUpdateLoop()
        else
            ClearHUD()
            if connection then connection:Disconnect() end
        end
    end
})

HUDToggle:AddColorPicker('HUDColorPicker', {
    Default = Color3.fromRGB(255, 0, 0),
    Title = 'HUD Color',
    Transparency = 0,
    Callback = function(Value)
        HUD.Color = Value
        if HUD.Target then
            UpdateHUD(HUD.Target)
        end
    end
})

FakeVisorGUI = Instance.new('ScreenGui')
FakeVisorGUI.Name = "FakeVisorGUI"
FakeVisorGUI.Parent = game.Players.LocalPlayer.PlayerGui
FakeVisorGUI.IgnoreGuiInset = true
FakeVisorGUI.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
FakeVisorGUI.Enabled = false

VisorGrainImage = Instance.new('ImageLabel')
VisorGrainImage.Name = "VisorGrainImage"
VisorGrainImage.Parent = FakeVisorGUI
VisorGrainImage.Image = "rbxassetid://28756351"
VisorGrainImage.ImageTransparency = 0.8999999761581421
VisorGrainImage.ScaleType = Enum.ScaleType.Tile
VisorGrainImage.TileSize = UDim2.new(0.19699999690055847, 0, 0.17299999296665192, 0)
VisorGrainImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
VisorGrainImage.BackgroundTransparency = 1
VisorGrainImage.BorderSizePixel = 0
VisorGrainImage.Size = UDim2.new(1, 0, 1, 0)
VisorGrainImage.ZIndex = 10

FakeVisorOverlay = Instance.new('Frame')
FakeVisorOverlay.Name = "FakeVisorOverlay"
FakeVisorOverlay.Parent = FakeVisorGUI
FakeVisorOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
FakeVisorOverlay.BackgroundTransparency = 1
FakeVisorOverlay.BorderSizePixel = 0
FakeVisorOverlay.Size = UDim2.new(1, 0, 1, 0)

VisorBar = Instance.new('Frame')
VisorBar.Name = "VisorBar"
VisorBar.Parent = FakeVisorOverlay
VisorBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VisorBar.BackgroundTransparency = 0
VisorBar.BorderSizePixel = 0
VisorBar.Position = UDim2.new(0.7518296837806702, 0, 0, 0)
VisorBar.Size = UDim2.new(0.24817033112049103, 0, 1, 0)
VisorBar.ZIndex = 3

VisorBar2 = Instance.new('Frame')
VisorBar2.Name = "VisorBar2"
VisorBar2.Parent = FakeVisorOverlay
VisorBar2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
VisorBar2.BackgroundTransparency = 0
VisorBar2.BorderSizePixel = 0
VisorBar2.Position = UDim2.new(0, 0, 0, 0)
VisorBar2.Size = UDim2.new(0.24817033112049103, 0, 1, 0)
VisorBar2.ZIndex = 3

ColorCorrection = Instance.new('ColorCorrectionEffect')
ColorCorrection.Name = "FakeVisorGUI"
ColorCorrection.Parent = workspace.CurrentCamera
ColorCorrection.Brightness = 0
ColorCorrection.Contrast = -0.1
ColorCorrection.Saturation = -0.5
ColorCorrection.TintColor = Color3.fromRGB(120, 120, 120)
ColorCorrection.Enabled = false

function applyHighlightToPlayer(character)
    if character and character ~= game.Players.LocalPlayer.Character and character:FindFirstChild("HumanoidRootPart") then
        highlight = Instance.new("Highlight")
        highlight.Name = "FakeVisorHighlight"
        highlight.Parent = character
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0
        highlight.OutlineTransparency = 1
        highlight.Enabled = FakeVisorGUI.Enabled

        game:GetService("RunService").RenderStepped:Connect(function()
            if character and character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and FakeVisorGUI.Enabled then
                rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayResult = workspace:Raycast(
                    workspace.CurrentCamera.CFrame.Position,
                    (character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Unit * 2000,
                    rayParams
                )
                highlight.Enabled = rayResult and rayResult.Instance and rayResult.Instance:IsDescendantOf(character) and FakeVisorGUI.Enabled
            else
                highlight.Enabled = false
            end
        end)
    end
end

function applyHighlightToPlayers()
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= game.Players.LocalPlayer and player.Character then
            applyHighlightToPlayer(player.Character)
        end
    end
end

game.Players.PlayerAdded:Connect(function(player)
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            wait()
            applyHighlightToPlayer(character)
        end)
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    wait()
    applyHighlightToPlayers()
end)

applyHighlightToPlayers()

VisualsLeft2:AddToggle('FakeVisorToggle', {
    Text = 'FakeVisor+',
    Default = false,
    Callback = function(Value)
        FakeVisorGUI.Enabled = Value
        ColorCorrection.Enabled = Value
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer and player.Character then
                highlight = player.Character:FindFirstChild("FakeVisorHighlight")
                if highlight then
                    highlight.Enabled = Value
                end
            end
        end
    end
})

VisualsLeft2:AddToggle('RainToggle', {
    Text = "Rain",
    Default = false,
    Callback = function(v)
        _G.Rain = v
        p = game.Players.LocalPlayer
        w = workspace
        l = game:GetService("Lighting")
        id = "rbxassetid://8465072117"
        r, c = {}, nil

        if v then
            _G._RainOriginal = {
                Sky = l:FindFirstChildOfClass("Sky") and l:FindFirstChildOfClass("Sky"):Clone(),
                Effects = {},
                FogColor = l.FogColor,
                FogStart = l.FogStart,
                FogEnd = l.FogEnd,
                Brightness = l.Brightness,
                ClockTime = l.ClockTime,
                OutdoorAmbient = l.OutdoorAmbient
            }
            for _, obj in ipairs(l:GetChildren()) do
                if obj:IsA("Atmosphere") or obj:IsA("BloomEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") or obj:IsA("DepthOfFieldEffect") then
                    table.insert(_G._RainOriginal.Effects, obj:Clone())
                    obj:Destroy()
                end
            end
            for _, obj in ipairs(l:GetChildren()) do
                if obj:IsA("Sky") then
                    obj:Destroy()
                end
            end

            sky = Instance.new("Sky", l)
            sky.Name = "RainSky"
            sky.SkyboxBk = "http://www.roblox.com/asset/?id=63935588"
            sky.SkyboxDn = "http://www.roblox.com/asset/?id=63926807"
            sky.SkyboxFt = "http://www.roblox.com/asset/?id=63935604"
            sky.SkyboxLf = "http://www.roblox.com/asset/?id=63935617"
            sky.SkyboxRt = "http://www.roblox.com/asset/?id=63935471"
            sky.SkyboxUp = "http://www.roblox.com/asset/?id=63935261"
            sky.MoonTextureId = "rbxasset://sky/moon.jpg"
            sky.SunTextureId = "rbxasset://sky/sun.jpg"
            sky.StarCount = 0
            sky.SunAngularSize = 21

            l.FogColor = Color3.new(0.05, 0.05, 0.05)
            l.FogStart = 0
            l.FogEnd = 100
            l.Brightness = 0
            l.OutdoorAmbient = Color3.new(0, 0, 0)
            l.ClockTime = 0

            rain = Instance.new("Sound", w)
            rain.SoundId = "rbxassetid://9066016561"
            rain.Name = "RainLoop"
            rain.Volume = 0.8
            rain.Looped = true
            rain:Play()

            thunder = Instance.new("Sound", w)
            thunder.SoundId = "rbxassetid://4961240438"
            thunder.Name = "Thunder"
            thunder.Looped = false

            task.spawn(function()
                while _G.Rain do
                    task.wait(math.random(20, 50))
                    if not _G.Rain then break end
                    thunder.Volume = math.random(50, 100) / 100
                    thunder:Play()
                end
            end)

            for i = 1, 30 do
                m = game:GetObjects(id)[1]
                if m then
                    for _, v2 in ipairs(m:GetDescendants()) do
                        if v2:IsA("ParticleEmitter") then
                            v2.Rate = v2.Rate / 4
                        end
                        if v2:IsA("BasePart") and not m.PrimaryPart then
                            m.PrimaryPart = v2
                        end
                    end
                    m.Parent = w
                    table.insert(r, m)
                end
            end

            c = game:GetService("RunService").Heartbeat:Connect(function()
                char = p.Character
                if not char then return end
                hrp = char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                base = hrp.Position - Vector3.new(0, 3, 0)
                dir = workspace.CurrentCamera.CFrame.LookVector
                for _, e in ipairs(r) do
                    angle = math.random() * math.pi * 2
                    dist = math.random(5, 2500) / 100
                    x = math.cos(angle) * dist
                    z = math.sin(angle) * dist
                    offset = Vector3.new(x, 0, z)
                    pnt = base + offset
                    proj = offset.Unit:Dot(dir) * offset.Magnitude
                    if offset.Magnitude < 3 then
                        pnt = pnt + dir * (3 - proj)
                    end
                    if e.PrimaryPart then
                        e:SetPrimaryPartCFrame(CFrame.new(pnt))
                    end
                end
            end)
        else
            for _, v2 in ipairs(w:GetChildren()) do
                if v2:IsA("Model") and v2:FindFirstChildWhichIsA("ParticleEmitter", true) then
                    v2:Destroy()
                end
                if v2:IsA("Sound") and (v2.Name == "RainLoop" or v2.Name == "Thunder") then
                    v2:Destroy()
                end
            end
            for _, s2 in ipairs(l:GetChildren()) do
                if s2:IsA("Sky") and s2.Name == "RainSky" then
                    s2:Destroy()
                end
            end

            if _G._RainOriginal then
                l.FogColor = _G._RainOriginal.FogColor
                l.FogStart = _G._RainOriginal.FogStart
                l.FogEnd = _G._RainOriginal.FogEnd
                l.Brightness = _G._RainOriginal.Brightness
                l.ClockTime = _G._RainOriginal.ClockTime
                l.OutdoorAmbient = _G._RainOriginal.OutdoorAmbient
                for _, e2 in ipairs(l:GetChildren()) do
                    if e2:IsA("Atmosphere") or e2:IsA("BloomEffect") or e2:IsA("ColorCorrectionEffect") or e2:IsA("SunRaysEffect") or e2:IsA("DepthOfFieldEffect") then
                        e2:Destroy()
                    end
                end
                for _, e2 in ipairs(_G._RainOriginal.Effects or {}) do
                    e2:Clone().Parent = l
                end
                if _G._RainOriginal.Sky then
                    _G._RainOriginal.Sky:Clone().Parent = l
                end
                _G._RainOriginal = nil
            end

            if c then c:Disconnect() end
        end
    end
})

freecamEnabled = false
freecamSpeed = 50
cam = workspace.CurrentCamera
UIS = game:GetService("UserInputService")
RS = game:GetService("RunService")
onMobile = not UIS.KeyboardEnabled
keysDown = {}
rotating = false

freecamToggle = VisualsLeft2:AddToggle("FreecamToggle", {
    Text = "Freecam",
    Default = false,
    Callback = function(value)
        freecamEnabled = value
        if value then
            cam.CameraType = Enum.CameraType.Scriptable
            if game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
            end
        else
            RS:UnbindFromRenderStep("Freecam")
            cam.CameraType = Enum.CameraType.Custom
            if game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
    end,
}):AddKeyPicker("FreecamKey", {
    Default = "None", 
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Freecam",
    Callback = function() end,
})

blur = Instance.new("BlurEffect", game:GetService("Lighting"))
blur.Size = 0

VisualsLeft2:AddToggle('BlurToggle', {
    Text = 'Blur',
    Default = false,
    Callback = function(value)
        if value then
            HUD.BlurConnection = game:GetService('RunService').RenderStepped:Connect(function()
                HUD.Cam = Camera
                HUD.CurrentLookVector = HUD.Cam.CFrame.LookVector
                HUD.RotationSpeed = (HUD.CurrentLookVector - (HUD.LastLookVector or HUD.CurrentLookVector)).Magnitude * 130
                blur.Size = math.clamp(HUD.RotationSpeed, 0, 20)
                HUD.LastLookVector = HUD.CurrentLookVector
            end)
        else
            if HUD.BlurConnection then
                HUD.BlurConnection:Disconnect()
                HUD.BlurConnection = nil
            end
            blur.Size = 0
        end
    end
})

Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
Humanoid = Character:WaitForChild("Humanoid")
IsEnabled = false
SelectedEffect = "Explosion"
JumpConnection = nil

function createExplosion(position)
    local explosion = Instance.new("Explosion")
    explosion.Position = position
    explosion.BlastRadius = 10
    explosion.BlastPressure = 50
    explosion.DestroyJointRadiusPercent = 0
    explosion.Parent = game.Workspace
end

function createParticleEffect(position)
    local particleEmitter = Instance.new("ParticleEmitter")
    particleEmitter.Texture = "rbxassetid://243728913"
    particleEmitter.Size = NumberSequence.new(1, 0)
    particleEmitter.Transparency = NumberSequence.new(0, 1)
    particleEmitter.Lifetime = NumberRange.new(0.5, 1)
    particleEmitter.Rate = 100
    particleEmitter.Speed = NumberRange.new(10)
    local part = Instance.new("Part")
    particleEmitter.Parent = part
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = game.Workspace
    wait(1)
    if part.Parent then
        part:Destroy()
    end
end

function createShockwave(position)
    local part = Instance.new("Part")
    part.Position = position
    part.Size = Vector3.new(0.5, 0.5, 0.5)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.4
    part.BrickColor = BrickColor.new("Cyan")
    part.Material = Enum.Material.Neon
    part.Parent = game.Workspace
    for i = 1, 30 do
        part.Size = part.Size + Vector3.new(0.5, 0.1, 0.5)
        part.Transparency = part.Transparency + 0.02
        wait(0.02)
    end
    if part.Parent then
        part:Destroy()
    end
end

function createFireBurst(position)
    local fire = Instance.new("Fire")
    fire.Size = 8
    fire.Heat = 15
    local part = Instance.new("Part")
    fire.Parent = part
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = game.Workspace
    wait(0.6)
    for i = 1, 5 do
        fire.Size = fire.Size - 1.6
        fire.Heat = fire.Heat - 3
        wait(0.02)
    end
    if part.Parent then
        part:Destroy()
    end
end

function createMeteorTrail(position)
    local part = Instance.new("Part")
    part.Position = position + Vector3.new(0, 5, 0)
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = false
    part.CanCollide = false
    part.BrickColor = BrickColor.new("Really red")
    part.Material = Enum.Material.Neon
    part.Parent = game.Workspace
    local fire = Instance.new("Fire")
    fire.Size = 5
    fire.Parent = part
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, 0, math.huge)
    bv.Velocity = Vector3.new(math.random(-10, 10), 0, math.random(-10, 10))
    bv.Parent = part
    wait(0.8)
    if part.Parent then
        part:Destroy()
    end
end

function createGravityPulse(position)
    local part = Instance.new("Part")
    part.Position = position
    part.Size = Vector3.new(4, 4, 4)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.5
    part.BrickColor = BrickColor.new("Deep blue")
    part.Material = Enum.Material.Neon
    part.Parent = game.Workspace
    for i = 1, 15 do
        part.Size = part.Size - Vector3.new(0.2, 0.2, 0.2)
        part.Transparency = part.Transparency + 0.03
        wait(0.03)
    end
    if part.Parent then
        part:Destroy()
    end
end

function onJump()
    if not IsEnabled then return end
    rootPart = Character:FindFirstChild("HumanoidRootPart")
    if rootPart then
        position = rootPart.Position - Vector3.new(0, 3, 0)
        if SelectedEffect == "Explosion" then
            createExplosion(position)
            createParticleEffect(position)
        elseif SelectedEffect == "Shockwave" then
            createShockwave(position)
        elseif SelectedEffect == "FireBurst" then
            createFireBurst(position)
        elseif SelectedEffect == "MeteorTrail" then
            createMeteorTrail(position)
        elseif SelectedEffect == "GravityPulse" then
            createGravityPulse(position)
        end
    end
end

function setupJumpConnection()
    if JumpConnection then
        JumpConnection:Disconnect()
    end
    JumpConnection = Humanoid.StateChanged:Connect(function(oldState, newState)
        if newState == Enum.HumanoidStateType.Jumping then
            onJump()
        end
    end)
end

setupJumpConnection()

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    setupJumpConnection()
end)

VisualsLeft2:AddToggle('JumpEffectToggle', {
    Text = 'JumpCircle',
    Default = false,
    Callback = function(Value)
        IsEnabled = Value
    end
})

player = game.Players.LocalPlayer
TESPcolor = Color3.fromRGB(255, 255, 255)
rotation = 0
outerRadius = 70
outerSize = 24
innerRadius = 30
cubeSize = 30
outerArrows = {}
for i = 1, 3 do
    outerArrows[i] = {}
    for j = 1, 3 do
        line = Drawing.new("Line")
        line.Color = TESPcolor
        line.Thickness = j == 1 and 2 or (j == 2 and 4 or 6)
        line.Transparency = j == 1 and 1 or (j == 2 and 0.3 or 0.1)
        line.Visible = false
        outerArrows[i][j] = line
    end
end

centerTriangle = {}
for i = 1, 3 do
    line = Drawing.new("Line")
    line.Color = TESPcolor
    line.Thickness = 2
    line.Transparency = 0.9
    line.Visible = false
    centerTriangle[i] = line
end

cubeLines = {}
for i = 1, 8 do
    line = Drawing.new("Line")
    line.Color = TESPcolor
    line.Thickness = 2
    line.Transparency = 1
    line.Visible = false
    cubeLines[i] = line
end

VisualsLeft2:AddToggle('TESPEnabled', {
    Text = 'Target ESP',
    Default = false,
    Callback = function(Value)
        isEnabled = Value
    end
}):AddColorPicker('TESPESPColor', {
    Default = Color3.fromRGB(255, 255, 255),
    Title = 'ESP Color',
    Callback = function(Value)
        TESPcolor = Value
        for _, group in ipairs(outerArrows) do
            for _, line in ipairs(group) do
                line.Color = TESPcolor
            end
        end
        for _, line in ipairs(centerTriangle) do
            line.Color = TESPcolor
        end
        for _, line in ipairs(cubeLines) do
            line.Color = TESPcolor
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function(dt)
    if not isEnabled then
        for _, group in ipairs(outerArrows) do
            for _, line in ipairs(group) do line.Visible = false end
        end
        for _, line in ipairs(centerTriangle) do line.Visible = false end
        for _, line in ipairs(cubeLines) do line.Visible = false end
        return
    end
    if player:GetMouse().Target then
        targetChar = player:GetMouse().Target:FindFirstAncestorOfClass("Model")
        if targetChar and game.Players:GetPlayerFromCharacter(targetChar) and targetChar:FindFirstChild("HumanoidRootPart") then
            screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(targetChar.HumanoidRootPart.Position)
            if onScreen then
                center = Vector2.new(screenPos.X, screenPos.Y)
                rotation = (rotation + 25 * dt) % 360
                if mode == "Spinning" then
                    for i, base in ipairs({0, 120, 240}) do
                        angle = base + rotation
                        fromPoint = center + Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle))) * outerRadius
                        toPoint = center + Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle))) * (outerRadius + outerSize)
                        for _, line in ipairs(outerArrows[i]) do
                            line.From = fromPoint
                            line.To = toPoint
                            line.Visible = true
                        end
                    end
                else
                    for _, group in ipairs(outerArrows) do
                        for _, line in ipairs(group) do line.Visible = false end
                    end
                end
                if mode == "Triangle" then
                    points = {}
                    for i = 1, 3 do
                        table.insert(points, center + Vector2.new(math.cos(math.rad(120 * (i - 1) + rotation)), math.sin(math.rad(120 * (i - 1) + rotation))) * innerRadius)
                    end
                    for i = 1, 3 do
                        centerTriangle[i].From = points[i]
                        centerTriangle[i].To = points[(i % 3) + 1]
                        centerTriangle[i].Visible = true
                    end
                else
                    for _, line in ipairs(centerTriangle) do line.Visible = false end
                end
                if mode == "Cube" then
                    t = tick()
                    cos = math.cos(t)
                    sin = math.sin(t)
                    topLeft = Vector2.new(-cubeSize * cos + cubeSize * sin, -cubeSize * sin - cubeSize * cos)
                    topRight = Vector2.new(cubeSize * cos + cubeSize * sin, cubeSize * sin - cubeSize * cos)
                    bottomLeft = Vector2.new(-cubeSize * cos - cubeSize * sin, -cubeSize * sin + cubeSize * cos)
                    bottomRight = Vector2.new(cubeSize * cos - cubeSize * sin, cubeSize * sin + cubeSize * cos)
                    cubeLines[1].From = center + topLeft
                    cubeLines[1].To = center + topLeft + Vector2.new(12 * cos, 12 * sin)
                    cubeLines[2].From = center + topLeft
                    cubeLines[2].To = center + topLeft + Vector2.new(-12 * sin, 12 * cos)
                    cubeLines[3].From = center + topRight
                    cubeLines[3].To = center + topRight + Vector2.new(-12 * cos, -12 * sin)
                    cubeLines[4].From = center + topRight
                    cubeLines[4].To = center + topRight + Vector2.new(12 * sin, 12 * cos)
                    cubeLines[5].From = center + bottomLeft
                    cubeLines[5].To = center + bottomLeft + Vector2.new(12 * cos, 12 * sin)
                    cubeLines[6].From = center + bottomLeft
                    cubeLines[6].To = center + bottomLeft + Vector2.new(12 * sin, -12 * cos)
                    cubeLines[7].From = center + bottomRight
                    cubeLines[7].To = center + bottomRight + Vector2.new(-12 * cos, -12 * sin)
                    cubeLines[8].From = center + bottomRight
                    cubeLines[8].To = center + bottomRight + Vector2.new(-12 * sin, -12 * cos)
                    for i = 1, 8 do cubeLines[i].Visible = true end
                else
                    for i = 1, 8 do cubeLines[i].Visible = false end
                end
                return
            end
        end
    end
    for _, group in ipairs(outerArrows) do
        for _, line in ipairs(group) do line.Visible = false end
    end
    for _, line in ipairs(centerTriangle) do line.Visible = false end
    for _, line in ipairs(cubeLines) do line.Visible = false end
end)

Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer

painSounds = {6371760398, 7634551011, 8011814794}
deathSounds = {5256796890, 1080611063, 17852350709, 9114029940, 6108565657, 110421821366022, 100394179871193, 95511297090996, 130783010708902, 79504119354128, 132911636910381, 138744152664023, 347611423}
burnSounds = {8749386406, 92640324390687, 95229831690196, 122851157735773, 89815929082235}
coughSounds = {75109796923105, 6333150436, 1489929212, 6333150725}
infectionMusicTracks = {4881487887, 8713437441, 111367072132776, 1846266716}
infectionSoundIds = {8156308296, 122416246102880}
survivorEndFrameSoundId = 128753342462400

soundIndexes = {pain=1, death=1, burn=1, cough=1, infectionMusic=1, infectionSound=1}
painCooldown = 2
burnCooldown = 6
coughCooldown = 6
lastPain = 0
lastBurn = 0
lastCough = 0
lastEndFrameTrigger = 0
endFrameCooldown = 2
isDead = false
infectionTeamName = "Infected"
survivorTeamName = "Survivors"
suppressPainNames = {BurningScript=true, MCoughScript=true, RageScript=true, RUNNING_POISON_HANDLER=true}

function getNextSoundId(key, list)
    i = soundIndexes[key]
    if i > #list then i = 1 end
    soundIndexes[key] = i + 1
    return list[i]
end

function playSound(soundId, parent, volume)
    if not SoundScriptEnabled then return end
    s = Instance.new("Sound")
    s.SoundId = "rbxassetid://" .. tostring(soundId)
    s.Volume = volume or 1
    s.Parent = parent
    s:Play()
    s.Ended:Connect(function() s:Destroy() end)
end

function anyPlayerInTeam(teamName)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Team and p.Team.Name == teamName then return true end
    end
    return false
end

function allPlayersInInfectedTeam()
    for _, p in pairs(Players:GetPlayers()) do
        if not p.Team or p.Team.Name ~= infectionTeamName then return false end
    end
    return true
end

function tryPlayEndFrameSound(gui)
    if not SoundScriptEnabled then return end
    if tick() - lastEndFrameTrigger < endFrameCooldown then return end
    if LocalPlayer.Team then
        if LocalPlayer.Team.Name == infectionTeamName and anyPlayerInTeam(survivorTeamName) then
            playSound(getNextSoundId("infectionMusic", infectionMusicTracks), gui, 1)
        elseif LocalPlayer.Team.Name == infectionTeamName and allPlayersInInfectedTeam() then
            playSound(getNextSoundId("infectionSound", infectionSoundIds), gui, 3)
        elseif LocalPlayer.Team.Name == survivorTeamName then
            playSound(survivorEndFrameSoundId, gui, 2)
        end
    end
    lastEndFrameTrigger = tick()
end

function hasSuppression(character)
    for name in pairs(suppressPainNames) do
        if character:FindFirstChild(name) then return true end
    end
    return false
end

function onCharacter(character)
    if not SoundScriptEnabled then return end
    humanoid = character:WaitForChild("Humanoid")
    head = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")
    if not head then return end

    lastHealth = humanoid.Health
    isDead = false

    humanoid.HealthChanged:Connect(function(hp)
        if not SoundScriptEnabled or isDead or hp <= 0 then return end
        if hp < lastHealth and not hasSuppression(character) and tick() - lastPain >= painCooldown then
            playSound(getNextSoundId("pain", painSounds), head, 1)
            lastPain = tick()
        end
        lastHealth = hp
    end)

    humanoid.Died:Connect(function()
        if not SoundScriptEnabled or isDead then return end
        isDead = true
        playSound(getNextSoundId("death", deathSounds), head, 1)
    end)

    character.ChildAdded:Connect(function(child)
        if not SoundScriptEnabled or not child:IsA("Script") then return end
        if child.Name == "BurningScript" and tick() - lastBurn >= burnCooldown then
            playSound(getNextSoundId("burn", burnSounds), head, 1)
            lastBurn = tick()
        elseif child.Name == "MCoughScript" and tick() - lastCough >= coughCooldown then
            playSound(getNextSoundId("cough", coughSounds), head, 1)
            lastCough = tick()
        end
    end)
end

function watchGUI()
    task.spawn(function()
        gui = nil
        repeat
            ok, res = pcall(function()
                return LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("InfectionGUI")
            end)
            if ok then gui = res end
            task.wait(0.2)
        until gui

        gui.ChildAdded:Connect(function(child)
            if not SoundScriptEnabled or not child:IsA("Frame") or child.Name ~= "EndFrame" then return end
            tryPlayEndFrameSound(gui)
        end)

        existing = gui:FindFirstChild("EndFrame")
        if existing and SoundScriptEnabled then tryPlayEndFrameSound(gui) end
    end)
end

SoundScriptEnabled = false

if LocalPlayer.Character then onCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacter)
watchGUI()

VisualsLeft2:AddToggle('SoundScriptEnabled', {
    Text = "Sounds Effects",
    Default = false,
    Callback = function(Value)
        SoundScriptEnabled = Value
        if Value and LocalPlayer.Character then
            onCharacter(LocalPlayer.Character)
        elseif not Value then
            isDead = false
            lastPain = 0
            lastBurn = 0
            lastCough = 0
            lastEndFrameTrigger = 0
            soundIndexes = {pain=1, death=1, burn=1, cough=1, infectionMusic=1, infectionSound=1}
        end
    end
})

Players = game:GetService("Players")
UserInputService = game:GetService("UserInputService")
RunService = game:GetService("RunService")

player = Players.LocalPlayer
guiName = "CandleGUI"
_G.BaseOffset = _G.BaseOffset or nil
_G.CandleEnabled = false

function CreateCandle()
	playerGui = player:WaitForChild("PlayerGui")
	existing = playerGui:FindFirstChild(guiName)
	if existing then
		return
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = guiName
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	candle = Instance.new("ImageLabel")
	candle.Name = "Candle"
	candle.Parent = screenGui
	candle.Size = UDim2.new(0, 128, 0, 128)
	startPos = UDim2.new(0.5, -64, 0.5, -150)
	candle.BackgroundTransparency = 1
	candle.Image = "rbxassetid://16100003106"
	candle.ScaleType = Enum.ScaleType.Fit
	candle.Active = true

	camera = workspace.CurrentCamera
	viewport = camera and camera.ViewportSize or Vector2.new(0, 0)
	baseOffset = _G.BaseOffset or Vector2.new(viewport.X / 2 + startPos.X.Offset, viewport.Y / 2 + startPos.Y.Offset)
	_G.BaseOffset = baseOffset

	if not screenGui:FindFirstChild("CandleSound") then
		sound = Instance.new("Sound")
		sound.Name = "CandleSound"
		sound.SoundId = "rbxassetid://1837428718"
		sound.Volume = 1
		sound.Looped = true
		sound.Parent = screenGui
		sound:Play()
	end

	dragging = false
	dragOffset = Vector2.new()

	candle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = UserInputService:GetMouseLocation()
			absPos = candle.AbsolutePosition
			dragOffset = Vector2.new(mousePos.X - absPos.X, mousePos.Y - absPos.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)

	startTime = tick()
	RunService.RenderStepped:Connect(function()
		if not candle or not candle.Parent then return end
		t = tick() - startTime
		offsetY = math.sin(t * 2) * 5
		offsetRot = math.sin(t * 1.5) * 2

		if dragging then
			mousePos = UserInputService:GetMouseLocation()
			newX = mousePos.X - dragOffset.X
			newY = mousePos.Y - dragOffset.Y
			baseOffset = Vector2.new(newX, newY)
			_G.BaseOffset = baseOffset
		end

		finalY = baseOffset.Y + offsetY
		candle.Position = UDim2.new(0, baseOffset.X, 0, finalY)
		candle.Rotation = offsetRot
	end)
end

function RemoveCandle()
	gui = player:FindFirstChild("PlayerGui"):FindFirstChild(guiName)
	if gui then
		gui:Destroy()
	end
end

function AutoRespawnCandle()
	player.CharacterAdded:Connect(function()
		task.wait(1)
		if _G.CandleEnabled then
			CreateCandle()
		end
	end)
end

AutoRespawnCandle()

VisualsLeft2:AddToggle('CandleToggle', {
	Text = 'Candle',
	Default = false,
	Callback = function(value)
		_G.CandleEnabled = value
		if value then
			CreateCandle()
		else
			RemoveCandle()
		end
	end
})

VisualsLeft2:AddToggle('ViewmodelEnabled', {
    Text = "ForceField Viewmodel",
    Default = false,
    Callback = function(Value)
        ViewmodelSettings.Enabled = Value
        UpdateViewmodel()
    end
})

Trail = VisualsLeft2:AddToggle('TrailToggle', {
    Text = 'Trail',
    Default = false,
    Callback = function(Value)
        TrailEnabled = Value
        if not Value then
            if Trail and typeof(Trail) == "Instance" then Trail:Destroy() end
            if Attach0 then Attach0:Destroy() end
            if Attach1 then Attach1:Destroy() end
            Attach0 = nil
            Attach1 = nil
            Trail = nil
        end
    end
})

Trail:AddColorPicker('TrailColorPicker', {
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        TrailColor = Value
        if Trail and typeof(Trail) == "Instance" then
            Trail.Color = ColorSequence.new(Value)
        end
    end
})

CrosshairToggle = VisualsLeft2:AddToggle('CrosshairEnabled', {
    Text = 'Custom Crosshair',
    Default = false,
    Tooltip = 'Shows custom crosshair',
    Callback = function(Value)
        if Value then EnableCrosshair() else DisableCrosshair() end
    end
})

CrosshairToggle:AddColorPicker('CrosshairColor', {
    Default = Color3.fromRGB(0, 255, 0),
    Title = 'Crosshair Color',
    Transparency = 0,
    Callback = UpdateCrosshairColor
})

VisualsLeft2:AddToggle('HeadshotEnabled', {
    Text = 'Headshot Sound',
    Default = false,
    Tooltip = 'Plays sound on headshot',
    Callback = function(Value)
        HeadshotSettings.Enabled = Value
    end
})

VisualsLeft2:AddDropdown('HeadshotType', {
    Values = {"Boink", "TF2", "Rust", "CSGO", "Hitmarker", "Fortnite"},
    Default = "TF2",
    Multi = false,
    Text = 'Headshot Type',
    Tooltip = 'Select headshot sound type',
    Callback = function(Value)
        HeadshotSettings.SoundId = HitmarkerSounds[Value]
    end
})

VisualsLeft2:AddDropdown('HUDStyleDropdown', {
    Values = {'Compact', 'Modern', 'Minimal', 'Holographic'},
    Default = 1,
    Multi = false,
    Text = 'HUD Style',
    Callback = function(Value)
        HUD.Style = Value
        if HUD.Target then
            UpdateHUD(HUD.Target)
        end
    end
})

VisualsLeft2:AddDropdown('HUDFontDropdown', {
    Values = {'Arial', 'Bangers', 'Gotham'},
    Default = 3,
    Multi = false,
    Text = 'HUD Font',
    Callback = function(Value)
        HUD.Font = Enum.Font[Value]
        if HUD.Target then
            UpdateHUD(HUD.Target)
        end
    end
})

VisualsLeft2:AddDropdown('TESPmode', {
    Values = {'Cube', 'Triangle', 'Spinning'},
    Default = 1,
    Multi = false,
    Text = 'ESP Mode',
    Callback = function(Value)
        mode = Value
    end
})

VisualsLeft2:AddDropdown('EffectDropdown', {
    Values = { 'Explosion', 'Shockwave', 'FireBurst', 'MeteorTrail', 'GravityPulse' },
    Default = 1,
    Multi = false,
    Text = 'Select Effect JumpCircle',
    Callback = function(Value)
        SelectedEffect = Value
    end
})

VisualsLeft2:AddSlider('HeadshotVolume', {
    Text = 'Headshot Volume',
    Default = HeadshotSettings.Volume,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        HeadshotSettings.Volume = Value
    end
})

VisualsLeft2:AddSlider("SpeedSlider", {
    Text = "Freecam Speed",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Callback = function(value)
        freecamSpeed = value
    end
})

RS.RenderStepped:Connect(function()
    if not freecamEnabled or not game.Players.LocalPlayer.Character or not game.Players.LocalPlayer.Character.Humanoid or game.Players.LocalPlayer.Character.Humanoid.Health <= 0 then 
        if freecamEnabled then
            freecamEnabled = false
            freecamToggle:SetValue(false)
            cam.CameraType = Enum.CameraType.Custom
            if game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = false
            end
        end
        return 
    end
    if rotating then
        delta = UIS:GetMouseDelta()
        cf = cam.CFrame
        yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
        newAmount = math.deg(yAngle)+delta.Y
        if newAmount > 65 or newAmount < -65 then
            if not (yAngle<0 and delta.Y<0) and not (yAngle>0 and delta.Y>0) then
                delta = Vector2.new(delta.X,0)
            end 
        end
        cf *= CFrame.Angles(-math.rad(delta.Y),0,0)
        cf = CFrame.Angles(0,-math.rad(delta.X),0) * (cf - cf.Position) + cf.Position
        cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)
        if delta ~= Vector2.new(0,0) then cam.CFrame = cam.CFrame:Lerp(cf,freecamSpeed/1000) end
        UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
    else
        UIS.MouseBehavior = Enum.MouseBehavior.Default
    end
    if keysDown["Enum.KeyCode.W"] then
        cam.CFrame *= CFrame.new(Vector3.new(0,0,-freecamSpeed/100))
    end
    if keysDown["Enum.KeyCode.A"] then
        cam.CFrame *= CFrame.new(Vector3.new(-freecamSpeed/100,0,0))
    end
    if keysDown["Enum.KeyCode.S"] then
        cam.CFrame *= CFrame.new(Vector3.new(0,0,freecamSpeed/100))
    end
    if keysDown["Enum.KeyCode.D"] then
        cam.CFrame *= CFrame.new(Vector3.new(freecamSpeed/100,0,0))
    end
end)

validKeys = {"Enum.KeyCode.W","Enum.KeyCode.A","Enum.KeyCode.S","Enum.KeyCode.D"}

UIS.InputBegan:Connect(function(Input)
    for i, key in pairs(validKeys) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = true
        end
    end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X>(cam.ViewportSize.X/2)) then
        rotating = true
    end
    if Input.UserInputType == Enum.UserInputType.Touch then
        if Input.Position.X < cam.ViewportSize.X/2 then
            touchPos = Input.Position
        end
    end
end)

UIS.InputEnded:Connect(function(Input)
    for key, v in pairs(keysDown) do
        if key == tostring(Input.KeyCode) then
            keysDown[key] = false
        end
    end
    if Input.UserInputType == Enum.UserInputType.MouseButton2 or (Input.UserInputType == Enum.UserInputType.Touch and UIS:GetMouseLocation().X>(cam.ViewportSize.X/2)) then
        rotating = false
    end
    if Input.UserInputType == Enum.UserInputType.Touch and touchPos then
        if Input.Position.X < cam.ViewportSize.X/2 then
            touchPos = nil
            keysDown["Enum.KeyCode.W"] = false
            keysDown["Enum.KeyCode.A"] = false
            keysDown["Enum.KeyCode.S"] = false
            keysDown["Enum.KeyCode.D"] = false
        end
    end
end)

UIS.TouchMoved:Connect(function(input)
    if touchPos then
        if input.Position.X < cam.ViewportSize.X/2 then
            if input.Position.Y < touchPos.Y then
                keysDown["Enum.KeyCode.W"] = true
                keysDown["Enum.KeyCode.S"] = false
            else
                keysDown["Enum.KeyCode.W"] = false
                keysDown["Enum.KeyCode.S"] = true
            end
            if input.Position.X < (touchPos.X-15) then
                keysDown["Enum.KeyCode.A"] = true
                keysDown["Enum.KeyCode.D"] = false
            elseif input.Position.X > (touchPos.X+15) then
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = true
            else
                keysDown["Enum.KeyCode.A"] = false
                keysDown["Enum.KeyCode.D"] = false
            end
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if freecamEnabled and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character.HumanoidRootPart.Anchored = true
    end
end)

VisualsLeft2:AddSlider('CameraDistanceSlider', {
    Text = "Camera Distance",
    Default = LocalPlayer.CameraMaxZoomDistance,
    Min = 100,
    Max = 1000,
    Rounding = 0,
    Callback = function(Value)
        LocalPlayer.CameraMaxZoomDistance = Value
    end
})

VisualsLeft2:AddSlider('GameTime', {
    Text = "ClockTime",
    Default = 12,
    Min = 0,
    Max = 24,
    Rounding = 1,
    Callback = function(Value)
        ViewmodelSettings.ClockTime = Value
        UpdateViewmodel()
    end
})

VisualsLeft2:AddSlider('FOVSlider', {
    Text = "Field of View",
    Default = Camera.FieldOfView,
    Min = 30,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        CustomFOV = Value
        Camera.FieldOfView = Value
    end
})

player = game.Players.LocalPlayer

VisualsLeft2:AddSlider('RightArmLength', {
    Text = 'Right Arm Length',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        local viewModel = workspace.Camera:FindFirstChild("ViewModel")
        if viewModel and viewModel:FindFirstChild("Right Arm") then
            viewModel["Right Arm"].Size = Vector3.new(1, Value, 1)
        end
    end
})

VisualsLeft2:AddSlider('LeftArmLength', {
    Text = 'Left Arm Length',
    Default = 2,
    Min = 0,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        local viewModel = workspace.Camera:FindFirstChild("ViewModel")
        if viewModel and viewModel:FindFirstChild("Left Arm") then
            viewModel["Left Arm"].Size = Vector3.new(1, Value, 1)
        end
    end
})

player.CharacterAdded:Connect(function(char)
    local viewModel = workspace.Camera:WaitForChild("ViewModel", 5)
    if viewModel then
        if viewModel:FindFirstChild("Right Arm") then
            viewModel["Right Arm"].Size = Vector3.new(1, Options.RightArmLength.Value, 1)
        else
            viewModel:WaitForChild("Right Arm", 5)
            if viewModel:FindFirstChild("Right Arm") then
                viewModel["Right Arm"].Size = Vector3.new(1, Options.RightArmLength.Value, 1)
            end
        end
        if viewModel:FindFirstChild("Left Arm") then
            viewModel["Left Arm"].Size = Vector3.new(1, Options.LeftArmLength.Value, 1)
        else
            viewModel:WaitForChild("Left Arm", 5)
            if viewModel:FindFirstChild("Left Arm") then
                viewModel["Left Arm"].Size = Vector3.new(1, Options.LeftArmLength.Value, 1)
            end
        end
    end
end)

MovementLeft = Tabs.Movement:AddLeftGroupbox('Speed and JumpPower')
MovementRight = Tabs.Movement:AddRightGroupbox('Fly')
MovementLeft2 = Tabs.Movement:AddLeftGroupbox('Noclips')
MovementLeft3 = Tabs.Movement:AddLeftGroupbox('Fake Lags')
MovementRight2 = Tabs.Movement:AddRightGroupbox('Other')

Players = game:GetService("Players")
RunService = game:GetService("RunService")
UserInputService = game:GetService("UserInputService")
Camera = workspace.CurrentCamera
ReplicatedStorage = game:GetService("ReplicatedStorage")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
humanoidRootPart = character:WaitForChild("HumanoidRootPart")

flyEnabled = false
flySpeed = 40
fly2Enabled = false
fly2Speed = 60
moveDirection = Vector3.zero
remotes = {}
speedMode = "CFrame"

function getEvent()
    evt = ReplicatedStorage:FindFirstChild("Events")
    if evt then
        event = evt:FindFirstChild("__RZDONL")
        if event and event:IsA("RemoteEvent") then
            return event
        end
    end
    return nil
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = newCharacter:WaitForChild("Humanoid")
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
    if flyEnabled then
        humanoidRootPart.Anchored = true
    else
        humanoidRootPart.Anchored = false
    end
    if Toggles.IncreaseSpeed.Value then
        if speedMode == "CFrame" then
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
                _G.SpeedConnection = nil
            end
            _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                    h = player.Character.Humanoid
                    r = player.Character.HumanoidRootPart
                    d = h.MoveDirection
                    if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                        r.CFrame = r.CFrame + Vector3.new(d.X * Options.SpeedValue.Value, 0, d.Z * Options.SpeedValue.Value)
                    end
                end
            end)
        elseif speedMode == "Velocity" then
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
                _G.SpeedConnection = nil
            end
            _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                    h = player.Character.Humanoid
                    r = player.Character.HumanoidRootPart
                    d = h.MoveDirection
                    if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                        r.Velocity = Vector3.new(d.X * Options.SpeedValue.Value * 100, r.Velocity.Y, d.Z * Options.SpeedValue.Value * 100)
                    else
                        r.Velocity = Vector3.new(0, r.Velocity.Y, 0)
                    end
                end
            end)
        end
    end
end)

MovementLeft:AddDropdown('SpeedMode', {
    Values = {'CFrame', 'Velocity'},
    Default = 1,
    Multi = false,
    Text = 'Speedhack Mode',
    Callback = function(Value)
        speedMode = Value
        if Toggles.IncreaseSpeed.Value then
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
                _G.SpeedConnection = nil
            end
            if Value == "CFrame" then
                _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                        h = player.Character.Humanoid
                        r = player.Character.HumanoidRootPart
                        d = h.MoveDirection
                        if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                            r.CFrame = r.CFrame + Vector3.new(d.X * Options.SpeedValue.Value, 0, d.Z * Options.SpeedValue.Value)
                        end
                    end
                end)
            elseif Value == "Velocity" then
                _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                    if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                        h = player.Character.Humanoid
                        r = player.Character.HumanoidRootPart
                        d = h.MoveDirection
                        if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                            r.Velocity = Vector3.new(d.X * Options.SpeedValue.Value * 100, r.Velocity.Y, d.Z * Options.SpeedValue.Value * 100)
                        else
                            r.Velocity = Vector3.new(0, r.Velocity.Y, 0)
                        end
                    end
                end)
            end
        end
    end
})

MovementLeft:AddToggle('IncreaseSpeed', {
    Text = 'Speedhack',
    Default = false,
    Callback = function(Value)
        if Value then
            if not _G.SpeedConnection then
                if speedMode == "CFrame" then
                    _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                            h = player.Character.Humanoid
                            r = player.Character.HumanoidRootPart
                            d = h.MoveDirection
                            if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                                r.CFrame = r.CFrame + Vector3.new(d.X * Options.SpeedValue.Value, 0, d.Z * Options.SpeedValue.Value)
                            end
                        end
                    end)
                elseif speedMode == "Velocity" then
                    _G.SpeedConnection = RunService.Heartbeat:Connect(function()
                        if player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") then
                            h = player.Character.Humanoid
                            r = player.Character.HumanoidRootPart
                            d = h.MoveDirection
                            if h:GetState() ~= Enum.HumanoidStateType.Climbing then
                                r.Velocity = Vector3.new(d.X * Options.SpeedValue.Value * 100, r.Velocity.Y, d.Z * Options.SpeedValue.Value * 100)
                            else
                                r.Velocity = Vector3.new(0, r.Velocity.Y, 0)
                            end
                        end
                    end)
                end
            end
        else
            if _G.SpeedConnection then
                _G.SpeedConnection:Disconnect()
                _G.SpeedConnection = nil
            end
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.Velocity = Vector3.new(0, player.Character.HumanoidRootPart.Velocity.Y, 0)
            end
        end
    end
}):AddKeyPicker('SpeedKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Speedhack',
    Callback = function() end
})

MovementLeft:AddSlider('SpeedValue', {
    Text = 'Speed',
    Default = 0.16,
    Min = 0,
    Max = 2,
    Rounding = 2,
    Callback = function(Value) end
})

-- локальные ссылки для производительности
local function GetHumanoid()
    local char = player.Character
    if char then
        return char:FindFirstChild("Humanoid")
    end
end

local function SetJumpHeight(value)
    local humanoid = GetHumanoid()
    if humanoid then
        humanoid.UseJumpPower = false
        humanoid.JumpHeight = value
    end
end

MovementLeft:AddToggle('JumpPowerToggle', {
    Text = 'JumpPower',
    Default = false,
    Callback = function(Value)
        if Value then
            if not _G.JumpHeightConnection then
                _G.JumpHeightConnection = RunService.RenderStepped:Connect(function()
                    SetJumpHeight(Options.JumpPowerSlider.Value)
                end)

                -- Если используешь runtime cleaner:
                -- shared._TrackRuntime(_G.JumpHeightConnection)
            end
        else
            if _G.JumpHeightConnection then
                _G.JumpHeightConnection:Disconnect()
                _G.JumpHeightConnection = nil
            end
            SetJumpHeight(7.1)
        end
    end
}):AddKeyPicker('JumpPowerKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'JumpPower',
    Callback = function() end
})

MovementLeft:AddSlider('JumpPowerSlider', {
    Text = 'Jump Height',
    Default = 5,
    Min = 5,
    Max = 30,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        if Toggles.JumpPowerToggle.Value then
            SetJumpHeight(Value)
        end
    end
})

FlyToggle = MovementRight:AddToggle("FlyEnabled", {
    Text = "Fly",
    Default = false,
    Callback = function(Value)
        flyEnabled = Value
        if humanoidRootPart then
            humanoidRootPart.Anchored = Value
            if not Value then
                humanoidRootPart.Velocity = Vector3.zero
            end
        end
    end
})

FlyToggle:AddKeyPicker("FlyKey", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fly"
})

FlySpeedSlider = MovementRight:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 40,
    Min = 10,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        flySpeed = Value
    end
})

function fly2(hrp, state)
    fly2Enabled = state
    if state then
        remotes.Fly_RUN = RunService.RenderStepped:Connect(function()
            if not fly2Enabled then return end
            moveVector = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + (Camera.CFrame.LookVector * fly2Speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - (Camera.CFrame.LookVector * fly2Speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - (Camera.CFrame.RightVector * fly2Speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + (Camera.CFrame.RightVector * fly2Speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + (Camera.CFrame.UpVector * fly2Speed) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - (Camera.CFrame.UpVector * fly2Speed) end
            hrp.Velocity = moveVector
            event = getEvent()
            if event then
                event:FireServer("__---r", Vector3.zero, hrp.CFrame)
            end
        end)
    else
        if remotes.Fly_RUN then
            remotes.Fly_RUN:Disconnect()
            remotes.Fly_RUN = nil
        end
        hrp.Velocity = Vector3.zero
    end
end

Fly2Toggle = MovementRight:AddToggle("Fly2Toggle", {
    Text = "Long Fly",
    Default = false,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            fly2(player.Character.HumanoidRootPart, v)
        end
    end
})

Fly2Toggle:AddKeyPicker("Fly2Key", {
    Default = "None",
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Long Fly"
})

Fly2SpeedSlider = MovementRight:AddSlider("Fly2Speed", {
    Text = "Long-Fly Speed",
    Default = 60,
    Min = 10,
    Max = 150,
    Rounding = 0,
    Callback = function(Value)
        fly2Speed = Value
    end
})

RunService.RenderStepped:Connect(function(deltaTime)
    if flyEnabled and humanoidRootPart then
        moveDirection = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Camera.CFrame.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection = moveDirection - Camera.CFrame.UpVector end
        if moveDirection.Magnitude > 0 then
            humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveDirection.Unit * (flySpeed * deltaTime)
        end
    end
end)

player = game.Players.LocalPlayer
NoclipDoorsToggle = MovementLeft2:AddToggle('NoclipDoors', {
    Text = "Noclip Doors",
    Default = false,
    Callback = function(State)
        for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
            if v:FindFirstChild("DoorBase") then v.DoorBase.CanCollide = not State end
            if v:FindFirstChild("DoorA") then v.DoorA.CanCollide = not State end
            if v:FindFirstChild("DoorB") then v.DoorB.CanCollide = not State end
            if v:FindFirstChild("DoorC") then v.DoorC.CanCollide = not State end
            if v:FindFirstChild("DoorD") then v.DoorD.CanCollide = not State end
        end
    end
})
game:GetService("Workspace").Map.Doors.ChildAdded:Connect(function(child)
    if NoclipDoorsToggle.Value then
        if child:FindFirstChild("DoorBase") then child.DoorBase.CanCollide = false end
        if child:FindFirstChild("DoorA") then child.DoorA.CanCollide = false end
        if child:FindFirstChild("DoorB") then child.DoorB.CanCollide = false end
        if child:FindFirstChild("DoorC") then child.DoorC.CanCollide = false end
        if child:FindFirstChild("DoorD") then child.DoorD.CanCollide = false end
    end
end)
player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        player.CharacterAdded:Wait()
        if NoclipDoorsToggle.Value then
            for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
                if v:FindFirstChild("DoorBase") then v.DoorBase.CanCollide = false end
                if v:FindFirstChild("DoorA") then v.DoorA.CanCollide = false end
                if v:FindFirstChild("DoorB") then v.DoorB.CanCollide = false end
                if v:FindFirstChild("DoorC") then v.DoorC.CanCollide = false end
                if v:FindFirstChild("DoorD") then v.DoorD.CanCollide = false end
            end
        end
    end)
end)
if NoclipDoorsToggle.Value then
    for _, v in pairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
        if v:FindFirstChild("DoorBase") then v.DoorBase.CanCollide = false end
        if v:FindFirstChild("DoorA") then v.DoorA.CanCollide = false end
        if v:FindFirstChild("DoorB") then v.DoorB.CanCollide = false end
        if v:FindFirstChild("DoorC") then v.DoorC.CanCollide = false end
        if v:FindFirstChild("DoorD") then v.DoorD.CanCollide = false end
    end
end

_G.Noclip = false

function Noclip()
    if game.Players.LocalPlayer.Character and _G.Noclip then
        for _, selfChar in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if selfChar:IsA("BasePart") and selfChar.CanCollide == true then
                selfChar.CanCollide = false
            end
        end
    end
end

game:GetService("RunService").Stepped:Connect(Noclip)

NoclipToggle = MovementLeft2:AddToggle('NoclipToggle', {
    Text = "Noclip",
    Default = false,
    Callback = function(Value)
        _G.Noclip = Value
    end
}):AddKeyPicker('NoclipKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Noclip'
})

FakelagSettings = {
    Enabled = false,
    MaxLagPackets = 10,
    LagDuration = 0
}

LagTick = 0
IsLagging = false

FakelagToggle = MovementLeft3:AddToggle('FakelagToggle', {
    Text = 'Fakelag',
    Default = false,
    Callback = function(v)
        FakelagSettings.Enabled = v
    end
})

FakelagToggle:AddKeyPicker('FakelagKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Fakelag'
})

MovementLeft3:AddSlider('LagDurationSlider', {
    Text = 'Lag Duration',
    Default = 0.100,
    Min = 0,
    Max = 1,
    Rounding = 3,
    Callback = function(v)
        FakelagSettings.LagDuration = v
    end
})

game:GetService('RunService').Heartbeat:Connect(function()
    if not FakelagSettings.Enabled then return end
    if not game:GetService('Players').LocalPlayer.Character or not game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid') or game:GetService('Players').LocalPlayer.Character:FindFirstChildOfClass('Humanoid').Health <= 0 then return end

    if not IsLagging then
        IsLagging = true
        LagTick = 0
        game:GetService('NetworkClient'):SetOutgoingKBPSLimit(1)
        task.delay(FakelagSettings.LagDuration, function()
            IsLagging = false
            game:GetService('NetworkClient'):SetOutgoingKBPSLimit(9e9)
        end)
    end

    LagTick = LagTick + 1
    if LagTick >= FakelagSettings.MaxLagPackets then
        LagTick = 0
    end
end)

_G.UpsideDown = false

MovementRight2:AddToggle('UpsideDownToggle', {
    Text = "UpsideDown",
    Default = false,
    Callback = function(Value)
        _G.UpsideDown = Value
        if not Value then
            lastCFrame = nil
            if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
                game.Players.LocalPlayer.Character.Humanoid.AutoRotate = true
                game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
                game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
    if _G.UpsideDown and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game.Players.LocalPlayer.Character.Humanoid.Health > 0 then
        game.Players.LocalPlayer.Character.Humanoid.AutoRotate = false
        game.Players.LocalPlayer.Character.Humanoid.PlatformStand = false
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        if game.Players.LocalPlayer.Character.Humanoid.Jump then
            game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.X, game.Players.LocalPlayer.Character.Humanoid.JumpPower, game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity.Z)
            game.Players.LocalPlayer.Character.Humanoid.Jump = false
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if game.Players.LocalPlayer.Character.Humanoid:GetState() == Enum.HumanoidStateType.Landed then
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end
        camera = workspace.CurrentCamera
        moveDir = game.Players.LocalPlayer.Character.Humanoid.MoveDirection
        lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        rotationCFrame = CFrame.Angles(math.rad(180), 0, 0)
        newCFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position)
        if moveDir.Magnitude > 0 then
            lookAtCFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(-moveDir.X, 0, -moveDir.Z))
            newCFrame = newCFrame * lookAtCFrame * rotationCFrame
        else
            lookAtCFrame = CFrame.new(Vector3.new(0, 0, 0), Vector3.new(-lookDir.X, 0, -lookDir.Z))
            newCFrame = newCFrame * lookAtCFrame * rotationCFrame
        end
        if not lastCFrame then
            lastCFrame = newCFrame
        end
        newCFrame = lastCFrame:Lerp(newCFrame, 0.5)
        lastCFrame = newCFrame
        if moveDir.Magnitude > 0 then
            moveVector = moveDir * game.Players.LocalPlayer.Character.Humanoid.WalkSpeed * deltaTime
            newCFrame = CFrame.new(newCFrame.Position + moveVector) * newCFrame.Rotation
        end
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = newCFrame
        game.Players.LocalPlayer.Character.HumanoidRootPart.CanCollide = true
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    if _G.UpsideDown then
        newChar:WaitForChild("Humanoid").AutoRotate = false
        newChar:WaitForChild("Humanoid").PlatformStand = false
        for _, part in pairs(newChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        camera = workspace.CurrentCamera
        lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        rotationCFrame = CFrame.Angles(math.rad(180), 0, 0)
        newCFrame = CFrame.new(newChar:WaitForChild("HumanoidRootPart").Position) * CFrame.new(Vector3.new(0, 0, 0), Vector3.new(-lookDir.X, 0, -lookDir.Z)) * rotationCFrame
        lastCFrame = newCFrame
        newChar:WaitForChild("HumanoidRootPart").CFrame = newCFrame
        newChar:WaitForChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Running)
    end
end)

_G.Backwards = false

MovementRight2:AddToggle('BackwardsToggle', {
    Text = "Walk Backwards",
    Default = false,
    Callback = function(Value)
        _G.Backwards = Value
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.Backwards then
        camera = workspace.CurrentCamera
        lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        targetCFrame = CFrame.new(Vector3.new(0, 0, 0), lookDir) * CFrame.Angles(0, math.pi, 0)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game.Players.LocalPlayer.Character.HumanoidRootPart.Position) * targetCFrame
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
    if _G.Backwards then
        camera = workspace.CurrentCamera
        lookDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
        targetCFrame = CFrame.new(Vector3.new(0, 0, 0), lookDir) * CFrame.Angles(0, math.pi, 0)
        newChar.HumanoidRootPart.CFrame = CFrame.new(newChar.HumanoidRootPart.Position) * targetCFrame
    end
end)

NoJumpDelay = false

MovementRight2:AddToggle('NoJumpDelay', {
    Text = 'No Jump Delay',
    Default = false,
    Callback = function(Value)
        NoJumpDelay = Value
    end
})

UserInputService = game:GetService("UserInputService")
Players = game:GetService("Players")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")

jumpHeld = false
canJump = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = false
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if NoJumpDelay then
            if jumpHeld and humanoid.FloorMaterial ~= Enum.Material.Air and canJump then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                canJump = false
                task.delay(0.35, function()
                    canJump = true
                end)
            end
        end
    end
end)

p = game:GetService("Players").LocalPlayer

AlwaysSprintToggle = MovementRight2:AddToggle('AlwaysSprint', {
    Text = "Always Sprint",
    Default = false,
    Callback = function(State)
        if State then
            RunService:BindToRenderStep("AlwaysSprint", Enum.RenderPriority.Character.Value, function()
                if Toggles.AlwaysSprint.Value then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                end
            end)
        else
            RunService:UnbindFromRenderStep("AlwaysSprint")
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
        end
    end
})

AlwaysCrouchToggle = MovementRight2:AddToggle('AlwaysCrouch', {
    Text = "Always Crouch",
    Default = false,
    Callback = function(State)
        if State then
            RunService:BindToRenderStep("AlwaysCrouch", Enum.RenderPriority.Character.Value, function()
                if Toggles.AlwaysCrouch.Value then
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.C, false, game)
                end
            end)
        else
            RunService:UnbindFromRenderStep("AlwaysCrouch")
            game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.C, false, game)
        end
    end
})

functions = functions or {}
functions.infstaminaF = false
remotes = remotes or {}
me = game.Players.LocalPlayer

InfStaminaToggle = MovementRight2:AddToggle('InfStaminaToggle', {
    Text = "Infinite Stamina",
    Default = false,
    Callback = function(Value)
        functions.infstaminaF = Value

        if functions.infstaminaF then
            local success, no = pcall(function()
                local target = getupvalue(getrenv()._G.S_Take, 2)
                local oldStamina
                oldStamina = hookfunction(target, function(v1, ...)
                    if functions.infstaminaF then
                        v1 = 0
                    end
                    -- Вызов оригинальной функции без рекурсии:
                    return oldStamina(v1, ...)
                end)
            end)

            if not success then
                local stamina = {}
                local function get()
                    for index, value in pairs(getgc(true)) do
                        if type(value) == "table" and rawget(value, "S") then
                            stamina[#stamina + 1] = value
                        end
                    end
                end

                local ss, nn = pcall(get)
                if ss then
                    remotes.infstamina = game:GetService("RunService").RenderStepped:Connect(function()
                        get()
                        if functions.infstaminaF then
                            for _, a in pairs(stamina) do
                                a.S = 100
                            end
                        end
                    end)
                else
                    remotes.infstamina = game:GetService("RunService").RenderStepped:Connect(function()
                        if functions.infstaminaF then
                            local char = me.Character
                            if not char then return end
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if not hum then return end
                            local check = hum:GetAttribute("ZSPRN_M")
                            if not check then hum:SetAttribute("ZSPRN_M", true) end
                        end
                    end)
                end
            end
        else
            if remotes.infstamina then
                remotes.infstamina:Disconnect()
            end
            remotes.infstamina = nil
            if me.Character then
                local hum = me.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetAttribute("ZSPRN_M", nil)
                end
            end
        end
    end
})

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats

MovementRight2:AddToggle('FastAccel', {
    Text = 'Fast Acceleration',
    Default = false,
    Callback = function(Value)
        if charStats:FindFirstChild(player.Name) then
            charStats[player.Name].AccelerationModifier.Value = Value and 1e6 or 1
            charStats[player.Name].AccelerationModifier2.Value = Value and 1e6 or 1
        end
    end
})

charStats.ChildAdded:Connect(function(child)
    if child.Name == player.Name and Toggles.FastAccel.Value then
        child.AccelerationModifier.Value = 1e6
        child.AccelerationModifier2.Value = 1e6
    end
end)

player.CharacterAdded:Connect(function(char)
    if Toggles.FastAccel.Value then
        repeat task.wait() until charStats:FindFirstChild(player.Name)
        charStats[player.Name].AccelerationModifier.Value = 1e6
        charStats[player.Name].AccelerationModifier2.Value = 1e6
    end
    char:WaitForChild("Humanoid").Died:Connect(function()
        player.CharacterAdded:Wait()
        if Toggles.FastAccel.Value then
            repeat task.wait() until charStats:FindFirstChild(player.Name)
            charStats[player.Name].AccelerationModifier.Value = 1e6
            charStats[player.Name].AccelerationModifier2.Value = 1e6
        end
    end)
end)

if charStats:FindFirstChild(player.Name) and Toggles.FastAccel.Value then
    charStats[player.Name].AccelerationModifier.Value = 1e6
    charStats[player.Name].AccelerationModifier2.Value = 1e6
end

player = game:GetService("Players").LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
runService = game:GetService("RunService")
replicatedStorage = game:GetService("ReplicatedStorage")

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end)

fallDamageModule = replicatedStorage:FindFirstChild("FallDamageModule")
if fallDamageModule then
    fallDamage = require(fallDamageModule)
    if type(fallDamage) == "table" and fallDamage.FallDamage then
        fallDamage.FallDamage = function() return 0 end
    end
end

MovementRight2:AddToggle('NofallDamage1', {
    Text = 'No fall Damage1',
    Default = false,
    Callback = function(Value)
        if Value then
            connection = runService.RenderStepped:Connect(function()
                if humanoid and humanoid.Health > 0 then
                    humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
            end)
        else
            if connection then
                connection:Disconnect()
                connection = nil
            end
        end
    end
})

DisableFallDamage = false
DisableRagdoll = false
DisableDrown = false

EventFallRagdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("__RZDONL")
EventDrown = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("TK_DGM")

originalFallRagdollParent = EventFallRagdoll and EventFallRagdoll.Parent
originalDrownParent = EventDrown and EventDrown.Parent

function updateEvents()
    if EventFallRagdoll then
        if DisableRagdoll or DisableFallDamage then
            EventFallRagdoll.Parent = nil
        else
            EventFallRagdoll.Parent = originalFallRagdollParent
        end
    end
    
    if EventDrown then
        if DisableDrown then
            EventDrown.Parent = nil
        else
            EventDrown.Parent = originalDrownParent
        end
    end
end

NoFallDamageToggle = MovementRight2:AddToggle('NoFallDamage2', {
    Text = "No Fall Damage2",
    Default = false,
    Callback = function(Value)
        DisableFallDamage = Value
        updateEvents()
    end
})

DisableRagdollToggle = MovementRight2:AddToggle('DisableRagdoll', {
    Text = "Disable Ragdoll",
    Default = false,
    Callback = function(Value)
        DisableRagdoll = Value
        updateEvents()
    end
})

DisableDrownToggle = MovementRight2:AddToggle('DisableDrown', {
    Text = "Disable Drown",
    Default = false,
    Callback = function(Value)
        DisableDrown = Value
        updateEvents()
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if not EventFallRagdoll then
        EventFallRagdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("__RZDONL")
        if EventFallRagdoll then
            originalFallRagdollParent = EventFallRagdoll.Parent
            updateEvents()
        end
    end
    if not EventDrown then
        EventDrown = game:GetService("ReplicatedStorage"):FindFirstChild("Events") and game:GetService("ReplicatedStorage").Events:FindFirstChild("TK_DGM")
        if EventDrown then
            originalDrownParent = EventDrown.Parent
            updateEvents()
        end
    end
    
    if EventFallRagdoll and EventFallRagdoll.Parent and (DisableRagdoll or DisableFallDamage) then
        EventFallRagdoll.Parent = nil
    end
    if EventDrown and EventDrown.Parent and DisableDrown then
        EventDrown.Parent = nil
    end
end)

UserInputService = game:GetService("UserInputService")
Players = game:GetService("Players")
RunService = game:GetService("RunService")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoid = character:WaitForChild("Humanoid")
HRP = character:WaitForChild("HumanoidRootPart")

jumpHeld = false
BunnyHopEnabled = false
_G.BhopSpeed = 25

MovementRight2:AddToggle('BunnyHopToggle', {
    Text = 'BunnyHop',
    Default = false,
    Callback = function(Value)
        BunnyHopEnabled = Value
    end
}):AddKeyPicker('BunnyHopKeyPicker', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'BunnyHop',
    Callback = function(Value)
        BunnyHopEnabled = Value
    end
})

MovementRight2:AddSlider('BhopSpeed', {
    Text = 'Bhop Speed',
    Default = 25,
    Min = 10,
    Max = 70,
    Rounding = 0,
    Callback = function(value)
        _G.BhopSpeed = value
    end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        jumpHeld = false
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = character:WaitForChild("Humanoid")
    HRP = character:WaitForChild("HumanoidRootPart")
end)

RunService.RenderStepped:Connect(function()
    if not BunnyHopEnabled then return end
    if humanoid.FloorMaterial ~= Enum.Material.Air then return end
    if jumpHeld then
        local boost = (_G.BhopSpeed / 10)
        HRP.Velocity += HRP.CFrame.LookVector * boost
    end
end)

GravitySlider = MovementRight2:AddSlider('GravitySlider', {
    Text = "Gravity",
    Default = game.Workspace.Gravity,
    Min = 75,
    Max = 196,
    Rounding = 0,
    Callback = function(Value)
        game.Workspace.Gravity = Value
    end
})

InfectionLeft = Tabs.Infection:AddLeftGroupbox('Player')

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")

playerBlockersPath = nil
sewerBlockersPath = nil
blockersTask = nil
blockersConnection = nil
player = Players.LocalPlayer

ACTIVE_COLOR = Color3.fromRGB(52, 142, 64)
DEFAULT_COLOR = Color3.fromRGB(255, 0, 0)

function SetPartsProperties(folder, canCollide, color)
    if folder then
        for _, part in ipairs(folder:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = canCollide
                if folder.Name == "PlayerBlockers" then
                    part.BrickColor = BrickColor.new(color)
                end
            end
        end
    end
end

function CheckBlockersPath()
    filter = Workspace:FindFirstChild("Filter")
    if not filter then
        Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Filter" then
                parts = child:FindFirstChild("Parts")
                if parts then
                    playerBlockersPath = parts:FindFirstChild("PlayerBlockers")
                    sewerBlockersPath = parts:FindFirstChild("SewerBlockers")
                end
            end
        end)
        return
    end

    parts = filter:FindFirstChild("Parts")
    if not parts then
        filter.ChildAdded:Connect(function(child)
            if child.Name == "Parts" then
                playerBlockersPath = child:FindFirstChild("PlayerBlockers")
                sewerBlockersPath = child:FindFirstChild("SewerBlockers")
            end
        end)
        return
    end

    playerBlockersPath = parts:FindFirstChild("PlayerBlockers")
    sewerBlockersPath = parts:FindFirstChild("SewerBlockers")
    if not (playerBlockersPath and sewerBlockersPath) then
        parts.ChildAdded:Connect(function(child)
            if child.Name == "PlayerBlockers" then
                playerBlockersPath = child
            elseif child.Name == "SewerBlockers" then
                sewerBlockersPath = child
            end
        end)
    end
end

function ToggleBlockers(value)
    if blockersTask then
        task.cancel(blockersTask)
        blockersTask = nil
    end
    if blockersConnection then
        blockersConnection:Disconnect()
        blockersConnection = nil
    end

    if value then
        if playerBlockersPath and sewerBlockersPath then
            blockersTask = task.spawn(function()
                while value and playerBlockersPath and sewerBlockersPath do
                    SetPartsProperties(playerBlockersPath, false, ACTIVE_COLOR)
                    SetPartsProperties(sewerBlockersPath, false, nil)
                    task.wait(0.1)
                end
            end)
        else
            blockersConnection = Workspace.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "PlayerBlockers" or descendant.Name == "SewerBlockers" then
                    if descendant.Name == "PlayerBlockers" then
                        playerBlockersPath = descendant
                    elseif descendant.Name == "SewerBlockers" then
                        sewerBlockersPath = descendant
                    end
                    if playerBlockersPath and sewerBlockersPath then
                        blockersTask = task.spawn(function()
                            while value and playerBlockersPath and sewerBlockersPath do
                                SetPartsProperties(playerBlockersPath, false, ACTIVE_COLOR)
                                SetPartsProperties(sewerBlockersPath, false, nil)
                                task.wait(0.1)
                            end
                        end)
                    end
                end
            end)
        end
    else
        if playerBlockersPath and sewerBlockersPath then
            SetPartsProperties(playerBlockersPath, true, DEFAULT_COLOR)
            SetPartsProperties(sewerBlockersPath, true, nil)
        end
    end
end

CheckBlockersPath()

player.CharacterAdded:Connect(function()
    CheckBlockersPath()
    if Options.RemoveSewersBlockers and Options.RemoveSewersBlockers.Value then
        ToggleBlockers(true)
    end
end)

InfectionLeft:AddToggle('RemoveSewersBlockers', {
    Text = 'Noclip SewersBlockers',
    Default = false,
    Callback = function(value)
        ToggleBlockers(value)
    end
})

data = {
  {"TrussWithNoSupports",CFrame.new(-4254.453125,136.19529724121094,-548.9240112304688,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.453125,138.19529724121094,-548.9239501953125,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.453125,140.19529724121094,-548.9238891601562,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.4541015625,142.19517517089844,-548.9366455078125,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.455078125,144.19430541992188,-548.9448852539062,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.45654296875,146.19346618652344,-548.9537353515625,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.45556640625,158.1901092529297,-548.946044921875,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.4541015625,156.19094848632812,-548.9533081054688,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.453125,154.19178771972656,-548.9459838867188,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.46044921875,152.1918182373047,-548.9313354492188,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.4580078125,148.19349670410156,-548.9356689453125,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4254.458984375,150.19265747070312,-548.9230346679688,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4216.15283203125,137.19705200195312,-548.9248046875,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4216.1533203125,139.19705200195312,-548.9247436523438,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4216.1533203125,141.19705200195312,-548.9246826171875,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4216.154296875,143.19692993164062,-548.9374389648438,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4216.1552734375,145.19606018066406,-548.9456787109375,-1,-0.00008632201206637546,0,-0.00008632201206637546,1,0,-0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,135.14459228515625,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,133.51153564453125,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,131.8783721923828,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,145.04400634765625,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,143.4107208251953,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,141.77764892578125,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,140.14459228515625,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,136.8783721923828,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05419921875,138.51153564453125,14.63259506225586,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,154.84254455566406,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,153.20948791503906,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,151.57643127441406,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,149.9434051513672,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,146.67703247070312,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,148.31011962890625,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,164.64132690429688,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,163.00828552246094,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,161.37498474121094,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,159.741943359375,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,156.475830078125,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,158.10890197753906,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,174.4401397705078,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,172.8068389892578,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,171.1737823486328,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,169.54074096679688,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,166.27438354492188,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4872.05517578125,167.9076690673828,14.63412857055664,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,134.3916473388672,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,180.39137268066406,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,182.391357421875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,184.39132690429688,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,186.39129638671875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,188.3912811279297,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,192.39125061035156,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,196.39122009277344,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,190.39126586914062,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,194.3912353515625,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,168.39141845703125,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,178.39134216308594,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,158.39151000976562,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,160.3914794921875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,162.39146423339844,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,164.39144897460938,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,166.3914337158203,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,170.39138793945312,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,174.391357421875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,176.391357421875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,172.39137268066406,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,156.3914794921875,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,136.3916473388672,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,138.39163208007812,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,140.39161682128906,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,142.3916015625,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,144.39157104492188,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,146.3915557861328,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,148.3915252685547,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,150.39151000976562,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,152.39151000976562,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.4853515625,154.39151000976562,-134.1024169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4751.171875,141.150634765625,-364.2601013183594,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4751.171875,143.15061950683594,-364.2601013183594,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4751.171875,145.15060424804688,-364.2601013183594,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4751.171875,147.1505584716797,-364.2601013183594,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.3505859375,140.65087890625,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.3505859375,142.64532470703125,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.3505859375,144.64254760742188,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.3505859375,146.6397247314453,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,130.39169311523438,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,132.39169311523438,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,134.39169311523438,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,180.3913116455078,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,182.39129638671875,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,184.39125061035156,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,186.39120483398438,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,188.3911895751953,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,192.3911590576172,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,196.39111328125,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,190.39117431640625,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,194.39114379882812,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,168.39138793945312,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,178.3912811279297,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,158.39149475097656,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,160.39144897460938,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,162.39144897460938,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,164.39141845703125,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,166.3914031982422,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,170.39134216308594,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,174.39129638671875,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,176.39129638671875,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,172.39132690429688,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,156.39146423339844,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,136.3916778564453,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,138.39166259765625,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,140.3916473388672,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,142.39163208007812,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,144.39158630371094,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,146.39157104492188,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,148.3915252685547,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,150.39151000976562,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,152.39151000976562,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4694.9853515625,154.39151000976562,-131.38026428222656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,128.8783721923828,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,130.3783721923828,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,135.14459228515625,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,133.51153564453125,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,131.8783721923828,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,145.04400634765625,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,143.4107208251953,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,141.77764892578125,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,140.14459228515625,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,136.8783721923828,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.60888671875,138.51153564453125,-28.857234954833984,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,154.84254455566406,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,153.20948791503906,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,151.57643127441406,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,149.9434051513672,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,146.67703247070312,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,148.31011962890625,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,164.64132690429688,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,163.00828552246094,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,161.37498474121094,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,159.741943359375,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,156.475830078125,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,158.10890197753906,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,174.4401397705078,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,172.8068389892578,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,171.1737823486328,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,169.54074096679688,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,166.27438354492188,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4871.609375,167.9076690673828,-28.856212615966797,0.3420426845550537,-0,-0.9396843910217285,0,1,-0,0.9396843910217285,0,0.3420426845550537),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,129.28146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,130.78146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,132.28146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,133.78146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,135.28146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,136.78146362304688,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,138.38145446777344,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,148.14732360839844,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,146.51397705078125,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,144.88092041015625,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,143.24783325195312,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,139.98146057128906,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67822265625,141.61477661132812,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,157.94586181640625,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,156.31280517578125,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,154.6797637939453,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,153.04673767089844,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,149.78041076660156,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,151.41346740722656,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,167.7445831298828,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,166.1115264892578,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,164.47825622558594,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,162.84521484375,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,159.5791473388672,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,161.21221923828125,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,177.5435028076172,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,175.91004943847656,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,174.27699279785156,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,172.6439666748047,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,169.3776397705078,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4850.67919921875,171.0109100341797,80.517578125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4731.169921875,140.65087890625,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4731.169921875,142.64532470703125,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4731.169921875,144.64254760742188,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4731.169921875,146.6397247314453,-360.9294738769531,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,134.39173889160156,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,180.39125061035156,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,182.3912353515625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,184.39117431640625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,186.39111328125,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,188.39109802246094,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,192.3910675048828,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,196.39100646972656,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,190.39108276367188,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,194.39102172851562,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,168.391357421875,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,178.39122009277344,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,158.3914794921875,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,160.39141845703125,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,162.3914031982422,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,164.39138793945312,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,166.39137268066406,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,170.39129638671875,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,174.3912353515625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,176.3912353515625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,172.3912811279297,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,156.39146423339844,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,136.39170837402344,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,138.39169311523438,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,140.3916778564453,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,142.39166259765625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,144.3916015625,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,146.39158630371094,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,148.3915252685547,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,150.39151000976562,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,152.39151000976562,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4739.4853515625,154.39151000976562,-200.702392578125,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,129.3814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,130.8814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,132.3814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,133.8814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,135.3814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,136.8814697265625,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,138.48146057128906,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,148.24732971191406,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,146.61398315429688,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,144.98092651367188,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,143.34783935546875,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,140.0814666748047,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,141.71478271484375,31.964719772338867,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,158.04586791992188,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,156.41281127929688,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,154.77976989746094,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,153.14674377441406,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,149.8804168701172,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,151.5134735107422,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,167.84458923339844,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,166.21153259277344,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,164.57826232910156,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,162.94522094726562,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,159.6791534423828,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,161.31222534179688,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,177.6435089111328,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,176.0100555419922,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,174.3769989013672,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,172.7439727783203,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,169.47764587402344,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4831.318359375,171.1109161376953,31.963865280151367,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,129.34811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,130.84811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,132.34811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,133.84811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,135.34811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,136.84811401367188,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,138.44810485839844,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,148.21397399902344,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,146.58062744140625,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,144.94757080078125,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,143.31448364257812,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,140.04811096191406,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,141.68142700195312,63.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,158.01251220703125,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,156.37945556640625,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,154.7464141845703,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,153.11338806152344,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,149.84706115722656,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,151.48011779785156,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,167.8112335205078,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,166.1781768798828,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,164.54490661621094,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,162.911865234375,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,159.6457977294922,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,161.27886962890625,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,177.6101531982422,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,175.97669982910156,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,174.34364318847656,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,172.7106170654297,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,169.4442901611328,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,171.0775604248047,63.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,135.14459228515625,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,133.51153564453125,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,131.8783721923828,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,145.04400634765625,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,143.4107208251953,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,141.77764892578125,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,140.14459228515625,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,136.8783721923828,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.44287109375,138.51153564453125,10.186671257019043,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,154.84254455566406,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,153.20948791503906,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,151.57643127441406,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,149.9434051513672,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,146.6770477294922,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,148.3101043701172,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,164.64132690429688,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,163.00828552246094,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,161.37498474121094,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,159.74192810058594,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,156.475830078125,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,158.10890197753906,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,174.4401397705078,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,172.8068389892578,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,171.1737823486328,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,169.54074096679688,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,166.27438354492188,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4886.4443359375,167.9076690673828,10.185628890991211,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,132.1914825439453,-77.80001068115234,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,134.1914825439453,-77.80001068115234,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.56494140625,136.1914825439453,-77.80025482177734,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.56494140625,138.1914825439453,-77.80025482177734,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,150.1914520263672,-77.80013275146484,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.56494140625,148.1914520263672,-77.80013275146484,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,146.1914520263672,-77.80013275146484,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,144.1914520263672,-77.80013275146484,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.56494140625,140.19146728515625,-77.80025482177734,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4477.5654296875,142.1914520263672,-77.80013275146484,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.18896484375,132.87095642089844,-85.98394775390625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.18896484375,134.8707733154297,-85.98385620117188,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.189453125,136.8705596923828,-85.9835205078125,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.18896484375,138.87045288085938,-85.98343658447266,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.1884765625,150.8694305419922,-85.9830093383789,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.18896484375,148.86964416503906,-85.98310089111328,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.1884765625,146.86985778808594,-85.98319244384766,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.1884765625,144.86985778808594,-85.98328399658203,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.18896484375,140.87030029296875,-85.98334503173828,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4283.1884765625,142.8700714111328,-85.9833755493164,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,132.19151306152344,-77.80001068115234,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,134.19151306152344,-77.80001068115234,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.06494140625,136.19149780273438,-77.80025482177734,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.06494140625,138.19149780273438,-77.80025482177734,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,150.19143676757812,-77.80013275146484,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.06494140625,148.19143676757812,-77.80013275146484,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,146.1914520263672,-77.80013275146484,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,144.1914520263672,-77.80013275146484,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.06494140625,140.19146728515625,-77.80025482177734,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4540.0654296875,142.1914520263672,-77.80013275146484,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,129.34811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,130.84811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,132.34811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,133.84811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,135.34811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,136.84811401367188,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,138.44810485839844,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,148.21397399902344,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,146.58062744140625,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,144.94757080078125,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,143.31448364257812,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,140.04811096191406,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,141.68142700195312,55.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,158.01251220703125,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,156.37945556640625,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,154.7464141845703,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,153.11338806152344,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,149.84706115722656,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,151.48011779785156,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,167.8112335205078,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,166.1781768798828,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,164.54490661621094,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,162.911865234375,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,159.6457977294922,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,161.27886962890625,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,177.6101531982422,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,175.97669982910156,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,174.34364318847656,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,172.7106170654297,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,169.4442901611328,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,171.0775604248047,55.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,129.34811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,130.84811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,132.34811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,133.84811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,135.34811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,136.84811401367188,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,138.44810485839844,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,148.21397399902344,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,146.58062744140625,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,144.94757080078125,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,143.31448364257812,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,140.04811096191406,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,141.68142700195312,71.8980712890625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,158.01251220703125,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,156.37945556640625,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,154.7464141845703,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,153.11338806152344,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,149.84706115722656,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,151.48011779785156,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,167.8112335205078,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,166.1781768798828,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,164.54490661621094,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,162.911865234375,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,159.6457977294922,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,161.27886962890625,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,177.6101531982422,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,175.97669982910156,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,174.34364318847656,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,172.7106170654297,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,169.4442901611328,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4864.7060546875,171.0775604248047,71.897216796875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,190.391357421875,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,180.3914337158203,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,182.39141845703125,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,184.3914031982422,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,186.39138793945312,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,188.39137268066406,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,192.39134216308594,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,196.39132690429688,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,198.39132690429688,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,194.39132690429688,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,168.39144897460938,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,178.3914031982422,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,158.3915252685547,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,160.39151000976562,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,162.39149475097656,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,164.3914794921875,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,166.39146423339844,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,170.3914337158203,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,174.39141845703125,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,176.39141845703125,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,172.39141845703125,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,156.39149475097656,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,136.39161682128906,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,138.3916015625,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,140.39158630371094,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,142.39157104492188,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,144.3915557861328,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,146.39154052734375,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,148.3915252685547,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,150.39151000976562,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,152.39151000976562,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,154.39151000976562,-246.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,146.3915252685547,-257.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,148.3915252685547,-257.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,150.39151000976562,-257.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,152.39151000976562,-257.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4755.88525390625,154.39151000976562,-257.60235595703125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,135.14459228515625,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,133.51153564453125,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,131.8783721923828,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,145.04400634765625,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,143.4107208251953,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,141.77764892578125,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,140.14459228515625,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,136.8783721923828,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.6513671875,138.51153564453125,-12.366025924682617,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,154.84254455566406,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,153.20948791503906,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,151.57643127441406,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,149.9434051513672,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,146.6770477294922,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,148.3101043701172,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,164.64132690429688,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,163.00828552246094,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,161.37498474121094,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,159.74192810058594,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,156.475830078125,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,158.10890197753906,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,174.4401397705078,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,172.8068389892578,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,171.1737823486328,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,169.54074096679688,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,166.27438354492188,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4894.65234375,167.9076690673828,-12.367167472839355,-0.9397009611129761,0,-0.3419983685016632,0,1,0,0.3419983685016632,0,-0.9397009611129761),Vector3.new(0.49,1.63,1.63),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.935546875,140.1227264404297,-544.7286987304688,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.935546875,142.1227264404297,-544.7286987304688,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.935546875,144.1227264404297,-544.7286987304688,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.935546875,146.1227264404297,-544.7286987304688,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.9345703125,158.1227264404297,-544.7288208007812,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.93505859375,156.1227264404297,-544.728759765625,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.93505859375,154.1227264404297,-544.728759765625,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.93505859375,152.1227264404297,-544.728759765625,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.935546875,148.1227264404297,-544.7286987304688,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4685.93505859375,150.1227264404297,-544.728759765625,0.49995946884155273,0.00007475604797946289,0.8660488128662109,-0.00007475604797946289,1,-0.00004316275590099394,-0.8660488128662109,-0.00004316275590099394,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,132.69146728515625,-2.800048828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,134.69146728515625,-2.800048828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.8662109375,136.69146728515625,-2.7998046875,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.8662109375,138.69146728515625,-2.7998046875,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,150.69146728515625,-2.7999267578125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.8662109375,148.69146728515625,-2.7999267578125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,146.69146728515625,-2.7999267578125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,144.69146728515625,-2.7999267578125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.8662109375,140.69146728515625,-2.7998046875,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4423.86572265625,142.69146728515625,-2.7999267578125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4470.28125,73.50336456298828,-288.7451171875,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4470.28125,75.49517059326172,-288.7451171875,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4470.28515625,77.48844146728516,-288.7423400878906,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4470.2822265625,79.4795150756836,-288.75006103515625,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4470.28369140625,81.47233581542969,-288.7452392578125,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4468.7490234375,73.50336456298828,-287.45953369140625,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4468.7490234375,75.49517059326172,-287.45953369140625,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4468.7529296875,77.48844146728516,-287.4565734863281,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4468.75,79.4795150756836,-287.46429443359375,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4468.75146484375,81.47233581542969,-287.4595031738281,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4467.216796875,73.50336456298828,-286.1739501953125,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4467.216796875,75.49517059326172,-286.1739501953125,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4467.220703125,77.48844146728516,-286.1709899902344,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4467.2177734375,79.4795150756836,-286.1785583496094,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4467.21875,81.47233581542969,-286.1739501953125,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.7509765625,83.51990509033203,-476.5061950683594,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.7490234375,85.52102661132812,-476.5072021484375,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.751953125,97.49401092529297,-476.4994812011719,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.7509765625,87.52116394042969,-476.5061950683594,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.7509765625,89.51415252685547,-476.5061950683594,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.74609375,91.5075912475586,-476.5086669921875,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.75537109375,93.49984741210938,-476.5052795410156,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4616.75,95.49287414550781,-476.5068054199219,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90185546875,88.50361633300781,-409.97509765625,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90185546875,86.50361633300781,-409.97509765625,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.9013671875,74.52647399902344,-409.9773864746094,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90185546875,76.52647399902344,-409.97705078125,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90234375,78.52647399902344,-409.9770812988281,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.89794921875,80.51973724365234,-409.97357177734375,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90673828125,82.51081848144531,-409.9751892089844,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4567.90185546875,84.50363159179688,-409.97509765625,-0.8660074472427368,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,-0.8660074472427368),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.8232421875,75.70748901367188,-394.78509521484375,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.83251953125,77.70740509033203,-394.7704162597656,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.8408203125,79.70733642578125,-394.7557373046875,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.85302734375,81.70049285888672,-394.7375793457031,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.85986328125,83.69155883789062,-394.730712890625,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4519.86865234375,85.68427276611328,-394.7112731933594,0.5000182390213013,-0.004271174315363169,0.8660043478012085,0.008587077260017395,0.999963104724884,-0.000026187393814325333,-0.8659722805023193,0.00744954077526927,0.5000364780426025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14697265625,94.7187728881836,-432.5180969238281,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14306640625,96.71989440917969,-432.5191650390625,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.150390625,108.69287872314453,-432.51226806640625,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14697265625,98.72003173828125,-432.5180969238281,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14697265625,100.71302032470703,-432.5180969238281,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.1416015625,102.70645904541016,-432.5206298828125,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14892578125,104.69871520996094,-432.51678466796875,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4642.14306640625,106.69174194335938,-432.51806640625,-0.8660522699356079,0,0.49995413422584534,0,1,0,-0.49995413422584534,0,-0.8660522699356079),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.98095703125,95.51876831054688,-422.3702087402344,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.98193359375,97.51988983154297,-422.3741149902344,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.9755859375,109.49287414550781,-422.366943359375,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.98095703125,99.52002716064453,-422.3702087402344,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.98095703125,101.51301574707031,-422.3702087402344,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.9833984375,103.50645446777344,-422.3756103515625,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.9794921875,105.49871063232422,-422.36834716796875,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4655.98095703125,107.49173736572266,-422.3740539550781,-0.49995946884155273,0,-0.8660488128662109,0,1,0,0.8660488128662109,0,-0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,83.51990509033203,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.24951171875,85.52102661132812,-435.80413818359375,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.251953125,97.49401092529297,-435.7961730957031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,87.52116394042969,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,89.51415252685547,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.24609375,91.5075912475586,-435.8054504394531,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.25537109375,93.49984741210938,-435.80206298828125,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.25,95.49287414550781,-435.8034973144531,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.03271484375,111.79646301269531,-602.4319458007812,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.03369140625,95.81636047363281,-602.423583984375,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.0419921875,97.82008361816406,-602.4266357421875,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.03271484375,109.79646301269531,-602.4319458007812,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.02490234375,99.82026672363281,-602.4201049804688,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.03466796875,101.81373596191406,-602.421142578125,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.0595703125,103.80970764160156,-602.4265747070312,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.033203125,105.80000305175781,-602.424560546875,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4464.02294921875,107.79310607910156,-602.4158325195312,0.865559995174408,-0,-0.5008052587509155,0,1,-0,0.5008052587509155,0,0.865559995174408),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,83.51990509033203,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.24951171875,85.52102661132812,-435.80413818359375,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.251953125,97.49401092529297,-435.7961730957031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,87.52116394042969,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.2509765625,89.51415252685547,-435.8030090332031,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.24609375,91.5075912475586,-435.8054504394531,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.25537109375,93.49984741210938,-435.80206298828125,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4640.25,95.49287414550781,-435.8034973144531,-0.8660969734191895,0,0.4998767077922821,0,1,0,-0.4998767077922821,0,-0.8660969734191895),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.10986328125,84.51808166503906,-528.9690551757812,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.10888671875,86.5191879272461,-528.9677734375,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.11669921875,98.4920654296875,-528.9699096679688,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.10986328125,88.5193099975586,-528.9690551757812,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.10986328125,90.51228332519531,-528.9690551757812,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.10791015625,92.50569152832031,-528.9645385742188,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.111328125,94.49793243408203,-528.9733276367188,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4632.109375,96.4909439086914,-528.9679565429688,0.49987316131591797,0,0.8660986423492432,0,1,0,-0.8660986423492432,0,0.49987316131591797),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.2431640625,86.7843246459961,-364.7330627441406,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.2412109375,76.81535339355469,-364.732421875,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.2412109375,78.80715942382812,-364.732421875,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.24560546875,80.80043029785156,-364.7311706542969,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.24072265625,82.79150390625,-364.7372741699219,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4546.2431640625,84.7843246459961,-364.7330627441406,0.8660072684288025,0,0.5000314116477966,0,1,0,-0.5000314116477966,0,0.8660072684288025),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4502.6220703125,76.11430358886719,-359.9189758300781,0.49995946884155273,0,0.8660488128662109,0,1,0,-0.8660488128662109,0,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4502.62548828125,78.10757446289062,-359.9155578613281,0.49995946884155273,0,0.8660488128662109,0,1,0,-0.8660488128662109,0,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4502.6240234375,80.09864807128906,-359.9234619140625,0.49995946884155273,0,0.8660488128662109,0,1,0,-0.8660488128662109,0,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4502.6240234375,82.09146881103516,-359.91864013671875,0.49995946884155273,0,0.8660488128662109,0,1,0,-0.8660488128662109,0,0.49995946884155273),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.56396484375,75.82141876220703,-269.01519775390625,-0.5735992193222046,0,-0.8191365599632263,0,1,0,0.8191365599632263,0,-0.5735992193222046),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.564453125,77.81348419189453,-269.0161437988281,-0.5735992193222046,0,-0.8191365599632263,0,1,0,0.8191365599632263,0,-0.5735992193222046),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.560546875,79.80686950683594,-269.0185852050781,-0.5735992193222046,0,-0.8191365599632263,0,1,0,0.8191365599632263,0,-0.5735992193222046),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.56298828125,81.79843139648438,-269.0111083984375,-0.5735992193222046,0,-0.8191365599632263,0,1,0,0.8191365599632263,0,-0.5735992193222046),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.5625,83.79146575927734,-269.01617431640625,-0.5735992193222046,0,-0.8191365599632263,0,1,0,0.8191365599632263,0,-0.5735992193222046),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4465.6845703125,73.50336456298828,-284.88836669921875,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4465.6845703125,75.49517059326172,-284.88836669921875,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4465.6884765625,77.48844146728516,-284.8855895996094,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4465.685546875,79.4795150756836,-284.89312744140625,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4465.6865234375,81.47233581542969,-284.88836669921875,0.6427633166313171,0,0.7660649418830872,0,1,0,-0.7660649418830872,0,0.6427633166313171),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.90966796875,132.7266845703125,-528.2367553710938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.9091796875,134.7222900390625,-528.2230224609375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.9091796875,136.716796875,-528.2343139648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.90673828125,138.7111358642578,-528.2215576171875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.908203125,150.68338012695312,-528.2205810546875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.9091796875,148.68850708007812,-528.2235717773438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.9091796875,146.69290161132812,-528.2347412109375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.90234375,144.6975860595703,-528.2289428710938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.90576171875,140.7073211669922,-528.2597045898438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4316.90380859375,142.7017059326172,-528.2493896484375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.30908203125,132.7262420654297,-520.243896484375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.32275390625,134.72183227539062,-520.2431030273438,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.3115234375,136.7163543701172,-520.2432861328125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.32421875,138.710693359375,-520.2413330078125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.3251953125,150.6829376220703,-520.2423095703125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.322265625,148.6880645751953,-520.2432861328125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.31103515625,146.6924591064453,-520.2434692382812,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.31689453125,144.6971435546875,-520.2366333007812,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.2861328125,140.70689392089844,-520.239990234375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4314.29638671875,142.70127868652344,-520.23828125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,128.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,130.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,132.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,134.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,136.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,148.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50439453125,146.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,144.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,142.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,138.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,140.89132690429688,-263.89892578125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,160.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50439453125,158.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,156.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,154.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,150.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,152.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50537109375,172.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,170.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,168.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,166.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,162.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,164.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50537109375,188.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50537109375,186.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.50537109375,184.89132690429688,-263.89990234375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,182.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,180.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,178.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,174.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4592.5048828125,176.89132690429688,-263.900390625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,128.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,130.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,132.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,134.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,136.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,148.89132690429688,-159.39991760253906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.50439453125,146.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,144.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,142.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,138.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,140.89132690429688,-159.39894104003906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,160.89132690429688,-159.39991760253906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.50439453125,158.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,156.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,154.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,150.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,152.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.50537109375,172.89132690429688,-159.39991760253906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,170.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,168.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,166.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,162.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,164.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.50537109375,184.89132690429688,-159.39991760253906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,182.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,180.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,178.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,174.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4593.5048828125,176.89132690429688,-159.40040588378906,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,180.19134521484375,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,182.19131469726562,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,136.19151306152344,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,178.19140625,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,134.19151306152344,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,170.19137573242188,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,172.19134521484375,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,176.19125366210938,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,168.19143676757812,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,174.1912841796875,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,160.19143676757812,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,162.19139099121094,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,166.19129943847656,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,158.1914825439453,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,164.1913299560547,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,150.19146728515625,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,152.19143676757812,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,156.19134521484375,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,148.19154357910156,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,154.19137573242188,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,138.19151306152344,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,140.19151306152344,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,142.19146728515625,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,144.19143676757812,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4675.6044921875,146.19139099121094,-225.4000244140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,134.19151306152344,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,136.19151306152344,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,138.19151306152344,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,180.19134521484375,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,182.19131469726562,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,186.19122314453125,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,178.19140625,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,184.19125366210938,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,170.19137573242188,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,172.19134521484375,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,176.19125366210938,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,168.19143676757812,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,174.1912841796875,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,160.19143676757812,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,162.19139099121094,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,166.19129943847656,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,158.1914825439453,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,164.1913299560547,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,150.19146728515625,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,152.19143676757812,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,156.19134521484375,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,148.1915283203125,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,154.19137573242188,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,188.19122314453125,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,140.19151306152344,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,142.19146728515625,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,144.19143676757812,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4622.6044921875,146.19139099121094,-261.3000183105469,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,169.8919219970703,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,171.8918914794922,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,175.8917999267578,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,167.89198303222656,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,173.89183044433594,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,159.89195251464844,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,161.8919219970703,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,165.89183044433594,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,157.8920135498047,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,163.89186096191406,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,149.8920135498047,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,151.8919677734375,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,155.89187622070312,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,147.89205932617188,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,153.89190673828125,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,139.8920440673828,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,141.8920135498047,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,145.8919219970703,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,137.89210510253906,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,143.89195251464844,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,177.8917999267578,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,129.89208984375,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,131.8920440673828,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,133.8920135498047,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4424.14599609375,135.8919677734375,-392.59503173828125,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.083984375,146.796875,-603.7406005859375,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0693359375,166.79075622558594,-603.7431640625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0791015625,168.790283203125,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08349609375,172.7888641357422,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08203125,164.79165649414062,-603.7411499023438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08349609375,170.78936767578125,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.07177734375,156.79425048828125,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.083984375,158.79339599609375,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08349609375,162.79197692871094,-603.7411499023438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0703125,154.7947540283203,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.083984375,160.79286193847656,-603.7426147460938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08251953125,180.78627014160156,-603.7416381835938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.083984375,148.796875,-603.7406616210938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08447265625,152.7954559326172,-603.7421875,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.08349609375,174.78817749023438,-603.74267578125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.083984375,150.7959747314453,-603.7406616210938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.06884765625,186.7840576171875,-603.7431640625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0830078125,184.78492736816406,-603.74267578125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.06884765625,176.7876434326172,-603.7416381835938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0703125,178.78675842285156,-603.7416381835938,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4421.0830078125,182.785400390625,-603.74267578125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,181.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,183.2417449951172,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,185.24168395996094,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,187.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,189.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,177.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,169.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,171.24179077148438,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,175.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,167.24188232421875,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,173.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,159.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,161.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,165.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,157.24191284179688,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,163.24176025390625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,149.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,151.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,155.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,147.24195861816406,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,153.24180603027344,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,139.241943359375,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,141.24191284179688,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,145.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,137.24200439453125,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,143.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,179.24183654785156,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,129.2419891357422,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,131.241943359375,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,133.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4231.68798828125,135.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,181.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,183.2417449951172,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,185.24168395996094,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,187.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,189.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,177.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,169.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,171.24179077148438,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,175.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,167.24188232421875,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,173.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,159.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,161.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,165.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,157.24191284179688,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,163.24176025390625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,149.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,151.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,155.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,147.24195861816406,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,153.24180603027344,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,139.241943359375,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,141.24191284179688,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,145.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,137.24200439453125,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,143.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,179.24183654785156,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,129.2419891357422,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,131.241943359375,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,133.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4263.68798828125,135.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,181.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,183.2417449951172,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,185.24168395996094,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,187.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,189.2416534423828,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,177.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,169.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,171.24179077148438,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,175.24169921875,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,167.24188232421875,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,173.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,159.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,161.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,165.24172973632812,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,157.24191284179688,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,163.24176025390625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,149.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,151.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,155.2417755126953,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,147.24195861816406,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,153.24180603027344,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,139.241943359375,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,141.24191284179688,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,145.2418212890625,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,137.24200439453125,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,143.24185180664062,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,179.24183654785156,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,129.2419891357422,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,131.241943359375,-388.0549011230469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,133.2418975830078,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4287.68798828125,135.2418670654297,-388.054931640625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,181.2417755126953,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,183.2417449951172,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,185.24168395996094,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,187.2416534423828,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,189.2416534423828,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,177.24169921875,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,169.2418212890625,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,171.24179077148438,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,175.24169921875,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,167.24188232421875,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,173.24172973632812,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,159.24185180664062,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,161.2418212890625,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,165.24172973632812,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,157.24191284179688,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,163.24176025390625,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,149.2418975830078,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,151.2418670654297,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,155.2417755126953,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,147.24195861816406,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,153.24180603027344,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,139.241943359375,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,141.24191284179688,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,145.2418212890625,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,137.24200439453125,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,143.24185180664062,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,179.24183654785156,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,129.2419891357422,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,131.241943359375,-427.95489501953125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,133.2418975830078,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4270.68798828125,135.2418670654297,-427.9549255371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60546875,136.89132690429688,-132.39939880371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.6044921875,148.89132690429688,-132.3996124267578,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,146.89132690429688,-132.39915466308594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60546875,144.89132690429688,-132.3992156982422,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60546875,142.89132690429688,-132.39927673339844,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60546875,138.89132690429688,-132.39939880371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60546875,140.89132690429688,-132.3993377685547,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.6044921875,160.89132690429688,-132.3996124267578,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,158.89132690429688,-132.39915466308594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,156.89132690429688,-132.3992156982422,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,154.89132690429688,-132.39927673339844,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,150.89132690429688,-132.39939880371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,152.89132690429688,-132.3993377685547,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.6044921875,172.89132690429688,-132.3997039794922,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,170.89132690429688,-132.3992462158203,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,168.89132690429688,-132.39927673339844,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,166.89132690429688,-132.3993377685547,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,162.89132690429688,-132.39942932128906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,164.89132690429688,-132.39939880371094,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.6044921875,184.89132690429688,-132.3997039794922,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,182.89132690429688,-132.3992462158203,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,180.89132690429688,-132.39930725097656,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,178.89132690429688,-132.3993682861328,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,174.89132690429688,-132.3994903564453,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4594.60400390625,176.89132690429688,-132.39942932128906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,147.40744018554688,-590.348388671875,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,149.40744018554688,-590.3484497070312,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,151.40744018554688,-590.3485107421875,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.0859375,171.4013214111328,-590.35107421875,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.095703125,173.40084838867188,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.10009765625,177.39942932128906,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.0986328125,169.4022216796875,-590.3490600585938,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.10009765625,175.39993286132812,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.08837890625,161.40481567382812,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,163.40396118164062,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.10009765625,167.4025421142578,-590.3490600585938,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.0869140625,159.4053192138672,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,165.40342712402344,-590.3505249023438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.09912109375,185.39683532714844,-590.3495483398438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,153.40744018554688,-590.3485717773438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.10107421875,157.40602111816406,-590.35009765625,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.10009765625,179.39874267578125,-590.3505859375,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.1005859375,155.4065399169922,-590.3485717773438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.08544921875,191.39462280273438,-590.35107421875,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.099609375,189.39549255371094,-590.3505859375,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.08544921875,181.39820861816406,-590.3495483398438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.0869140625,183.39732360839844,-590.3495483398438,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4453.099609375,187.39596557617188,-590.3505859375,-1.1920928955078125e-07,0.00006103888881625608,1.0000001192092896,-0.00006103888881625608,1,-0.00006103888881625608,-1.0000001192092896,-0.00006103888881625608,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,128.79405212402344,-569.8397827148438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,130.79405212402344,-569.8397827148438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,132.79405212402344,-569.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.775390625,186.7767333984375,-569.8373413085938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77587890625,184.77760314941406,-569.8508911132812,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,176.7803192138672,-569.8372192382812,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,178.77943420410156,-569.8388061523438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77587890625,182.778076171875,-569.8510131835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,174.78085327148438,-569.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,180.77894592285156,-569.8504028320312,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.775390625,166.78343200683594,-569.8378295898438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,168.782958984375,-569.8471069335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,172.7815399169922,-569.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,164.78433227539062,-569.8500366210938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,170.78204345703125,-569.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,156.78692626953125,-569.8402709960938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,158.78607177734375,-569.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,162.78465270996094,-569.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,154.7874298095703,-569.8386840820312,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,160.78553771972656,-569.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,146.79005432128906,-569.8479614257812,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,148.78955078125,-569.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,152.7881317138672,-569.8524780273438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,144.79095458984375,-569.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,150.7886505126953,-569.8518676757812,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,134.79405212402344,-569.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,136.7935333251953,-569.8524780273438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,138.7926483154297,-569.8523559570312,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,140.7921142578125,-569.8529663085938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,142.79124450683594,-569.8528442382812,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77880859375,128.79458618164062,-581.8397827148438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,130.79458618164062,-581.8397827148438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,132.79458618164062,-581.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77587890625,186.7772674560547,-581.8373413085938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,184.77813720703125,-581.8509521484375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,176.78085327148438,-581.8372802734375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,178.77996826171875,-581.8388061523438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7763671875,182.7786102294922,-581.8510131835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,174.78138732910156,-581.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,180.77947998046875,-581.8504638671875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77587890625,166.78396606445312,-581.8378295898438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,168.7834930419922,-581.8471069335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,172.78207397460938,-581.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,164.7848663330078,-581.8500366210938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,170.78257751464844,-581.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,156.78746032714844,-581.8402709960938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,158.78660583496094,-581.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,162.78518676757812,-581.8515014648438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,154.7879638671875,-581.8387451171875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,160.78607177734375,-581.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,146.79058837890625,-581.8480224609375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,148.7900848388672,-581.8519897460938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77685546875,152.78866577148438,-581.8524780273438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,144.79148864746094,-581.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.7783203125,150.7891845703125,-581.8519287109375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77880859375,134.79458618164062,-581.8392944335938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77880859375,136.7940673828125,-581.8524780273438,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77734375,138.79318237304688,-581.8524169921875,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,140.7926483154297,-581.8529663085938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4253.77783203125,142.79177856445312,-581.8529052734375,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.783203125,128.79647827148438,-602.8470458984375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.783203125,130.79647827148438,-602.8469848632812,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.783203125,132.79647827148438,-602.846923828125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.78515625,186.77915954589844,-602.8441162109375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77197265625,184.780029296875,-602.8446044921875,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.78515625,176.78273010253906,-602.8453979492188,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.78369140625,178.7818603515625,-602.8453979492188,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77197265625,182.78050231933594,-602.8445434570312,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.771484375,174.7832794189453,-602.8458251953125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.7724609375,180.7813720703125,-602.8456420898438,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.78466796875,166.78585815429688,-602.8442993164062,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77587890625,168.78538513183594,-602.8449096679688,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.771484375,172.78396606445312,-602.844970703125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77294921875,164.78675842285156,-602.8457641601562,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.771484375,170.7844696044922,-602.8449096679688,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.7822265625,156.7893524169922,-602.8452758789062,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77099609375,158.7884979248047,-602.8452758789062,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.771484375,162.78707885742188,-602.84619140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.78369140625,154.78985595703125,-602.84521484375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77099609375,160.7879638671875,-602.84619140625,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77490234375,146.79248046875,-602.8464965820312,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77099609375,148.79197692871094,-602.8465576171875,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.7705078125,152.79055786132812,-602.8451538085938,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.783203125,144.7933807373047,-602.8456420898438,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77099609375,150.79107666015625,-602.8465576171875,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.783203125,134.79647827148438,-602.8468627929688,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.7705078125,136.79595947265625,-602.846923828125,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.7705078125,138.79507446289062,-602.845458984375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77001953125,140.79454040527344,-602.8460693359375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4232.77001953125,142.79367065429688,-602.8460693359375,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,181.49122619628906,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,179.49122619628906,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,171.49134826660156,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,173.49131774902344,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,177.49122619628906,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,169.4914093017578,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,175.4912567138672,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,161.4913787841797,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,163.49134826660156,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,167.4912567138672,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,159.49143981933594,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,165.4912872314453,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,151.49142456054688,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,153.49139404296875,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,157.49130249023438,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,149.49148559570312,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,155.49134826660156,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,141.49147033691406,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,143.49143981933594,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,147.49134826660156,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,139.4915313720703,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,145.4913787841797,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,129.49156188964844,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,131.49151611328125,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,133.49147033691406,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,135.49142456054688,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,137.49139404296875,-427.5950622558594,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,181.49122619628906,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,179.49122619628906,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,171.49134826660156,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,173.49131774902344,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,177.49122619628906,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,169.4914093017578,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,175.4912567138672,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,161.4913787841797,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,163.49134826660156,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,167.4912567138672,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,159.49143981933594,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,165.4912872314453,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,151.49142456054688,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,153.49139404296875,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,157.49130249023438,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,149.49148559570312,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,155.49134826660156,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,141.49147033691406,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,143.49143981933594,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,147.49134826660156,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,139.4915313720703,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,145.4913787841797,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,129.49156188964844,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,131.49151611328125,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,133.49147033691406,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,135.49142456054688,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4457.7490234375,137.49139404296875,-419.3950500488281,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,178.79122924804688,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,170.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,172.79132080078125,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,176.79122924804688,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,168.79141235351562,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,174.791259765625,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,160.7913818359375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,162.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,166.791259765625,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,158.79144287109375,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,164.79129028320312,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,150.7914276123047,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,152.79139709472656,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,156.7913055419922,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,148.79148864746094,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,154.7913360595703,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,140.79147338867188,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,142.79144287109375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,146.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,138.79153442382812,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,144.7913818359375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,128.79156494140625,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,130.79151916503906,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,132.79147338867188,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,134.7914276123047,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4440.7490234375,136.79139709472656,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,185.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,183.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,181.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,179.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,177.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,169.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,171.1916046142578,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,175.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,167.1916961669922,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,173.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,159.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,161.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,165.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,157.1917266845703,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,163.1915740966797,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,149.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,151.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,155.19158935546875,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,147.1917724609375,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,153.19161987304688,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,139.19175720214844,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,141.1917266845703,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,145.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,137.1918182373047,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,143.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,187.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,129.19180297851562,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,131.19175720214844,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,133.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4499.103515625,135.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,185.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,183.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,181.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,179.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,177.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,169.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,171.1916046142578,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,175.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,167.1916961669922,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,173.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,159.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,161.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,165.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,157.1917266845703,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,163.1915740966797,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,149.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,151.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,155.19158935546875,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,147.1917724609375,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,153.19161987304688,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,139.19175720214844,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,141.1917266845703,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,145.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,137.1918182373047,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,143.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,187.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,129.19180297851562,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,131.19175720214844,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,133.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4488.103515625,135.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,185.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,183.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,181.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,179.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,177.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,169.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,171.1916046142578,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,175.19151306152344,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,167.1916961669922,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,173.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,159.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,161.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,165.19154357910156,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,157.1917266845703,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,163.1915740966797,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,149.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,151.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,155.19158935546875,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,147.1917724609375,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,153.19161987304688,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,139.19175720214844,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,141.1917266845703,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,145.19163513183594,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,137.1918182373047,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,143.19166564941406,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,187.19149780273438,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,129.19180297851562,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,131.19175720214844,-389.6002197265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,133.19171142578125,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4512.103515625,135.19168090820312,-389.6002502441406,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4713.99609375,198.50624084472656,-166.80059814453125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4713.99609375,200.5042266845703,-166.80059814453125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4713.99609375,202.50318908691406,-166.80059814453125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4713.99609375,204.50120544433594,-166.80059814453125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4713.99609375,206.50013732910156,-166.80059814453125,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,178.79122924804688,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,170.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,172.79132080078125,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,176.79122924804688,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,168.79141235351562,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,174.791259765625,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,160.7913818359375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,162.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,166.791259765625,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,158.79144287109375,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,164.79129028320312,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,150.7914276123047,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,152.79139709472656,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,156.7913055419922,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,148.79148864746094,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,154.7913360595703,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,140.79147338867188,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,142.79144287109375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,146.79135131835938,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,138.79153442382812,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,144.7913818359375,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,128.79156494140625,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,130.79151916503906,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,132.79147338867188,-397.59503173828125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,134.7914276123047,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4433.7490234375,136.79139709472656,-397.5950622558594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4857.2626953125,180.8602752685547,45.383697509765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4857.2626953125,182.8602294921875,45.383697509765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4857.2626953125,184.8601837158203,45.383697509765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4857.2626953125,186.86013793945312,45.383697509765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4857.2626953125,188.860107421875,45.383697509765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4862.86328125,180.7602081298828,37.28497314453125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4862.86328125,182.7602081298828,37.28497314453125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4862.86328125,184.76016235351562,37.28497314453125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4862.86328125,186.76016235351562,37.28497314453125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4862.86328125,188.76016235351562,37.28497314453125,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,167.0441131591797,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,169.04307556152344,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,171.0410919189453,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,173.04002380371094,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,175.04612731933594,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,177.0441131591797,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,179.04307556152344,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,181.0410919189453,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,183.04002380371094,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,187.0441131591797,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,185.04612731933594,-575.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,134.44760131835938,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,136.44757080078125,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,140.44747924804688,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,132.4476776123047,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,138.447509765625,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,148.44747924804688,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,130.44754028320312,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,142.4476318359375,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,128.44757080078125,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,162.4473876953125,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,156.447509765625,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,150.44744873046875,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,160.44741821289062,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,146.44754028320312,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,154.4475860595703,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,144.44757080078125,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,152.44744873046875,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,158.44747924804688,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,164.4473876953125,-415.89849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,134.44760131835938,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,136.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,140.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,132.4476776123047,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,138.447509765625,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,148.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,130.44754028320312,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,142.4476318359375,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,128.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,162.4473876953125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,156.447509765625,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,150.44744873046875,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,160.44741821289062,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,146.44754028320312,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,154.4475860595703,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,144.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,152.44744873046875,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,158.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4146.80029296875,164.4473876953125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,167.0441131591797,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,169.04307556152344,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,171.0410919189453,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,173.04002380371094,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,175.04612731933594,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,177.0441131591797,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,179.04307556152344,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,181.0410919189453,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,183.04002380371094,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,187.0441131591797,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4493.9052734375,185.04612731933594,-581.3485717773438,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,134.44760131835938,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,136.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,140.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,132.4476776123047,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,138.447509765625,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,148.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,130.44754028320312,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,142.4476318359375,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,128.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,162.4473876953125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,156.447509765625,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,150.44744873046875,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,160.44741821289062,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,146.44754028320312,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,154.4475860595703,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,144.44757080078125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,152.44744873046875,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,158.44747924804688,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4186.60009765625,164.4473876953125,-436.39849853515625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,143.258544921875,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,145.25851440429688,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,149.2584228515625,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,141.25860595703125,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,147.25845336914062,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,133.25860595703125,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,135.25856018066406,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,139.2584686279297,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,131.25865173339844,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,137.2584991455078,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,129.25851440429688,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,157.2584228515625,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,127.258544921875,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,161.25839233398438,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,153.25851440429688,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,155.25848388671875,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,159.25839233398438,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4758.99609375,151.25857543945312,-373.6158447265625,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4439.49560546875,195.0061492919922,-569.5497436523438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4439.49560546875,197.00413513183594,-569.5497436523438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4439.49560546875,199.0030975341797,-569.5497436523438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4439.49560546875,201.00111389160156,-569.5497436523438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4439.49560546875,203.0000457763672,-569.5497436523438,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4444.7490234375,180.7940673828125,-393.99615478515625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4444.7490234375,182.79205322265625,-393.99615478515625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4444.7490234375,184.791015625,-393.99615478515625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4444.7490234375,186.78903198242188,-393.99615478515625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4444.7490234375,188.7879638671875,-393.99615478515625,0,0,1,0,1,-0,-1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4449.54833984375,180.79165649414062,-379.3994140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4449.54833984375,182.7915496826172,-379.3994140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4449.54833984375,184.79147338867188,-379.3994140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4449.54833984375,186.79136657714844,-379.3994140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4449.54833984375,188.79127502441406,-379.3994140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4718.69482421875,198.4002227783203,-154.10009765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4718.69482421875,200.40020751953125,-154.10009765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4718.69482421875,202.40016174316406,-154.10009765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4718.69482421875,204.40016174316406,-154.10009765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4718.69482421875,206.400146484375,-154.10009765625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.6943359375,198.4001922607422,-164.60009765625,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.6943359375,200.4001922607422,-164.60009765625,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.6943359375,202.40016174316406,-164.60009765625,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.6943359375,204.40016174316406,-164.60009765625,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4725.6943359375,206.40016174316406,-164.60009765625,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4696.40087890625,188.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4696.40087890625,190.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4696.40087890625,192.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4696.40087890625,194.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4696.40087890625,196.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4698.40087890625,188.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4698.40087890625,190.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4698.40087890625,192.09732055664062,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4698.40087890625,194.09732055664062,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4698.40087890625,196.09732055664062,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4700.40087890625,188.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4700.40087890625,190.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4700.40087890625,192.09730529785156,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4700.40087890625,194.09730529785156,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4700.40087890625,196.09730529785156,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4702.40087890625,188.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4702.40087890625,190.0973358154297,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4702.40087890625,192.0972900390625,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4702.40087890625,194.0972900390625,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4702.40087890625,196.0972900390625,-200.80003356933594,-1.1920928955078125e-07,0,-1.0000001192092896,0,1,0,1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-190.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-190.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-190.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-190.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-190.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-188.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-188.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-188.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-188.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-188.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-186.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-186.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-186.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-186.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-186.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-184.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-184.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-184.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-184.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-184.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-182.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-182.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-182.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-182.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-182.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-178.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-178.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-178.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-178.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-178.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-180.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-180.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-180.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-180.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-180.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-176.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-176.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-176.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-176.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-176.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-174.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-174.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-174.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-174.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-174.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-172.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-172.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-172.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-172.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-172.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-170.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-170.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-170.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-170.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-170.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-168.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-168.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-168.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-168.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-168.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-166.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-166.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-166.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-166.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-166.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-164.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-164.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-164.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-164.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-164.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-162.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-162.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-162.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-162.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-162.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-158.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-158.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-158.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-158.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-158.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-160.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-160.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-160.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-160.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-160.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-156.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-156.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-156.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-156.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-156.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-154.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-154.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-154.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-154.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-154.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-152.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-152.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-152.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-152.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-152.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-150.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-150.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-150.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-150.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-150.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-148.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-148.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-148.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-148.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-148.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-146.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-146.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-146.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-146.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-146.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-144.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-144.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-144.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-144.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-144.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-142.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-142.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-142.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-142.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-142.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-140.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-140.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69979858398438,-140.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69979858398438,-140.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69979858398438,-140.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-138.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-138.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.6997833251953,-138.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.6997833251953,-138.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.6997833251953,-138.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,187.69981384277344,-136.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,189.69981384277344,-136.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,191.69976806640625,-136.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,193.69976806640625,-136.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4692.10009765625,195.69976806640625,-136.6000213623047,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,164.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,162.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,134.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,136.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,148.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,146.691162109375,-186.8996124267578,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,144.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,142.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,138.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,140.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.20361328125,160.691162109375,-186.9005889892578,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,158.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,156.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,154.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,150.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4479.203125,152.691162109375,-186.9001007080078,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.82080078125,145.49179077148438,-353.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,143.49179077148438,-353.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8212890625,141.49179077148438,-353.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8212890625,139.49179077148438,-353.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8212890625,135.49179077148438,-353.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8212890625,137.49179077148438,-353.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.82080078125,157.49179077148438,-353.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,155.49179077148438,-353.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,153.49179077148438,-353.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,151.49179077148438,-353.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,147.49179077148438,-353.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,149.49179077148438,-353.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.82080078125,169.49179077148438,-353.20953369140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,167.49179077148438,-353.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,165.49179077148438,-353.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,163.49179077148438,-353.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,159.49179077148438,-353.20928955078125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,161.49179077148438,-353.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.82080078125,181.49179077148438,-353.20953369140625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,179.49179077148438,-353.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,177.49179077148438,-353.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,175.49179077148438,-353.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,171.49179077148438,-353.2093200683594,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4167.8203125,173.49179077148438,-353.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,164.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,162.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,134.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,136.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,148.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.1025390625,146.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,144.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,142.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,138.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,140.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.103515625,160.8911590576172,-214.49996948242188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,158.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,156.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,154.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,150.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4473.10302734375,152.8911590576172,-214.50045776367188,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,148.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,146.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,144.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,142.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,138.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,140.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,136.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4756.50341796875,134.49978637695312,-155.37728881835938,1,0,0,0,1,0,0,0,1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,145.49176025390625,-257.2094421386719,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,143.49176025390625,-257.208984375,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,141.49176025390625,-257.20904541015625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,139.49176025390625,-257.2091064453125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,135.49176025390625,-257.209228515625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,137.49176025390625,-257.20916748046875,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,157.49176025390625,-257.2094421386719,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,155.49176025390625,-257.208984375,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,153.49176025390625,-257.20904541015625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,151.49176025390625,-257.2091064453125,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,147.49176025390625,-257.209228515625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,149.49176025390625,-257.20916748046875,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,169.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,167.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,165.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,163.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,159.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,161.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.12060546875,181.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,179.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,177.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,175.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,171.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4170.1201171875,173.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,143.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,141.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,139.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,137.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,135.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,143.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,141.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,139.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,137.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,135.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,143.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,141.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,139.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,137.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,135.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,143.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,141.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,139.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,137.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,135.49176025390625,-256.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,143.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,141.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,139.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,137.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,133.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4284.419921875,135.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,143.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,141.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,139.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,137.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4260.419921875,135.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,143.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,141.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,139.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,137.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4236.419921875,135.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,143.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,141.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,139.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,137.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4212.419921875,135.49176025390625,-354.2090148925781,0,0,-1,0,1,0,1,0,0),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,181.49176025390625,-268.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,179.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,177.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,175.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,171.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,173.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,169.49176025390625,-268.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,167.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,165.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,163.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,159.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,161.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,157.49176025390625,-268.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,155.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,153.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,151.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,147.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,149.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,145.49176025390625,-268.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,143.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,141.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,139.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,135.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,137.49176025390625,-268.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,181.49176025390625,-344.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,179.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,177.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,175.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,171.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,173.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,169.49176025390625,-344.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,167.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,165.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,163.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,159.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,161.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,157.49176025390625,-344.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,155.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,153.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,151.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,147.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,149.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,145.49176025390625,-344.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,143.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,141.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,139.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,135.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,137.49176025390625,-344.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,181.49176025390625,-338.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,179.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,177.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,175.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,171.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,173.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,145.49176025390625,-338.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,143.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,141.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,139.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,135.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,137.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,169.49176025390625,-338.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,167.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,165.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,163.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,159.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,161.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,157.49176025390625,-338.1087646484375,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,155.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,153.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,151.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,147.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4161.919921875,149.49176025390625,-338.1092529296875,-1,0,0,0,1,0,0,0,-1),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.12060546875,145.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,143.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,141.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,139.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,135.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,137.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.12060546875,157.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,155.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,153.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,151.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,147.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,149.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.12060546875,169.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,167.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,165.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,163.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,159.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,161.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.12060546875,181.49176025390625,-257.20947265625,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,179.49176025390625,-257.2090148925781,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,177.49176025390625,-257.2090759277344,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,175.49176025390625,-257.2091369628906,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,171.49176025390625,-257.2092590332031,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
  {"TrussWithNoSupports",CFrame.new(-4175.1201171875,173.49176025390625,-257.2091979980469,-1.1920928955078125e-07,0,1.0000001192092896,0,1,0,-1.0000001192092896,0,-1.1920928955078125e-07),Vector3.new(0.60,2.00,2.00),true,BrickColor.new("Lime green"),true},
}

function createTrusses()
    folder = Instance.new("Folder")
    folder.Name = "Trusses"
    folder.Parent = workspace.Terrain
    for _, p in ipairs(data) do
        t = Instance.new("TrussPart")
        t.Name = p[1]
        t.CFrame = p[2]
        t.Size = p[3]
        t.Anchored = p[4]
        t.BrickColor = p[5]
        t.CanCollide = p[6]
        t.Parent = folder
    end
end

InfectionLeft:AddToggle('TrussToggle', {
    Text = 'Zombie Team Ladders',
    Default = false,
    Callback = function(Value)
        if Value then
            createTrusses()
        else
            if workspace.Terrain:FindFirstChild("Trusses") then
                workspace.Terrain.Trusses:Destroy()
            end
        end
    end
})

game.Players.LocalPlayer.CharacterAdded:Connect(function()
    if Toggles.TrussToggle.Value and not workspace.Terrain:FindFirstChild("Trusses") then
        createTrusses()
    end
end)

humanoid = nil

function ResetCharacter()
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end
end

function SetupHumanoid()
    character = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")

    humanoid.HealthChanged:Connect(function()
        if humanoid.Health <= 0 then
            task.wait(0.5)
            SetupHumanoid()
        end
    end)
end

SetupHumanoid()

InfectionLeft:AddButton({
    Text = "Reset Character",
    Func = function()
        ResetCharacter()
    end
})

Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    SetupHumanoid()
end)

FarmLeft = Tabs.Farm:AddLeftGroupbox('With Alt farm')
FarmRight = Tabs.Farm:AddRightGroupbox('Other')

RunService = game:GetService("RunService")
Players = game:GetService("Players")
LocalPlayer = Players.LocalPlayer
DeathRespawn_Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")
ragdoll = game:GetService("ReplicatedStorage"):FindFirstChild("Events"):FindFirstChild("__RZDONL")

TPFarm_Enabled = false
TPFarm_TargetName = "l1nq0r"
TPFarm_SteppedConnection = nil
TPFarm_RenderConnection = nil
TPFarm_CharConnection = nil
TPFarm_RagdollConnection = nil

function TPFarm_OnCharacterAdded(char)
    task.wait(0.4)
    hrp = char:FindFirstChild("HumanoidRootPart")
    hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum) then return end
    
    originalPosition = hrp.CFrame
    
    head = char:FindFirstChild("Head")
    leftArm = char:FindFirstChild("Left Arm")
    rightArm = char:FindFirstChild("Right Arm")
    leftLeg = char:FindFirstChild("Left Leg")
    rightLeg = char:FindFirstChild("Right Leg")
    
    if head then head.CanCollide = false end
    if leftArm then leftArm.CanCollide = false end
    if rightArm then rightArm.CanCollide = false end
    if leftLeg then leftLeg.CanCollide = false end
    if rightLeg then rightLeg.CanCollide = false end
    
    if TPFarm_SteppedConnection then
        TPFarm_SteppedConnection:Disconnect()
        TPFarm_SteppedConnection = nil
    end
    
    if TPFarm_RagdollConnection then
        TPFarm_RagdollConnection:Disconnect()
        TPFarm_RagdollConnection = nil
    end
    
    TPFarm_SteppedConnection = RunService.Stepped:Connect(function()
        if not TPFarm_Enabled then return end
        mainPlayer = Players:FindFirstChild(TPFarm_TargetName)
        if not mainPlayer then return end
        mainChar = mainPlayer.Character
        if not mainChar then return end
        mainHRP = mainChar:FindFirstChild("HumanoidRootPart")
        if not mainHRP then return end
        
        targetCFrame = mainHRP.CFrame * CFrame.new(0, 0, -2)
        if head then head.CFrame = targetCFrame end
        if leftArm then leftArm.CFrame = targetCFrame end
        if rightArm then rightArm.CFrame = targetCFrame end
        if leftLeg then leftLeg.CFrame = targetCFrame end
        if rightLeg then rightLeg.CFrame = targetCFrame end
        
        hrp.CFrame = originalPosition
    end)
    
    if ragdoll then
        TPFarm_RagdollConnection = RunService.Heartbeat:Connect(function()
            if not TPFarm_Enabled or not ragdoll or not hrp then return end
            ragdoll:FireServer("__---r", Vector3.zero, hrp.CFrame)
            task.wait(0.001)
        end)
    end
    
    healthConnection = hum:GetPropertyChangedSignal("Health"):Connect(function()
        if TPFarm_Enabled then
            hum.Health = 0
        end
        if hum.Health <= 0 then
            if healthConnection then
                healthConnection:Disconnect()
                healthConnection = nil
            end
            if TPFarm_SteppedConnection then
                TPFarm_SteppedConnection:Disconnect()
                TPFarm_SteppedConnection = nil
            end
            if TPFarm_RagdollConnection then
                TPFarm_RagdollConnection:Disconnect()
                TPFarm_RagdollConnection = nil
            end
        end
    end)
end

function TPFarm_Enable()
    if TPFarm_Enabled then return end
    TPFarm_Enabled = true
    if LocalPlayer.Character then TPFarm_OnCharacterAdded(LocalPlayer.Character) end
    
    if TPFarm_CharConnection then
        TPFarm_CharConnection:Disconnect()
    end
    TPFarm_CharConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
        if not TPFarm_Enabled then return end
        TPFarm_OnCharacterAdded(newChar)
        tool = LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
        if tool and newChar then tool.Parent = newChar end
    end)
    
    if TPFarm_RenderConnection then
        TPFarm_RenderConnection:Disconnect()
    end
    TPFarm_RenderConnection = RunService.RenderStepped:Connect(function()
        if not TPFarm_Enabled then return end
        char = LocalPlayer.Character
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                DeathRespawn_Event:InvokeServer("KMG4R904")
            end
        end
    end)
end

function TPFarm_Disable()
    if not TPFarm_Enabled then return end
    TPFarm_Enabled = false
    if TPFarm_SteppedConnection then TPFarm_SteppedConnection:Disconnect() TPFarm_SteppedConnection = nil end
    if TPFarm_RenderConnection then TPFarm_RenderConnection:Disconnect() TPFarm_RenderConnection = nil end
    if TPFarm_CharConnection then TPFarm_CharConnection:Disconnect() TPFarm_CharConnection = nil end
    if TPFarm_RagdollConnection then TPFarm_RagdollConnection:Disconnect() TPFarm_RagdollConnection = nil end
    if LocalPlayer.Character then
        head = LocalPlayer.Character:FindFirstChild("Head")
        leftArm = LocalPlayer.Character:FindFirstChild("Left Arm")
        rightArm = LocalPlayer.Character:FindFirstChild("Right Arm")
        leftLeg = LocalPlayer.Character:FindFirstChild("Left Leg")
        rightLeg = LocalPlayer.Character:FindFirstChild("Right Leg")
        if head then head.CanCollide = true end
        if leftArm then leftArm.CanCollide = true end
        if rightArm then rightArm.CanCollide = true end
        if leftLeg then leftLeg.CanCollide = true end
        if rightLeg then rightLeg.CanCollide = true end
    end
end

FarmLeft:AddToggle('TPFarmToggle', {
    Text = "TP Farm",
    Default = false,
    Callback = function(Value)
        if Value then TPFarm_Enable() else TPFarm_Disable() end
    end
})

FarmLeft:AddInput('TPFarmTarget', {
    Text = "Main acc",
    Default = "l1nq0r",
    Placeholder = "Write your main account",
    Callback = function(Value)
        TPFarm_TargetName = Value
    end
})

RunService = game:GetService("RunService")
Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
LocalPlayer = Players.LocalPlayer
DeathRespawn_Event = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")

AutoFarmEnabled = false
AutoClaimAllowanceCoolDown = false
Teleporting = false
ATMUsage = {}

function WaitForCharacter()
    while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
        task.wait(0.1)
    end
    return LocalPlayer.Character, LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

function GetATM()
    character, hrp = WaitForCharacter()
    if not hrp then return nil, math.huge end

    closestATM = nil
    minDistance = math.huge
    for _, v in ipairs(Workspace.Map.ATMz:GetChildren()) do
        mainPart = v:FindFirstChild("MainPart")
        if mainPart then
            usageCount = ATMUsage[mainPart] or 0
            if usageCount < 2 then
                atmDistance = (hrp.Position - mainPart.Position).Magnitude
                if atmDistance < minDistance then
                    minDistance = atmDistance
                    closestATM = mainPart
                end
            end
        end
    end
    return closestATM, minDistance
end

function teleportSmoothly(targetPosition)
    character, hrp = WaitForCharacter()
    if not hrp then return end

    Teleporting = true
    stepSize = 3
    currentPos = hrp.Position
    direction = (targetPosition - currentPos).Unit
    while (targetPosition - currentPos).Magnitude > stepSize and AutoFarmEnabled do
        character, hrp = WaitForCharacter()
        if not hrp then
            Teleporting = false
            return
        end
        hrp.CFrame = CFrame.new(currentPos + direction * stepSize)
        currentPos = currentPos + direction * stepSize
        task.wait(0.1)
    end
    character, hrp = WaitForCharacter()
    if hrp then
        hrp.CFrame = CFrame.new(targetPosition)
    end
    task.wait(0.5)
    Teleporting = false
end

function teleportToNearestATM()
    closestATM, _ = GetATM()
    if closestATM then
        teleportSmoothly(closestATM.Position)
        ATMUsage[closestATM] = (ATMUsage[closestATM] or 0) + 1
    end
end

function AutoFarm()
    while AutoFarmEnabled do
        character, hrp = WaitForCharacter()
        if not hrp then
            task.wait(1)
            continue
        end

        nextAllowance = game:GetService("ReplicatedStorage").PlayerbaseData2[LocalPlayer.Name]:FindFirstChild("NextAllowance")
        if nextAllowance and nextAllowance.Value == 0 and not AutoClaimAllowanceCoolDown then
            ATM, distance = GetATM()
            if ATM then
                AutoClaimAllowanceCoolDown = true
                teleportToNearestATM()
                task.wait(0.5)
                game:GetService("ReplicatedStorage").Events.CLMZALOW:InvokeServer(ATM)
                task.wait(0.5)
                AutoClaimAllowanceCoolDown = false
            end
        end

        task.wait(0.1)
    end
end

function AutoRespawn()
    while AutoFarmEnabled do
        character = LocalPlayer.Character
        if character then
            humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 and not humanoid:GetAttribute("Respawning") then
                humanoid:SetAttribute("Respawning", true)
                DeathRespawn_Event:InvokeServer("KMG4R904")
                task.wait(1)
                if character then
                    humanoid:SetAttribute("Respawning", false)
                end
            end
        end
        task.wait(1)
    end
end

LocalPlayer.CharacterAdded:Connect(function(character)
    hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:SetAttribute("Respawning", false)
    end
    if AutoFarmEnabled then
        spawn(AutoFarm)
        spawn(AutoRespawn)
    end
end)

aatmToggle = FarmRight:AddToggle('AutoFarmToggle', {
    Text = "AutoFarm ATM",
    Default = false,
    Callback = function(Value)
        AutoFarmEnabled = Value
        if AutoFarmEnabled then
            spawn(AutoFarm)
            spawn(AutoRespawn)
        end
    end
})

run = game:GetService("RunService")
me = game.Players.LocalPlayer
_G.LockpickEnabled = false

function lockpick(gui)
    for _, a in pairs(gui:GetDescendants()) do
        if a:IsA("ImageLabel") and a.Name == "Bar" and a.Parent.Name ~= "Attempts" then
            oldsize = a.Size
            run.RenderStepped:Connect(function()
                if _G.LockpickEnabled then
                    a.Size = UDim2.new(0, 280, 0, 280)
                else
                    a.Size = oldsize
                end
            end)
        end
    end
end

me.PlayerGui.ChildAdded:Connect(function(gui)
    if gui:IsA("ScreenGui") and gui.Name == "LockpickGUI" then
        lockpick(gui)
    end
end)

hbeToggle = FarmRight:AddToggle('LockpickToggle', {
    Text = "No Fail Lockpick",
    Default = false,
    Callback = function(Value)
        _G.LockpickEnabled = Value
    end
})

MiscLeft = Tabs.Misc:AddLeftGroupbox('Hiddens')
MiscRight = Tabs.Misc:AddRightGroupbox('Auto\'s')
MiscLeft2 = Tabs.Misc:AddLeftGroupbox('Anti-effect')
MiscLeft3 = Tabs.Misc:AddLeftGroupbox('Teleports')
MiscLeft4 = Tabs.Misc:AddLeftGroupbox('Anti-Aim')
MiscRight2 = Tabs.Misc:AddRightGroupbox('Animations')
MiscRight4 = Tabs.Misc:AddRightGroupbox('ChatBot')
MiscRight3 = Tabs.Misc:AddRightGroupbox('Others')

Players = game:GetService("Players")
Workspace = game:GetService("Workspace")
RunService = game:GetService("RunService")

player = Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoidRootPart = character:WaitForChild("HumanoidRootPart")
humanoid = character:WaitForChild("Humanoid")

enabled = false
animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://282574440"
danceTrack = nil
dysenc = {}
temp = 1
animpos = 1.755
underground = -2.6

function onCharacterAdded(char)
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    character = char
    if Toggles.hiddenbodyToggle and Toggles.hiddenbodyToggle.Value then
        enableSpoofMethod()
    end
end

if player.Character then
    onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)

player.CharacterRemoving:Connect(function()
    if danceTrack then
        pcall(function()
            danceTrack:Stop()
            danceTrack:Destroy()
        end)
        danceTrack = nil
        enabled = false
    end
end)

function enableSpoofMethod()
    enabled = true
    danceTrack = humanoid:LoadAnimation(animation)
    danceTrack.Looped = true
    danceTrack.Priority = Enum.AnimationPriority.Action4
    danceTrack:Play(0.1, 1, 0)
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        temp = temp + 1
        if enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if danceTrack then
                danceTrack.TimePosition = animpos
            end
            hrp = player.Character.HumanoidRootPart
            dysenc[1] = hrp.CFrame
            dysenc[2] = hrp.AssemblyLinearVelocity
            spoofed = hrp.CFrame + Vector3.new(0, underground, 0)
            hrp.CFrame = spoofed
            RunService.RenderStepped:Wait()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = dysenc[1]
                hrp.AssemblyLinearVelocity = dysenc[2]
            end
        end
    end)
end

function disableSpoofMethod()
    enabled = false
    if danceTrack then
        danceTrack:Stop()
        danceTrack:Destroy()
        danceTrack = nil
    end
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

MiscLeft:AddToggle('hiddenbodyToggle', {
    Text = 'Hidden Body',
    Default = false,
    Callback = function(Value)
        if Value then
            enableSpoofMethod()
        else
            disableSpoofMethod()
        end
    end
}):AddKeyPicker('HiddenBodyKey', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Hidden Body',
    Callback = function()
    end
})

humanoid.Died:Connect(function()
    disableSpoofMethod()
end)

GameFramework = GameFramework or {}
GameFramework.HeadGlitch = false
Client = game:GetService("Players").LocalPlayer
Camera = workspace.CurrentCamera

MiscLeft:AddButton({
    Text = 'Hide Head',
    Func = function()
        GameFramework.HeadGlitch = true
        Character = Client.Character
        if Character then
            NeckJoint = Character.HumanoidRootPart.CTs.RGCT_Neck
            Character.Torso.Neck:Destroy()
            Character.Torso.NeckAttachment:Destroy()
            NeckJoint.TwistLowerAngle = 0
            NeckJoint.TwistUpperAngle = 0
            NeckJoint.Restitution = 0
            NeckJoint.UpperAngle = 0
            NeckJoint.MaxFrictionTorque = 0
            Character.Head.HeadCollider:Destroy()
        end
    end
})

Client.CharacterAdded:Connect(function(newCharacter)
    if GameFramework.HeadGlitch then
        GameFramework.HeadGlitch = false
    end
end)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    if GameFramework.HeadGlitch and Client.Character and Client.Character:FindFirstChild("HumanoidRootPart") and Client.Character:FindFirstChild("Head") then
        Character = Client.Character
        Character.Head.CanCollide = false
        Character.Head.CFrame = Client.Character.HumanoidRootPart.CFrame * CFrame.new(0, -4, 0)
    end
end)

MiscLeft:AddButton({
    Text = "Hide Arms",
    Func = function()
        character = game:GetService("Players").LocalPlayer.Character
        if character then
            leftArm = character:FindFirstChild("Left Arm")
            rightArm = character:FindFirstChild("Right Arm")
            if leftArm then leftArm:Destroy() end
            if rightArm then rightArm:Destroy() end
        end
    end
})

MiscLeft:AddButton({
    Text = "Hide Legs",
    Func = function()
        character = game:GetService("Players").LocalPlayer.Character
        if character then
            leftLeg = character:FindFirstChild("Left Leg")
            rightLeg = character:FindFirstChild("Right Leg")
            if leftLeg then leftLeg:Destroy() end
            if rightLeg then rightLeg:Destroy() end
        end
    end
})

function GetSafe(Studs, Type)
    if Type then
        Part = nil
        for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
            if v:FindFirstChild("MainPart") and string.find(v.Name, "Safe") then
                Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
                if Distance < Studs then
                    Studs = Distance
                    Part = v:FindFirstChild("MainPart")
                end
            end
        end
        return Part
    else
        Part = nil
        for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
            if v:FindFirstChild("MainPart") and string.find(v.Name, "Safe") and v:FindFirstChild("Values").Broken.Value == false then
                Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
                if Distance < Studs then
                    Studs = Distance
                    Part = v:FindFirstChild("MainPart")
                end
            end
        end
        return Part
    end
end

function GetRegister(Studs)
    Part = nil
    for _, v in ipairs(game:GetService("Workspace").Map.BredMakurz:GetChildren()) do
        if v:FindFirstChild("MainPart") and string.find(v.Name, "Register") and v:FindFirstChild("Values").Broken.Value == false then
            Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("MainPart").Position).Magnitude
            if Distance < Studs then
                Studs = Distance
                Part = v:FindFirstChild("MainPart")
            end
        end
    end
    return Part
end

function Getloor(Studs, Type)
    if Type then
        Part = nil
        for _, v in ipairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
            if v:FindFirstChild("DoorBase") then
                Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("DoorBase").Position).Magnitude
                if Distance < Studs then
                    Studs = Distance
                    Part = v:FindFirstChild("DoorBase")
                end
            end
        end
        return Part
    else
        Part = nil
        for _, v in ipairs(game:GetService("Workspace").Map.Doors:GetChildren()) do
            if v:FindFirstChild("DoorBase") and v:FindFirstChild("Values").Locked.Value == true and v:FindFirstChild("Values").Broken.Value == false then
                Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v:FindFirstChild("DoorBase").Position).Magnitude
                if Distance < Studs then
                    Studs = Distance
                    Part = v:FindFirstChild("DoorBase")
                end
            end
        end
        return Part
    end
end

MiscRight:AddToggle('AutoBreakDoor', {
    Text = 'Auto Break Door',
    Default = false,
    Callback = function(State)
        if State then
            AutoBreakDoorConnection = game:GetService('RunService').RenderStepped:Connect(function()
                if Toggles.AutoBreakDoor.Value and (game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Nunchucks") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Knuckledusters") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Bayonet") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Taiga") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Rambo") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("BBaton") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Machete") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Sledgehammer") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Shiv") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Wrench") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Balisong") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fire-Axe") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Chainsaw")) then
                    ClosestDoor = Getloor(AutoBreakDoorRangeValue, false)
                    if ClosestDoor and not AutoBreakDoorCoolDown then
                        AutoBreakDoorCoolDown = true
                        AutoBreakDoorValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestDoor.Parent, "Door")
                        game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakDoorValue, false, game:GetService("Players").LocalPlayer.Character["Right Leg"], ClosestDoor, ClosestDoor.Parent, ClosestDoor.Position, ClosestDoor.Position)
                        wait(0.5)
                        AutoBreakDoorCoolDown = false
                    end
                end
            end)
        else
            if AutoBreakDoorConnection then AutoBreakDoorConnection:Disconnect() end
        end
    end
})

MiscRight:AddToggle('AutoBreakSafe', {
    Text = 'Auto Break Safe',
    Default = false,
    Callback = function(State)
        if State then
            AutoBreakSafeConnection = game:GetService('RunService').RenderStepped:Connect(function()
                if Toggles.AutoBreakSafe.Value and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") then
                    ClosestSafe = GetSafe(AutoBreakSafeRangeValue, false)
                    if ClosestSafe and not AutoBreakSafeCoolDown then
                        AutoBreakSafeCoolDown = true
                        AutoBreakSafeValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestSafe.Parent, "Register")
                        game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakSafeValue, false, game:GetService("Players").LocalPlayer.Character["Right Arm"], ClosestSafe, ClosestSafe.Parent, ClosestSafe.Position, ClosestSafe.Position)
                        wait(0.5)
                        AutoBreakSafeCoolDown = false
                    end
                end
            end)
        else
            if AutoBreakSafeConnection then AutoBreakSafeConnection:Disconnect() end
        end
    end
})

MiscRight:AddToggle('AutoBreakRegister', {
    Text = 'Auto Break Register',
    Default = false,
    Callback = function(State)
        if State then
            AutoBreakRegisterConnection = game:GetService('RunService').RenderStepped:Connect(function()
                if Toggles.AutoBreakRegister.Value and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Crowbar") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Knuckledusters") then
                    ClosestRegister = GetRegister(AutoBreakRegisterRangeValue)
                    if ClosestRegister and not AutoBreakRegisterCoolDown then
                        AutoBreakRegisterCoolDown = true
                        AutoBreakRegisterValue = game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "DZDRRRKI", ClosestRegister.Parent, "Register")
                        game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool"), "2389ZFX34", AutoBreakRegisterValue, false, game:GetService("Players").LocalPlayer.Character["Right Arm"], ClosestRegister, ClosestRegister.Parent, ClosestRegister.Position, ClosestRegister.Position)
                        wait(0.5)
                        AutoBreakRegisterCoolDown = false
                    end
                end
            end)
        else
            if AutoBreakRegisterConnection then AutoBreakRegisterConnection:Disconnect() end
        end
    end
})

me = game.Players.LocalPlayer
run = game:GetService("RunService")
AutoOpenDoorsF = false
AutoUnlockDoorsF = false
AutoLockDoorsF = false
AutoCloseDoorsF = false
AutoKnockDoorsF = false
OpenDoorsDistance = 1
UnlockDoorsDistance = 1
LockDoorsDistance = 1
CloseDoorsDistance = 1
AutoKnockDoorsDistance = 1

MiscRight:AddToggle('AutoOpenDoorsToggle', {
    Text = "Auto Open Doors",
    Default = false,
    Callback = function(Value)
        AutoOpenDoorsF = Value
        if Value then
            spawn(OpenDoorsL)
        end
    end
})

MiscRight:AddToggle('AutoUnlockDoorsToggle', {
    Text = "Auto Unlock Doors",
    Default = false,
    Callback = function(Value)
        AutoUnlockDoorsF = Value
        if Value then
            spawn(UnlockDoorsL)
        end
    end
})

MiscRight:AddToggle('AutoLockDoorsToggle', {
    Text = "Auto Lock Doors",
    Default = false,
    Callback = function(Value)
        AutoLockDoorsF = Value
        if Value then
            spawn(LockDoorsL)
        end
    end
})

MiscRight:AddToggle('AutoCloseDoorsToggle', {
    Text = "Auto Close Doors",
    Default = false,
    Callback = function(Value)
        AutoCloseDoorsF = Value
        if Value then
            spawn(CloseDoorsL)
        end
    end
})

MiscRight:AddToggle('AutoKnockDoorsToggle', {
    Text = "Auto Knock Doors",
    Default = false,
    Callback = function(Value)
        AutoKnockDoorsF = Value
        if Value then
            spawn(KnockDoorsL)
        end
    end
})

AutoDepositToggle = false

MiscRight:AddToggle('AutoDeposit', {
    Text = "AutoDeposit All",
    Default = false,
    Callback = function(Value)
        AutoDepositToggle = Value
    end
})

spawn(function()
    while true do
        if AutoDepositToggle then
            for _, v in pairs(workspace.Map.ATMz:GetChildren()) do
                if v.MainPart and (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.MainPart.Position).Magnitude <= 15 then
                    cash = game:GetService("ReplicatedStorage").PlayerbaseData2[game:GetService("Players").LocalPlayer.Name].Cash.Value
                    if cash > 0 then
                        game:GetService("ReplicatedStorage").Events.ATM:InvokeServer("DP", cash, v.MainPart)
                    end
                    break
                end
            end
        end
        task.wait(1)
    end
end)

GetDoor = function(dist)
    mapFolder = workspace:FindFirstChild("Map")
    if not mapFolder then return nil end
    folderDoors = mapFolder:FindFirstChild("Doors")
    if not folderDoors then return nil end
    closestDoor = nil
    closestDist = dist
    for _, d in pairs(folderDoors:GetChildren()) do
        doorBase = d:FindFirstChild("DoorBase")
        if doorBase then
            distance = (me.Character.HumanoidRootPart.Position - doorBase.Position).Magnitude
            if distance < closestDist then
                closestDist = distance
                closestDoor = d
            end
        end
    end
    return closestDoor
end

OpenDoorsL = function()
    while AutoOpenDoorsF do
        if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
            me.Character = me.Character or me.CharacterAdded:Wait()
            me.Character:WaitForChild("HumanoidRootPart")
        end
        hrp = me.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            run.RenderStepped:Wait()
            continue
        end
        door = GetDoor(OpenDoorsDistance)
        if door then
            values = door:FindFirstChild("Values")
            events = door:FindFirstChild("Events")
            if values and events then
                locked = values:FindFirstChild("Locked")
                openValue = values:FindFirstChild("Open")
                toggleEvent = events:FindFirstChild("Toggle")
                if locked and openValue and toggleEvent and not locked.Value and not openValue.Value then
                    knob1 = door:FindFirstChild("Knob1")
                    knob2 = door:FindFirstChild("Knob2")
                    if knob1 and knob2 then
                        knob1pos = (hrp.Position - knob1.Position).Magnitude
                        knob2pos = (hrp.Position - knob2.Position).Magnitude
                        chosenKnob = knob1pos < knob2pos and knob1 or knob2
                        toggleEvent:FireServer("Open", chosenKnob)
                    end
                end
            end
        end
        run.RenderStepped:Wait()
    end
end

UnlockDoorsL = function()
    while AutoUnlockDoorsF do
        if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
            me.Character = me.Character or me.CharacterAdded:Wait()
            me.Character:WaitForChild("HumanoidRootPart")
        end
        hrp = me.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            run.RenderStepped:Wait()
            continue
        end
        door = GetDoor(UnlockDoorsDistance)
        if door then
            values = door:FindFirstChild("Values")
            events = door:FindFirstChild("Events")
            if values and events then
                locked = values:FindFirstChild("Locked")
                toggleEvent = events:FindFirstChild("Toggle")
                if locked and toggleEvent and locked.Value then
                    toggleEvent:FireServer("Unlock", door.Lock)
                end
            end
        end
        run.RenderStepped:Wait()
    end
end

LockDoorsL = function()
    while AutoLockDoorsF do
        if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
            me.Character = me.Character or me.CharacterAdded:Wait()
            me.Character:WaitForChild("HumanoidRootPart")
        end
        hrp = me.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            run.RenderStepped:Wait()
            continue
        end
        door = GetDoor(LockDoorsDistance)
        if door then
            values = door:FindFirstChild("Values")
            events = door:FindFirstChild("Events")
            if values and events then
                locked = values:FindFirstChild("Locked")
                toggleEvent = events:FindFirstChild("Toggle")
                if locked and toggleEvent and not locked.Value then
                    toggleEvent:FireServer("Lock", door.Lock)
                end
            end
        end
        run.RenderStepped:Wait()
    end
end

CloseDoorsL = function()
    while AutoCloseDoorsF do
        if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
            me.Character = me.Character or me.CharacterAdded:Wait()
            me.Character:WaitForChild("HumanoidRootPart")
        end
        hrp = me.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            run.RenderStepped:Wait()
            continue
        end
        door = GetDoor(CloseDoorsDistance)
        if door then
            values = door:FindFirstChild("Values")
            events = door:FindFirstChild("Events")
            if values and events then
                openValue = values:FindFirstChild("Open")
                toggleEvent = events:FindFirstChild("Toggle")
                if openValue and toggleEvent and openValue.Value then
                    knob1 = door:FindFirstChild("Knob1")
                    knob2 = door:FindFirstChild("Knob2")
                    if knob1 and knob2 then
                        knob1pos = (hrp.Position - knob1.Position).Magnitude
                        knob2pos = (hrp.Position - knob2.Position).Magnitude
                        chosenKnob = knob1pos < knob2pos and knob1 or knob2
                        toggleEvent:FireServer("Close", chosenKnob)
                    end
                end
            end
        end
        run.RenderStepped:Wait()
    end
end

KnockDoorsL = function()
    while AutoKnockDoorsF do
        if not me.Character or not me.Character:FindFirstChild("HumanoidRootPart") then
            me.Character = me.Character or me.CharacterAdded:Wait()
            me.Character:WaitForChild("HumanoidRootPart")
        end
        hrp = me.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            run.RenderStepped:Wait()
            continue
        end
        door = GetDoor(AutoKnockDoorsDistance)
        if door then
            events = door:FindFirstChild("Events")
            if events then
                toggleEvent = events:FindFirstChild("Toggle")
                if toggleEvent then
                    knob1 = door:FindFirstChild("Knob1")
                    knob2 = door:FindFirstChild("Knob2")
                    if knob1 and knob2 then
                        knob1pos = (hrp.Position - knob1.Position).Magnitude
                        knob2pos = (hrp.Position - knob2.Position).Magnitude
                        chosenKnob = knob1pos < knob2pos and knob1 or knob2
                        toggleEvent:FireServer("Knock", chosenKnob)
                    end
                end
            end
        end
        run.RenderStepped:Wait()
    end
end

AutoClaimEnabled = false
AutoClaimAllowanceCoolDown = false

p = game:GetService("Players").LocalPlayer
ws = game:GetService("Workspace")
run = game:GetService("RunService")
hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart") or nil

function updateHRP()
    if p.Character then
        hrp = p.Character:FindFirstChild("HumanoidRootPart")
    end
end

function GetATM()
    updateHRP()
    if not hrp then return nil end
    closestATM, minDistance = nil, math.huge
    for _, v in ipairs(ws.Map.ATMz:GetChildren()) do
        mainPart = v:FindFirstChild("MainPart")
        if mainPart then
            distance = (hrp.Position - mainPart.Position).Magnitude
            if distance < minDistance then
                minDistance, closestATM = distance, mainPart
            end
        end
    end
    return closestATM
end

function AutoClaimAllowance()
    while AutoClaimEnabled do
        updateHRP()
        nextAllowance = game:GetService("ReplicatedStorage").PlayerbaseData2[p.Name]:FindFirstChild("NextAllowance")
        if nextAllowance and nextAllowance.Value == 0 then
            ATM = GetATM()
            if ATM and not AutoClaimAllowanceCoolDown then
                AutoClaimAllowanceCoolDown = true
                game:GetService("ReplicatedStorage").Events.CLMZALOW:InvokeServer(ATM)
                wait(0.5)
                AutoClaimAllowanceCoolDown = false
            end
        end
        wait(1)
    end
end

p.CharacterAdded:Connect(function(character)
    hrp = character:WaitForChild("HumanoidRootPart")
    if AutoClaimEnabled then
        spawn(AutoClaimAllowance)
    end
end)

MiscRight:AddToggle('AutoClaimAllowance', {
    Text = "AutoClaim Allowance",
    Default = false,
    Callback = function(Value)
        AutoClaimEnabled = Value
        if AutoClaimEnabled then
            spawn(AutoClaimAllowance)
        end
    end
})

RespToggleState = false

MiscRight:AddToggle('AutoRespawn', {
    Text = "Auto Respawn",
    Default = false,
    Callback = function(Value)
        RespToggleState = Value
    end
})

deathssevent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("DeathRespawn")

run.RenderStepped:Connect(function()
    if RespToggleState then
        char = me.Character
        if char then
            humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                deathssevent:InvokeServer("KMG4R904")
            end
        end
    end
end)

VendingEnabled = false
VendingItem = "soda"
VendingDistance = 1
UnstuckEnabled = false

MiscRight:AddToggle('VendingToggle', {
    Text = 'AutoBuyVending',
    Default = false,
    Callback = function(Value)
        VendingEnabled = Value
    end
})

MiscRight:AddToggle('UnstuckToggle', {
    Text = 'AutoUnstuckVending',
    Default = false,
    Callback = function(Value)
        UnstuckEnabled = Value
    end
})

function StartUnstuckLoop()
    task.spawn(function()
        while true do
            task.wait(1)
            if UnstuckEnabled and game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Right Leg") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists") and game:GetService("Players").LocalPlayer.Character:FindFirstChild("Fists") == game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                ClosestStuckMachine = nil
                ClosestStuckDistance = 15

                for _, v in pairs(workspace:WaitForChild("Map"):WaitForChild("VendingMachines"):GetChildren()) do
                    if v:FindFirstChild("MainPart") and v:FindFirstChild("Values") and v.Values:FindFirstChild("Stuck") and v.Values.Stuck.Value then
                        Distance = (v.MainPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if Distance <= ClosestStuckDistance then
                            ClosestStuckDistance = Distance
                            ClosestStuckMachine = v
                        end
                    end
                end

                if ClosestStuckMachine then
                    success, UnstuckValue = pcall(function()
                        return game:GetService("ReplicatedStorage").Events["XMHH.2"]:InvokeServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character.Fists, "DZDRRRKI", ClosestStuckMachine, "Vending")
                    end)
                    if success and UnstuckValue then
                        for i = 1, 3 do
                            game:GetService("ReplicatedStorage").Events["XMHH2.2"]:FireServer("🍞", tick(), game:GetService("Players").LocalPlayer.Character.Fists, "2389ZFX34", UnstuckValue, false, game:GetService("Players").LocalPlayer.Character["Right Leg"], ClosestStuckMachine.MainPart, ClosestStuckMachine, ClosestStuckMachine.MainPart.Position, ClosestStuckMachine.MainPart.Position)
                        end
                    end
                end
            end
        end
    end)
end

StartUnstuckLoop()

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if UnstuckEnabled then
        StartUnstuckLoop()
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if VendingEnabled then
            if game:GetService("Players").LocalPlayer.Character and game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                ClosestMachine = nil
                ClosestDistance = VendingDistance

                for _, v in pairs(workspace:WaitForChild("Map"):WaitForChild("VendingMachines"):GetChildren()) do
                    if v:FindFirstChild("MainPart") and v:FindFirstChild("Values") and v.Values:FindFirstChild("Stuck") and not v.Values.Stuck.Value and v.Values:FindFirstChild("Broken") and not v.Values.Broken.Value then
                        Distance = (v.MainPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                        if Distance <= ClosestDistance then
                            ClosestDistance = Distance
                            ClosestMachine = v.MainPart
                        end
                    end
                end

                if ClosestMachine then
                    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("VendinMachine"):InvokeServer(ClosestMachine, VendingItem)
                end
            end
        end
    end
end)

function GetDealer(Studs, Type)
    Part = nil
    Studs = Studs or math.huge
    for _, v in ipairs(game:GetService("Workspace").Map.Shopz:GetChildren()) do
        if v.Name == Type and v:FindFirstChild("MainPart") then
            Distance = (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.MainPart.Position).Magnitude
            if Distance < Studs then
                Studs = Distance
                Part = v.MainPart
            end
        end
    end
    return Part
end

function GetArmor()
    for _, v in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
        if v:FindFirstChild("BrokenM") then
            return v.Name
        end
    end
    return "None"
end

MiscRight:AddToggle('AutoBuyToggle', {
    Text = 'AutoBuy',
    Default = false,
    Callback = function(Value)
        AutoBuyEnabled = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoBuyToggle.Value do
                    Dealer = GetDealer(math.huge, "Dealer")
                    if Dealer then
                        for item, enabled in pairs(Options.AutoBuyDropdown.Value) do
                            if enabled then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
}):AddKeyPicker('AutoBuyKeyPicker', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Auto Buy',
    Callback = function(Value)
        AutoBuyEnabled = Value
    end
})

MiscRight:AddToggle('AutoSellToggle', {
    Text = 'AutoSell',
    Default = false,
    Callback = function(Value)
        AutoSellEnabled = Value
        if Value then
            task.spawn(function()
                while Toggles.AutoSellToggle.Value do
                    Dealer = GetDealer(math.huge, "Dealer")
                    if Dealer then
                        for category, enabled in pairs(Options.AutoSellDropdown.Value) do
                            if enabled then
                                for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
                                    if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
                                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                                        if category == "All" then
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                                        end
                                    end
                                end
                                for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                                    if item:IsA("Tool") then
                                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                                        if category == "All" then
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                                        end
                                    end
                                end
                            end
                        end
                    end
                    task.wait()
                end
            end)
        end
    end
}):AddKeyPicker('AutoSellKeyPicker', {
    Default = 'None',
    SyncToggleState = true,
    Mode = 'Toggle',
    Text = 'Auto Sell',
    Callback = function(Value)
        AutoSellEnabled = Value
    end
})

MiscRight:AddToggle('AutoRepairToggle', {
    Text = 'AutoRepair and Refill',
    Default = false,
    Callback = function(Value)
        if Value then
            task.spawn(function()
                while Toggles.AutoRepairToggle.Value do
                    if not AutoRePairAndReFillCoolDown then
                        AutoRePairAndReFillCoolDown = true
                        Dealer = GetDealer(AutoRepairRange, "Dealer") or GetDealer(AutoRepairRange, "ArmoryDealer")
                        if Dealer and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool") then
                            if Dealer.Parent.Name == "Dealer" then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name, Dealer, "ResupplyAmmo")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Armour", GetArmor(), Dealer, "ResupplyAmmo")
                            elseif Dealer.Parent.Name == "ArmoryDealer" then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name, Dealer, "ResupplyAmmo")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Armour", GetArmor(), Dealer, "ResupplyAmmo")
                            end
                        end
                        task.wait(0.5)
                        AutoRePairAndReFillCoolDown = false
                    end
                    task.wait()
                end
            end)
        end
    end
})

pickupMethod = "Without Remote Event"

toolsFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedTools")
cashFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedBread")
pilesFolder = game:GetService("Workspace"):WaitForChild("Filter"):WaitForChild("SpawnedPiles")

toolsEnabled = false
cashEnabled = false
scrapsEnabled = false
cratesEnabled = false

scrapsConnection = nil
toolsConnection = nil
cratesConnection = nil
moneyConnection = nil
canPickup = true
lastPickupTime = 0
cooldown = 0.8

function interactWithPrompt(v)
	if v:IsA("ProximityPrompt") and canPickup then
		v.HoldDuration = 0
		fireproximityprompt(v)
		canPickup = false
		lastPickupTime = tick()
	end
end

function pickupWithoutRemote(v)
	if toolsEnabled and v:IsA("Model") and toolsFolder:FindFirstChild(v.Name) then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	elseif cashEnabled and v:IsA("BasePart") and v.Name == "CashDrop1" then
		for _, p in pairs(v:GetChildren()) do interactWithPrompt(p) end
	elseif scrapsEnabled and v:IsA("Model") and (v.Name == "S1" or v.Name == "S2") then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	elseif cratesEnabled and v:IsA("Model") and (v.Name == "C1" or v.Name == "C2" or v.Name == "C3") then
		for _, p in pairs(v:GetDescendants()) do interactWithPrompt(p) end
	end
end

function scanItems()
	while toolsEnabled or cashEnabled or scrapsEnabled or cratesEnabled do
		if not canPickup and tick() - lastPickupTime >= cooldown then
			canPickup = true
		end
		for _, v in ipairs(toolsFolder:GetChildren()) do pickupWithoutRemote(v) end
		for _, v in ipairs(cashFolder:GetChildren()) do pickupWithoutRemote(v) end
		for _, v in ipairs(pilesFolder:GetChildren()) do pickupWithoutRemote(v) end
		task.wait(0.1)
	end
end

function pickupWithRemoteScraps()
	rpScraps = game:GetService("ReplicatedStorage")
	remoteScraps = rpScraps:WaitForChild("Events"):WaitForChild("PIC_PU")
	scrapsFolderScraps = pilesFolder
	canPickupRemoteScraps = true
	startTickScraps = tick()
	scrapsConnection = run.RenderStepped:Connect(function()
		maxdistScraps = 15
		closestScraps = nil
		for _, a in pairs(scrapsFolderScraps:GetChildren()) do
			if a and (a.Name == "S1" or a.Name == "S2") and me.Character and me.Character.HumanoidRootPart then
				getdistScraps = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
				if getdistScraps < maxdistScraps then
					maxdistScraps = getdistScraps
					closestScraps = a
				end
			end
		end
		if closestScraps and canPickupRemoteScraps then
			remoteScraps:FireServer(string.reverse(closestScraps:GetAttribute("jzu")))
			canPickupRemoteScraps = false
		elseif closestScraps and tick() - startTickScraps >= 4.5 then
			canPickupRemoteScraps = true
			startTickScraps = tick()
		end
	end)
end

function pickupWithRemoteTools()
	rpTools = game:GetService("ReplicatedStorage")
	remoteTools = rpTools:WaitForChild("Events"):WaitForChild("PIC_TLO")
	toolsFolderTools = toolsFolder
	canPickupRemoteTools = true
	startTickTools = tick()
	toolsConnection = run.RenderStepped:Connect(function()
		maxdistTools = 15
		closestTools = nil
		for _, a in pairs(toolsFolderTools:GetChildren()) do
			if a and me.Character and me.Character.HumanoidRootPart then
				handleTools = a:FindFirstChild("Handle") or a:FindFirstChild("WeaponHandle")
				if handleTools and (handleTools:IsA("Part") or handleTools:IsA("MeshPart")) then
					getdistTools = (me.Character.HumanoidRootPart.Position - handleTools.Position).Magnitude
					if getdistTools < maxdistTools then
						maxdistTools = getdistTools
						closestTools = a
					end
				end
			end
		end
		if closestTools then
			HandleTools = closestTools:FindFirstChild("Handle") or closestTools:FindFirstChild("WeaponHandle")
			if HandleTools and canPickupRemoteTools then
				remoteTools:FireServer(HandleTools)
				canPickupRemoteTools = false
			elseif HandleTools and tick() - startTickTools >= 1.5 then
				canPickupRemoteTools = true
				startTickTools = tick()
			end
		end
	end)
end

function pickupWithRemoteCrates()
	rpCrates = game:GetService("ReplicatedStorage")
	remoteCrates = rpCrates:WaitForChild("Events"):WaitForChild("PIC_PU")
	scrapsFolderCrates = pilesFolder
	canPickupRemoteCrates = true
	startTickCrates = tick()
	cratesConnection = run.RenderStepped:Connect(function()
		maxdistCrates = 15
		closestCrates = nil
		for _, a in pairs(scrapsFolderCrates:GetChildren()) do
			if a and (a.Name == "C1" or a.Name == "C2" or a.Name == "C3") and me.Character and me.Character.HumanoidRootPart then
				getdistCrates = (me.Character.HumanoidRootPart.Position - a.MeshPart.Position).Magnitude
				if getdistCrates < maxdistCrates then
					maxdistCrates = getdistCrates
					closestCrates = a
				end
			end
		end
		if closestCrates and canPickupRemoteCrates then
			remoteCrates:FireServer(string.reverse(closestCrates:GetAttribute("jzu")))
			canPickupRemoteCrates = false
		elseif closestCrates and tick() - startTickCrates >= 7 then
			canPickupRemoteCrates = true
			startTickCrates = tick()
		end
	end)
end

function pickupWithRemoteMoney()
	rpMoney = game:GetService("ReplicatedStorage")
	remoteMoney = rpMoney:WaitForChild("Events"):WaitForChild("CZDPZUS")
	moneyFolderMoney = cashFolder
	canPickupRemoteMoney = true
	startTickMoney = tick()
	moneyConnection = run.RenderStepped:Connect(function()
		maxdistMoney = 15
		closestMoney = nil
		for _, a in pairs(moneyFolderMoney:GetChildren()) do
			if a and me.Character and me.Character.HumanoidRootPart then
				getdistMoney = (me.Character.HumanoidRootPart.Position - a.Position).Magnitude
				if getdistMoney < maxdistMoney then
					maxdistMoney = getdistMoney
					closestMoney = a
				end
			end
		end
		if closestMoney and canPickupRemoteMoney then
			remoteMoney:FireServer(closestMoney)
			canPickupRemoteMoney = false
		elseif closestMoney and tick() - startTickMoney >= 0.7 then
			canPickupRemoteMoney = true
			startTickMoney = tick()
		end
	end)
end

toolsFolder.ChildAdded:Connect(pickupWithoutRemote)
cashFolder.ChildAdded:Connect(pickupWithoutRemote)
pilesFolder.ChildAdded:Connect(pickupWithoutRemote)
workspace.DescendantAdded:Connect(interactWithPrompt)

MiscRight:AddToggle('ToggleScraps', {
    Text = "AutoPickup Scraps",
    Default = false,
    Callback = function(Value)
        scrapsEnabled = Value
        if scrapsConnection then
            scrapsConnection:Disconnect()
            scrapsConnection = nil
        end
        if scrapsEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteScraps()
            end
        end
    end
})

MiscRight:AddToggle('ToggleTools', {
    Text = "AutoPickup Tools",
    Default = false,
    Callback = function(Value)
        toolsEnabled = Value
        if toolsConnection then
            toolsConnection:Disconnect()
            toolsConnection = nil
        end
        if toolsEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteTools()
            end
        end
    end
})

MiscRight:AddToggle('ToggleCrates', {
    Text = "AutoPickup Crates",
    Default = false,
    Callback = function(Value)
        cratesEnabled = Value
        if cratesConnection then
            cratesConnection:Disconnect()
            cratesConnection = nil
        end
        if cratesEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteCrates()
            end
        end
    end
})

MiscRight:AddToggle('ToggleCash', {
    Text = "AutoPickup Money",
    Default = false,
    Callback = function(Value)
        cashEnabled = Value
        if moneyConnection then
            moneyConnection:Disconnect()
            moneyConnection = nil
        end
        if cashEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteMoney()
            end
        end
    end
})

MiscRight:AddDropdown('PickupMethod', {
    Text = "Pickup Method",
    Default = "Without Remote Event",
    Values = {"Without Remote Event", "With Remote Event"},
    Callback = function(Value)
        pickupMethod = Value
        if scrapsConnection then
            scrapsConnection:Disconnect()
            scrapsConnection = nil
        end
        if toolsConnection then
            toolsConnection:Disconnect()
            toolsConnection = nil
        end
        if cratesConnection then
            cratesConnection:Disconnect()
            cratesConnection = nil
        end
        if moneyConnection then
            moneyConnection:Disconnect()
            moneyConnection = nil
        end
        if scrapsEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteScraps()
            end
        end
        if toolsEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteTools()
            end
        end
        if cratesEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteCrates()
            end
        end
        if cashEnabled then
            if pickupMethod == "Without Remote Event" then
                task.spawn(scanItems)
            else
                pickupWithRemoteMoney()
            end
        end
    end
})

MiscRight:AddDropdown('ItemDropdown', {
    Values = { 'soda', 'snack' },
    Default = 1,
    Text = 'Select Item for buy (vending)',
    Callback = function(Value)
        VendingItem = Value
    end
})

MiscRight:AddDropdown('AutoBuyDropdown', {
    Values = (function()
        t = {}
        Shopz = game:GetService("Workspace").Map.Shopz
        if Shopz:FindFirstChild("Dealer") and Shopz.Dealer:FindFirstChild("CurrentStocks") then
            for _, v in ipairs(Shopz.Dealer.CurrentStocks:GetChildren()) do
                if v ~= game:GetService("Players").LocalPlayer and v.Name then
                    table.insert(t, v.Name)
                end
            end
        end
        return #t > 0 and t or {"None"}
    end)(),
    Default = {},
    Multi = true,
    Text = 'Select AutoBuy Items',
    Callback = function(Value)
        if Toggles.AutoBuyToggle.Value then
            Dealer = GetDealer(math.huge, "Dealer")
            if Dealer then
                for item, enabled in pairs(Value) do
                    if enabled then
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
                        game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
                    end
                end
            end
        end
    end
})

Options.AutoBuyDropdown:OnChanged(function()
    if Toggles.AutoBuyToggle.Value then
        Dealer = GetDealer(math.huge, "Dealer")
        if Dealer then
            for item, enabled in pairs(Options.AutoBuyDropdown.Value) do
                if enabled then
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Melees", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Melees", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Guns", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Throwables", item, Dealer)
                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("LegalStore", "Misc", item, Dealer)
                end
            end
        end
    end
end)

MiscRight:AddDropdown('AutoSellDropdown', {
    Values = {"All", "Melees", "Guns", "Throwables", "Misc"},
    Default = {},
    Multi = true,
    Text = 'Select Categories to Sell',
    Callback = function(Value)
        if Toggles.AutoSellToggle.Value then
            Dealer = GetDealer(math.huge, "Dealer")
            if Dealer then
                for category, enabled in pairs(Value) do
                    if enabled then
                        for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
                            if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                                if category == "All" then
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                                end
                            end
                        end
                        for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                            if item:IsA("Tool") then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                                if category == "All" then
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                    game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
})

Options.AutoSellDropdown:OnChanged(function()
    if Toggles.AutoSellToggle.Value then
        Dealer = GetDealer(math.huge, "Dealer")
        if Dealer then
            for category, enabled in pairs(Options.AutoSellDropdown.Value) do
                if enabled then
                    for _, item in ipairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do
                        if item:IsA("Tool") and item.Name ~= GetArmor() and item.Name ~= game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Tool").Name then
                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                            if category == "All" then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                            end
                        end
                    end
                    for _, item in ipairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") then
                            game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", category == "All" and "Melees" or category, item.Name, Dealer, "Sell")
                            if category == "All" then
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Guns", item.Name, Dealer, "Sell")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Throwables", item.Name, Dealer, "Sell")
                                game:GetService("ReplicatedStorage").Events.SSHPRMTE1:InvokeServer("IllegalStore", "Misc", item.Name, Dealer, "Sell")
                            end
                        end
                    end
                end
            end
        end
    end
end)

MiscRight:AddSlider('DistanceSlider', {
    Text = 'AutoBuyVendingDistance',
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        VendingDistance = Value
    end
})

MiscRight:AddSlider('AutoBreakDoorRange', {
    Text = 'Auto Break Door Range',
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        AutoBreakDoorRangeValue = Value
    end
})

MiscRight:AddSlider('AutoBreakSafeRange', {
    Text = 'Auto Break Safe Range',
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        AutoBreakSafeRangeValue = Value
    end
})

MiscRight:AddSlider('AutoBreakRegisterRange', {
    Text = 'Auto Break Register Range',
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        AutoBreakRegisterRangeValue = Value
    end
})

MiscRight:AddSlider('OpenDoorsDistance', {
    Text = "Open Doors Distance",
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        OpenDoorsDistance = Value
    end
})

MiscRight:AddSlider('UnlockDoorsDistance', {
    Text = "Unlock Doors Distance",
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        UnlockDoorsDistance = Value
    end
})

MiscRight:AddSlider('LockDoorsDistance', {
    Text = "Lock Doors Distance",
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        LockDoorsDistance = Value
    end
})

MiscRight:AddSlider('CloseDoorsDistance', {
    Text = "Close Doors Distance",
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        CloseDoorsDistance = Value
    end
})

MiscRight:AddSlider('AutoKnockDoorsDistance', {
    Text = "Knock Doors Distance",
    Default = 1,
    Min = 1,
    Max = 15,
    Rounding = 0,
    Callback = function(Value)
        AutoKnockDoorsDistance = Value
    end
})

MiscRight:AddSlider('AutoRepairSlider', {
    Text = 'Repair Range',
    Default = 1,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(Value)
        AutoRepairRange = Value
    end
})

MiscLeft2:AddButton({
    Text = "Anti-blur",
    Func = function()
        cameraFolder = workspace:FindFirstChild("Camera")
        if cameraFolder then
            for _, obj in pairs(cameraFolder:GetChildren()) do
                obj:Destroy()
            end
        end
    end
})

MiscLeft2:AddToggle('AntiSmokeToggle', {
    Text = "Anti-Smoke",
    Default = false,
    Callback = function(Value)
        _G.NoSmoke = Value

        game.Workspace.Debris.ChildAdded:Connect(function(Item)
            if Item.Name == "SmokeExplosion" and _G.NoSmoke then
                wait(0.1)
                if Item:FindFirstChild("Particle1") then
                    Item.Particle1:Destroy()
                end
                if Item:FindFirstChild("Particle2") then
                    Item.Particle2:Destroy()
                end
            end
        end)

        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if Item.Name == "SmokeScreenGUI" and _G.NoSmoke then
                Item.Enabled = false
            end
        end)
    end
})

MiscLeft2:AddToggle('AntiFlashBangToggle', {
    Text = "Anti-Flash",
    Default = false,
    Callback = function(Value)
        _G.NoFlashBang = Value

        game.Workspace.Camera.ChildAdded:Connect(function(Item)
            if _G.NoFlashBang and Item.Name == "BlindEffect" then
                Item.Enabled = false
            end
        end)

        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if _G.NoFlashBang and Item.Name == "FlashedGUI" then
                Item.Enabled = false
            end
        end)
    end
})

MiscLeft2:AddToggle('AntiOverlayToggle', {
    Text = "Anti-Overlay",
    Default = false,
    Callback = function(Value)
        _G.NoOverlay = Value
        game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(Item)
            if Item.Name == "OverlayGUI" then
                Item.Enabled = not _G.NoOverlay
            end
        end)
        if game.Players.LocalPlayer.PlayerGui:FindFirstChild("OverlayGUI") then
            game.Players.LocalPlayer.PlayerGui.OverlayGUI.Enabled = not _G.NoOverlay
        end
    end
})

Client = Players.LocalPlayer

MiscLeft2:AddToggle('NoVisorToggle', {
    Text = 'Anti Visor / Helmet',
    Default = false,
    Callback = function(Value)
        for _, GUI in pairs(Client.PlayerGui:GetDescendants()) do
            if GUI.Name == "HelmetOverlayGUI" then
                GUI.Enabled = not Value
                GUI:GetPropertyChangedSignal("Enabled"):Connect(function()
                    if Value then
                        GUI.Enabled = false
                    end
                end)
            end
        end
    end
})

Players = game:GetService("Players")
RunService = game:GetService("RunService")
Workspace = game:GetService("Workspace")
ReplicatedStorage = game:GetService("ReplicatedStorage")
UserInputService = game:GetService("UserInputService")
me = Players.LocalPlayer
event = ReplicatedStorage:WaitForChild("Events"):WaitForChild("__RZDONL")
loopConnections = {}
tpActive = false
selectedPlayer = nil
targetPos = nil
customPos = nil

TeleportTargets = {
    Motel = Vector3.new(-4618.79932, 3.29673815, -903.594055),
    Cafe = Vector3.new(-4622.74414, 6.00001335, -259.846344),
    Tower = Vector3.new(-4460.875, 149.4496, -845.541138),
    Pizza = Vector3.new(-4404.69189, 5.19999599, -128.68782),
    Junkyard = Vector3.new(-3889.20801, 3.89897966, -507.586273),
    Subway = Vector3.new(-4719.51807, -32.2998962, -704.136169),
    VibeCheck = Vector3.new(-4777.06055, -200.964722, -965.857422),
    Mountain1 = Vector3.new(-4722.73145, 190.600052, -36.4695663),
    Mountain2 = Vector3.new(-4237.23779, 212.485321, -835.784119),
    Mountain3 = Vector3.new(-4145.39209, 200.522568, 160.654404),
    SaveCube = Vector3.new(-4184.4, 102.7, 276.9),
    SaveVibe = Vector3.new(-4857.5, -161.5, -918.3),
    SaveMount = Vector3.new(-5169.8, 102.6, -515.5)
}

function FindNearestTarget(targetType)
    hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    nearestTarget = nil
    minDistance = math.huge

    if targetType == "ATM" then
        for _, atm in pairs(Workspace.Map.ATMz:GetChildren()) do
            if atm:FindFirstChild("MainPart") then
                distance = (hrp.Position - atm.MainPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = atm.MainPart
                end
            end
        end
    elseif targetType == "Dealer" then
        for _, shop in pairs(Workspace.Map.Shopz:GetChildren()) do
            if shop.Name ~= "ArmoryDealer" and shop:FindFirstChild("MainPart") then
                distance = (hrp.Position - shop.MainPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = shop.MainPart
                end
            end
        end
    elseif targetType == "ArmoryDealer" then
        for _, shop in pairs(Workspace.Map.Shopz:GetChildren()) do
            if shop.Name == "ArmoryDealer" and shop:FindFirstChild("MainPart") then
                distance = (hrp.Position - shop.MainPart.Position).Magnitude
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = shop.MainPart
                end
            end
        end
    end
    return nearestTarget
end

function teleportToLocation(targetPosition, offsetDistance, targetType)
    hrp = me.Character and me.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        targetPart = FindNearestTarget(targetType)
        if targetPart and offsetDistance > 0 then
            forwardVector = targetPart.CFrame.LookVector
            hrp.CFrame = CFrame.new(targetPosition) + (forwardVector * offsetDistance)
        else
            hrp.CFrame = CFrame.new(targetPosition)
        end
        event:FireServer("__---r", Vector3.new(0, 0, 0), hrp.CFrame)
        hrp.CanCollide = false
        task.wait(0.001)
        hrp.CanCollide = true
    end
end

function CreateTeleportToggle(name, flag, targetType)
    MiscLeft3:AddToggle(flag, {
        Text = name,
        Default = false,
        Callback = function(Value)
            if Value then
                targetPos = nil
                offsetDistance = 0
                if targetType == "ATM" then
                    target = FindNearestTarget("ATM")
                    offsetDistance = 4
                    targetPos = target and target.Position
                elseif targetType == "CreateXYZ" then
                    targetPos = customPos
                elseif targetType == "Dealer" then
                    target = FindNearestTarget("Dealer")
                    offsetDistance = 3
                    targetPos = target and target.Position
                elseif targetType == "ArmoryDealer" then
                    target = FindNearestTarget("ArmoryDealer")
                    offsetDistance = 8
                    targetPos = target and target.Position
                else
                    targetPos = TeleportTargets[targetType]
                end
                if targetPos then
                    if loopConnections[flag] then
                        loopConnections[flag]:Disconnect()
                    end
                    loopConnections[flag] = RunService.RenderStepped:Connect(function()
                        if Toggles[flag].Value and targetPos then
                            teleportToLocation(targetPos, offsetDistance, targetType)
                        else
                            loopConnections[flag]:Disconnect()
                            loopConnections[flag] = nil
                        end
                    end)
                end
            end
        end
    })
end

CreateTeleportToggle("Teleport to ATM", "TP_ATM", "ATM")
CreateTeleportToggle("Teleport to Dealer", "TP_Dealer", "Dealer")
CreateTeleportToggle("Teleport to Armory Dealer", "TP_ArmoryDealer", "ArmoryDealer")
CreateTeleportToggle("Teleport to Motel", "TP_Motel", "Motel")
CreateTeleportToggle("Teleport to Cafe", "TP_Cafe", "Cafe")
CreateTeleportToggle("Teleport to Tower", "TP_Tower", "Tower")
CreateTeleportToggle("Teleport to Pizza", "TP_Pizza", "Pizza")
CreateTeleportToggle("Teleport to Junkyard", "TP_Junkyard", "Junkyard")
CreateTeleportToggle("Teleport to Subway", "TP_Subway", "Subway")
CreateTeleportToggle("Teleport to Vibe Check", "TP_VibeCheck", "VibeCheck")
CreateTeleportToggle("Teleport to Mountain 1", "TP_Mountain1", "Mountain1")
CreateTeleportToggle("Teleport to Mountain 2", "TP_Mountain2", "Mountain2")
CreateTeleportToggle("Teleport to Mountain 3", "TP_Mountain3", "Mountain3")
CreateTeleportToggle("Teleport to Save Cube", "TP_SaveCube", "SaveCube")
CreateTeleportToggle("Teleport to Save Vibe", "TP_SaveVibe", "SaveVibe")
CreateTeleportToggle("Teleport to Save Mount", "TP_SaveMount", "SaveMount")
CreateTeleportToggle("Teleport to Custom XYZ", "TP_CustomXYZ", "CreateXYZ")
MiscLeft3:AddInput("CustomXYZ", {
    Text = "Custom XYZ",
    Default = "0, 0, 0",
    Placeholder = "x, y, z",
    Callback = function(Value)
        x, y, z = Value:match("(%-?%d+%.?%d*), (%-?%d+%.?%d*), (%-?%d+%.?%d*)")
        if x and y and z then
            customPos = Vector3.new(tonumber(x), tonumber(y), tonumber(z))
        end
    end
})

antiAimEnabled = false
antiAimSpeed = 1
headTiltEnabled = false
headTiltDirection = "Up"
yawOffset = 0
spinDirection = 1

MiscLeft4:AddToggle('EnableAntiAim', {
    Text = 'Anti-Aim',
    Default = false,
    Callback = function(Value) 
        antiAimEnabled = Value 
        if not Value and head and head:FindFirstChild("HeadWeld") then
            head.HeadWeld:Destroy()
        end
    end
})

MiscLeft4:AddToggle('EnableHeadTilt', {
    Text = 'Head Tilt',
    Default = false,
    Callback = function(Value) 
        headTiltEnabled = Value 
        if not Value and head and head:FindFirstChild("HeadWeld") then
            head.HeadWeld.C1 = CFrame.new(0, 0.5, 0)
        end
    end
})

MiscLeft4:AddDropdown('HeadTiltDirection', {
    Values = {'Up', 'Down'},
    Default = 1,
    Multi = false,
    Text = 'Head Tilt Direction',
    Callback = function(Value) headTiltDirection = Value end
})

MiscLeft4:AddSlider('AntiAimSpeed', {
    Text = 'Anti-Aim Speed',
    Default = 1,
    Min = 0.1,
    Max = 5,
    Rounding = 1,
    Compact = false,
    Callback = function(Value) antiAimSpeed = Value end
})

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    if not antiAimEnabled or not game:GetService("Players").LocalPlayer.Character or not game:GetService("Players").LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
    hrp = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
    head = game:GetService("Players").LocalPlayer.Character:FindFirstChild("Head")
    
    yawOffset = yawOffset + (antiAimSpeed * deltaTime * 360 * spinDirection)
    if math.abs(yawOffset) >= 180 then
        spinDirection = -spinDirection
        yawOffset = math.clamp(yawOffset, -180, 180)
    end
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(yawOffset + math.sin(os.clock() * antiAimSpeed * 5) * 45), 0)
    
    if head and headTiltEnabled and not head:FindFirstChild("HeadWeld") then
        weld = Instance.new("Weld")
        weld.Name = "HeadWeld"
        weld.Part0 = hrp
        weld.Part1 = head
        weld.C0 = CFrame.new(0, 1.5, 0)
        weld.Parent = head
    end
    
    if head and head:FindFirstChild("HeadWeld") then
        if headTiltEnabled then
            if headTiltDirection == "Up" then
                head.HeadWeld.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(-90), 0, 0)
            elseif headTiltDirection == "Down" then
                head.HeadWeld.C1 = CFrame.new(0, 0.5, 0) * CFrame.Angles(math.rad(90), 0, 0)
            end
        else
            head.HeadWeld.C1 = CFrame.new(0, 0.5, 0)
        end
    end
end)

MiscRight3:AddButton({
    Text = 'Toggle Vibecheck Elevator',
    Func = function()
        Knob = Workspace.Map.Doors.Elevator_28.Knob1
        Client = game:GetService("Players").LocalPlayer
        if Client.Character then
            Client.Character.HumanoidRootPart.CFrame = Knob.CFrame
            Prompt = Knob:WaitForChild("ProximityPrompt")
            task.wait(0.05)
            for Index = 1, 10 do 
                fireproximityprompt(Prompt)
            end
        end
    end
})

function createBendoverTool()
    SleepTool = Instance.new("Tool")
    SleepTool.Name = "Bend Over\nOff"
    SleepTool.RequiresHandle = false
    SleepTool.ToolTip = "Bend Over"

    b = {}
    c = {}
    _ = {
        ID = 0;
        Type = "Animation";
        Properties = {
            Name = "Sleep";
            AnimationId = "http://www.roblox.com/asset/?id=4686925579"
        };
        Children = {
            {ID = 1; Type = "NumberValue"; Properties = {Name = "ThumbnailBundleId"; Value = 515}; Children = {}};
            {ID = 2; Type = "NumberValue"; Properties = {Name = "ThumbnailKeyframe"; Value = 13}; Children = {}};
            {ID = 3; Type = "NumberValue"; Properties = {Name = "ThumbnailZoom"; Value = 1.1576576576577}; Children = {}};
            {ID = 4; Type = "NumberValue"; Properties = {Name = "ThumbnailHorizontalOffset"; Value = -0.0025025025025025}; Children = {}};
            {ID = 5; Type = "NumberValue"; Properties = {Name = "ThumbnailVerticalOffset"; Value = -0.0025025025025025}; Children = {}};
            {ID = 6; Type = "NumberValue"; Properties = {Name = "ThumbnailCharacterRotation"}; Children = {}}
        }
    }

    function a(d, parent)
        e = Instance.new(d.Type)
        if d.ID then
            temp = c[d.ID]
            if temp then
                temp[1][temp[2]] = e
                c[d.ID] = nil
            else
                b[d.ID] = e
            end
        end
        for prop, val in pairs(d.Properties) do
            if type(val) == "string" then
                id = tonumber(val:match("^_R:(%w+)_$"))
                if id then
                    if b[id] then
                        val = b[id]
                    else
                        c[id] = {e, prop}
                        val = nil
                    end
                end
            end
            e[prop] = val
        end
        for _, child in pairs(d.Children) do
            a(child, e)
        end
        e.Parent = parent
        return e
    end

    create = a

    savedAnimate = nil
    activeTrack = nil
    isPlaying = false

    function getCharacterAndHumanoid()
        player = game:GetService("Players").LocalPlayer
        character = player.Character
        if not character then return nil, nil end
        humanoid = character:FindFirstChildOfClass("Humanoid")
        return character, humanoid
    end

    function playBendOverAnimation()
        character, humanoid = getCharacterAndHumanoid()
        if not character or not humanoid then return end
        SleepTool.Name = "Bend Over\nOn"
        if character:FindFirstChild("Animate") then
            savedAnimate = character.Animate:Clone()
        end
        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            animation = create(_, nil)
            animate = character:WaitForChild("Animate")
            bindable = animate:WaitForChild("PlayEmote")
            bindable:Invoke(animation)
            task.spawn(function()
                task.wait(0.1)
                for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do 
                    if track.Animation.AnimationId:match("4686925579") then 
                        track:AdjustSpeed(0)
                        activeTrack = track
                        break 
                    end
                end
            end)
            task.wait(0.3)
            if character:FindFirstChild("Animate") then
                character.Animate:Destroy()
            end
        else
            animation = Instance.new("Animation")
            animation.AnimationId = "rbxassetid://189854234"
            activeTrack = humanoid:LoadAnimation(animation)
            activeTrack:Play()
            task.wait(0.3)
            activeTrack:AdjustSpeed(0)
        end
        isPlaying = true
    end

    function restoreOriginalAnimation()
        character, humanoid = getCharacterAndHumanoid()
        if not character then return end
        SleepTool.Name = "Bend Over\nOff"
        if activeTrack then
            activeTrack:Stop()
            activeTrack = nil
        end
        if savedAnimate and character then
            oldAnimate = character:FindFirstChild("Animate")
            if oldAnimate then
                oldAnimate:Destroy()
            end
            newAnimate = savedAnimate:Clone()
            newAnimate.Parent = character
            savedAnimate = nil
        end
        isPlaying = false
    end

    SleepTool.Equipped:Connect(function()
        if not isPlaying then
            pcall(playBendOverAnimation)
        end
    end)

    SleepTool.Unequipped:Connect(function()
        if isPlaying then
            pcall(restoreOriginalAnimation)
        end
    end)

    game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
        savedAnimate = nil
        activeTrack = nil
        isPlaying = false
        SleepTool.Name = "Bend Over\nOff"
    end)

    return SleepTool
end

function createHugTool()
    HugTool = Instance.new("Tool")
    HugTool.Name = "Hug Tool\nOff"
    HugTool.RequiresHandle = false
    HugTool.ToolTip = "Hug Tool R6"

    HugTool.Equipped:Connect(function()
        HugTool.Name = "Hug Tool\nOn"
        Anim_1 = Instance.new("Animation")
        Anim_1.AnimationId = "rbxassetid://283545583"
        Play_1 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim_1)
        Anim_2 = Instance.new("Animation")
        Anim_2.AnimationId = "rbxassetid://225975820"
        Play_2 = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim_2)
        Play_1:Play()
        Play_2:Play()
    end)

    HugTool.Unequipped:Connect(function()
        HugTool.Name = "Hug Tool\nOff"
        if Play_1 then Play_1:Stop() end
        if Play_2 then Play_2:Stop() end
    end)

    return HugTool
end

function createJerkTool()
    speaker = game.Players.LocalPlayer
    humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    backpack = speaker:FindFirstChildWhichIsA("Backpack")
    if not humanoid or not backpack then return end

    tool = Instance.new("Tool")
    tool.Name = "Jerk Off"
    tool.ToolTip = "in the stripped club. straight up \"jorking it\" . and by \"it\" , haha, well. let's just say. My peanits."
    tool.RequiresHandle = false

    jorkin = false
    track = nil

    function r15()
        return speaker.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
    end

    function stopTomfoolery()
        jorkin = false
        if track then
            track:Stop()
            track = nil
        end
    end

    tool.Equipped:Connect(function() jorkin = true end)
    tool.Unequipped:Connect(stopTomfoolery)
    humanoid.Died:Connect(stopTomfoolery)

    task.spawn(function()
        while true do
            task.wait()
            if not jorkin then continue end
            isR15 = r15()
            if not track then
                anim = Instance.new("Animation")
                anim.AnimationId = not isR15 and "rbxassetid://72042024" or "rbxassetid://698251653"
                track = humanoid:LoadAnimation(anim)
            end
            track:Play()
            track:AdjustSpeed(isR15 and 0.7 or 0.65)
            track.TimePosition = 0.6
            task.wait(0.1)
            while track and track.TimePosition < (not isR15 and 0.65 or 0.7) do task.wait(0.1) end
            if track then
                track:Stop()
                track = nil
            end
        end
    end)

    return tool
end

tools = {}

MiscRight3:AddToggle('BendoverToggle', {
    Text = 'Bendover Tool',
    Default = false,
    Callback = function(Value)
        if Value then
            tools.Bendover = createBendoverTool()
            tools.Bendover.Parent = game.Players.LocalPlayer.Backpack
        else
            if tools.Bendover then
                tools.Bendover:Destroy()
                tools.Bendover = nil
            end
        end
    end
})

MiscRight3:AddToggle('HugToggle', {
    Text = 'Hug Tool',
    Default = false,
    Callback = function(Value)
        if Value then
            tools.Hug = createHugTool()
            tools.Hug.Parent = game.Players.LocalPlayer.Backpack
        else
            if tools.Hug then
                tools.Hug:Destroy()
                tools.Hug = nil
            end
        end
    end
})

MiscRight3:AddToggle('JerkToggle', {
    Text = 'Jerk Tool',
    Default = false,
    Callback = function(Value)
        if Value then
            tools.Jerk = createJerkTool()
            if tools.Jerk then
                tools.Jerk.Parent = game.Players.LocalPlayer.Backpack
            end
        else
            if tools.Jerk then
                tools.Jerk:Destroy()
                tools.Jerk = nil
            end
        end
    end
})

Animations = {
    ["Fake-BlindAnim"] = "14694544863",
    ["Fake-Crounch"] = "14694501365",
    ["Fake-OpenLoop"] = "14694544925",
    ["Fake-PSlide"] = "12323412326",
    ["TorzoFreeze"] = "13084367111",
    ["Carpet"] = "282574440",
    ["Fake-DoorHit"] = "14894406295",
    ["Fake-Finish"] = "14894394657",
	["Dance4 (free)"] = "14849677565",
	["Dance5 (free)"] = "14849684060",
	["Dance6 (free)"] = "14849689388",
	["Sit (free)"] = "14849671564",
	["billie (paid)"] = "81801849845556",
	["chrono (paid)"] = "111638685543061",
	["sponge (paid)"] = "115515299922873",
	["twist (paid)"] = "131381346101768",
	["goth (paid)"] = "99321992329001",
	["soviet1 (paid)"] = "137127771280152",
	["soviet2 (paid)"] = "98785483099216",
	["drip (paid)"] = "103038098286931",
	["thriller (paid)"] = "140059371442945",
	["shuffle (paid)"] = "88402264773310",
	["stomp (paid)"] = "113960847628297",
	["hustle (paid)"] = "136973226231083",
	["rvvz (paid)"] = "81864653411401",
	["xd (paid)"] = "114072413596758",
	["mesmerizer (paid)"] = "130586033168879",
}

Tracks = {}

function PlayAnimation(animationId)
    plr = game.Players.LocalPlayer
    char = plr.Character or plr.CharacterAdded:Wait()
    hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum then
        animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
        animation = Instance.new("Animation")
        animation.AnimationId = "rbxassetid://" .. animationId
        track = animator:LoadAnimation(animation)
        track.Priority = Enum.AnimationPriority.Action
        track.Looped = true
        track:Play()
        return track
    end
end

for name, id in pairs(Animations) do
    Tracks[id] = nil
    MiscRight2:AddToggle('Anim' .. name, {
        Text = name,
        Default = false,
        Callback = function(Value)
            if Value then
                if not Tracks[id] then
                    Tracks[id] = PlayAnimation(id)
                end
            else
                if Tracks[id] then
                    Tracks[id]:Stop()
                    Tracks[id] = nil
                end
            end
        end
    })
end

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats

MiscRight2:AddToggle('FakeDowned', {
    Text = 'Fake-Downed',
    Default = false,
    Callback = function(Value)
        charStats[player.Name].Downed.Value = Value
    end
})

charStats[player.Name].Changed:Connect(function()
    if not charStats:FindFirstChild(player.Name) then
        charStats.ChildAdded:Wait()
    end
    Toggles.FakeDowned:SetValue(Toggles.FakeDowned.Value)
end)

player.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        charStats.ChildAdded:Wait()
        Toggles.FakeDowned:SetValue(Toggles.FakeDowned.Value)
    end)
end)

Messages = {
    LqnHub = {
        "LQN HUB vibes! Dominate with style!",
        "Unleash chaos with LQN HUB power!",
        "Top-tier gameplay? LQN HUB way!",
        "Crush it with LQN HUB magic!",
        "LQN HUB hype! Rule the game!",
        "Stay ahead with LQN HUB elite!",
        "Game just got better! LQN HUB zone!",
        "LQN HUB flow! Outplay everyone!",
        "Be a legend with LQN HUB rise!",
        "Own the game with LQN HUB energy!",
        "LQN HUB squad! Lead the pack!",
        "Pros choose LQN HUB glory!",
        "Level up your game! LQN HUB fire!",
        "LQN HUB rush! Make every moment count!",
        "Master the game with LQN HUB skill!",
        "No one stops LQN HUB!",
        "Game’s finest? That’s LQN HUB!",
        "LQN HUB spark! Ignite your run!",
        "Play smarter with LQN HUB edge!",
        "Domination starts with LQN HUB!"
    },
    Russian = {
        "Я в игре, и это уже победа!",
        "Кто тут главный? Очевидно я!",
        "Играю так, что все в шоке!",
        "Это мой момент, не мешайте!",
        "Смотрите и учитесь, новички!",
        "Я в деле, и это чувствуется!",
        "Геймплей на миллион, как всегда!",
        "Кто хочет попробовать? Го!",
        "Я тут, чтобы всех удивить!",
        "Игра идет, а я на волне!",
        "Мой вайб в игре непобедим!",
        "Кто следующий? Я готов!",
        "Играю, как будто это финал!",
        "Все смотрят на меня, и не зря!",
        "Я в игре, и это шоу!",
        "Кто может лучше? Никто!",
        "Мой стиль в игре? Безупречно!",
        "Игра кипит, а я на вершине!",
        "Я тут, чтобы зажечь!",
        "Геймплей? Я его определяю!",
        "Я рулю в этой игре, попробуй догони!",
        "Мои скиллы просто огонь, держись!",
        "В игре я король, без вопросов!",
        "Мой вайб — это чистый взрыв!",
        "Я здесь, чтобы доминировать!",
        "Играю так, что все завидуют!",
        "Мой стиль не повторить, учись!",
        "Я в игре, и это эпик!",
        "Кто хочет бросить вызов? Я жду!",
        "Мои мувы — это чистое золото!",
        "Я задаю тон в этой игре!",
        "Играю, как профи, без шансов!",
        "Мой геймплей — это легенда!",
        "Я в игре, и это мой трон!",
        "Кто может тягаться? Никто!",
        "Мои скиллы сияют ярче всех!",
        "Я здесь, чтобы всех порвать!",
        "Игра кипит, а я на пике!",
        "Мой вайб — это чистый адреналин!",
        "Я играю, как будто это кино!",
        "Мои мувы — это чистый класс!",
        "Я в игре, и это мой мир!",
        "Кто следующий? Я уже готов!",
        "Мой стиль в игре — это шедевр!",
        "Играю так, что все в агонии!",
        "Я здесь, чтобы всех удивить!",
        "Мой геймплей — это чистый флекс!",
        "Я рулю, а вы лишь смотрите!",
        "Мои скиллы — это чистый взрыв!",
        "Я в игре, и это мой спектакль!",
        "Кто хочет попробовать? Вперед!",
        "Мой стиль — это чистая магия!",
        "Я играю, как будто я босс!",
        "Мои мувы — это чистый вайб!",
        "Я здесь, чтобы всех затмить!",
        "Играю так, что все в восторге!",
        "Мой геймплей — это чистый шик!",
        "Я в игре, и это мой момент!",
        "Кто может лучше? Да никто!",
        "Мои скиллы — это чистый огонь!",
        "Я здесь, чтобы всех разнести!",
        "Игра кипит, а я на волне!",
        "Мой вайб — это чистый триумф!",
        "Я играю, как будто я звезда!",
        "Мои мувы — это чистый фокус!",
        "Я в игре, и это мой путь!",
        "Кто следующий? Я наготове!",
        "Мой стиль — это чистый блеск!",
        "Играю так, что все в шоке!",
        "Мой геймплей — это чистый хайп!",
        "Я рулю, а вы лишь мечтаете!",
        "Мои скиллы — это чистый класс!",
        "Я в игре, и это мой пик!",
        "Кто хочет вызов? Я здесь!",
        "Мой стиль — это чистый вайб!",
        "Я играю, как будто я легенда!",
        "Мои мувы — это чистый триумф!",
        "Я здесь, чтобы всех покорить!",
        "Играю так, что все в ауте!",
        "Мой геймплей — это чистый фейерверк!",
        "Я в игре, и это мой трон!",
        "Кто может тягаться? Никто!",
        "Мои скиллы — это чистый космос!",
        "Я здесь, чтобы всех взорвать!"
    },
    English = {
        "I’m in the game, and it’s already a win!",
        "Who’s the boss? Yeah, that’s me!",
        "Playing so good, everyone’s stunned!",
        "This is my time, don’t interrupt!",
        "Watch and learn, newbies!",
        "I’m here, and it’s a vibe!",
        "Gameplay’s on point, as usual!",
        "Who wants a challenge? Let’s go!",
        "I’m here to steal the show!",
        "Game’s on, and I’m riding the wave!",
        "My vibe in game? Unbeatable!",
        "Who’s next? I’m ready!",
        "Playing like it’s the grand final!",
        "All eyes on me, and for good reason!",
        "I’m in, and it’s a spectacle!",
        "Who can top this? No one!",
        "My game style? Flawless!",
        "Game’s heating up, and I’m on top!",
        "I’m here to light it up!",
        "Gameplay? I’m setting the standard!",
        "I’m running this game, catch up!",
        "My skills are pure fire, watch out!",
        "I’m the king of this game, no doubt!",
        "My vibe’s a total explosion!",
        "I’m here to dominate, step up!",
        "Playing so good, they’re jealous!",
        "My style’s untouchable, learn it!",
        "I’m in the game, and it’s epic!",
        "Who wants to test me? I’m ready!",
        "My moves are straight gold!",
        "I’m setting the pace in this game!",
        "Playing like a pro, no contest!",
        "My gameplay’s a legend already!",
        "I’m in, and this is my throne!",
        "Who can match me? Nobody!",
        "My skills shine brighter than all!",
        "I’m here to crush it, watch me!",
        "Game’s on fire, and I’m the spark!",
        "My vibe’s pure adrenaline rush!",
        "I’m playing like it’s a movie!",
        "My moves are pure class, see it!",
        "I’m in the game, and it’s my world!",
        "Who’s next? I’m locked and loaded!",
        "My style’s a masterpiece, study it!",
        "Playing so good, they’re shook!",
        "My gameplay’s pure hype, feel it!",
        "I’m running the show, just watch!",
        "My skills are a total blast!",
        "I’m in, and it’s my stage!",
        "Who wants a shot? I’m waiting!",
        "My style’s pure magic, behold!",
        "I’m playing like I’m the boss!",
        "My moves are pure vibe, catch it!",
        "I’m here to outshine everyone!",
        "Playing so good, they’re stunned!",
        "My gameplay’s pure flair, see it!",
        "I’m in the game, and it’s my time!",
        "Who can do better? No one!",
        "My skills are pure heat, feel it!",
        "I’m here to wreck it, let’s go!",
        "Game’s alive, and I’m the pulse!",
        "My vibe’s a total triumph!",
        "I’m playing like a superstar!",
        "My moves are pure focus, watch!",
        "I’m in, and it’s my journey!",
        "Who’s up next? I’m prepped!",
        "My style’s pure shine, check it!",
        "Playing so good, it’s unreal!",
        "My gameplay’s a total banger!",
        "I’m ruling, and you’re just dreaming!",
        "My skills are pure class, own it!",
        "I’m in the game, and it’s my peak!",
        "Who wants a challenge? I’m here!",
        "My style’s pure vibe, feel it!",
        "I’m playing like I’m a legend!",
        "My moves are pure victory!",
        "I’m here to conquer it all!",
        "Playing so good, they’re out!",
        "My gameplay’s a pure fireworks show!",
        "I’m in, and it’s my crown!",
        "Who can compete? Nobody!",
        "My skills are pure cosmos!",
        "I’m here to blow it up!"
    },
    TrashTalk = {
        English = {
            "GET GOOD HOLY",
            "WOW LOL YOURE ACTUALLY SO TRASH",
            "I CANT BELIEVE THATS YOUR AIM",
            "AINT A WAY YOU AIM LIKE THAT LOOOOOOL",
            "MY GRANDMA CAN AIM BETTER THAN THAT LOOOOOOOOOOOOOL",
            "WOW, I STARTED TO FALL ASLEEP YOURE SO BAD",
            "Bro, your aim’s so lame it hurts to watch!",
            "Your moves are so weak I’m falling asleep!",
            "You’re playing like a noob who just spawned!",
            "Did you even try to aim or just give up?",
            "Your skills are so boring I’m zoning out!",
            "Bro, my pet fish could dodge better!",
            "You’re moving like a sleepy turtle!",
            "That was your best move? I’m laughing!",
            "Your gameplay’s so weak it’s painful!",
            "Bro, you’re playing like a lost newbie!",
            "Your aim’s so off it’s a total joke!",
            "You’re out here flopping every second!",
            "Did you aim at the clouds for fun?",
            "Your moves are so lame I’m yawning!",
            "Bro, my cat could play better than you!",
            "You’re so weak it’s almost funny!",
            "Your skills are napping on the job!",
            "You’re playing like you forgot the keys!",
            "Bro, that move was pure nonsense!",
            "Your aim’s so bad it’s a world record!",
            "You’re moving like a stuck robot!",
            "Did you learn to play from a brick?",
            "Your gameplay’s so dull I’m nodding off!",
            "Bro, you’re the king of weak plays!",
            "You’re out here missing every shot!",
            "Your aim’s like a broken compass!",
            "You’re playing like a confused bot!",
            "Bro, my lamp could aim better!",
            "Your moves are a total snooze!",
            "You’re so slow I forgot you’re here!",
            "Did you aim at the floor or what?",
            "Your gameplay’s a complete mess!",
            "Bro, you’re the champ of lame moves!",
            "You’re playing like you’re half asleep!",
            "Your skills are lost in the dark!",
            "You’re out here failing every chance!",
            "Bro, my chair could dodge better!",
            "Your aim’s so weak it’s a comedy!",
            "You’re moving like a frozen snail!",
            "Did you trip over your own skills?",
            "Your gameplay’s a total flop show!",
            "Bro, you’re playing like a rookie!",
            "Your moves are pure chaos, not good!",
            "You’re so bad it’s kinda hilarious!",
            "Bro, my toaster could play better!",
            "Your aim’s so off it’s a mystery!",
            "You’re playing like a lagging noob!",
            "Did you forget how to move or what?",
            "Your gameplay’s a walking disaster!",
            "Bro, you’re the master of weak plays!",
            "You’re out here fumbling every move!",
            "Your aim’s so lame it’s iconic!",
            "You’re moving like a tired sloth!",
            "Bro, that was a legendary flop!",
            "Your skills are hiding in a void!",
            "You’re playing like you just started!",
            "Did you aim at the sky for laughs?",
            "Your gameplay’s a pure trainwreck!",
            "Bro, my pillow could aim better!",
            "You’re so weak it’s almost epic!",
            "Your moves are a big facepalm!",
            "You’re out here losing with flair!",
            "Bro, you’re playing like a sleepy bot!",
            "Your aim’s so bad it’s historic!",
            "Did you learn to play from a rock?",
            "Your gameplay’s making me dizzy!",
            "Bro, you’re the emperor of flops!",
            "You’re moving like a broken toy!",
            "Your aim’s so weak it’s a myth!",
            "You’re playing like a total newbie!",
            "Bro, my fridge could dodge better!",
            "Your moves are a complete oof!",
            "You’re so bad it’s almost art!",
            "Did you aim at the moon for fun?",
            "Your gameplay’s a total wipeout!",
            "Bro, you’re the king of noob plays!",
            "You’re out here missing with style!",
            "Your aim’s so off it’s unreal!",
            "You’re playing like a confused noob!",
            "Bro, that move was pure chaos!",
            "Your skills are stuck in a loop!",
            "You’re moving like a lazy zombie!",
            "Did you forget the game controls?",
            "Your gameplay’s a total yawn!",
            "Bro, my table could play better!",
            "You’re so weak it’s a spectacle!",
            "Your aim’s like a wild guess!",
            "You’re playing like you’re lost!",
            "Bro, you’re the champ of fails!",
            "Your moves are a total blur!",
            "You’re out here flopping hard!",
            "Did you aim at nothing or what?",
            "Your gameplay’s a pure meltdown!",
            "Bro, my shoe could aim better!",
            "You’re so bad it’s a legend!",
            "Your aim’s so weak it’s a farce!",
            "You’re playing like a sleepy rookie!",
            "Bro, that was a massive whiff!",
            "Your skills are nowhere to be found!",
            "You’re out here failing with gusto!",
            "Did you trip on your own moves?",
            "Your gameplay’s a complete bust!",
            "Bro, my rug could dodge better!",
            "You’re moving like a stuck wheel!",
            "Your aim’s so bad it’s a saga!",
            "You’re playing like a dazed bot!",
            "Bro, you’re the lord of weak plays!",
            "Your moves are a total letdown!",
            "You’re so bad it’s almost cool!",
            "Did you aim at the stars or what?",
            "Your gameplay’s a pure fiasco!",
            "Bro, my cup could play better!",
            "You’re out here losing every round!",
            "Your aim’s so lame it’s a tale!",
            "You’re playing like a noob in panic!",
            "Bro, that move was a total dud!",
            "Your skills are asleep at the wheel!",
            "You’re moving like a rusty gear!",
            "Did you forget how to aim or what?",
            "Your gameplay’s a complete haze!",
            "Bro, my sock could aim better!",
            "You’re so weak it’s a masterpiece!",
            "Your aim’s like a broken radar!",
            "You’re playing like a baffled noob!",
            "Bro, you’re the prince of flops!",
            "Your moves are a total washout!",
            "You’re out here failing in style!",
            "Did you aim at the void for kicks?",
            "Your gameplay’s a pure calamity!",
            "Bro, my hat could dodge better!",
            "You’re so bad it’s a phenomenon!",
            "Your aim’s so weak it’s a story!",
            "You’re playing like a zoned-out bot!",
            "Bro, that was a colossal miss!",
            "Your skills are lost in the mist!",
            "You’re out here flopping with flair!",
            "Did you trip over your own aim?",
            "Your gameplay’s a total shambles!",
            "Bro, my pen could play better!",
            "You’re moving like a sleepy ghost!",
            "Your aim’s so bad it’s a chronicle!",
            "You’re playing like a rookie in shock!",
            "Bro, you’re the duke of weak plays!",
            "Your moves are a complete flop!",
            "You’re so bad it’s almost mythic!",
            "Did you aim at the ground for fun?",
            "Your gameplay’s a pure disaster!",
            "Bro, my spoon could aim better!",
            "You’re out here losing with gusto!",
            "Your aim’s so lame it’s a legend!",
            "You’re playing like a clueless bot!",
            "Bro, that move was a total bust!",
            "Your skills are stuck in the mud!",
            "You’re moving like a tired bot!",
            "Did you forget the game or what?",
            "Your gameplay’s a complete blur!",
            "Bro, my book could dodge better!"
        },
        Russian = {
            "Серьезно, это твой прицел? Ха!",
            "Бро, мой хомяк быстрее бегает!",
            "Ты забыл, как играть, или что?",
            "Твои скиллы где-то в отпуске!",
            "Боты и то лучше играют!",
            "Ты вообще стараешься или троллишь?",
            "Мой младший брат тебя уделает!",
            "Это твой лучший выстрел? Скука!",
            "Твой геймплей? Спящий режим!",
            "Твой прицел как у штурмовика!",
            "Сказал бы 'хорошая попытка', но нет!",
            "Твои движения такие предсказуемые!",
            "Бро, удали игру, спаси нас!",
            "Даже мой вайфай играет лучше!",
            "Ты играешь, будто без пальцев!",
            "Мой пёс лучше уклоняется!",
            "Это твой план? Я ржу!",
            "Ты движешься, как статуя!",
            "Ты с закрытыми глазами целишься?",
            "Твой геймплей — это кринж!",
            "Бро, ты делаешь это слишком легко!",
            "Какая отмазка теперь? Лаги?",
            "Ты так слаб, я устал смотреть!",
            "Ты играешь, как сломанный джойстик!",
            "Моя рыбка лучше целится!",
            "Твой мув — это просто зевота!",
            "Ты тонешь в игре, как в болоте!",
            "Ты учишься промахиваться или как?",
            "Твои скиллы застряли на старте!",
            "Я ржу с твоего прицела!",
            "Бро, ты как мем с фейлами!",
            "Это игра? Нет, это твой сон!",
            "Твой прицел — это комедия!",
            "Даже картошка лучше играет!",
            "Ты как в клею застрял!",
            "Бро, это мастер-класс по промахам!",
            "Твой геймплей — сплошная скука!",
            "Ты учишься играть у тостера?",
            "Ты так медленный, я тебя забыл!",
            "Твой прицел — это головная боль!",
            "Бро, ты король плохих мувов!",
            "Твои скиллы в вечном отпуске!",
            "Мне скучно смотреть на твой фейл!",
            "Ты играешь, как в первый раз!",
            "Бро, твой прицел — это анекдот!",
            "Ты спотыкаешься на пустом месте!",
            "Ты в небо целишься специально?",
            "Твой геймплей — это катастрофа!",
            "Мой кот тебя переиграет!",
            "Ты так слаб, это почти искусство!",
            "Бро, твой фейл войдет в историю!",
            "Ты играешь, как полусонный!",
            "Твой прицел — это легенда!",
            "Твой прицел как в тумане!",
            "Бро, ты играешь, как ржавый бот!",
            "Твои мувы — полный краш!",
            "Ты вообще читал управление?",
            "Твой прицел такой слабый, я в шоке!",
            "Бро, ты чемпион по промахам!",
            "Это твой план? Сплошной провал!",
            "Ты движешься, как сонная черепаха!",
            "Твой геймплей — это тоска, проснись!",
            "Бро, ты аллергик на победы!",
            "Твой прицел — это просто рандом!",
            "Ты играешь, как потерянный нуб!",
            "Ты споткнулся о свои скиллы?",
            "Твои мувы — это сплошной ржач!",
            "Бро, ты застрял в режиме фейла!",
            "Твой прицел такой плохой, это классика!",
            "Ты играешь, будто наобум!",
            "Твой геймплей — это хаос, ооф!",
            "Бро, мой улитка тебя обгонит!",
            "Ты так слаб, это даже смешно!",
            "Твой прицел уже сдался!",
            "Ты забыл, для чего кнопки?",
            "Ты играешь, как лагающий бот!",
            "Бро, это был курс по фейлам!",
            "Твои мувы — хаос, но не крутой!",
            "Ты фейлишь с особым шиком!",
            "Твой прицел не знает, куда целиться!",
            "Бро, ты мастер задыхаться на старте!",
            "Ты играешь, как с завязанными глазами!",
            "Твои скиллы улетели в космос!",
            "Бро, моя лампа лучше играет!",
            "Ты движешься, как замороженный сок!",
            "Твой прицел — это мировой рекорд фейлов!",
            "Бро, ты играешь, как сонный зомби!",
            "Твои мувы — это поездка в никуда!",
            "Ты фейлишь каждую секунду!",
            "Ты целишься в пол для прикола?",
            "Твой геймплей — это шоу клоунов!",
            "Бро, мой стул лучше уклоняется!",
            "Ты так слаб, это почти круто!",
            "Твой прицел — как сломанный компас!",
            "Ты играешь, как растерянный бот!",
            "Бро, этот мув был просто бред!",
            "Твои скиллы спят на работе!",
            "Ты промахиваешься каждую минуту!",
            "Ты учишься играть у камня?",
            "Твой геймплей кружит голову!",
            "Бро, ты император фейлов!",
            "Ты движешься, как робот без батареек!",
            "Твой прицел — это сплошная загадка!",
            "Ты играешь, как новичок в панике!",
            "Бро, мой холодильник лучше целится!",
            "Твои мувы — это сплошной фейспалм!",
            "Ты проигрываешь с особым стилем!",
            "Ты целишься в луну или как?",
            "Твой геймплей — это ходячий ооф!",
            "Бро, ты мастер эпичных провалов!",
            "Ты играешь, как в странном сне!",
            "Твой прицел — это исторический фейл!",
            "Ты движешься, как уставшая улитка!",
            "Бро, это был легендарный промах!",
            "Твои скиллы прячутся во тьме!",
            "Ты играешь, как нуб наобум!",
            "Ты забыл, как двигаться, или что?",
            "Твой геймплей — это полный вынос!",
            "Бро, моя подушка лучше играет!",
            "Ты играешь, как на автопилоте!",
            "Твой прицел — это просто миф!",
            "Бро, ты застрял в прошлом веке!",
            "Твои мувы — это сплошной лол!",
            "Ты фейлишь, как настоящий профи!",
            "Твой прицел тонет в болоте!",
            "Бро, ты играешь, как в замедленке!",
            "Твои скиллы ушли в спячку!",
            "Ты промахнулся в миллионный раз!",
            "Ты учишься у чайника играть?",
            "Твой геймплей — это сплошной ржач!",
            "Бро, ты король эпичных фейлов!",
            "Ты движешься, как ленивый кот!",
            "Твой прицел — это чистый анриал!",
            "Ты играешь, как в параллельной реальности!",
            "Бро, мой кактус лучше целится!",
            "Твои мувы — это полный абсурд!",
            "Ты проигрываешь с особым шармом!",
            "Ты целишься в другую игру или что?",
            "Твой геймплей — это мемный фейл!",
            "Бро, ты чемпион по лузам!",
            "Ты играешь, как в полусне!",
            "Твой прицел — это сплошной трэш!",
            "Ты движешься, как сонный мишка!",
            "Бро, это был фейл века!",
            "Твои скиллы утонули в луже!",
            "Ты играешь, как заблудший нуб!",
            "Ты забыл, где кнопки, или как?",
            "Твой геймплей — это чистый краш!",
            "Бро, мой тапок лучше играет!"
        }
    }
}

IsSpamming = false
SelectedMode = "LqnHub"
TrashTalkLanguage = "English"
LastMessageTime = 0
Cooldown = 2.6

MiscRight4:AddToggle('SpamToggle', {
    Text = 'Chat Spam',
    Default = false,
    Callback = function(Value)
        IsSpamming = Value
    end
})

MiscRight4:AddDropdown('ModeDropdown', {
    Values = { 'LqnHub', 'Russian', 'English', 'TrashTalk' },
    Default = 1,
    Text = 'Message Type',
    Callback = function(Value)
        SelectedMode = Value
    end
})

MiscRight4:AddDropdown('TrashTalkLanguageDropdown', {
    Values = { 'English', 'Russian' },
    Default = 1,
    Text = 'TrashTalk Language',
    Callback = function(Value)
        TrashTalkLanguage = Value
    end
})

task.spawn(function()
    while true do
        if IsSpamming and (tick() - LastMessageTime >= Cooldown) then
            if SelectedMode == "TrashTalk" then
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(Messages.TrashTalk[TrashTalkLanguage][math.random(1, #Messages.TrashTalk[TrashTalkLanguage])])
            else
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(Messages[SelectedMode][math.random(1, #Messages[SelectedMode])])
            end
            LastMessageTime = tick()
        end
        wait(0.1)
    end
end)

p = game:GetService("Players").LocalPlayer
enabled = false

function f()
    pcall(function()
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):SetKeyDown('0x20')
        task.wait(0.1)
        game:GetService("VirtualUser"):SetKeyUp('0x20')
    end)
    pcall(function()
        w = workspace.CurrentCamera
        w.CFrame = w.CFrame * CFrame.Angles(math.rad(0.5),0,0)
        task.wait(0.1)
        w.CFrame = w.CFrame * CFrame.Angles(math.rad(-0.5),0,0)
    end)
end

function enable()
    if enabled then return end
    enabled = true
    c1 = p.Idled:Connect(function() if enabled then f() end end)
    coroutine.resume(coroutine.create(function()
        while enabled do f() task.wait(30) end
    end))
    c2 = p.CharacterAdded:Connect(function()
        task.wait(1)
        if enabled then f() end
    end)
end

function disable()
    if not enabled then return end
    enabled = false
    if c1 then c1:Disconnect() c1 = nil end
    if c2 then c2:Disconnect() c2 = nil end
end

MiscRight3:AddToggle('AntiAFKToggle', {
    Text = "Anti AFK",
    Default = false,
    Callback = function(v)
        if v then enable() else disable() end
    end
})

AdminCheck_Enabled = false
AdminCheck_Connection = nil
AdminCheck_Coroutine = nil

AdminList = {
    ["tabootvcat"] = true, ["Revenantic"] = true, ["Saabor"] = true, ["MoIitor"] = true, ["IAmUnderAMask"] = true,
    ["SheriffGorji"] = true, ["xXFireyScorpionXx"] = true, ["LoChips"] = true, ["DeliverCreations"] = true,
    ["TDXiswinning"] = true, ["TZZV"] = true, ["FelixVenue"] = true, ["SIEGFRlED"] = true, ["ARRYvvv"] = true,
    ["z_papermoon"] = true, ["Malpheasance"] = true, ["ModHandIer"] = true, ["valphex"] = true, ["J_anday"] = true,
    ["tvdisko"] = true, ["yIlehs"] = true, ["COLOSSUSBUILTOFSTEEL"] = true, ["SeizedHolder"] = true, ["r3shape"] = true,
    ["RVVZ"] = true, ["adurize"] = true, ["codedcosmetics"] = true, ["QuantumCaterpillar"] = true,
    ["FractalHarmonics"] = true, ["GalacticSculptor"] = true, ["oTheSilver"] = true, ["Kretacaous"] = true,
    ["icarus_xs1goliath"] = true, ["GlamorousDradon"] = true, ["rainjeremy"] = true, ["parachuter2000"] = true,
    ["faintermercury"] = true, ["harht"] = true, ["Sansek1252"] = true, ["Snorpuwu"] = true, ["BenAzoten"] = true,
    ["Cand1ebox"] = true, ["KeenlyAware"] = true, ["mrzued"] = true, ["BruhmanVIII"] = true, ["Nystesia"] = true,
    ["fausties"] = true, ["zateopp"] = true, ["Iordnabi"] = true, ["ReviveTheDevil"] = true, ["jake_jpeg"] = true,
    ["UncrossedMeat3888"] = true, ["realpenyy"] = true, ["karateeeh"] = true, ["JayyMlg"] = true, ["Lo_Chips"] = true,
    ["Avelosky"] = true, ["king_ab09"] = true, ["TigerLe123"] = true, ["Dalvanuis"] = true, ["iSonMillions"] = true,
    ["DieYouOder"] = true, ["whosframed"] = true
}

CheckAdmins = function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if AdminList[plr.Name] then
            LocalPlayer:Kick("Admin")
            task.wait(2)
            game:Shutdown()
            return
        end
    end
end

AdminCheck_Enable = function()
    if AdminCheck_Enabled then return end
    AdminCheck_Enabled = true
    CheckAdmins()
    AdminCheck_Connection = Players.PlayerAdded:Connect(function(plr)
        if not AdminCheck_Enabled then return end
        if AdminList[plr.Name] then
            LocalPlayer:Kick("Detected Admin")
            task.wait(2)
            game:Shutdown()
        end
    end)
    AdminCheck_Coroutine = coroutine.create(function()
        while AdminCheck_Enabled do
            CheckAdmins()
            task.wait(4)
        end
    end)
    coroutine.resume(AdminCheck_Coroutine)
end

AdminCheck_Disable = function()
    if not AdminCheck_Enabled then return end
    AdminCheck_Enabled = false
    if AdminCheck_Connection then
        AdminCheck_Connection:Disconnect()
        AdminCheck_Connection = nil
    end
    AdminCheck_Coroutine = nil
end

MiscRight3:AddToggle('AdminCheckToggle', {
    Text = "Admin & Moderator Check",
    Default = false,
    Callback = function(Value)
        if Value then
            AdminCheck_Enable()
        else
            AdminCheck_Disable()
        end
    end
})

fastPickupEnabled = false

function bypassProximityPrompts()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end

function enableBypass()
    fastPickupEnabled = true
    bypassProximityPrompts()
    game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(v)
        if fastPickupEnabled then
            v.HoldDuration = 0
        end
    end)
end

function disableBypass()
    fastPickupEnabled = false
end

MiscRight3:AddToggle('FastInteract_Toggle', {
    Text = "Fast Interact",
    Default = false,
    Callback = function(Value)
        if Value then
            enableBypass()
        else
            disableBypass()
        end
    end
})

MiscRight3:AddToggle('ChatToggle', {
    Text = "Chat Enabler",
    Default = false,
    Callback = function(Value)
        game:GetService("TextChatService").ChatWindowConfiguration.Enabled = Value
    end
})

MiscRight3:AddToggle('DisableParts', {
    Text = "NoBarriers",
    Tooltip = "Makes you invincible to BarbedWires, and Grinders",
    Default = false,
    Callback = function(State)
        findAndDisableParts(not State)
        findAndDisableParts2(not State)
    end
})

function disableTouchAndQuery(part, value)
    if part:IsA("BasePart") then
        part.CanTouch = value
        part.CanQuery = value
    end
end

function findAndDisableParts(value)
    partNames = {"BarbedWire", "RG_Part", "Spike"}
    for _, partName in ipairs(partNames) do
        for _, part in pairs(game.Workspace:GetDescendants()) do
            if part.Name == partName then
                disableTouchAndQuery(part, value)
            end
        end
    end
end

function findAndDisableParts2(value)
    partNames2 = {"FirePart", "Grinder"}
    for _, partName in ipairs(partNames2) do
        for _, part in pairs(game.Workspace:GetDescendants()) do
            if part.Name == partName then
                disableTouchAndQuery(part, value)
            end
        end
    end
end

player = game.Players.LocalPlayer
charStats = game:GetService("ReplicatedStorage").CharStats
parts = {"Head", "Left Arm", "Left Leg", "Right Arm", "Right Leg"}

MiscRight3:AddToggle('BreakParts', {
    Text = 'Break Limbs',
    Default = false,
    Callback = function(Value)
        for _, part in ipairs(parts) do
            if charStats[player.Name].HealthValues[part] then
                charStats[player.Name].HealthValues[part].Broken.Value = Value
            end
        end
    end
})

MiscRight3:AddToggle('UnbreakParts', {
    Text = 'Unbreak Limbs',
    Default = false,
    Callback = function(Value)
        for _, part in ipairs(parts) do
            if charStats[player.Name].HealthValues[part] then
                charStats[player.Name].HealthValues[part].Broken.Value = false
            end
        end
    end
})

game:GetService("RunService").RenderStepped:Connect(function()
    if Toggles.UnbreakParts.Value then
        for _, part in ipairs(parts) do
            if charStats[player.Name].HealthValues[part] then
                charStats[player.Name].HealthValues[part].Broken.Value = false
            end
        end
    end
end)

spinEnabled = false
spinSpeed = 1000
player = game.Players.LocalPlayer
character = player.Character or player.CharacterAdded:Wait()
humanoidRootPart = character:WaitForChild("HumanoidRootPart")

spinToggle = MiscRight3:AddToggle("SpinToggle", {
    Text = "Spin",
    Default = false,
    Callback = function(value)
        spinEnabled = value
    end,
}):AddKeyPicker("SpinKey", {
    Default = "None", 
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Spin",
    Callback = function()
    end,
})

hiddenfling, movel = false, 0.1

function fling()
    while hiddenfling do
        game:GetService("RunService").Heartbeat:Wait()
        char = game:GetService("Players").LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        if hrp then
            vel = hrp.Velocity
            hrp.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
            game:GetService("RunService").RenderStepped:Wait()
            hrp.Velocity = vel
            game:GetService("RunService").Stepped:Wait()
            hrp.Velocity = vel + Vector3.new(0, movel, 0)
            movel = -movel
        end
    end
end

MiscRight3:AddToggle('FlingToggle', {
    Text = "Fling",
    Default = false,
    Callback = function(Value)
        hiddenfling = Value
        if Value then
            if not flingTask then
                flingTask = task.spawn(fling)
            end
        else
            if flingTask then
                task.cancel(flingTask)
                flingTask = nil
            end
        end
    end,
}):AddKeyPicker("FlingKey", {
    Default = "None", 
    SyncToggleState = true,
    Mode = "Toggle",
    Text = "Fling",
    Callback = function()
    end,
})

work = false

MiscRight3:AddToggle('VelocityToggle', {
    Text = 'Anti-Fling',
    Default = false,
    Callback = function(Value)
        work = Value
    end
})

RunService.RenderStepped:Connect(function()
    if not work then return end
    char = LocalPlayer.Character
    if not char then return end
    hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    oldVelocity = hrp.Velocity

    for _, part in pairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanTouch = false
            if part.Velocity.Magnitude > oldVelocity.Magnitude * 3 then
                part.Velocity = Vector3.zero
            end
        end
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            plrChar = player.Character
            if plrChar then
                for _, part in pairs(plrChar:GetChildren()) do
                    if part:IsA("BasePart") then
                        if part.Velocity.Magnitude > oldVelocity.Magnitude * 1.3 then
                            part.Velocity = Vector3.zero
                            part.CanTouch = false
                        end
                    end
                end
            end
        end
    end
end)

FinishSpeedMulti = game:GetService("ReplicatedStorage").Values.FinishSpeedMulti

MiscRight3:AddToggle('FinishSpeedToggle', {
    Text = 'Finish Speed',
    Default = false,
    Callback = function(Value)
        if Value then
            FinishSpeedMulti.Value = Options.FinishSpeedSlider.Value
        else
            FinishSpeedMulti.Value = 1
        end
    end
})

MiscRight3:AddSlider("SpeedSlider", {
    Text = "Spin Speed",
    Default = 1000,
    Min = 1000,
    Max = 10000,
    Rounding = 1,
    Callback = function(value)
        spinSpeed = value
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if spinEnabled and humanoidRootPart then
        humanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0, math.rad(spinSpeed / 10), 0)
    end
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
end)

MiscRight3:AddSlider('FinishSpeedSlider', {
    Text = 'Finish Speed',
    Default = 1,
    Min = 1,
    Max = 2,
    Rounding = 1,
    Compact = false,
    Callback = function(Value)
        if Toggles.FinishSpeedToggle.Value then
            FinishSpeedMulti.Value = Value
        end
    end
})

Options.FinishSpeedSlider:OnChanged(function()
    if Toggles.FinishSpeedToggle.Value then
        FinishSpeedMulti.Value = Options.FinishSpeedSlider.Value
    end
end)

MenuGroup = Tabs.Settings:AddLeftGroupbox('Menu')

--MouseEnabled = true
--game:GetService("RunService").RenderStepped:Connect(function()
--    game:GetService("UserInputService").MouseIconEnabled = MouseEnabled
--end)

--MenuGroup:AddToggle('MouseVisibilityToggle', {
--    Text = 'Show Mouse',
--    Default = true,
--    Callback = function(Value) 
--        MouseEnabled = Value
--    end
--})

MenuGroup:AddToggle('KeybindFrameToggle', {
    Text = 'Show Keybinds gui',
    Default = false,
    Callback = function(Value)
        Library.KeybindFrame.Visible = Value
    end
})

UnloadButton = MenuGroup:AddButton({
    Text = 'Unload',
    Func = function()
        Library:Unload()
    end
})

MenuKeybind = MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
    Default = 'RightShift',
    Mode = 'Toggle',
    Text = 'Menu keybind',
    NoUI = true,
    Callback = function(Value) end
})

Library.ToggleKeybind = Options.MenuKeybind

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({'MenuKeybind'})

ThemeManager:SetFolder('LQN')
SaveManager:SetFolder('LQN/configs')

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Library:Notify("Join in discord - discord.gg/jWv4vzY86T", 20)
