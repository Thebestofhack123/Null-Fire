local defaults = {
	Noclip = false,
	AntiFling = false,
	Gravity = 195,
	VelocityBypass = false,
	ShowCurrentDisaster = false,
	ShowDisasterHint = false,
	Notify = false,
	Jesus = false,
	IslandCollide = false,
	Jesus = false,
	Bypass = false,
	NoVoid = false,
	PosSpoof = Vector3.new(),
	RotSpoof = Vector3.new(),
	RotSpoofS = Vector3.new(),
	AntiTeleport = false,
	NoBrizzardUI = false,
	NoSandstormUI = false,
	AntiEarthquake = false,
}
local vals = table.clone(defaults)

local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

getGlobalTable().FireHubLoaded = true

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/Null-Fire/main/Core/Libraries/Fire-Lib/Main.lua"))()
local closed = false
local cons = {}
local plr = game.Players.LocalPlayer
local fakeChar = Instance.new("Model")
fakeChar.Name = plr.Name.."_FAKE"
local fakeHrp = Instance.new("Part", fakeChar)
fakeHrp.Size = Vector3.new(2,2,1)
fakeHrp.CanCollide = false
fakeHrp.Transparency = 0.8
fakeHrp.Name = "HumanoidRootPart"
local fakeHum = Instance.new("Humanoid", fakeChar)
fakeChar.PrimaryPart = fakeHrp

local sideGui = Instance.new("ScreenGui", getfenv().gethui and getfenv().gethui() or game.CoreGui)
local sideUI = Instance.new("TextLabel", sideGui)
sideUI.BackgroundTransparency = 1
sideUI.TextScaled = true
sideUI.AnchorPoint = Vector2.new(0, 0.5)
sideUI.Size = UDim2.fromScale(1, 0)
sideUI.TextColor3 = Color3.new(1,1,1)
sideUI.TextStrokeTransparency = 0
sideUI.Position = UDim2.fromScale(0.0175, 0.5)
sideUI.TextXAlignment = Enum.TextXAlignment.Left
sideUI.Font = Enum.Font.Arcade
sideUI.Visible = true
sideUI.Text = ""

local fakeLevel = workspace:FindFirstChild("FakeWaterLevel") or workspace.WaterLevel:Clone()
fakeLevel.Name = "FakeWaterLevel"
fakeLevel.Parent = workspace
fakeLevel:ClearAllChildren()
fakeLevel.Transparency = 1
fakeLevel.Size = Vector3.new(2048, 5, 2048)

local function updLine(txt)
	if sideUI.Text ~= "" then
		sideUI.Text = sideUI.Text.."\n"
	end
	sideUI.Text = sideUI.Text..txt
	sideUI.Size = UDim2.fromScale(1, sideUI.Size.Y.Scale + 0.02)
end

local warning = "None"
game:GetService("ReplicatedStorage").Remotes.Round.OnClientEvent:Connect(function(s,w)
	if s == "Warn Disaster" then
		warning = table.concat(w:split("! "), "! ", 2)
	end
end)

local realCharacter = plr.Character or plr.CharacterAdded:Wait()
local disaster = "None"
local prev = "None"
local map = "None"
local respawning = false

local function died()
	respawning = true
	plr.Character = realCharacter
end
cons[#cons+1] = plr.CharacterAdded:Connect(function(char)
	if char ~= fakeChar then
		realCharacter = char
		char:WaitForChild("Humanoid", 9e9).Died:Connect(died)
		char:WaitForChild("Animate", 9e9)
		char:WaitForChild("HumanoidRootPart", 9e9)
		char:WaitForChild("Head", 9e9)
		task.wait(1)
		respawning = false
	end
end)

local pp
local d = 3
local td = 128
local none = {Name = "None"}

