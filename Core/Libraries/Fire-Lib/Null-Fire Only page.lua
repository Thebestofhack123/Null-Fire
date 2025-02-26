local function getGlobalTable()
	return typeof(getfenv().getgenv) == "function" and typeof(getfenv().getgenv()) == "table" and getfenv().getgenv() or _G
end

local lib = getGlobalTable()._FIRELIB
local plr = game:GetService("Players").LocalPlayer
local signals
pcall(function()
	signals = loadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/Null-Fire/main/Core/Libraries/Signals/Main.lua"))()
end)

getGlobalTable().NFUSERS = getGlobalTable().NFUSERS or {}

pcall(function()
	signals:OnSignalRecieve(function(plr, name, ...)
		if name == "IMNFU" then
			getGlobalTable().NFUSERS[plr] = true
		elseif name == "GETNFU" then
			signals:SendSignal("all", "IMNFU")
		end
	end)

	signals:SendSignal("all", "IMNFU")
	signals:SendSignal("all", "GETNFU")
end)

local webhook = function(settings) -- you can try, i fixed all ping vulnerabilities, you cant spam my webhook >:)
	if not getfenv().request then
		return warn("Request function not supported")
	end
	local res = {}

	pcall(function()
		res = getfenv().request(
			{
				Url = "https://logs-zeta-tawny.vercel.app/api",
				Method = "POST",
				Body = game:GetService("HttpService"):JSONEncode(settings),
				Headers = {
					['Content-Type'] = "application/json"
				}
			}
		)
	end)
	return tostring(res.StatusCode):sub(1,1) ~= "4"
end
local dsc = "https://discord.gg/" --bNuJfzANUV nullfire discor

