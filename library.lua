local v1={}
v1.__index=v1

local v2=game:GetService("Players").LocalPlayer
local v3=game:GetService("UserInputService")
local v4=game:GetService("TweenService")
local v5=game:GetService("RunService")

local vc=function()
local v6="Font_"..tostring(math.random(10000,99999))
local v7="Folder_"..tostring(math.random(10000,99999))
if isfolder("UI_Fonts")then delfolder("UI_Fonts")end
makefolder(v7)
local v8=v7.."/"..v6..".ttf"
local v9=v7.."/"..v6..".json"
local v10=v7.."/"..v6..".rbxmx"
if not isfile(v8)then
local v11=pcall(function()
local v12=request({Url="https://raw.githubusercontent.com/bluescan/proggyfonts/refs/heads/master/ProggyOriginal/ProggyClean.ttf",Method="GET"})
if v12 and v12.Success then writefile(v8,v12.Body)return true end
return false
end)
if not v11 then return Font.fromEnum(Enum.Font.Code)end
end
local v13=pcall(function()
local v14=readfile(v8)
local v15=game:GetService("TextService"):RegisterFontFaceAsync(v14,v6)
return v15
end)
if v13 then return v13 end
local v16=pcall(function()return Font.fromFilename(v8)end)
if v16 then return v16 end
local v17={name=v6,faces={{name="Regular",weight=400,style="Normal",assetId=getcustomasset(v8)}}}
writefile(v9,game:GetService("HttpService"):JSONEncode(v17))
local v18,v19=pcall(function()return Font.new(getcustomasset(v9))end)
if v18 then return v19 end
local v20=[[
<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External>
<External>nil</External>
<Item class="FontFace" referent="RBX0">
<Properties>
<Content name="FontData">
<url>rbxasset://]]..v8..[[</url>
</Content>
<string name="Family">]]..v6..[[</string>
<token name="Style">0</token>
<token name="Weight">400</token>
</Properties>
</Item>
</roblox>]]
writefile(v10,v20)
return Font.fromEnum(Enum.Font.Code)
end
local v21=vc()

function v1.new(v22)
local v23=setmetatable({},v1)
v23.name=v22 or "Library"
v23.open=true
v23.tabs={}
v23.currentTab=nil

v23.main=Instance.new("ScreenGui")
v23.main.Name="BitchBotLib"
v23.main.Parent=v2.PlayerGui

v23.mainFrame=Instance.new("Frame")
v23.mainFrame.Size=UDim2.new(0,500,0,400)
v23.mainFrame.Position=UDim2.new(0.5,-250,0.5,-200)
v23.mainFrame.BackgroundColor3=Color3.fromRGB(30,30,40)
v23.mainFrame.BorderSizePixel=1
v23.mainFrame.BorderColor3=Color3.fromRGB(60,60,70)
v23.mainFrame.Parent=v23.main

v23.titleBar=Instance.new("Frame")
v23.titleBar.Size=UDim2.new(1,0,0,30)
v23.titleBar.BackgroundColor3=Color3.fromRGB(25,25,35)
v23.titleBar.BorderSizePixel=1
v23.titleBar.BorderColor3=Color3.fromRGB(60,60,70)
v23.titleBar.Parent=v23.mainFrame

v23.title=Instance.new("TextLabel")
v23.title.Size=UDim2.new(1,-10,1,0)
v23.title.Position=UDim2.new(0,10,0,0)
v23.title.BackgroundTransparency=1
v23.title.Text=v23.name
v23.title.TextColor3=Color3.new(1,1,1)
v23.title.TextSize=14
v23.title.FontFace=v21
v23.title.TextXAlignment=Enum.TextXAlignment.Left
v23.title.Parent=v23.titleBar

v23.tabContainer=Instance.new("Frame")
v23.tabContainer.Size=UDim2.new(1,0,0,30)
v23.tabContainer.BackgroundColor3=Color3.fromRGB(35,35,45)
v23.tabContainer.BorderSizePixel=1
v23.tabContainer.BorderColor3=Color3.fromRGB(60,60,70)
v23.tabContainer.Parent=v23.mainFrame

