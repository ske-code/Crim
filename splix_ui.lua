
local function vc()
local v2="Font_"..tostring(math.random(10000,99999))
local v24="Folder_"..tostring(math.random(10000,99999))
if isfolder("UI_Fonts")then delfolder("UI_Fonts")end
makefolder(v24)
local v3=v24.."/"..v2..".ttf"
local v4=v24.."/"..v2..".json"
local v5=v24.."/"..v2..".rbxmx"
if not isfile(v3)then
local v8=pcall(function()
local v9=request({Url="https://raw.githubusercontent.com/bluescan/proggyfonts/refs/heads/master/ProggyOriginal/ProggyClean.ttf",Method="GET"})
if v9 and v9.Success then writefile(v3,v9.Body)return true end
return false
end)
if not v8 then return Font.fromEnum(Enum.Font.Code)end
end
local v12=pcall(function()
local v13=readfile(v3)
local v14=game:GetService("TextService"):RegisterFontFaceAsync(v13,v2)
return v14
end)
if v12 then return v12 end
local v15=pcall(function()return Font.fromFilename(v3)end)
if v15 then return v15 end
local v16={name=v2,faces={{name="Regular",weight=400,style="Normal",assetId=getcustomasset(v3)}}}
writefile(v4,game:GetService("HttpService"):JSONEncode(v16))
local v17,v18=pcall(function()return Font.new(getcustomasset(v4))end)
if v17 then return v18 end
local v19=[[
<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
<External>null</External>
<External>nil</External>
<Item class="FontFace" referent="RBX0">
<Properties>
<Content name="FontData">
<url>rbxasset://]]..v3..[[</url>
</Content>
<string name="Family">]]..v2..[[</string>
<token name="Style">0</token>
<token name="Weight">400</token>
</Properties>
</Item>
</roblox>]]
writefile(v5,v19)
return Font.fromEnum(Enum.Font.Code)
end
local vxc=vc()
local ws=game:GetService("Workspace")
local uis=game:GetService("UserInputService")
local rs=game:GetService("RunService")
local hs=game:GetService("HttpService")
local plrs=game:GetService("Players")
local stats=game:GetService("Stats")
local library={drawings={},hidden={},connections={},pointers={},began={},ended={},changed={},folders={main="splix",assets="splix/assets",configs="splix/configs"},shared={initialized=false,fps=0,ping=0}}
if not isfolder(library.folders.main) then makefolder(library.folders.main) end
if not isfolder(library.folders.assets) then makefolder(library.folders.assets) end
if not isfolder(library.folders.configs) then makefolder(library.folders.configs) end
local utility={}
local pages={}
local sections={}
local theme={accent=Color3.fromRGB(50,100,255),light_contrast=Color3.fromRGB(30,30,30),dark_contrast=Color3.fromRGB(20,20,20),outline=Color3.fromRGB(0,0,0),inline=Color3.fromRGB(50,50,50),textcolor=Color3.fromRGB(255,255,255),textborder=Color3.fromRGB(0,0,0),font=vxc,textsize=13}
function utility:Size(xScale,xOffset,yScale,yOffset,instance)
if instance then
local x=xScale*instance.Size.x+xOffset
local y=yScale*instance.Size.y+yOffset
return Vector2.new(x,y)
else
local vx,vy=ws.CurrentCamera.ViewportSize.x,ws.CurrentCamera.ViewportSize.y
local x=xScale*vx+xOffset
local y=yScale*vy+yOffset
return Vector2.new(x,y)
end
end
function utility:Position(xScale,xOffset,yScale,yOffset,instance)
if instance then
local x=instance.Position.x+xScale*instance.Size.x+xOffset
local y=instance.Position.y+yScale*instance.Size.y+yOffset
return Vector2.new(x,y)
else
local vx,vy=ws.CurrentCamera.ViewportSize.x,ws.CurrentCamera.ViewportSize.y
local x=xScale*vx+xOffset
local y=yScale*vy+yOffset
return Vector2.new(x,y)
end
end
function utility:Create(instanceType,instanceOffset,instanceProperties,instanceParent)
local instanceType=instanceType or "Frame"
local instanceOffset=instanceOffset or {Vector2.new(0,0)}
local instanceProperties=instanceProperties or {}
local instanceHidden=false
local instance=nil
if instanceType=="Frame" or instanceType=="frame" then
local frame=Drawing.new("Square")
frame.Visible=true
frame.Filled=true
frame.Thickness=0
frame.Color=Color3.fromRGB(255,255,255)
frame.Size=Vector2.new(100,100)
frame.Position=Vector2.new(0,0)
frame.ZIndex=50
frame.Transparency=library.shared.initialized and 1 or 0
instance=frame
elseif instanceType=="TextLabel" or instanceType=="textlabel" then
local text=Drawing.new("Text")
text.Font=3
text.Visible=true
text.Outline=true
text.Center=false
text.Color=Color3.fromRGB(255,255,255)
text.ZIndex=50
text.Transparency=library.shared.initialized and 1 or 0
instance=text
elseif instanceType=="Triangle" or instanceType=="triangle" then
local frame=Drawing.new("Triangle")
frame.Visible=true
frame.Filled=true
frame.Thickness=0
frame.Color=Color3.fromRGB(255,255,255)
frame.ZIndex=50
frame.Transparency=library.shared.initialized and 1 or 0
instance=frame
elseif instanceType=="Image" or instanceType=="image" then
local image=Drawing.new("Image")
image.Size=Vector2.new(12,19)
image.Position=Vector2.new(0,0)
image.Visible=true
image.ZIndex=50
image.Transparency=library.shared.initialized and 1 or 0
instance=image
elseif instanceType=="Circle" or instanceType=="circle" then
local circle=Drawing.new("Circle")
circle.Visible=false
circle.Color=Color3.fromRGB(255,0,0)
circle.Thickness=1
circle.NumSides=30
circle.Filled=true
circle.Transparency=1
circle.ZIndex=50
circle.Radius=50
circle.Transparency=library.shared.initialized and 1 or 0
instance=circle
elseif instanceType=="Quad" or instanceType=="quad" then
local quad=Drawing.new("Quad")
quad.Visible=false
quad.Color=Color3.fromRGB(255,255,255)
quad.Thickness=1.5
quad.Transparency=1
quad.ZIndex=50
quad.Filled=false
quad.Transparency=library.shared.initialized and 1 or 0
instance=quad
elseif instanceType=="Line" or instanceType=="line" then
local line=Drawing.new("Line")
line.Visible=false
line.Color=Color3.fromRGB(255,255,255)
line.Thickness=1.5
line.Transparency=1
line.Thickness=1.5
line.ZIndex=50
line.Transparency=library.shared.initialized and 1 or 0
instance=line
end
if instance then
for i,v in pairs(instanceProperties) do
if i=="Hidden" or i=="hidden" then
instanceHidden=true
else
if library.shared.initialized then
instance[i]=v
else
if i~="Transparency" then
instance[i]=v
end
end
end
end
if not instanceHidden then
library.drawings[#library.drawings+1]={instance,instanceOffset,instanceProperties["Transparency"] or 1}
else
library.hidden[#library.hidden+1]={instance}
end
if instanceParent then
instanceParent[#instanceParent+1]=instance
end
return instance
end
end
function utility:UpdateOffset(instance,instanceOffset)
for i,v in pairs(library.drawings) do
if v[1]==instance then
v[2]=instanceOffset
end
end
end
function utility:UpdateTransparency(instance,instanceTransparency)
for i,v in pairs(library.drawings) do
if v[1]==instance then
v[3]=instanceTransparency
end
end
end
function utility:Remove(instance,hidden)
local ind=0
for i,v in pairs(hidden and library.hidden or library.drawings) do
if v[1]==instance then
ind=i
if hidden then
v[1]=nil
else
v[2]=nil
v[1]=nil
end
end
end
table.remove(hidden and library.hidden or library.drawings,ind)
instance:Remove()
end
function utility:GetTextBounds(text,textSize,font)
local textbounds=Vector2.new(0,0)
local textlabel=utility:Create("TextLabel",{Vector2.new(0,0)},{Text=text,Size=textSize,Font=font,Hidden=true})
textbounds=textlabel.TextBounds
utility:Remove(textlabel,true)
return textbounds
end
function utility:MouseLocation()
return uis:GetMouseLocation()
end
function utility:MouseOverDrawing(values,valuesAdd)
local valuesAdd=valuesAdd or {}
local values={(values[1] or 0)+(valuesAdd[1] or 0),(values[2] or 0)+(valuesAdd[2] or 0),(values[3] or 0)+(valuesAdd[3] or 0),(values[4] or 0)+(valuesAdd[4] or 0)}
local mouseLocation=utility:MouseLocation()
return (mouseLocation.x>=values[1] and mouseLocation.x<=(values[1]+(values[3]-values[1]))) and (mouseLocation.y>=values[2] and mouseLocation.y<=(values[2]+(values[4]-values[2])))
end
function utility:GetScreenSize()
return ws.CurrentCamera.ViewportSize
end
function utility:LoadImage(instance,imageName,imageLink)
local data
if isfile(library.folders.assets.."/"..imageName..".png") then
data=readfile(library.folders.assets.."/"..imageName..".png")
else
if imageLink then
data=game:HttpGet(imageLink)
writefile(library.folders.assets.."/"..imageName..".png",data)
else
return
end
end
if data and instance then
instance.Data=data
end
end
function utility:Lerp(instance,instanceTo,instanceTime)
local currentTime=0
local currentIndex={}
local connection
for i,v in pairs(instanceTo) do
currentIndex[i]=instance[i]
end
local function lerp()
for i,v in pairs(instanceTo) do
instance[i]=((v-currentIndex[i])*currentTime/instanceTime)+currentIndex[i]
end
end
connection=rs.RenderStepped:Connect(function(delta)
if currentTime<instanceTime then
currentTime=currentTime+delta
lerp()
else
connection:Disconnect()
end
end)
end
function utility:Combine(t1,t2)
local t3={}
for i,v in pairs(t1) do t3[i]=v end
local t=#t3
for z,x in pairs(t2) do t3[z+t]=x end
return t3
end
library.__index=library
pages.__index=pages
sections.__index=sections
function library:New(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "UI Title"
local size=info.size or info.Size or Vector2.new(504,604)
local accent=info.accent or info.Accent or info.color or info.Color or theme.accent
theme.accent=accent
local window={pages={},isVisible=false,uibind=Enum.KeyCode.Z,currentPage=nil,fading=false,dragging=false,drag=Vector2.new(0,0),currentContent={frame=nil,dropdown=nil,multibox=nil,colorpicker=nil,keybind=nil}}
local main_frame=utility:Create("Frame",{Vector2.new(0,0)},{Size=utility:Size(0,size.X,0,size.Y),Position=utility:Position(0.5,-(size.X/2),0.5,-(size.Y/2)),Color=theme.outline});window["main_frame"]=main_frame
local frame_inline=utility:Create("Frame",{Vector2.new(1,1),main_frame},{Size=utility:Size(1,-2,1,-2,main_frame),Position=utility:Position(0,1,0,1,main_frame),Color=theme.accent})
local inner_frame=utility:Create("Frame",{Vector2.new(1,1),frame_inline},{Size=utility:Size(1,-2,1,-2,frame_inline),Position=utility:Position(0,1,0,1,frame_inline),Color=theme.light_contrast})
local title=utility:Create("TextLabel",{Vector2.new(4,2),inner_frame},{Text=name,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Position=utility:Position(0,4,0,2,inner_frame)})
local inner_frame_inline=utility:Create("Frame",{Vector2.new(4,18),inner_frame},{Size=utility:Size(1,-8,1,-22,inner_frame),Position=utility:Position(0,4,0,18,inner_frame),Color=theme.inline})
local inner_frame_inline2=utility:Create("Frame",{Vector2.new(1,1),inner_frame_inline},{Size=utility:Size(1,-2,1,-2,inner_frame_inline),Position=utility:Position(0,1,0,1,inner_frame_inline),Color=theme.outline})
local back_frame=utility:Create("Frame",{Vector2.new(1,1),inner_frame_inline2},{Size=utility:Size(1,-2,1,-2,inner_frame_inline2),Position=utility:Position(0,1,0,1,inner_frame_inline2),Color=theme.dark_contrast});window["back_frame"]=back_frame
local tab_frame_inline=utility:Create("Frame",{Vector2.new(4,24),back_frame},{Size=utility:Size(1,-8,1,-28,back_frame),Position=utility:Position(0,4,0,24,back_frame),Color=theme.outline})
local tab_frame_inline2=utility:Create("Frame",{Vector2.new(1,1),tab_frame_inline},{Size=utility:Size(1,-2,1,-2,tab_frame_inline),Position=utility:Position(0,1,0,1,tab_frame_inline),Color=theme.inline})
local tab_frame=utility:Create("Frame",{Vector2.new(1,1),tab_frame_inline2},{Size=utility:Size(1,-2,1,-2,tab_frame_inline2),Position=utility:Position(0,1,0,1,tab_frame_inline2),Color=theme.light_contrast});window["tab_frame"]=tab_frame
function window:GetConfig()
local config={}
for i,v in pairs(library.pointers) do
if typeof(v:Get())=="table" and v:Get().Transparency then
local hue,sat,val=v:Get().Color:ToHSV()
config[i]={Color={hue,sat,val},Transparency=v:Get().Transparency}
else
config[i]=v:Get()
end
end
return game:GetService("HttpService"):JSONEncode(config)
end
function window:LoadConfig(config)
local config=hs:JSONDecode(config)
for i,v in pairs(config) do
if library.pointers[i] then
library.pointers[i]:Set(v)
end
end
end
function window:Move(vector)
for i,v in pairs(library.drawings) do
if v[2][2] then
v[1].Position=utility:Position(0,v[2][1].X,0,v[2][1].Y,v[2][2])
else
v[1].Position=utility:Position(0,vector.X,0,vector.Y)
end
end
end
function window:CloseContent()
if window.currentContent.dropdown and window.currentContent.dropdown.open then
local dropdown=window.currentContent.dropdown
dropdown.open=not dropdown.open
utility:LoadImage(dropdown.dropdown_image,"arrow_down","https://i.imgur.com/tVqy0nL.png")
for i,v in pairs(dropdown.holder.drawings) do
utility:Remove(v)
end
dropdown.holder.drawings={}
dropdown.holder.buttons={}
dropdown.holder.inline=nil
window.currentContent.frame=nil
window.currentContent.dropdown=nil
elseif window.currentContent.multibox and window.currentContent.multibox.open then
local multibox=window.currentContent.multibox
multibox.open=not multibox.open
utility:LoadImage(multibox.multibox_image,"arrow_down","https://i.imgur.com/tVqy0nL.png")
for i,v in pairs(multibox.holder.drawings) do
utility:Remove(v)
end
multibox.holder.drawings={}
multibox.holder.buttons={}
multibox.holder.inline=nil
window.currentContent.frame=nil
window.currentContent.multibox=nil
elseif window.currentContent.colorpicker and window.currentContent.colorpicker.open then
local colorpicker=window.currentContent.colorpicker
colorpicker.open=not colorpicker.open
for i,v in pairs(colorpicker.holder.drawings) do
utility:Remove(v)
end
colorpicker.holder.drawings={}
window.currentContent.frame=nil
window.currentContent.colorpicker=nil
elseif window.currentContent.keybind and window.currentContent.keybind.open then
local modemenu=window.currentContent.keybind.modemenu
window.currentContent.keybind.open=not window.currentContent.keybind.open
for i,v in pairs(modemenu.drawings) do
utility:Remove(v)
end
modemenu.drawings={}
modemenu.buttons={}
modemenu.frame=nil
window.currentContent.frame=nil
window.currentContent.keybind=nil
end
end
function window:IsOverContent()
local isOver=false
if window.currentContent.frame and utility:MouseOverDrawing({window.currentContent.frame.Position.X,window.currentContent.frame.Position.Y,window.currentContent.frame.Position.X+window.currentContent.frame.Size.X,window.currentContent.frame.Position.Y+window.currentContent.frame.Size.Y}) then
isOver=true
end
return isOver
end
function window:Unload()
for i,v in pairs(library.connections) do
v:Disconnect()
v=nil
end
for i,v in next,library.hidden do
coroutine.wrap(function()
if v[1] and v[1].Remove and v[1].__OBJECT_EXISTS then
local instance=v[1]
v[1]=nil
v=nil
instance:Remove()
end
end)()
end
for i,v in pairs(library.drawings) do
coroutine.wrap(function()
if v[1].__OBJECT_EXISTS then
local instance=v[1]
v[2]=nil
v[1]=nil
v=nil
instance:Remove()
end
end)()
end
for i,v in pairs(library.began) do v=nil end
for i,v in pairs(library.ended) do v=nil end
for i,v in pairs(library.changed) do v=nil end
library.drawings=nil
library.hidden=nil
library.connections=nil
library.began=nil
library.ended=nil
library.changed=nil
uis.MouseIconEnabled=true
end
function window:Watermark(info)
window.watermark={visible=false}
local info=info or {}
local watermark_name=info.name or info.Name or info.title or info.Title or string.format("$$ Splix || uid : %u || ping : %u || fps : %u",1,100,200)
local text_bounds=utility:GetTextBounds(watermark_name,theme.textsize,theme.font)
local watermark_outline=utility:Create("Frame",{Vector2.new(100,38/2-10)},{Size=utility:Size(0,text_bounds.X+20,0,21),Position=utility:Position(0,100,0,38/2-10),Hidden=true,ZIndex=60,Color=theme.outline,Visible=window.watermark.visible}
)window.watermark.outline=watermark_outline
local watermark_inline=utility:Create("Frame",{Vector2.new(1,1),watermark_outline},{Size=utility:Size(1,-2,1,-2,watermark_outline),Position=utility:Position(0,1,0,1,watermark_outline),Hidden=true,ZIndex=60,Color=theme.inline,Visible=window.watermark.visible})
local watermark_frame=utility:Create("Frame",{Vector2.new(1,1),watermark_inline},{Size=utility:Size(1,-2,1,-2,watermark_inline),Position=utility:Position(0,1,0,1,watermark_inline),Hidden=true,ZIndex=60,Color=theme.light_contrast,Visible=window.watermark.visible})
local watermark_accent=utility:Create("Frame",{Vector2.new(0,0),watermark_frame},{Size=utility:Size(1,0,0,1,watermark_frame),Position=utility:Position(0,0,0,0,watermark_frame),Hidden=true,ZIndex=60,Color=theme.accent,Visible=window.watermark.visible})
local watermark_title=utility:Create("TextLabel",{Vector2.new(2+6,4),watermark_outline},{Text=string.format("splix - fps : %u - uid : %u",35,2),Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Hidden=true,ZIndex=60,Position=utility:Position(0,2+6,0,4,watermark_outline),Visible=window.watermark.visible})
function window.watermark:UpdateSize()
watermark_outline.Size=utility:Size(0,watermark_title.TextBounds.X+4+(6*2),0,21)
watermark_inline.Size=utility:Size(1,-2,1,-2,watermark_outline)
watermark_frame.Size=utility:Size(1,-2,1,-2,watermark_inline)
watermark_accent.Size=utility:Size(1,0,0,1,watermark_frame)
end
function window.watermark:Visibility()
watermark_outline.Visible=window.watermark.visible
watermark_inline.Visible=window.watermark.visible
watermark_frame.Visible=window.watermark.visible
watermark_accent.Visible=window.watermark.visible
watermark_title.Visible=window.watermark.visible
end
function window.watermark:Update(updateType,updateValue)
if updateType=="Visible" then
window.watermark.visible=updateValue
window.watermark:Visibility()
end
end
utility:Connection(rs.RenderStepped,function(fps)
library.shared.fps=math.round(1/fps)
library.shared.ping=tonumber(string.split(stats.Network.ServerStatsItem["Data Ping"]:GetValueString()," ")[1].."")
end)
watermark_title.Text=string.format("$$ Splix || uid : %u || ping : %i || fps : %u",1,tostring(library.shared.ping),library.shared.fps)
window.watermark:UpdateSize()
spawn(function()
while wait(0.1) do
watermark_title.Text=string.format("$$ Splix || uid : %u || ping : %i || fps : %u",1,tostring(library.shared.ping),library.shared.fps)
window.watermark:UpdateSize()
end
end)
return window.watermark
end
function window:KeybindsList(info)
window.keybindslist={visible=false,keybinds={}}
local info=info or {}
local keybindslist_outline=utility:Create("Frame",{Vector2.new(10,(utility:GetScreenSize().Y/2)-200)},{Size=utility:Size(0,150,0,22),Position=utility:Position(0,10,0.4,0),Hidden=true,ZIndex=55,Color=theme.outline,Visible=window.keybindslist.visible} )window.keybindslist.outline=keybindslist_outline
local keybindslist_inline=utility:Create("Frame",{Vector2.new(1,1),keybindslist_outline},{Size=utility:Size(1,-2,1,-2,keybindslist_outline),Position=utility:Position(0,1,0,1,keybindslist_outline),Hidden=true,ZIndex=55,Color=theme.inline,Visible=window.keybindslist.visible})
local keybindslist_frame=utility:Create("Frame",{Vector2.new(1,1),keybindslist_inline},{Size=utility:Size(1,-2,1,-2,keybindslist_inline),Position=utility:Position(0,1,0,1,keybindslist_inline),Hidden=true,ZIndex=55,Color=theme.light_contrast,Visible=window.keybindslist.visible})
local keybindslist_accent=utility:Create("Frame",{Vector2.new(0,0),keybindslist_frame},{Size=utility:Size(1,0,0,1,keybindslist_frame),Position=utility:Position(0,0,0,0,keybindslist_frame),Hidden=true,ZIndex=55,Color=theme.accent,Visible=window.keybindslist.visible})
local keybindslist_title=utility:Create("TextLabel",{Vector2.new(keybindslist_outline.Size.X/2,4),keybindslist_outline},{Text="- Keybinds -",Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Center=true,Hidden=true,ZIndex=55,Position=utility:Position(0.5,0,0,5,keybindslist_outline),Visible=window.keybindslist.visible})
function window.keybindslist:Resort()
local index=0
for i,v in pairs(window.keybindslist.keybinds) do
v:Move(0+(index*17))
index=index+1
end
end
function window.keybindslist:Add(keybindname,keybindvalue)
if keybindname and keybindvalue and not window.keybindslist.keybinds[keybindname] then
local keybindTable={}
local keybind_outline=utility:Create("Frame",{Vector2.new(0,keybindslist_outline.Size.Y-1),keybindslist_outline},{Size=utility:Size(1,0,0,18,keybindslist_outline),Position=utility:Position(0,0,1,-1,keybindslist_outline),Hidden=true,ZIndex=55,Color=theme.outline,Visible=window.keybindslist.visible})
local keybind_inline=utility:Create("Frame",{Vector2.new(1,1),keybind_outline},{Size=utility:Size(1,-2,1,-2,keybind_outline),Position=utility:Position(0,1,0,1,keybind_outline),Hidden=true,ZIndex=55,Color=theme.inline,Visible=window.keybindslist.visible})
local keybind_frame=utility:Create("Frame",{Vector2.new(1,1),keybind_inline},{Size=utility:Size(1,-2,1,-2,keybind_inline),Position=utility:Position(0,1,0,1,keybind_inline),Hidden=true,ZIndex=55,Color=theme.dark_contrast,Visible=window.keybindslist.visible})
local keybind_title=utility:Create("TextLabel",{Vector2.new(4,3),keybind_outline},{Text=keybindname,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Center=false,Hidden=true,ZIndex=55,Position=utility:Position(0,4,0,3,keybind_outline),Visible=window.keybindslist.visible})
local keybind_value=utility:Create("TextLabel",{Vector2.new(keybind_outline.Size.X-4-utility:GetTextBounds(keybindname,theme.textsize,theme.font).X,3),keybind_outline},{Text="["..keybindvalue.."]",Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Hidden=true,ZIndex=55,Position=utility:Position(1,-4-utility:GetTextBounds(keybindname,theme.textsize,theme.font).X,0,3,keybind_outline),Visible=window.keybindslist.visible})
function keybindTable:Move(yPos)
keybind_outline.Position=utility:Position(0,0,1,-1+yPos,keybindslist_outline)
keybind_inline.Position=utility:Position(0,1,0,1,keybind_outline)
keybind_frame.Position=utility:Position(0,1,0,1,keybind_inline)
keybind_title.Position=utility:Position(0,4,0,3,keybind_outline)
keybind_value.Position=utility:Position(1,-4-keybind_value.TextBounds.X,0,3,keybind_outline)
end
function keybindTable:Remove()
utility:Remove(keybind_outline,true)
utility:Remove(keybind_inline,true)
utility:Remove(keybind_frame,true)
utility:Remove(keybind_title,true)
utility:Remove(keybind_value,true)
window.keybindslist.keybinds[keybindname]=nil
keybindTable=nil
end
function keybindTable:Visibility()
keybind_outline.Visible=window.keybindslist.visible
keybind_inline.Visible=window.keybindslist.visible
keybind_frame.Visible=window.keybindslist.visible
keybind_title.Visible=window.keybindslist.visible
keybind_value.Visible=window.keybindslist.visible
end
window.keybindslist.keybinds[keybindname]=keybindTable
window.keybindslist:Resort()
end
end
function window.keybindslist:Remove(keybindname)
if keybindname and window.keybindslist.keybinds[keybindname] then
window.keybindslist.keybinds[keybindname]:Remove()
window.keybindslist.keybinds[keybindname]=nil
window.keybindslist:Resort()
end
end
function window.keybindslist:Visibility()
keybindslist_outline.Visible=window.keybindslist.visible
keybindslist_inline.Visible=window.keybindslist.visible
keybindslist_frame.Visible=window.keybindslist.visible
keybindslist_accent.Visible=window.keybindslist.visible
keybindslist_title.Visible=window.keybindslist.visible
for i,v in pairs(window.keybindslist.keybinds) do v:Visibility() end
end
function window.keybindslist:Update(updateType,updateValue)
if updateType=="Visible" then
window.keybindslist.visible=updateValue
window.keybindslist:Visibility()
end
end
utility:Connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),function()
keybindslist_outline.Position=utility:Position(0,10,0.4,0)
keybindslist_inline.Position=utility:Position(0,1,0,1,keybindslist_outline)
keybindslist_frame.Position=utility:Position(0,1,0,1,keybindslist_inline)
keybindslist_accent.Position=utility:Position(0,0,0,0,keybindslist_frame)
keybindslist_title.Position=utility:Position(0.5,0,0,5,keybindslist_outline)
window.keybindslist:Resort()
end)
function window:Cursor(info)
window.cursor={}
local cursor=utility:Create("Triangle",nil,{Color=theme.cursoroutline,Thickness=2.5,Filled=false,ZIndex=65,Hidden=true});window.cursor["cursor"]=cursor
local cursor_inline=utility:Create("Triangle",nil,{Color=theme.accent,Filled=true,Thickness=0,ZIndex=65,Hidden=true});window.cursor["cursor_inline"]=cursor_inline
utility:Connection(rs.RenderStepped,function()
local mouseLocation=utility:MouseLocation()
cursor.PointA=Vector2.new(mouseLocation.X,mouseLocation.Y)
cursor.PointB=Vector2.new(mouseLocation.X+16,mouseLocation.Y+6)
cursor.PointC=Vector2.new(mouseLocation.X+6,mouseLocation.Y+16)
cursor_inline.PointA=Vector2.new(mouseLocation.X,mouseLocation.Y)
cursor_inline.PointB=Vector2.new(mouseLocation.X+16,mouseLocation.Y+6)
cursor_inline.PointC=Vector2.new(mouseLocation.X+6,mouseLocation.Y+16)
end)
uis.MouseIconEnabled=false
return window.cursor
end
function window:Fade()
window.fading=true
window.isVisible=not window.isVisible
spawn(function()
for i,v in pairs(library.drawings) do
utility:Lerp(v[1],{Transparency=window.isVisible and v[3] or 0},0.25)
end
end)
window.cursor["cursor"].Transparency=window.isVisible and 1 or 0
window.cursor["cursor_inline"].Transparency=window.isVisible and 1 or 0
uis.MouseIconEnabled=not window.isVisible
window.fading=false
end
function window:Initialize()
window.pages[1]:Show()
for i,v in pairs(window.pages) do v:Update() end
library.shared.initialized=true
window:Watermark()
window:KeybindsList()
window:Cursor()
window:Fade()
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and window.isVisible and utility:MouseOverDrawing({main_frame.Position.X,main_frame.Position.Y,main_frame.Position.X+main_frame.Size.X,main_frame.Position.Y+20}) then
local mouseLocation=utility:MouseLocation()
window.dragging=true
window.drag=Vector2.new(mouseLocation.X-main_frame.Position.X,mouseLocation.Y-main_frame.Position.Y)
end
end
library.ended[#library.ended+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and window.isVisible and window.dragging then
window.dragging=false
window.drag=Vector2.new(0,0)
end
end
library.changed[#library.changed+1]=function(Input)
if window.dragging and window.isVisible then
local mouseLocation=utility:MouseLocation()
if utility:GetScreenSize().Y-main_frame.Size.Y-5>5 then
local move=Vector2.new(math.clamp(mouseLocation.X-window.drag.X,5,utility:GetScreenSize().X-main_frame.Size.X-5),math.clamp(mouseLocation.Y-window.drag.Y,5,utility:GetScreenSize().Y-main_frame.Size.Y-5))
window:Move(move)
else
local move=Vector2.new(mouseLocation.X-window.drag.X,mouseLocation.Y-window.drag.Y)
window:Move(move)
end
end
end
library.began[#library.began+1]=function(Input)
if Input.KeyCode==window.uibind then window:Fade() end
end
utility:Connection(uis.InputBegan,function(Input)
for _,func in pairs(library.began) do
if not window.dragging then
local e,s=pcall(function() func(Input) end)
else
break
end
end
end)
utility:Connection(uis.InputEnded,function(Input)
for _,func in pairs(library.ended) do local e,s=pcall(function() func(Input) end) end
end)
utility:Connection(uis.InputChanged,function()
for _,func in pairs(library.changed) do local e,s=pcall(function() func() end) end
end)
utility:Connection(ws.CurrentCamera:GetPropertyChangedSignal("ViewportSize"),function()
window:Move(Vector2.new((utility:GetScreenSize().X/2)-(size.X/2),(utility:GetScreenSize().Y/2)-(size.Y/2)))
end)
return setmetatable(window,library)
end
function library:Page(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "New Page"
local window=self
local page={open=false,sections={},sectionOffset={left=0,right=0},window=window}
local position=4
for i,v in pairs(window.pages) do position=position+(v.page_button.Size.X+2) end
local textbounds=utility:GetTextBounds(name,theme.textsize,theme.font)
local page_button=utility:Create("Frame",{Vector2.new(position,4),window.back_frame},{Size=utility:Size(0,textbounds.X+20,0,21),Position=utility:Position(0,position,0,4,window.back_frame),Color=theme.outline});page["page_button"]=page_button
local page_button_inline=utility:Create("Frame",{Vector2.new(1,1),page_button},{Size=utility:Size(1,-2,1,-1,page_button),Position=utility:Position(0,1,0,1,page_button),Color=theme.inline});page["page_button_inline"]=page_button_inline
local page_button_color=utility:Create("Frame",{Vector2.new(1,1),page_button_inline},{Size=utility:Size(1,-2,1,-1,page_button_inline),Position=utility:Position(0,1,0,1,page_button_inline),Color=theme.dark_contrast});page["page_button_color"]=page_button_color
local page_button_title=utility:Create("TextLabel",{Vector2.new(utility:Position(0.5,0,0,2,page_button_color).X-page_button_color.Position.X,2),page_button_color},{Text=name,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,Center=true,OutlineColor=theme.textborder,Position=utility:Position(0.5,0,0,2,page_button_color)})
window.pages[#window.pages+1]=page
function page:Update()
page.sectionOffset["left"]=0
page.sectionOffset["right"]=0
for i,v in pairs(page.sections) do
utility:UpdateOffset(v.section_inline,{Vector2.new(v.side=="right" and (window.tab_frame.Size.X/2)+2 or 5,5+page["sectionOffset"][v.side]),window.tab_frame})
page.sectionOffset[v.side]=page.sectionOffset[v.side]+v.section_inline.Size.Y+5
end
window:Move(window.main_frame.Position)
end
function page:Show()
if window.currentPage then
window.currentPage.page_button_color.Size=utility:Size(1,-2,1,-1,window.currentPage.page_button_inline)
window.currentPage.page_button_color.Color=theme.dark_contrast
window.currentPage.open=false
for i,v in pairs(window.currentPage.sections) do
for z,x in pairs(v.visibleContent) do x.Visible=false end
end
window:CloseContent()
end
window.currentPage=page
page_button_color.Size=utility:Size(1,-2,1,0,page_button_inline)
page_button_color.Color=theme.light_contrast
page.open=true
for i,v in pairs(page.sections) do for z,x in pairs(v.visibleContent) do x.Visible=true end end
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and window.isVisible and utility:MouseOverDrawing({page_button.Position.X,page_button.Position.Y,page_button.Position.X+page_button.Size.X,page_button.Position.Y+page_button.Size.Y}) and window.currentPage~=page then
page:Show()
end
end
return setmetatable(page,pages)
end
function pages:Section(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "New Section"
local side=info.side or info.Side or "left"
side=side:lower()
local window=self.window
local page=self
local section={window=window,page=page,visibleContent={},currentAxis=20,side=side}
local section_inline=utility:Create("Frame",{Vector2.new(side=="right" and (window.tab_frame.Size.X/2)+2 or 5,5+page["sectionOffset"][side]),window.tab_frame},{Size=utility:Size(0.5,-7,0,22,window.tab_frame),Position=utility:Position(side=="right" and 0.5 or 0,side=="right" and 2 or 5,0,5+page.sectionOffset[side],window.tab_frame),Color=theme.inline,Visible=page.open},section.visibleContent);section["section_inline"]=section_inline
local section_outline=utility:Create("Frame",{Vector2.new(1,1),section_inline},{Size=utility:Size(1,-2,1,-2,section_inline),Position=utility:Position(0,1,0,1,section_inline),Color=theme.outline,Visible=page.open},section.visibleContent);section["section_outline"]=section_outline
local section_frame=utility:Create("Frame",{Vector2.new(1,1),section_outline},{Size=utility:Size(1,-2,1,-2,section_outline),Position=utility:Position(0,1,0,1,section_outline),Color=theme.dark_contrast,Visible=page.open},section.visibleContent);section["section_frame"]=section_frame
local section_accent=utility:Create("Frame",{Vector2.new(0,0),section_frame},{Size=utility:Size(1,0,0,2,section_frame),Position=utility:Position(0,0,0,0,section_frame),Color=theme.accent,Visible=page.open},section.visibleContent);section["section_accent"]=section_accent
local section_title=utility:Create("TextLabel",{Vector2.new(3,3),section_frame},{Text=name,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Position=utility:Position(0,3,0,3,section_frame),Visible=page.open},section.visibleContent);section["section_title"]=section_title
function section:Update()
section_inline.Size=utility:Size(0.5,-7,0,section.currentAxis+4,window.tab_frame)
section_outline.Size=utility:Size(1,-2,1,-2,section_inline)
section_frame.Size=utility:Size(1,-2,1,-2,section_outline)
end
page.sectionOffset[side]=page.sectionOffset[side]+100+5
page.sections[#page.sections+1]=section
return setmetatable(section,sections)
end
function pages:MultiSection(info)
local info=info or {}
local msections=info.sections or info.Sections or {}
local side=info.side or info.Side or "left"
local size=info.size or info.Size or 150
side=side:lower()
local window=self.window
local page=self
local multiSection={window=window,page=page,sections={},backup={},visibleContent={},currentSection=nil,xAxis=0,side=side}
local multiSection_inline=utility:Create("Frame",{Vector2.new(side=="right" and (window.tab_frame.Size.X/2)+2 or 5,5+page["sectionOffset"][side]),window.tab_frame},{Size=utility:Size(0.5,-7,0,size,window.tab_frame),Position=utility:Position(side=="right" and 0.5 or 0,side=="right" and 2 or 5,0,5+page.sectionOffset[side],window.tab_frame),Color=theme.inline,Visible=page.open},multiSection.visibleContent);multiSection["section_inline"]=multiSection_inline
local multiSection_outline=utility:Create("Frame",{Vector2.new(1,1),multiSection_inline},{Size=utility:Size(1,-2,1,-2,multiSection_inline),Position=utility:Position(0,1,0,1,multiSection_inline),Color=theme.outline,Visible=page.open},multiSection.visibleContent);multiSection["section_outline"]=multiSection_outline
local multiSection_frame=utility:Create("Frame",{Vector2.new(1,1),multiSection_outline},{Size=utility:Size(1,-2,1,-2,multiSection_outline),Position=utility:Position(0,1,0,1,multiSection_outline),Color=theme.dark_contrast,Visible=page.open},multiSection.visibleContent);multiSection["section_frame"]=multiSection_frame
local multiSection_backFrame=utility:Create("Frame",{Vector2.new(0,2),multiSection_frame},{Size=utility:Size(1,0,0,17,multiSection_frame),Position=utility:Position(0,0,0,2,multiSection_frame),Color=theme.light_contrast,Visible=page.open},multiSection.visibleContent)
local multiSection_bottomFrame=utility:Create("Frame",{Vector2.new(0,multiSection_backFrame.Size.Y-1),multiSection_backFrame},{Size=utility:Size(1,0,0,1,multiSection_backFrame),Position=utility:Position(0,0,1,-1,multiSection_backFrame),Color=theme.outline,Visible=page.open},multiSection.visibleContent)
local multiSection_accent=utility:Create("Frame",{Vector2.new(0,0),multiSection_frame},{Size=utility:Size(1,0,0,2,multiSection_frame),Position=utility:Position(0,0,0,0,multiSection_frame),Color=theme.accent,Visible=page.open},multiSection.visibleContent);multiSection["section_accent"]=multiSection_accent
for i,v in pairs(msections) do
local msection={window=window,page=page,currentAxis=24,sections={},visibleContent={},section_inline=multiSection_inline,section_outline=multiSection_outline,section_frame=multiSection_frame,section_accent=multiSection_accent}
local textBounds=utility:GetTextBounds(v,theme.textsize,theme.font)
local msection_frame=utility:Create("Frame",{Vector2.new(multiSection.xAxis,0),multiSection_backFrame},{Size=utility:Size(0,textBounds.X+14,1,-1,multiSection_backFrame),Position=utility:Position(0,multiSection.xAxis,0,0,multiSection_backFrame),Color=i==1 and theme.dark_contrast or theme.light_contrast,Visible=page.open},multiSection.visibleContent);msection["msection_frame"]=msection_frame
local msection_line=utility:Create("Frame",{Vector2.new(msection_frame.Size.X,0),msection_frame},{Size=utility:Size(0,1,1,0,msection_frame),Position=utility:Position(1,0,0,0,msection_frame),Color=theme.outline,Visible=page.open},multiSection.visibleContent)
local msection_title=utility:Create("TextLabel",{Vector2.new(msection_frame.Size.X*0.5,1),msection_frame},{Text=v,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Center=true,Position=utility:Position(0.5,0,0,1,msection_frame),Visible=page.open},multiSection.visibleContent)
local msection_bottomline=utility:Create("Frame",{Vector2.new(0,msection_frame.Size.Y),msection_frame},{Size=utility:Size(1,0,0,1,msection_frame),Position=utility:Position(0,0,1,0,msection_frame),Color=i==1 and theme.dark_contrast or theme.outline,Visible=page.open},multiSection.visibleContent);msection["msection_bottomline"]=msection_bottomline
function msection:Update()
if multiSection.currentSection==msection then
multiSection.visibleContent=utility:Combine(multiSection.backup,multiSection.currentSection.visibleContent)
else
for z,x in pairs(msection.visibleContent) do x.Visible=false end
end
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and window.isVisible and page.open and utility:MouseOverDrawing({msection_frame.Position.X,msection_frame.Position.Y,msection_frame.Position.X+msection_frame.Size.X,msection_frame.Position.Y+msection_frame.Size.Y}) and multiSection.currentSection~=msection and not window:IsOverContent() then
multiSection.currentSection.msection_frame.Color=theme.light_contrast
multiSection.currentSection.msection_bottomline.Color=theme.outline
for i,v in pairs(multiSection.currentSection.visibleContent) do v.Visible=false end
multiSection.currentSection=msection
msection_frame.Color=theme.dark_contrast
msection_bottomline.Color=theme.dark_contrast
for i,v in pairs(multiSection.currentSection.visibleContent) do v.Visible=true end
multiSection.visibleContent=utility:Combine(multiSection.backup,multiSection.currentSection.visibleContent)
end
end
if i==1 then multiSection.currentSection=msection end
multiSection.sections[#multiSection.sections+1]=setmetatable(msection,sections)
multiSection.xAxis=multiSection.xAxis+textBounds.X+15
end
for z,x in pairs(multiSection.visibleContent) do multiSection.backup[z]=x end
page.sectionOffset[side]=page.sectionOffset[side]+100+5
page.sections[#page.sections+1]=multiSection
return table.unpack(multiSection.sections)
end
function sections:Label(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "New Label"
local middle=info.middle or info.Middle or false
local pointer=info.pointer or info.Pointer or info.flag or info.Flag or nil
local window=self.window
local page=self.page
local section=self
local label={axis=section.currentAxis}
local label_title=utility:Create("TextLabel",{Vector2.new(middle and (section.section_frame.Size.X/2) or 4,label.axis),section.section_frame},{Text=name,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Center=middle,Position=utility:Position(middle and 0.5 or 0,middle and 0 or 4,0,0,section.section_frame),Visible=page.open},section.visibleContent)
if pointer and tostring(pointer)~="" and tostring(pointer)~=" " and not library.pointers[tostring(pointer)] then library.pointers[tostring(pointer)]=label end
section.currentAxis=section.currentAxis+label_title.TextBounds.Y+4
section:Update()
return label
end
function sections:Toggle(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "New Toggle"
local def=info.def or info.Def or info.default or info.Default or false
local pointer=info.pointer or info.Pointer or info.flag or info.Flag or nil
local callback=info.callback or info.callBack or info.Callback or info.CallBack or function() end
local window=self.window
local page=self.page
local section=self
local toggle={axis=section.currentAxis,current=def,addedAxis=0,colorpickers=0,keybind=nil}
local toggle_outline=utility:Create("Frame",{Vector2.new(4,toggle.axis),section.section_frame},{Size=utility:Size(0,15,0,15),Position=utility:Position(0,4,0,toggle.axis,section.section_frame),Color=theme.outline,Visible=page.open},section.visibleContent)
local toggle_inline=utility:Create("Frame",{Vector2.new(1,1),toggle_outline},{Size=utility:Size(1,-2,1,-2,toggle_outline),Position=utility:Position(0,1,0,1,toggle_outline),Color=theme.inline,Visible=page.open},section.visibleContent)
local toggle_frame=utility:Create("Frame",{Vector2.new(1,1),toggle_inline},{Size=utility:Size(1,-2,1,-2,toggle_inline),Position=utility:Position(0,1,0,1,toggle_inline),Color=toggle.current==true and theme.accent or theme.light_contrast,Visible=page.open},section.visibleContent)
local toggle__gradient=utility:Create("Image",{Vector2.new(0,0),toggle_frame},{Size=utility:Size(1,0,1,0,toggle_frame),Position=utility:Position(0,0,0,0,toggle_frame),Transparency=0.5,Visible=page.open},section.visibleContent)
local toggle_title=utility:Create("TextLabel",{Vector2.new(23,toggle.axis+(15/2)-(utility:GetTextBounds(name,theme.textsize,theme.font).Y/2)),section.section_frame},{Text=name,Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Position=utility:Position(0,23,0,toggle.axis+(15/2)-(utility:GetTextBounds(name,theme.textsize,theme.font).Y/2),section.section_frame),Visible=page.open},section.visibleContent)
utility:LoadImage(toggle__gradient,"gradient","https://i.imgur.com/5hmlrjX.png")
function toggle:Get() return toggle.current end
function toggle:Set(bool)
if bool or not bool then
toggle.current=bool
toggle_frame.Color=toggle.current==true and theme.accent or theme.light_contrast
callback(toggle.current)
end
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and toggle_outline.Visible and window.isVisible and page.open and utility:MouseOverDrawing({section.section_frame.Position.X,section.section_frame.Position.Y+toggle.axis,section.section_frame.Position.X+section.section_frame.Size.X-toggle.addedAxis,section.section_frame.Position.Y+toggle.axis+15}) and not window:IsOverContent() then
toggle.current=not toggle.current
toggle_frame.Color=toggle.current==true and theme.accent or theme.light_contrast
callback(toggle.current)
if toggle.keybind and toggle.keybind.active then toggle.keybind.active=false window.keybindslist:Remove(toggle.keybind.keybindname) end
end
end
if pointer and tostring(pointer)~="" and tostring(pointer)~=" " and not library.pointers[tostring(pointer)] then library.pointers[tostring(pointer)]=toggle end
section.currentAxis=section.currentAxis+15+4
section:Update()
function toggle:Slider(info)
local info=info or {}
local name=info.name or info.Name or info.title or info.Title or "New Slider"
local min=info.min or info.Min or info.Min or 0
local max=info.max or info.Max or info.Max or 100
local def=info.def or info.Def or info.default or info.Default or min
local round=info.round or info.Round or 0
local callback=info.callback or info.callBack or info.Callback or info.CallBack or function() end
local slider={axis=toggle.axis,current=def,holding=false}
local slider_outline=utility:Create("Frame",{Vector2.new(4,toggle.axis+20),section.section_frame},{Size=utility:Size(1,-8,0,18,section.section_frame),Position=utility:Position(0,4,0,toggle.axis+20,section.section_frame),Color=theme.outline,Visible=page.open},section.visibleContent)
local slider_inline=utility:Create("Frame",{Vector2.new(1,1),slider_outline},{Size=utility:Size(1,-2,1,-2,slider_outline),Position=utility:Position(0,1,0,1,slider_outline),Color=theme.inline,Visible=page.open},section.visibleContent)
local slider_frame=utility:Create("Frame",{Vector2.new(1,1),slider_inline},{Size=utility:Size(1,-2,1,-2,slider_inline),Position=utility:Position(0,1,0,1,slider_inline),Color=theme.light_contrast,Visible=page.open},section.visibleContent)
local slider_fill=utility:Create("Frame",{Vector2.new(1,1),slider_frame},{Size=utility:Size((def-min)/(max-min),0,1,0,slider_frame),Position=utility:Position(0,1,0,1,slider_frame),Color=theme.accent,Visible=page.open},section.visibleContent)
local slider_value=utility:Create("TextLabel",{Vector2.new(slider_frame.Size.X-utility:GetTextBounds(tostring(def),theme.textsize,theme.font).X-4,slider.axis+20),section.section_frame},{Text=tostring(def),Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Position=utility:Position(1,-utility:GetTextBounds(tostring(def),theme.textsize,theme.font).X-4,0,slider.axis+20,section.section_frame),Visible=page.open},section.visibleContent)
function slider:UpdateValue(x)
local pct=math.clamp(x/slider_frame.Size.X,0,1)
local val=math.floor((min+(max-min)*pct)*(10^round))/(10^round)
slider.current=val
slider_fill.Size=utility:Size(pct,0,1,0,slider_frame)
slider_value.Text=tostring(val)
callback(val)
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and slider_outline.Visible and window.isVisible and page.open and utility:MouseOverDrawing({section.section_frame.Position.X,section.section_frame.Position.Y+toggle.axis+20,section.section_frame.Position.X+section.section_frame.Size.X,section.section_frame.Position.Y+toggle.axis+38}) and not window:IsOverContent() then
local mouseLocation=utility:MouseLocation()
local relx=mouseLocation.X-slider_frame.Position.X
slider:UpdateValue(relx)
slider.holding=true
end
end
library.changed[#library.changed+1]=function()
if slider.holding then
local mouseLocation=utility:MouseLocation()
local relx=mouseLocation.X-slider_frame.Position.X
slider:UpdateValue(relx)
end
end
library.ended[#library.ended+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and slider.holding then
slider.holding=false
end
end
section.currentAxis=section.currentAxis+20+18+4
section:Update()
return slider
end
return toggle
end
function sections:Slider(info)
local info=info or{}
local name=info.name or info.Name or info.title or info.Title or "New Slider"
local min=info.min or info.Min or 0
local max=info.max or info.Max or 100
local def=info.def or info.Def or info.default or info.Default or min
local round=info.round or info.Round or 0
local callback=info.callback or info.callBack or info.Callback or function() end
local window=self.window
local page=self.page
local section=self
local slider={axis=section.currentAxis,current=def,holding=false}
local slider_outline=utility:Create("Frame",{Vector2.new(4,slider.axis),section.section_frame},{Size=utility:Size(1,-8,0,18,section.section_frame),Position=utility:Position(0,4,0,slider.axis,section.section_frame),Color=theme.outline,Visible=page.open},section.visibleContent)
local slider_inline=utility:Create("Frame",{Vector2.new(1,1),slider_outline},{Size=utility:Size(1,-2,1,-2,slider_outline),Position=utility:Position(0,1,0,1,slider_outline),Color=theme.inline,Visible=page.open},section.visibleContent)
local slider_frame=utility:Create("Frame",{Vector2.new(1,1),slider_inline},{Size=utility:Size(1,-2,1,-2,slider_inline),Position=utility:Position(0,1,0,1,slider_inline),Color=theme.light_contrast,Visible=page.open},section.visibleContent)
local slider_fill=utility:Create("Frame",{Vector2.new(1,1),slider_frame},{Size=utility:Size((def-min)/(max-min),0,1,0,slider_frame),Position=utility:Position(0,1,0,1,slider_frame),Color=theme.accent,Visible=page.open},section.visibleContent)
local slider_value=utility:Create("TextLabel",{Vector2.new(slider_frame.Size.X-utility:GetTextBounds(tostring(def),theme.textsize,theme.font).X-4,slider.axis),section.section_frame},{Text=tostring(def),Size=theme.textsize,Font=theme.font,Color=theme.textcolor,OutlineColor=theme.textborder,Position=utility:Position(1,-utility:GetTextBounds(tostring(def),theme.textsize,theme.font).X-4,0,slider.axis,section.section_frame),Visible=page.open},section.visibleContent)
function slider:UpdateValue(x)
local pct=math.clamp(x/slider_frame.Size.X,0,1)
local val=math.floor((min+(max-min)*pct)*(10^round))/(10^round)
slider.current=val
slider_fill.Size=utility:Size(pct,0,1,0,slider_frame)
slider_value.Text=tostring(val)
callback(val)
end
library.began[#library.began+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and slider_outline.Visible and window.isVisible and page.open and utility:MouseOverDrawing({section.section_frame.Position.X,section.section_frame.Position.Y+slider.axis,section.section_frame.Position.X+section.section_frame.Size.X,section.section_frame.Position.Y+slider.axis+18}) and not window:IsOverContent() then
local mouseLocation=utility:MouseLocation()
local relx=mouseLocation.X-slider_frame.Position.X
slider:UpdateValue(relx)
slider.holding=true
end
end
library.changed[#library.changed+1]=function()
if slider.holding then
local mouseLocation=utility:MouseLocation()
local relx=mouseLocation.X-slider_frame.Position.X
slider:UpdateValue(relx)
end
end
library.ended[#library.ended+1]=function(Input)
if Input.UserInputType==Enum.UserInputType.MouseButton1 and slider.holding then
slider.holding=false
end
end
section.currentAxis=section.currentAxis+18+4
section:Update()
return slider
end
local example=library:New({name="SplixLike",size=Vector2.new(560,420)})
local page1=example:Page({name="Main"})
local left=page1:Section({name="Left",side="left"})
local right=page1:Section({name="Right",side="right"})
left:Label({name="Welcome"})
left:Toggle({name="Enable Feature",def=true,callback=function(v) end})
left:Slider({name="Speed",min=0,max=100,def=50,round=0,callback=function(v) end})
right:Label({name="Options"})
right:Toggle({name="Option A",def=false,callback=function(v) end})
right:Slider({name="Power",min=0,max=10,def=5,round=1,callback=function(v) end})
example:Initialize()
return library
