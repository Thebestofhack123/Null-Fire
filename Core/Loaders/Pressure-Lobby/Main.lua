local defaults = {
	flex = false,
	delay = 0,
	flex2 = false,
	delay2 = 0,
	flex3 = false,
	delay3 = 0,
	flex4 = false,
	delay4 = 0,
	skip1 = false,
	skip2 = false
}
local vals = table.clone(defaults)

local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end
getGlobalTable().MaxPlayers = game.Players.MaxPlayers
getGlobalTable().FireHubLoaded = true
local closed = false
local cons = {}
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/Null-Fire/main/Core/Libraries/Fire-Lib/Main.lua"))()
local plr = game.Players.LocalPlayer

local ftiv = false
local fti = getfenv().firetouchinterest
task.spawn(function()
	if fti then
		local part = Instance.new("Part", workspace)
		part.Position = Vector3.new(0, 100, 0)
		part.Touched:Connect(function()
			part:Destroy()
			ftiv = true
		end)
		task.wait(0.1)
		repeat task.wait() until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and part and part.Parent
		fti(part, plr.Character.HumanoidRootPart, 0)
		fti(plr.Character.HumanoidRootPart, part, 0)
		task.wait()
		repeat task.wait() until plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and part and part.Parent
		fti(part, plr.Character.HumanoidRootPart, 1)
		fti(plr.Character.HumanoidRootPart, part, 1)
	end
end)

local cd = {}
local firetouchinterest = function(a,b,touching)
	if ftiv then
		return fti(a,b,touching)
	end

	if cd[a] or cd[b] then return end
	cd[a] = true
	touching = touching == 1

	if not touching then
		local c = b
		local ct = c.CanTouch
		c.CanTouch = false
		task.wait(0.015)
		c.CanTouch = ct
	else
		local pp = b:GetPivot()
		local t,c,an = b.Transparency,b.CanCollide,b.Anchored
		b:PivotTo(a:GetPivot())
		b.Transparency = 1
		b.CanCollide = false
		b.Anchored = false
		b.Velocity += Vector3.new(0,1)
		a.Touched:Wait()
		b.Transparency = t
		b.CanCollide = c
		b.Anchored = an
		b:PivotTo(pp)
	end
	task.wait()
	cd[a] = false
end

local window = lib:MakeWindow({Title = "NullFire: Pressure Lobby", CloseCallback = function()
	getGlobalTable().FireHubLoaded = false
	for i,v in defaults do
		vals[i] = v
	end
	task.wait(0.1)
	for i,v in cons do
		if v then
			v:Disconnect()
		end
	end
	closed = true
end}, true)
local page = window:AddPage({Title = "Submarines"})
local inQueue = false
local function getFree(getc, lobby)
	if inQueue then return end
	inQueue = true
	while true do
		for i,v in getc:GetChildren() do
			if v and v.Name == lobby then
				local maxPlayers = tonumber(lobby:sub(1,2)) or tonumber(lobby:sub(1,1)) or 50
				local players = (#v.Main.BillboardGui.Frame.Frame:GetChildren()) - 1

				if players < maxPlayers and v.Main.BillboardGui.Frame.Timer.Text ~= "Transporting" then
					inQueue = false
					return v
				end
			end
		end
		task.wait()
	end
end
page:AddButton({Caption = "1 Player", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "1Player").Main, 1)
end})
page:AddButton({Caption = "2 Players", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "2Players").Main, 1)
end})
page:AddButton({Caption = "3 Players", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "3Players").Main, 1)
end})
page:AddButton({Caption = "4 Players", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "4Players").Main, 1)
end})
page:AddButton({Caption = "8 Players", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "8Players").Main, 1)
end})
page:AddButton({Caption = "50 Players [Paid]", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "50Players").Main, 1)
end})
page:AddButton({Caption = "Developer submarine", Callback = function()
	firetouchinterest(plr.Character.HumanoidRootPart, getFree(workspace.Teleporters, "DeveloperSub").Main, 1)
end})

local toSnipe = plr.DisplayName
local function getUser()
	for i,v in game.Players:GetPlayers() do
		if v.DisplayName:lower():match(toSnipe:lower()) or v.Name:lower():match(toSnipe:lower()) then
			return v
		end
	end
	return plr
end
local function snipe()
	if getUser() == plr then return end
	local a = false
	for i,v in workspace.Teleporters do
		if v.Main.BillboardGui.Frame.Frame:FindFirstChild(getUser().Name) then
			firetouchinterest(plr.Character.HumanoidRootPart, v.Main, 1)
			a = true
			task.wait(0.1)
		end
	end
	if not a and workspace:FindFirstChild("RaveyardTeleporters") then
		for i,v in workspace.RaveyardTeleporters do
			if v.Main.BillboardGui.Frame.Frame:FindFirstChild(getUser().Name) then
				firetouchinterest(plr.Character.HumanoidRootPart, v.Main, 1)
				a = true
				task.wait(0.1)
			end
		end
	end
	if not a then
		game.ReplicatedStorage.Events.ExitMatch:FireServer()
	end