cons[#cons+1] = game["Run Service"].RenderStepped:Connect(function()
	workspace.Gravity = (vals.Gravity + 1) > 1 and (vals.Gravity + 1) or 0
	fakeLevel.CanCollide = vals.Jesus
	workspace.FallenPartsDestroyHeight = (vals.NoVoid or vals.Bypass) and (0/0) or 0
	if not realCharacter or not realCharacter.Parent and workspace:FindFirstChild(plr.Name) then
		pp = nil
		realCharacter = workspace:FindFirstChild(plr.Name)
		if realCharacter then
			pp = realCharacter:GetPivot()
		end
	end
	map = (workspace.Structure:FindFirstChildOfClass("Model") or none).Name
	if realCharacter then
		if realCharacter:FindFirstChild("Humanoid") then
			fakeHum.HipHeight = realCharacter.Humanoid.HipHeight
		end
		if realCharacter:FindFirstChild("HumanoidRootParent") then
			fakeHrp.Size = realCharacter.HumanoidRootParent.Size
		end
		local pos = plr.Character:GetPivot().Position
		local flood = workspace.Structure:FindFirstChild("FloodLevel")
		local y = workspace.WaterLevel.Position.Y - 2.5
		if flood then
			y = math.max(y, flood.Position.Y - 2.5)
		end
		fakeLevel.Position = Vector3.new(pos.X, y, pos.Z)
		if not vals.Noclip then
			if realCharacter:FindFirstChild("HumanoidRootPart") then
				realCharacter.HumanoidRootPart.CanCollide = true
			end
		else
			for i,v in realCharacter:GetChildren() do
				if v and v:IsA("BasePart") then
					v.CanCollide = false
				end
			end
		end
		if plr.Character:FindFirstChildOfClass("Tool") and plr.Character:FindFirstChildOfClass("Tool").Name:lower():match("balloon") then
			workspace.Gravity = workspace.Gravity * 0.30612244897959184
		end
	end
	local mod = 0
	if workspace.CurrentCamera then
		workspace.CurrentCamera.CameraSubject = plr.Character
		local pos = workspace.CurrentCamera.CFrame.Position
		local dist = (pos - fakeHrp.Position).Magnitude
		if dist <= d then
			if dist <= d/7.5 then
				mod = 1
			else
				mod = d - dist
			end
		end
		mod = math.clamp(mod, 0, 1)
	end
	fakeHrp.LocalTransparencyModifier = mod
	if not respawning and realCharacter then
		if fakeHum.Health <= 0.01 and realCharacter and realCharacter:FindFirstChild("Humanoid") then
			realCharacter.Humanoid.Health = -100
		end
		if plr.Character == fakeChar and not vals.Bypass then
			fakeChar.Parent = nil
			realCharacter:PivotTo(fakeChar:GetPivot())
		end
		plr.Character = vals.Bypass and fakeChar or realCharacter
		local pos = fakeHrp.Position
		if pos.Y <= -25 or pos.Y + (fakeHrp.AssemblyLinearVelocity.Y/10) <= -25 then
			fakeHrp.AssemblyLinearVelocity = Vector3.new(fakeHrp.AssemblyLinearVelocity.X, math.abs(fakeHrp.AssemblyLinearVelocity.Y)/2, fakeHrp.AssemblyLinearVelocity.Z) + Vector3.new(0, 5)
			fakeChar:PivotTo(fakeHrp.CFrame + Vector3.new(0, 10))
		end
		if realCharacter and realCharacter:FindFirstChild("Humanoid") then
			realCharacter.Humanoid.PlatformStand = vals.Bypass
		end
		if vals.Bypass then
			if realCharacter:FindFirstChild("Humanoid") then
				realCharacter.Humanoid:MoveTo(fakeHrp.Position + (fakeHum.MoveDirection * 100))
				fakeHum.Health = math.clamp(realCharacter.Humanoid.Health, 1, 100)
			end
			fakeHrp.CanCollide = not vals.Noclip
			fakeChar.Parent = workspace
			
			if pp and (realCharacter:GetPivot().Position - pp.Position).Magnitude >= td and not vals.AntiTeleport then
				fakeChar:PivotTo(CFrame.new(realCharacter:GetPivot().Position))
			end

			realCharacter:PivotTo((fakeChar:GetPivot() + (fakeHrp.CFrame.XVector * vals.PosSpoof.X) + (fakeHrp.CFrame.YVector * vals.PosSpoof.Y) + (fakeHrp.CFrame.ZVector * vals.PosSpoof.Z)) * (CFrame.Angles(math.rad(vals.RotSpoof.X), math.rad(vals.RotSpoof.Y), math.rad(vals.RotSpoof.Z))))
		else
			if pp and (realCharacter:GetPivot().Position - pp.Position).Magnitude >= td and vals.AntiTeleport then
				realCharacter:PivotTo(pp)
			end
			fakeChar:PivotTo(realCharacter:GetPivot())
			fakeChar.Parent = nil
		end
	end
	for i,v in realCharacter:GetDescendants() do
		if v and v:IsA("BasePart") then
			if v.Name ~= "HumanoidRootPart" or vals.Bypass then
				v.CanCollide = false
			end
			v.LocalTransparencyModifier = fakeHrp.LocalTransparencyModifier
			if vals.Bypass then
				v.AssemblyLinearVelocity = Vector3.new(math.clamp(v.AssemblyLinearVelocity.X, -1, 1), 3, math.clamp(v.AssemblyLinearVelocity.Z, -1, 1))
			end
		end
	end
	if realCharacter then
		pp = realCharacter:GetPivot()
	end
	disaster = "None"
	for i,v in game.Players:GetPlayers() do
		if v and v.Character then
			if (vals.AntiFling or vals.AntiFling2) and v ~= plr then
				for idx,val in v.Character:GetChildren() do
					if val and val:IsA("BasePart") then
						if vals.AntiFling then
							val.AssemblyLinearVelocity = Vector3.new()
							val.AssemblyAngularVelocity = Vector3.new()
						end
						if vals.AntiFling2 then
							val.CanCollide = false
						end
					end
				end
			end
			if v ~= plr and v.Character:FindFirstChild("HumanoidRootPart") and not vals.AntiFling2 then
				v.Character.HumanoidRootPart.CanCollide = true
			end
			if v.Character:FindFirstChild("SurvivalTag") and v.Character.SurvivalTag.Value ~= "" then
				disaster = v.Character.SurvivalTag.Value
			end
		end
	end
	if plr.PlayerGui:FindFirstChild("BlizzardGui") then
		plr.PlayerGui.BlizzardGui.Enabled = not vals.NoBlizzardUI
	end

	if plr.PlayerGui:FindFirstChild("SandStormGui") then
		plr.PlayerGui.SandStormGui.Enabled = not vals.NoSandstormUI
	end
	
	sideUI.Text = ""
	sideUI.Size = UDim2.fromScale(1, 0)
	
	if vals.ShowCurrentDisaster then
		updLine("Disaster: "..disaster)
	end
	if vals.ShowDisasterHint then
		updLine("Warning: "..warning)
	end

	if prev ~= disaster and disaster ~= "None" then
		prev = disaster
		if vals.Notify then
			game.TextChatService.TextChannels.RBXGeneral:SendAsync(disaster.."!")
		end
	end
	if disaster == "None" then
		warning = "None"
		prev = "None"
	end
end)
task.spawn(function()
	while not closed and task.wait(0) do
		for i,v in workspace.Island:GetChildren() do
			if v and v:IsA("BasePart") then
				if v.Name == "LowerRocks" then
					v.CanCollide = vals.IslandCollide
				elseif (v.Name == "Grass" or v.Name == "Part") and vals.AntiEarthquake then
					v.AssemblyLinearVelocity = Vector3.new()
					v.AssemblyAngularVelocity = Vector3.new()
				end
			end
		end
	end
end)