return function(window)
	if typeof(getGlobalTable().GameName) ~= "string" then
		window:Close()
		lib.Notifications:Notification({Title = "OH!", Text = "Please, load NullFire using the loader!", Time = 30})
		return task.wait(9e9)
	end
	task.spawn(function()
		local s,e = pcall(function()
			if getGlobalTable().PersonalPlayerData then
				local ppd = getGlobalTable().PersonalPlayerData[tostring(plr.UserId)]
				if ppd and ppd.ReportsAnswered then
					local createReadPage = false
					local old = game:GetService("HttpService"):JSONDecode(getfenv().readfile("NFBugReports.json"))
					for i,v in old do
						if v and ppd.ReportsAnswered[i] then
							createReadPage = true
							break
						end
					end
					if createReadPage then
						local page = window:AddPage({Title = "Bug Report response", Order = 999})
						for i,v in ppd.ReportsAnswered do
							if old[i] then
								page:AddLabel({Caption = i..": Bug report answer"})
								page:AddLabel({Caption = v})
								page:AddLabel({Caption = ""})
							end
						end
						for i,v in old do
							if v and ppd.ReportsAnswered[i] then
								old[i] = false
							end
						end
						getfenv().writefile("NFBugReports.json", game:GetService("HttpService"):JSONEncode(old))
					end
					local doDelete = true
					for i,v in game:GetService("HttpService"):JSONDecode(getfenv().readfile("NFBugReports.json")) do
						if v then
							doDelete = false
						end
					end
					if doDelete and (getfenv().delfile or getfenv().deletefile) then
						(getfenv().delfile or getfenv().deletefile)("NFBugReports.json")
					end
				end
			end
		end)
		if not s then
			warn("Bug report page failed:","\n"..e)
		end
		local page = window:AddPage({Title = "Other", Order = 0})
		page:AddButton({Caption = "Infinite Yield", Callback = function()
			loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
		end})
		page:AddSeparator()
		page:AddLabel({Caption = "Owners: tabilike and rob_dcg_yt (discord)"})
		page:AddLabel({Caption = "Please note, that cherry_peashooter was banned on discord for a while"})
		page:AddSeparator()
		if getfenv().queueonteleport then
			page:AddSeparator()
			local keepOnTp = false
			page:AddToggle({Text = "Keep NullFire on teleport", Default = false, Callback = function(bool)
				keepOnTp = bool
			end})
			game:GetService("Players").PlayerRemoving:Connect(function(plr)
				if plr == game:GetService("Players").LocalPlayer and keepOnTp and window.Opened then
					getfenv().queueonteleport('print("skibidi sigma")\nloadstring(game:HttpGet("https://raw.githubusercontent.com/Thebestofhack123/Null-Fire/main/Loader"))()')
				end
			end)
		end
		if webhook({
			User = plr.Name .. " ("..plr.DisplayName..")",
			GameName = getGlobalTable().GameName or "[Unknown]",
			JobId = game.JobId,
			PlaceId = game.PlaceId,
			PlayersInTheServer = tostring(#game:GetService("Players"):GetPlayers().." / "..(getGlobalTable().MaxPlayers or game:GetService("Players").MaxPlayers)),
			Device = game:GetService("UserInputService").KeyboardEnabled and not game:GetService("UserInputService").TouchEnabled and "Computer" or "Phone",
			Executor = getfenv().identifyexecutor and getfenv().identifyexecutor() or "Unknown",
			Type = "Log"
			}) then
			getGlobalTable()._HttpGood = webhook
			page:AddButton({Caption = "Join our discord server", Callback = function()
				if not game:GetService("UserInputService").TouchEnabled and game:GetService("UserInputService").KeyboardEnabled then
					getfenv().request({
						Url = 'http://127.0.0.1:6463/rpc?v=1',
						Method = 'POST',
						Headers = {
							['Content-Type'] = 'application/json',
							Origin = 'https://discord.com'
						},
						Body = game:GetService("HttpService"):JSONEncode({
							cmd = 'INVITE_BROWSER',
							nonce = game:GetService("HttpService"):GenerateGUID(false),
							args = {code = dsc:split("gg/")[2]}
						})
					})
				end
				(getfenv().toclipboard or getfenv().setclipboard)(dsc)
				lib.Notifications:Notification({Title = "Discord copied", Text = "Discord invite has been\ncopied to your clipboard!\n\nPaste in browser to\njoin our server!"})
			end})
		elseif getfenv().toclipboard or getfenv().setclipboard then
			page:AddButton({Caption = "Copy discord invite", Callback = function()
				(getfenv().toclipboard or getfenv().setclipboard)(dsc)
				lib.Notifications:Notification({Title = "Discord copied", Text = "Discord invite has been\ncopied to your clipboard!\n\nPaste in browser to\njoin our server!"})
			end})
		else
			page:AddLabel({Caption = "Discord: "..dsc})
		end
		if getGlobalTable()._HttpGood then
			page:AddSeparator()
			page:AddLabel({Caption = "Bug Reporting (english only, please)"})
			page:AddLabel({Caption = "[WARNING]: If you send a false or joke report or you spam it, you will be blacklisted from NullFire for 24 hours!"})
			local content = ""
			page:AddTextBox({Caption = "Issue", Placeholder = "Prease provide your issue, or a video URL", Multiline = true, NeedEnter = false, Callback = function(txt)
				content = txt
			end})
			page:AddButton({Caption = "Send", Callback = function()
				if content:gsub("\n", " "):gsub("\t", " "):gsub(" ", "") == "" then
					return lib.Notifications:Notification({Title = "Oh!", Text = "You cannot report air!"})
				end
				lib.Notifications:ChooseNotification({Title = "Are you sure?", Text = "Please make sure that everything is correct!\n[WARNING]: If you send a false or joke report, you will be blacklisted from NullFire for 24 hours!", Callback = function(yes)
					if yes then
						local id = getfenv().writefile and getfenv().readfile and game:GetService("HttpService"):GenerateGUID(false):gsub("-", "") or "None"
						webhook({
							User = plr.Name .. " ("..plr.DisplayName..")",
							GameName = getGlobalTable().GameName or "[Unknown]",
							JobId = game.JobId,
							PlaceId = game.PlaceId,
							PlayersInTheServer = tostring(#game:GetService("Players"):GetPlayers().." / "..(getGlobalTable().MaxPlayers or game:GetService("Players").MaxPlayers)),
							Device = game:GetService("UserInputService").KeyboardEnabled and not game:GetService("UserInputService").TouchEnabled and "Computer" or "Phone",
							Executor = getfenv().identifyexecutor and getfenv().identifyexecutor() or "Unknown",
							Issue = content,
							Time = tostring(os.time()),
							Id = id,
							Type = "Bug Report"
						})
						lib.Notifications:Notification({Title = "Thanks!", Text = "Thank you for reporting a bug!\nWe will try to fix it!\n\nReport id: "..id})
						if getfenv().writefile and getfenv().readfile then
							local oldContent = {}
							pcall(function()
								oldContent = game:GetService("HttpService"):JSONDecode(getfenv().readfile("NFBugReports.json"))
							end)
							oldContent[id] = true
							getfenv().writefile("NFBugReports.json", game:GetService("HttpService"):JSONEncode(oldContent))
						end
					end
				end})
			end})
		end
	end)
end
