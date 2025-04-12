local LocalPlayer = game:GetService("Players").LocalPlayer
local promptRegistry = {}
local proximityFired = false
local firePrompt = getfenv().fireproximityprompt

if firePrompt then
    pcall(function()
        task.spawn(function()
            while true do
                if proximityFired then
                    local fakePrompt = Instance.new("ProximityPrompt", workspace)
                    fakePrompt.Triggered:Connect(function()
                        firePrompt:Disconnect()
                        proximityFired = true
                        fakePrompt:Destroy()
                    end)

                    firePrompt(fakePrompt)
                    task.wait(1.5)
                    if fakePrompt and fakePrompt.Parent then
                        fakePrompt:Destroy()
                    end
                end
                task.wait(0.1)
            end
        end)
    end)
end

local function waitFrames(frames)
    frames = math.max(tonumber(frames) or 1, 1)
    local total = 0
    for i = 1, frames do
        total += game:GetService("RunService").RenderStepped:Wait()
    end
    return total / frames
end

local function simulatePrompt(prompt)
    if not prompt or not prompt.Parent or promptRegistry[prompt] then return end
    promptRegistry[prompt] = true

    local originalMaxDistance = prompt.MaxActivationDistance
    local originalEnabled = prompt.Enabled
    local originalParent = prompt.Parent
    local originalHoldDuration = prompt.HoldDuration
    local originalLOS = prompt.RequiresLineOfSight

    local dummy = Instance.new("Part", workspace)
    dummy.Size = Vector3.new(1, 0.1, 0.1)
    dummy.Transparency = 1
    dummy.Anchored = true
    dummy.CanCollide = false

    prompt.Parent = dummy
    prompt.MaxActivationDistance = math.huge
    prompt.Enabled = true
    prompt.RequiresLineOfSight = false
    prompt.HoldDuration = 0

    dummy.CFrame = workspace.CurrentCamera.CFrame + workspace.CurrentCamera.CFrame.LookVector / 3
    prompt:InputHoldBegin()
    waitFrames(3)
    prompt:InputHoldEnd()
    waitFrames(3)

    prompt.Parent = originalParent
    prompt.MaxActivationDistance = originalMaxDistance
    prompt.Enabled = originalEnabled
    prompt.RequiresLineOfSight = originalLOS
    prompt.HoldDuration = originalHoldDuration

    dummy:Destroy()
    promptRegistry[prompt] = false
end

local function triggerPrompt(prompt)
    if proximityFired then
        firePrompt(prompt)
    else
        task.spawn(simulatePrompt, prompt)
    end
end

local fireTouch = getfenv().firetouchinterest
if fireTouch then
    task.spawn(function()
        local fakePart = Instance.new("Part", workspace)
        fakePart.Position = Vector3.new(0, 100, 0)
        fakePart.Anchored = true
        fakePart.CanCollide = false
        fakePart.Transparency = 1
        fakePart.Size = Vector3.new(1, 1, 1)

        fakePart.Touched:Connect(function()
            fakePart:Destroy()
        end)

        task.wait(0.1)
        fireTouch(LocalPlayer.Character.HumanoidRootPart, fakePart, 0)
        task.wait()
        fireTouch(fakePart, LocalPlayer.Character.HumanoidRootPart, 1)
    end)
end

local ShootRemote = game:GetService("ReplicatedStorage").Remotes.Weapon.Shoot
local ReloadRemote = game:GetService("ReplicatedStorage").Remotes.Weapon.Reload

local function reloadWeapon(tool)
    ReloadRemote:FireServer(workspace:GetServerTimeNow(), tool)
end

local function shootWeapon(tool, target)
    if not target then return end

    local pivot = target:FindFirstChild("HumanoidRootPart") or target:GetPivot()
    local pelletMap = {}
    for i = 1, tool.WeaponConfiguration.PelletsPerBullet.Value do
        pelletMap[tostring(i)] = target:FindFirstChild("Humanoid") or target
    end

    ShootRemote:FireServer(
        workspace:GetServerTimeNow(),
        tool,
        CFrame.lookAt(pivot.Position + (pivot.CFrame.LookVector * 5), pivot.Position),
        pelletMap
    )

    reloadWeapon(tool)
end

local function moveToPosition(pos)
    if typeof(pos) == "Instance" then
        pos = pos.Position
    end
    LocalPlayer.Character:PivotTo(CFrame.new(pos))
end

local function pickupTool(toolName)
    local tool = workspace.RuntimeItems:FindFirstChild(toolName)
    if not tool then return end

    LocalPlayer.Character.Humanoid:MoveTo(tool.Position)
    task.wait()

    game:GetService("ReplicatedStorage").Remotes.Tool.PickUpTool:FireServer(tool)

    repeat
        task.wait()
        tool = LocalPlayer.Character:FindFirstChild(toolName) or LocalPlayer.Backpack:FindFirstChild(toolName)
    until tool

    return tool
end

local function getUsableWeapon()
    for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("ServerWeaponState") then
            if item.ServerWeaponState.CurrentAmmo.Value > 0 then
                return item
            end
        end
    end

    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
        if item:IsA("Tool") and item:FindFirstChild("ServerWeaponState") then
            if item.ServerWeaponState.CurrentAmmo.Value > 0 then
                return item
            end
        end
    end

    return pickupTool("DefaultGun")
end

task.spawn(function()
    while true do
        task.wait(0.1)

        for _, obj in ipairs(workspace:GetDescendants()) do
            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
            if prompt then
                triggerPrompt(prompt)
            end
        end

        local weapon = getUsableWeapon()
        if weapon then
            for _, potentialTarget in ipairs(workspace:GetDescendants()) do
                if potentialTarget:IsA("Model") and potentialTarget:FindFirstChild("Humanoid") and potentialTarget ~= LocalPlayer.Character then
                    shootWeapon(weapon, potentialTarget)
                    break
                end
            end
        end
    end
end)