local window = lib:MakeWindow({Title = "NullFire: NDS", CloseCallback = function()
	for i,v in defaults do
		vals[i] = v
	end
	getGlobalTable().FireHubLoaded = false
	closed = true
	for i=1, 3 do
		game["Run Service"].RenderStepped:Wait()
	end
	plr.Character = realCharacter
	sideGui:Destroy()
	fakeChar:Destroy()
	for i,v in cons do
		v:Disconnect()
	end
end}, true)

local page = window:AddPage({Title = "Character"})
page:AddToggle({Caption = "Noclip", Default = false, Callback = function(b)
	vals.Noclip = b
end})
page:AddToggle({Caption = "Anti Fling", Default = false, Callback = function(b)
	vals.AntiFling = b
end})
page:AddToggle({Caption = "No players collision", Default = false, Callback = function(b)
	vals.AntiFling2 = b
end})
page:AddToggle({Caption = "Jesus (Water walker)", Default = false, Callback = function(b)
	vals.Jesus = b
end})
page:AddSeparator()
page:AddToggle({Caption = "Speed bypass", Default = false, Callback = function(b)
	vals.Bypass = b
end})

local function addVector3(cap, val)
	local setMode = false
	local first = true
	local text; text = page:AddTextBox({Caption = cap, Default = "0, 0, 0", Enter = true, Callback = function(txt)
		if setMode then
			setMode = false
			return
		end
		
		local splits = txt:gsub(";", ","):gsub(" ", ""):gsub("\r", ""):gsub("\n", ""):gsub("\t", ""):split(",")
		local n1, n2, n3 = (tonumber(splits[1]) or 0), (tonumber(splits[2]) or 0), (tonumber(splits[3]) or 0)
		local vector = Vector3.new(n1, n2, n3)
		
		vals[val] = vector
		if not first then
			setMode = true
			text:Set(tostring(vector))
		else
			first = false
		end
	end})
	return text
