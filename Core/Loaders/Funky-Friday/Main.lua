local defaults = {
	showNPS = false,
	showNPSD = false,
	autoplay = false,
	showMaxNPS = false,
	autosolo = false,
	showRendered = false,
	showFPS = false,
	unfair = false,
	infscore = false,
	nomiss = false,
	nodeath = false,
	increaseonmiss = false,
	megascore = false,
	combo = false,
	method = false,
	redirect = false,
	extraDelay = 0,
	extraLongDelay = 0,
	extraDelayRNG = 0,
	extraLongDelayRNG = 0,
	missnps = 0,
	chances = {
		Sick = 95,
		Good = 4,
		Ok = 1,
		Bad = 0,
		Miss = 0
	}
}
local vals = table.clone(defaults)

local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

getGlobalTable().FireHubLoaded = true

local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/Null-Fire/main/Core/Libraries/Fire-Lib/Main.lua"))()
local closed = false

if not getfenv().getgc then
	task.spawn(lib.Notifications.Notification, lib.Notifications, {Time = 30, Title = "Unsupported", Text = "Your executor ("..(getfenv().identifyexecutor and getfenv().identifyexecutor() or "RobloxClient").." does not support that script:\nMissing \"getgc\""})
end

local npsGui = Instance.new("ScreenGui", getfenv().gethui and getfenv().gethui() or game.CoreGui)
local npsText = Instance.new("TextLabel", npsGui)
npsText.BackgroundTransparency = 1
npsText.TextScaled = true
npsText.AnchorPoint = Vector2.new(0, 0.5)
npsText.Size = UDim2.fromScale(0.1, 0.5)
npsText.TextColor3 = Color3.new(1,1,1)
npsText.TextStrokeTransparency = 0
npsText.Position = UDim2.fromScale(0.0175, 0.5)
npsText.TextXAlignment = Enum.TextXAlignment.Left
npsText.Font = Enum.Font.Arcade
npsText.Visible = false

local cons = {}

local framework
if getfenv().getgc then
	for i=1, 6 do
		for i,v in getfenv().getgc(true) do
			if type(v) == "table" and rawget(v, "GameUI") then
				framework = v
				break
			end
		end
		if framework then break end
		task.wait(2.5)
	end
end

if not framework and getfenv().getgc then
	task.spawn(lib.Notifications.Notification, lib.Notifications, {Time = 30, Title = "Unsupported", Text = "Your executor ("..(getfenv().identifyexecutor and getfenv().identifyexecutor() or "RobloxClient").." does not support that script:\nFailed to grab the game framework (\"getgc\" is probably faked)"})
end

local set = getfenv().setidentity or getfenv().setthreadcontext or getfenv().setthreadidentity or function() end
local get = getfenv().getidentity or getfenv().getthreadcontext or getfenv().getthreadidentity or function() return 8 end

local old = get()

local notified = false
local storage = {}

local function getSignal(sig)
	if not getfenv().getconnections and framework then
		if not notified then
			notified = true
			task.spawn(lib.Notifications.Notification, lib.Notifications, {Time = 30, Title = "Unstable", Text = "Your executor ("..(getfenv().identifyexecutor and getfenv().identifyexecutor() or "RobloxClient").." does not support getconnections\nAutoplay can be buggy"})
		end
		return
	end
	for _, signal in getfenv().getconnections(sig) do
		local func = signal.Function
		if type(func) == "function" and debug.info(func, "s") ~= "[C]" then
			local scr = rawget(getfenv(func), "script")
			if scr and scr.Name == "ScrollHandler" then
				return function(keyCode)
					local kk = storage[keyCode] or {KeyCode = keyCode, UserInputType = Enum.UserInputType.Keyboard}
					storage[keyCode] = kk

					pcall(func, kk)
				end
			end
		end
	end
end

set(2)

local signalPress = getSignal(game:GetService("UserInputService").InputBegan)
local signalRelease = getSignal(game:GetService("UserInputService").InputEnded)

local spawn = task.spawn

local PressKey