end
local page = window:AddPage({Title = "Submarine sniping"})
local tb; tb = page:AddTextBox({Caption = "Player to snipe", Default = toSnipe, Placeholder = "Target", Callback = function(txt)
	if txt == toSnipe then return end
	toSnipe = txt
	tb:Set(getUser().DisplayName)
	snipe()
end})
page:AddLabel({Caption = "Leave empty or set to your username (or display name) to disable."})
task.spawn(function()
	while task.wait() and not closed do
		snipe()
	end
end)
local page = window:AddPage({Title = "Fun"})
local ch = {}
task.spawn(function()
	while task.wait() and not closed do
		if vals.flex then
			for i,v in ch do
				if not vals.flex then continue end
				task.spawn(game.ReplicatedStorage.Events.EquipBadge.FireServer, game.ReplicatedStorage.Events.EquipBadge, v)
				task.wait(vals.delay)
			end
		end
	end
end)
local ch2 = {}
task.spawn(function()
	while task.wait() and not closed do
		if vals.flex2 then
			for i,v in ch2 do
				if not vals.flex2 then continue end
				task.spawn(game.ReplicatedStorage.Events.EquipClothes.FireServer, game.ReplicatedStorage.Events.EquipClothes, v)
				task.wait(vals.delay2)
			end
		end
	end
end)
local ch3 = {}
local leftNametag, rightNametag = {"Left"}, {"Right"}
task.spawn(function()
	while task.wait() and not closed do
		if vals.flex3 then
			for i,v in ch3 do
				if v == "None" and vals.skip1 or not vals.flex3 then continue end
				task.spawn(game.ReplicatedStorage.Events.EquipNametag.FireServer, game.ReplicatedStorage.Events.EquipNametag, v, leftNametag)
				task.wait(vals.delay3)
			end
		end
	end
end)
task.spawn(function()
	while task.wait() and not closed do
		if vals.flex4 then
			for i,v in ch3 do
				if v == "None" and vals.skip2 or not vals.flex4 then continue end
				task.spawn(game.ReplicatedStorage.Events.EquipNametag.FireServer, game.ReplicatedStorage.Events.EquipNametag, v, rightNametag)
				task.wait(vals.delay4)
			end
		end
	end
end)
for i,v in game:GetService("Players").LocalPlayer.PlayerGui.Main.Inventory.Background.Badges.ScrollingFrame:GetChildren() do
	if v and v:IsA("Frame") then
		for idx,val in v:GetChildren() do
			if val and val:IsA("ImageButton") and val:FindFirstChild("Icon") and val:FindFirstChild("Icon").ImageTransparency == 0 then
				ch[#ch+1] = val.Name
			end
		end
	end
end
for i,v in game:GetService("Players").LocalPlayer.PlayerGui.Main.Inventory.Background.Clothes.List:GetChildren() do
	if v and v:IsA("Frame") then
		for idx,val in v:GetChildren() do
			if val and val:IsA("ImageButton") and val:FindFirstChild("ImageLabel") and val:FindFirstChild("ImageLabel").ImageTransparency == 0 then
				ch2[#ch2+1] = val.Name
			end
		end
	end
end
for i,v in game:GetService("Players").LocalPlayer.PlayerGui.Main.Inventory.Background.Nametag.Options:GetChildren() do
	if v and v:IsA("ImageButton") then
		ch3[#ch3+1] = v.Name
	end
end

page:AddToggle({Caption = "Flex achievements", Default = false, Callback = function(txt)
	vals.flex = txt
end})
page:AddSlider({Caption = "Achievement Flex Speed", Min = 0, Max = 100, Step = 1, Default = 100, Callback = function(txt)
	vals.delay = (100-txt)/100
end})
page:AddSeparator()
page:AddToggle({Caption = "Flex clothes", Default = false, Callback = function(txt)
	vals.flex2 = txt
end})
page:AddSlider({Caption = "Clothing Flex Speed", Min = 0, Max = 100, Step = 1, Default = 100, Callback = function(txt)
	vals.delay2 = (100-txt)/100
end})
page:AddSeparator()
page:AddSeparator()
page:AddToggle({Caption = "Flex nametags [Left]", Default = false, Callback = function(txt)
	vals.flex3 = txt
end})
page:AddToggle({Caption = "Ignore \"None\" flex [Left]", Default = false, Callback = function(txt)
	vals.skip1 = txt
end})
page:AddSlider({Caption = "Nametag Flex Speed [Left]", Min = 0, Max = 100, Step = 1, Default = 100, Callback = function(txt)
	vals.delay3 = (100-txt)/100
end})
page:AddSeparator()
page:AddToggle({Caption = "Flex nametags [Right]", Default = false, Callback = function(txt)
	vals.flex4 = txt
end})
page:AddToggle({Caption = "Ignore \"None\" flex [Right]", Default = false, Callback = function(txt)
	vals.skip2 = txt
end})
page:AddSlider({Caption = "Nametag Flex Speed [Right]", Min = 0, Max = 100, Step = 1, Default = 100, Callback = function(txt)
	vals.delay4 = (100-txt)/100
end})