end
addVector3("Position spoof [only with speed bypass]", "PosSpoof")
local rot = addVector3("Rotation spoof [only with speed bypass]", "RotSpoof")
addVector3("Rotation spoof speed", "RotSpoofS")
task.spawn(function()
	while not closed and task.wait(0.01) do
		if vals.RotSpoofS ~= Vector3.new() then
			local vector = vals.RotSpoof + vals.RotSpoofS
			rot:Set(tostring(Vector3.new(vector.X % 360, vector.Y % 360, vector.Z % 360)))
		end
	end
end)
page:AddSeparator()
page:AddToggle({Caption = "Anti teleport", Default = false, Callback = function(b)
	vals.AntiTeleport = b
end})

local page = window:AddPage({Title = "World"})
local grav = page:AddSlider({Caption = "Gravity", Default = 196, Min = 0, Max = 5500, Step = 1, Callback = function(v)
	vals.Gravity = v
end})
local function gravBtn(name, amnt)
	page:AddButton({Caption = name.." gravity ["..amnt.."]", Callback = function()
		grav:Set(amnt)
	end})
end

gravBtn("Normal", 195)
gravBtn("Balloon", 75)
page:AddSeparator()
gravBtn("Uranus", 175)
gravBtn("Neptune", 225)
gravBtn("Moon", 30)
gravBtn("Saturn", 210)
gravBtn("Jupiter", 495)
gravBtn("Venus", 180)
gravBtn("Mars", 75)
page:AddSeparator()
gravBtn("Sun", 5488)
gravBtn("Zero", 0)
gravBtn("Low", 10)
gravBtn("Very low", 3)

page:AddSeparator()
page:AddToggle({Caption = "Whole island collides", Default = false, Callback = function(b)
	vals.IslandCollide = b
end})
page:AddToggle({Caption = "No void", Default = false, Callback = function(b)
	vals.NoVoid = b
end})

local page = window:AddPage({Title = "Disaster"})
page:AddToggle({Caption = "Show current disaster", Default = false, Callback = function(b)
	vals.ShowCurrentDisaster = b
end})
page:AddToggle({Caption = "Show disaster hint", Default = false, Callback = function(b)
	vals.ShowDisasterHint = b
end})
page:AddToggle({Caption = "Notify disasters in chat", Default = false, Callback = function(b)
	vals.Notify = b
end})
page:AddToggle({Caption = "No blizzard UI", Default = false, Callback = function(b)
	vals.NoBlizzardUI = b
end})
page:AddToggle({Caption = "No sandstorm UI", Default = false, Callback = function(b)
	vals.NoSandstormUI = b
end})
page:AddToggle({Caption = "Anti Earthquake", Default = false, Callback = function(b)
	vals.AntiEarthquake = b
end})