local function sendevent(keyCode, state)
	game:GetService("VirtualInputManager"):SendKeyEvent(state, keyCode, false, game)
end

if signalPress and signalRelease then
	vals.method = true
	function PressKey(keyCode, state)
		if vals.method then
			(state and signalPress or signalRelease)(keyCode)
		else
			sendevent(keyCode, state)
		end
	end
else
	PressKey = sendevent
end

local ignoredNoteTypes = { Death = true, Mechanic = true, Poison = true }

local id = {}
local nps = {}
local maxNps = 0
local fps = 0
local rendered = 0
local keyCodeMap = {}

for _, enum in Enum.KeyCode:GetEnumItems() do
	keyCodeMap[enum.Value] = enum
end

local soloT = {
	[1] = "Server",
	[2] = "StageManager",
	[3] = "PlaySolo"
}
local empty = {}
local function startSolo()
	game:GetService("ReplicatedStorage"):WaitForChild("RE"):FireServer(soloT, empty)
end

local function rollChance(table)
	local totalChance = 0
	for _, chance in table do
		totalChance = totalChance + chance
	end

	local roll = math.random() * totalChance
	local cumulativeChance = 0

	for name, chance in table do
		cumulativeChance = cumulativeChance + chance
		if roll <= cumulativeChance then
			return name
		end
	end

	for name, _ in table do
		return name
	end

	return "None"
end

local hitVals = {
	["Miss"] = 100,
	["Sick"] = 96,
	["Good"] = 92,
	["Ok"] = 85,
	["Bad"] = 80
}

local function appendText(text, newLines)
	if text == "" then return end
	newLines = newLines or 1
	if npsText.Text ~= "" then
		npsText.Text = npsText.Text .. string.rep("\n", newLines) .. text
	else
		npsText.Text = text
	end
end

local rf = game:GetService("ReplicatedStorage").RF
local re = game:GetService("ReplicatedStorage").RE

local updsc = {"Server", "RoundManager", "UpdateScore"}
local updh = {"Server", "RoundManager", "UpdateHealth"}
local gain = {"Gain"}
local loss = {"Loss"}

local function gainScore(score)
	rf:InvokeServer(updsc, {score})
	rf:InvokeServer(updh, score > 0 and gain or loss)
end

if getfenv().hookmetamethod and getfenv().getnamecallmethod then
	local old; old = getfenv().hookmetamethod(game, "__namecall", function(self, ...)
		local method = getfenv().getnamecallmethod()
		if self == rf and method == "InvokeServer" then
			if vals.nomiss or vals.infscore or vals.megascore or vals.nodeath or vals.increaseonmiss then
				local args = {...}
				if args[1][3] == "UpdateScore" then
					local val = tonumber(args[2][1]) or 0
					local abs = math.abs(val)
					args[2][1] = (vals.infscore or vals.megascore) and 50000 or (vals.nomiss or vals.increaseonmiss) and (math.clamp(abs, 100, 10000)) or val
					return old(self, unpack(args))
				elseif args[1][3] == "UpdateHealth" and vals.nomiss then
					args[2][1] = "Gain"
					return old(self, unpack(args))
				elseif args[1][3] == "Died" and vals.nodeath then
					return "!"
				end
			end
		elseif self == re and method == "FireServer" then
			if ({...})[1][3] == "Died" and vals.nodeath then
				return
			end
		end

		return old(self, ...)
	end)
end

local NPS, s = 0, ""
local framesPassed = 0

local function func3(keyCode)
	nps[keyCode] = (nps[keyCode] or 0) + 1
	task.wait(1)
	nps[keyCode] = nps[keyCode] - 1
	if nps[keyCode] < 0 then
		nps[keyCode] = 0
	end
end

