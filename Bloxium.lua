-- Services
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local guiParent = pcall(function() return CoreGui end) and CoreGui or player:WaitForChild("PlayerGui")

-- Library Base
local Bloxium = {
	Theme = {
		Background = Color3.fromRGB(15, 15, 18),
		Sidebar = Color3.fromRGB(20, 20, 24),
		TopBar = Color3.fromRGB(22, 22, 26),
		Section = Color3.fromRGB(22, 22, 26),
		Element = Color3.fromRGB(30, 30, 36),
		Accent = Color3.fromRGB(90, 120, 255),
		Text = Color3.fromRGB(240, 240, 240),
		TextMuted = Color3.fromRGB(160, 160, 170),
		Border = Color3.fromRGB(45, 45, 52)
	}
}

-- Notification Host Initialization
local notifyHost = Instance.new("Frame")
notifyHost.Name = "NotificationHost"
notifyHost.Size = UDim2.new(0, 250, 1, -20)
notifyHost.Position = UDim2.new(1, -260, 0, 10)
notifyHost.BackgroundTransparency = 1

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Parent = notifyHost
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.Padding = UDim.new(0, 8)

function Bloxium:Notify(opts)
	opts = opts or {}
	local titleText = opts.Title or "Notification"
	local descText = opts.Description or ""
	local duration = opts.Duration or 3

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, 60)
	toast.BackgroundColor3 = Bloxium.Theme.Section
	toast.BorderSizePixel = 0
	toast.BackgroundTransparency = 1
	toast.Parent = notifyHost

	Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 6)

	local stroke = Instance.new("UIStroke")
	stroke.Color = Bloxium.Theme.Accent
	stroke.Thickness = 1
	stroke.Transparency = 1
	stroke.Parent = toast

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 20)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Bloxium.Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 13
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTransparency = 1
	title.Parent = toast

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -20, 0, 25)
	desc.Position = UAlright, let's get it done. Here is the full foundational ModuleScript for a modular, battlegrounds-style M1 combat and combo tracking system. 

This handles state attributes, combo resets, and spatial query hitboxing without locking anything to a 2D plane (keeping it fully 3D).

### M1 Combat Module (`ServerScriptService`)

```lua
local CombatModule = {}
local Debris = game:GetService("Debris")

-- Combat Configuration
local CONFIG = {
    MaxCombo = 4,
    Damage = 5,
    ComboResetTime = 1.5,
    HitboxSize = Vector3.new(4, 5, 4),
    HitboxOffset = CFrame.new(0, 0, -3) -- 3D forward offset from RootPart
}

function CombatModule.PerformM1(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not humanoid or humanoid.Health <= 0 or not rootPart then return end

    -- 1. State Checks (Cancel if stunned or already acting)
    if character:GetAttribute("IsStunned") or character:GetAttribute("IsBlocking") or character:GetAttribute("IsAttacking") then
        return
    end

    character:SetAttribute("IsAttacking", true)

    -- 2. Combo Tracking
    local currentCombo = character:GetAttribute("Combo") or 1
    local lastAttackTime = character:GetAttribute("LastAttackTime") or 0

    -- Reset combo if too much time passed between clicks
    if os.clock() - lastAttackTime > CONFIG.ComboResetTime then
        currentCombo = 1
    end
    character:SetAttribute("LastAttackTime", os.clock())

    -- 3. Hitbox Creation (Using Spatial Queries for accurate 3D hits)
    local overlapParams = OverlapParams.new()
    overlapParams.FilterDescendantsInstances = {character}
    overlapParams.FilterType = Enum.RaycastFilterType.Exclude

    local hitboxCFrame = rootPart.CFrame * CONFIG.HitboxOffset

    -- Optional: Visualize hitbox for debugging (Remove in production)
    local debugBox = Instance.new("Part")
    debugBox.Size = CONFIG.HitboxSize
    debugBox.CFrame = hitboxCFrame
    debugBox.Anchored = true
    debugBox.CanCollide = false
    debugBox.Transparency = 0.5
    debugBox.Color = Color3.fromRGB(255, 0, 0)
    debugBox.Parent = workspace
    Debris:AddItem(debugBox, 0.2)

    -- 4. Hit Detection & Damage
    local hitParts = workspace:GetPartBoundsInBox(hitboxCFrame, CONFIG.HitboxSize, overlapParams)
    local hitTargets = {}

    for _, part in ipairs(hitParts) do
        local enemyChar = part.Parent
        local enemyHum = enemyChar:FindFirstChild("Humanoid")

        if enemyHum and enemyHum.Health > 0 and not hitTargets[enemyHum] then
            hitTargets[enemyHum] = true -- Prevent multi-hitting the same target

            -- Check if it's the final hit of the combo
            local finalDamage = CONFIG.Damage
            if currentCombo == CONFIG.MaxCombo then
                finalDamage = finalDamage * 1.5
                -- Add knockback logic here for the combo finisher
            end

            enemyHum:TakeDamage(finalDamage)

            -- Apply brief hit stun
            enemyChar:SetAttribute("IsStunned", true)
            task.delay(0.4, function()
                if enemyChar then enemyChar:SetAttribute("IsStunned", false) end
            end)
        end
    end

    -- 5. Progress Combo State
    if currentCombo < CONFIG.MaxCombo then
        character:SetAttribute("Combo", currentCombo + 1)
    else
        character:SetAttribute("Combo", 1)
    end

    -- Clear attacking state after wind-down time
    task.wait(0.3) 
    if character then character:SetAttribute("IsAttacking", false) end
end

return CombatModule