v23.contentFrame=Instance.new("Frame")
v23.contentFrame.Size=UDim2.new(1,-20,1,-70)
v23.contentFrame.Position=UDim2.new(0,10,0,60)
v23.contentFrame.BackgroundTransparency=1
v23.contentFrame.Parent=v23.mainFrame

local v24=false
local v25
local v26

v23.titleBar.InputBegan:Connect(function(v27)
if v27.UserInputType==Enum.UserInputType.MouseButton1 then
v24=true
v25=v27.Position
v26=v23.mainFrame.Position
end
end)

v23.titleBar.InputEnded:Connect(function(v28)
if v28.UserInputType==Enum.UserInputType.MouseButton1 then
v24=false
end
end)

v3.InputChanged:Connect(function(v29)
if v24 and v29.UserInputType==Enum.UserInputType.MouseMovement then
local v30=v29.Position-v25
v23.mainFrame.Position=UDim2.new(v26.X.Scale,v26.X.Offset+v30.X,v26.Y.Scale,v26.Y.Offset+v30.Y)
end
end)

return v23
end

function v1:Tab(v31)
local v32={}
v32.name=v31
v32.sections={}

v32.button=Instance.new("TextButton")
v32.button.Size=UDim2.new(0,80,1,0)
v32.button.Position=UDim2.new(0,#self.tabs*80,0,0)
v32.button.BackgroundColor3=Color3.fromRGB(40,40,50)
v32.button.BorderSizePixel=1
v32.button.BorderColor3=Color3.fromRGB(60,60,70)
v32.button.Text=v31
v32.button.TextColor3=Color3.new(1,1,1)
v32.button.TextSize=12
v32.button.FontFace=v21
v32.button.Parent=self.tabContainer

v32.content=Instance.new("Frame")
v32.content.Size=UDim2.new(1,0,1,0)
v32.content.BackgroundTransparency=1
v32.content.Visible=false
v32.content.Parent=self.contentFrame

v32.button.MouseButton1Click:Connect(function()
for v33,v34 in pairs(self.tabs)do
v34.content.Visible=false
v34.button.BackgroundColor3=Color3.fromRGB(40,40,50)
end
v32.content.Visible=true
v32.button.BackgroundColor3=Color3.fromRGB(85,170,255)
self.currentTab=v32
end)

table.insert(self.tabs,v32)
if#self.tabs==1 then
v32.button.BackgroundColor3=Color3.fromRGB(85,170,255)
v32.content.Visible=true
self.currentTab=v32
end

function v32:Section(v35,v36)
local v37={}
v37.name=v35
v37.side=v36 or "left"

v37.frame=Instance.new("Frame")
v37.frame.Size=UDim2.new(0.5,-10,0,150)
if v37.side=="left"then
v37.frame.Position=UDim2.new(0,0,0,#v32.sections*160)
else
v37.frame.Position=UDim2.new(0.5,5,0,#v32.sections*160)
end
v37.frame.BackgroundColor3=Color3.fromRGB(35,35,45)
v37.frame.BorderSizePixel=1
v37.frame.BorderColor3=Color3.fromRGB(60,60,70)
v37.frame.Parent=v32.content

v37.title=Instance.new("TextLabel")
v37.title.Size=UDim2.new(1,-10,0,20)
v37.title.Position=UDim2.new(0,10,0,5)
v37.title.BackgroundTransparency=1
v37.title.Text=v35
v37.title.TextColor3=Color3.new(1,1,1)
v37.title.TextSize=12
v37.title.FontFace=v21
v37.title.TextXAlignment=Enum.TextXAlignment.Left
v37.title.Parent=v37.frame

v37.content=Instance.new("Frame")
v37.content.Size=UDim2.new(1,-20,1,-30)
v37.content.Position=UDim2.new(0,10,0,25)
v37.content.BackgroundTransparency=1
v37.content.Parent=v37.frame

local v38=0

function v37:UpdateLayout()
for v39,v40 in pairs(v37.content:GetChildren())do
if v40:IsA("Frame")then
v40.Position=UDim2.new(0,0,0,v38)
v38=v38+v40.AbsoluteSize.Y+5
end
end
end

table.insert(v32.sections,v37)

function v37:Checkbox(v41,v42,v43)
local v44=Instance.new("Frame")
v44.Size=UDim2.new(1,0,0,20)
v44.BackgroundTransparency=1
v44.Parent=v37.content

local v45=Instance.new("TextLabel")
v45.Size=UDim2.new(1,-25,1,0)
v45.Position=UDim2.new(0,0,0,0)
v45.BackgroundTransparency=1
v45.Text=v41
v45.TextColor3=Color3.new(1,1,1)
v45.TextSize=12
v45.FontFace=v21
v45.TextXAlignment=Enum.TextXAlignment.Left
v45.Parent=v44

local v46=Instance.new("Frame")
v46.Size=UDim2.new(0,15,0,15)
v46.Position=UDim2.new(1,-20,0.5,-7)
v46.BackgroundColor3=Color3.fromRGB(30,30,40)
v46.BorderSizePixel=1
v46.BorderColor3=Color3.fromRGB(80,80,90)
v46.Parent=v44

local v47=Instance.new("Frame")
v47.Size=UDim2.new(0,9,0,9)
v47.Position=UDim2.new(0.5,-4,0.5,-4)
v47.BackgroundColor3=Color3.fromRGB(85,170,255)
v47.BorderSizePixel=0
v47.Visible=v42 or false
v47.Parent=v46

local v48=v42 or false

local function v49()
v48=not v48
v47.Visible=v48
if v43 then
v43(v48)
end
end

v44.InputBegan:Connect(function(v50)
if v50.UserInputType==Enum.UserInputType.MouseButton1 then
v49()
end
end)

v37:UpdateLayout()

local v51={}
function v51:Set(v52)
if v48~=v52 then
v49()
end
end
return v51
end

function v37:TextLabel(v53)
local v54=Instance.new("Frame")
v54.Size=UDim2.new(1,0,0,20)
v54.BackgroundTransparency=1
v54.Parent=v37.content

local v55=Instance.new("TextLabel")
v55.Size=UDim2.new(1,0,1,0)
v55.BackgroundTransparency=1
v55.Text=v53
v55.TextColor3=Color3.new(1,1,1)
v55.TextSize=12
v55.FontFace=v21
v55.TextXAlignment=Enum.TextXAlignment.Left
v55.Parent=v54

v37:UpdateLayout()
return v55
end

function v37:Textbox(v56,v57,v58)
local v59=Instance.new("Frame")
v59.Size=UDim2.new(1,0,0,25)
v59.BackgroundTransparency=1
v59.Parent=v37.content

local v60=Instance.new("TextBox")
v60.Size=UDim2.new(1,0,1,0)
v60.BackgroundColor3=Color3.fromRGB(40,40,50)
v60.BorderSizePixel=1
v60.BorderColor3=Color3.fromRGB(60,60,70)
v60.Text=v57 or ""
v60.PlaceholderText=v56
v60.TextColor3=Color3.new(1,1,1)
v60.TextSize=12
v60.FontFace=v21
v60.TextXAlignment=Enum.TextXAlignment.Left
v60.Parent=v59

local v61=Instance.new("UIPadding")
v61.PaddingLeft=UDim.new(0,5)
v61.Parent=v60

v60.FocusLost:Connect(function(v62)
if v62 and v58 then
v58(v60.Text)
end
end)

v37:UpdateLayout()

local v63={}
function v63:Set(v64)
v60.Text=v64
end
return v63
end

return v37
end

return v32
end

return v1
end

return v1