local function func2(arrow, arrowData, count)
	local keyCode = keyCodeMap[arrowData[(arrow.Data.Position % count) .. ''].Keybinds.Keyboard[1] ]

	if vals.missnps ~= defaults.missnps and nps[keyCode] and nps[keyCode] > vals.missnps then
		nps[keyCode] = nps[keyCode] - 1
		arrow.HitValue = "Miss"
		return
	end
	local arrowId = (id[keyCode] or 0) + 1

	id[keyCode] = arrowId
	task.spawn(func3, keyCode)
	arrow.Buzy = true

	PressKey(keyCode, false)
	PressKey(keyCode, true)

	local arrowLen = (arrow.Data.Length or 0)
	if vals.extraDelay ~= 0 then
		arrowLen = arrowLen + ((vals.extraDelay/1000) + (math.random(-vals.extraDelayRNG, vals.extraDelayRNG))/1000)
	end
	if vals.extraLongDelay ~= 0 and arrow.Data.Length and arrow.Data.Length ~= 0 then
		arrowLen = arrowLen + (vals.extraLongDelay/1000) + (math.random(-vals.extraLongDelayRNG, vals.extraLongDelayRNG)/1000)
	end

	if arrowLen > 0 then
		task.wait(arrowLen)
	end

	arrow.Buzy = false

	if arrowId == id[keyCode] then
		PressKey(keyCode, false)
		id[keyCode] = 0
	end
end

local function func1(arrow, arrowData, count)
	rendered = rendered + 1

	if not arrow or arrow.Buzy or arrow.HitValue == "Miss" or arrow.NoteDataConfigs and ignoredNoteTypes[arrow.NoteDataConfigs.Type] then return end

	arrow.HitValue = arrow.HitValue or vals.autoplay and rollChance(vals.chances) or nil

	if arrow.Side == framework.UI.CurrentSide then
		local songTime = framework.SongPlayer.CurrentTime / (framework.SongPlayer.CurrentSongConfigs.PlaybackSpeed or 1)
		local hitboxOffset = framework.Settings.HitboxOffset.Value / 1000

		if vals.unfair then
			arrow.Data.Time = songTime + hitboxOffset
		end

		if vals.autoplay and (vals.unfair or math.clamp((1 - math.abs(arrow.Data.Time - (songTime + hitboxOffset))) * 100, 0, 100) >= (hitVals[arrow.HitValue or "Sick"] or hitVals.Sick)) then
			task.spawn(func2, arrow, arrowData, count)
		end
	end
end

local deltaSum, frames = 0, 12

cons[#cons+1] = game:GetService("RunService").RenderStepped:Connect(function(delta)
	rendered = 0
	deltaSum += delta
	framesPassed += 1
	if framesPassed == frames then
		fps = frames / deltaSum
		deltaSum = 0
		framesPassed = 0
	end

	if vals.autoplay or vals.unfair then
		local count = framework.SongPlayer:GetKeyCount()

		local arrowData = framework.ArrowData[count .. 'Key'].Arrows
		for i, arrow in next, framework.UI:GetNotes() do
			task.spawn(func1, arrow, arrowData, count)
		end
	end
	npsText.Text = ""
	if vals.showNPS or vals.showNPSD or vals.showMaxNPS or vals.showRendered or vals.showFPS then
		NPS = 0
		s = ""

		for i,v in nps do
			NPS = NPS + v
			s = s .. i.Name:sub(1,2) .. ":" .. (#i.Name == 1 and "  " or " ") .. string.format("%02d", v) .. "\n"
		end

		maxNps = math.max(NPS, maxNps)

		if vals.showNPS then
			appendText(string.format("%03d", NPS).." NPS")
		end
		if vals.showFPS then
			appendText(string.format("%03d", (tostring(fps)):split(".")[1]).." FPS")
		end
		if vals.showRendered then
			appendText(string.format("%03d", rendered).." Notes rendered")
		end
		if vals.showMaxNPS then
			appendText(string.format("%03d", maxNps).." Max NPS")
		end
		if vals.showNPSD and s ~= "" then
			if npsText.Text ~= "" then
				npsText.Text = s .. "\n" .. npsText.Text
			else
				npsText.Text = s
			end
		end
	end
	npsText.Visible = vals.showNPS or vals.showNPSD or vals.showMaxNPS or vals.showRendered or vals.showFPS
	npsText.Size = UDim2.fromScale(
		0.5,
		(#npsText.Text:split("\n"))/35
	)
	if vals.nomiss and framework.UI and framework.UI.Misses then
		framework.UI.Combo += framework.UI.Misses
		if framework.UI.ScoreCounter then
			framework.UI.ScoreCounter.Sick += framework.UI.Misses
			framework.UI.ScoreCounter.Miss = -1
		end
		framework.UI.Misses = 0
	end
	if vals.combo then
		framework.UI.Combo = 9999 - 1
		framework.UI.TotalHits = 9999 - 1
		framework.UI.Accuracy = 9999 - 1
		if framework.UI.ScoreCounter then
			framework.UI.ScoreCounter.Ok = 0
			framework.UI.ScoreCounter.Bad = 0
			framework.UI.ScoreCounter.Miss = -1
			framework.UI.ScoreCounter.Good = 0
			framework.UI.ScoreCounter.Sick = 9999 - 1
		end
	end
	if vals.autosolo then
		startSolo()
	end
end)
task.spawn(function()
	while not closed and task.wait(0) do
		if vals.infscore then
			for i=1, 3 do
				task.spawn(gainScore, 50000)
			end
		end
	end
end)

local firesignalGood = false
local sucks = (getfenv().identifyexecutor or function() return "robloz" end)():lower():match("delta") ~= nil
if getfenv().getconnections then
	local event = Instance.new("BindableEvent")
	event.Event:Connect(function()
		firesignalGood = true
	end)
	for i,v in getfenv().getconnections(event.Event) do
		if v and v.Function then
			task.spawn(pcall, v.Function)
		end
	end
	event:Destroy()
end

set(old)

local window = lib:MakeWindow({Title = "NullFire: Funky Friday", CloseCallback = function()
	for i,v in defaults do
		vals[i] = v
	end
	getGlobalTable().FireHubLoaded = false
	closed = true
	for i=1, 3 do
		game:GetService("RunService").RenderStepped:Wait()
	end
	for i,v in cons do
		v:Disconnect()
	end
	npsGui:Destroy()
end}, true)
if framework then
	local page = window:AddPage({Title = "Auto play"})
	page:AddToggle({Caption = "Autoplay", Callback = function(bool)
		vals.autoplay = bool
	end, Default = false})
	if vals.method then
		page:AddToggle({Caption = "Use FireSignal [Disable only if autoplayer does not work]", Callback = function(bool)
			vals.method = bool
		end, Default = not sucks and firesignalGood})
	end
	page:AddToggle({Caption = "Auto solo", Callback = function(bool)
		vals.autosolo = bool
	end, Default = false})
	page:AddSeparator()
	page:AddSlider({Caption = "\"Sick\" Chance", Default = 95, Min = 0, Max = 100, Step = 1, Callback = function(v)
		vals.chances.Sick = v
	end})
	page:AddSlider({Caption = "\"Good\" Chance", Default = 4, Min = 0, Max = 100, Step = 1, Callback = function(v)
		vals.chances.Good = v
	end})
	page:AddSlider({Caption = "\"Ok\" Chance", Default = 1, Min = 0, Max = 100, Step = 1, Callback = function(v)
		vals.chances.Ok = v
	end})
	page:AddSlider({Caption = "\"Bad\" Chance", Default = 0, Min = 0, Max = 100, Step = 1, Callback = function(v)
		vals.chances.Bad = v
	end})
	page:AddSlider({Caption = "\"Miss\" Chance", Default = 0, Min = 0, Max = 100, Step = 1, Callback = function(v)
		vals.chances.Miss = v
	end})
	page:AddSeparator()
	page:AddSlider({Caption = "Miss when reached X notes per second (0 to disable)", Default = 0, Min = 0, Max = 50, Step = 1, Callback = function(v)
		vals.missnps = v
	end})
	page:AddSeparator()
	page:AddSlider({Caption = "Arrow hold time (ms)", Default = 0, Min = 0, Max = 1000, Step = 1, Callback = function(v)
		vals.extraDelay = v
	end})
	page:AddSlider({Caption = "Extra random holding time (ms)", Default = 0, Min = 0, Max = 1000, Step = 1, Callback = function(v)
		vals.extraDelayRNG = v
	end})
	page:AddSeparator()
	page:AddSlider({Caption = "Long arrow hold time (ms)", Default = 0, Min = 0, Max = 1000, Step = 1, Callback = function(v)
		vals.extraLongDelay = v
	end})
	page:AddSlider({Caption = "Extra random long arrow holding time (ms)", Default = 0, Min = 0, Max = 1000, Step = 1, Callback = function(v)
		vals.extraLongDelayRNG = v
	end})
end

local page = window:AddPage({Title = "Visual"})
if framework then
	page:AddToggle({Caption = "Show notes per second", Callback = function(bool)
		vals.showNPS = bool
	end, Default = false})
	page:AddToggle({Caption = "Show notes per second [Advanced]", Callback = function(bool)
		vals.showNPSD = bool
	end, Default = false})
	page:AddToggle({Caption = "Show max notes per second", Callback = function(bool)
		vals.showMaxNPS = bool
	end, Default = false})
	page:AddToggle({Caption = "Show rendered notes", Callback = function(bool)
		vals.showRendered = bool
	end, Default = false})
end
page:AddToggle({Caption = "Show FPS", Callback = function(bool)
	vals.showFPS = bool
end, Default = false})

local page = window:AddPage({Title = "Unfair"})
if framework then
	page:AddToggle({Caption = "Unfair mode (Every note you will try to hit will be \"Sick 0.00ms\")", Callback = function(bool)
		vals.unfair = bool
	end, Default = false})
end
page:AddToggle({Caption = "Max score", Callback = function(bool)
	vals.infscore = bool
end, Default = false})
if framework then
	page:AddToggle({Caption = "No miss", Callback = function(bool)
		vals.nomiss = bool
	end, Default = false})
	page:AddToggle({Caption = "Mega-omega super-tuber nitro-ohio combo", Callback = function(bool)
		vals.combo = bool
	end, Default = false})
	page:AddSeparator()
end
if getfenv().hookmetamethod and getfenv().getnamecallmethod then
	page:AddToggle({Caption = "Mega score: Any score change will act like you just hit \"Sick\" note", Callback = function(bool)
		vals.megascore = bool
	end, Default = false})
	page:AddToggle({Caption = "Increase score on miss", Callback = function(bool)
		vals.increaseonmiss = bool
	end, Default = false})
	page:AddToggle({Caption = "No death", Callback = function(bool)
		vals.nodeath = bool
	end, Default = false})
end
local grant = "0"
page:AddSeparator()
local tb; tb = page:AddTextBox({Caption = "Score to give yourself", Placeholder = "", Default = grant, Callback = function(txt)
	if txt == grant then return end
	if not tonumber(txt) then
		tb:SetText(grant)
	else
		grant = txt
	end
end})
page:AddButton({Caption = "Give score", Callback = function()
	local num = tonumber(grant)
	local step = 50
	if num then
		if num > step then
			local leftover = num
			for i = step, num, step do
				task.spawn(gainScore, step)
				leftover = leftover - step
				if i % (step * 25) == 0 then
					task.wait()
				end
			end
			task.spawn(gainScore, leftover)
		elseif num < -step then
			local leftover = num
			for i = step, math.abs(num), step do
				task.spawn(gainScore, -step)
				leftover = leftover + step
				if i % (step * 25) == 0 then
					task.wait()
				end
			end
			task.spawn(gainScore, leftover)
		else
			task.spawn(gainScore, num)
		end
	end
end})

if getfenv().hookmetamethod then
	page:AddLabel({Caption = "Warning: Giving score can be buggy when max score or mega score options are enabled.\nAlso might break on multiplayer"})
end

task.wait(5)

if sucks then
	task.spawn(lib.Notifications.Notification, lib.Notifications, {Time = 30, Title = "Delta sucks", Text = "Delta sucks:\n99% chance of autoplayer wont work"})
end
