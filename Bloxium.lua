local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

local guiParent
local coreSuccess, coreResult = pcall(function()
	return CoreGui
end)

if coreSuccess and coreResult then
	guiParent = coreResult
else
	guiParent = player:WaitForChild("PlayerGui")
end

local Bloxium = {
	Theme = {
		Background = Color3.fromRGB(10, 10, 10),
		Sidebar = Color3.fromRGB(13, 13, 13),
		TopBar = Color3.fromRGB(8, 8, 8),
		Section = Color3.fromRGB(16, 16, 16),
		Element = Color3.fromRGB(20, 20, 20),
		ElementHover = Color3.fromRGB(26, 26, 26),
		Accent = Color3.fromRGB(220, 220, 220),
		Text = Color3.fromRGB(240, 240, 240),
		TextMuted = Color3.fromRGB(115, 115, 115),
		TextDim = Color3.fromRGB(80, 80, 80),
		Border = Color3.fromRGB(40, 40, 40),
		BorderLight = Color3.fromRGB(54, 54, 54)
	}
}

local function addCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = instance
	return corner
end

local function addStroke(instance, color, thickness, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Bloxium.Theme.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = transparency or 0
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

local function tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(
		duration or 0.15,
		style or Enum.EasingStyle.Quad,
		direction or Enum.EasingDirection.Out
	)

	return TweenService:Create(instance, info, properties)
end

local notifyHost = Instance.new("Frame")
notifyHost.Name = "NotificationHost"
notifyHost.Size = UDim2.new(0, 280, 1, -20)
notifyHost.Position = UDim2.new(1, -290, 0, 10)
notifyHost.BackgroundTransparency = 1
notifyHost.BorderSizePixel = 0

local notifyLayout = Instance.new("UIListLayout")
notifyLayout.Parent = notifyHost
notifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
notifyLayout.Padding = UDim.new(0, 8)

function Bloxium:Notify(opts)
	opts = opts or {}

	local titleText = string.upper(opts.Title or "SYSTEM ALERT")
	local descText = opts.Description or ""
	local duration = opts.Duration or 3

	local toast = Instance.new("Frame")
	toast.Name = "Notification"
	toast.Size = UDim2.new(1, 0, 0, 66)
	toast.BackgroundColor3 = Bloxium.Theme.Section
	toast.BackgroundTransparency = 1
	toast.BorderSizePixel = 0
	toast.Parent = notifyHost

	addCorner(toast, 8)

	local stroke = addStroke(toast, Bloxium.Theme.Border, 1, 1)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 1, -20)
	accent.Position = UDim2.new(0, 8, 0, 10)
	accent.BackgroundColor3 = Bloxium.Theme.Accent
	accent.BackgroundTransparency = 1
	accent.BorderSizePixel = 0
	accent.Parent = toast

	addCorner(accent, 3)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -32, 0, 20)
	title.Position = UDim2.new(0, 20, 0, 9)
	title.BackgroundTransparency = 1
	title.Text = titleText
	title.TextColor3 = Bloxium.Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTransparency = 1
	title.Parent = toast

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -32, 0, 28)
	desc.Position = UDim2.new(0, 20, 0, 29)
	desc.BackgroundTransparency = 1
	desc.Text = descText
	desc.TextColor3 = Bloxium.Theme.TextMuted
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 10
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextTransparency = 1
	desc.Parent = toast

	tween(toast, { BackgroundTransparency = 0 }, 0.25):Play()
	tween(stroke, { Transparency = 0 }, 0.25):Play()
	tween(accent, { BackgroundTransparency = 0 }, 0.25):Play()
	tween(title, { TextTransparency = 0 }, 0.25):Play()
	tween(desc, { TextTransparency = 0 }, 0.25):Play()

	task.delay(duration, function()
		if not toast or not toast.Parent then return end

		local fade = tween(toast, { BackgroundTransparency = 1 }, 0.25)
		tween(stroke, { Transparency = 1 }, 0.25):Play()
		tween(accent, { BackgroundTransparency = 1 }, 0.25):Play()
		tween(title, { TextTransparency = 1 }, 0.25):Play()
		tween(desc, { TextTransparency = 1 }, 0.25):Play()

		fade:Play()
		fade.Completed:Wait()

		if toast then
			toast:Destroy()
		end
	end)
end

function Bloxium:CreateWindow(config)
	config = config or {}

	local windowTitle = config.Title or "BLOXIUM"
	local windowSubtitle = config.Subtitle or ""
	local windowSize = config.Size or UDim2.fromOffset(650, 430)

	local Window = {
		Tabs = {},
		ActiveTab = nil
	}

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Bloxium"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = guiParent

	notifyHost.Parent = screenGui

	-- Using CanvasGroup fixes UICorner clipping spikes from children frames
	local mainFrame = Instance.new("CanvasGroup")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = windowSize
	mainFrame.Position = UDim2.new(
		0.5,
		-windowSize.X.Offset / 2,
		0.5,
		-windowSize.Y.Offset / 2
	)
	mainFrame.BackgroundColor3 = Bloxium.Theme.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.Parent = screenGui

	addCorner(mainFrame, 10)
	addStroke(mainFrame, Bloxium.Theme.Border, 1, 0)

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 42)
	topBar.BackgroundColor3 = Bloxium.Theme.TopBar
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame

	local topBarBottom = Instance.new("Frame")
	topBarBottom.Size = UDim2.new(1, -32, 0, 1)
	topBarBottom.Position = UDim2.new(0, 16, 1, -1)
	topBarBottom.BackgroundColor3 = Bloxium.Theme.Border
	topBarBottom.BorderSizePixel = 0
	topBarBottom.Parent = topBar

	local titleString = string.upper(windowTitle)
	if windowSubtitle ~= "" then
		titleString = string.upper(windowTitle)
			.. "  "
			.. "<font color='#707070'>"
			.. string.upper(windowSubtitle)
			.. "</font>"
	end

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -105, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleString
	title.RichText = true
	title.TextColor3 = Bloxium.Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -38, 0, 6)
	closeBtn.BackgroundColor3 = Bloxium.Theme.Element
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Bloxium.Theme.TextMuted
	closeBtn.Font = Enum.Font.Gotham
	closeBtn.TextSize = 18
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = topBar

	addCorner(closeBtn, 6)

	closeBtn.MouseEnter:Connect(function()
		tween(closeBtn, {
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(55, 20, 20),
			TextColor3 = Color3.fromRGB(235, 90, 90)
		}, 0.12):Play()
	end)

	closeBtn.MouseLeave:Connect(function()
		tween(closeBtn, {
			BackgroundTransparency = 1,
			TextColor3 = Bloxium.Theme.TextMuted
		}, 0.12):Play()
	end)

	closeBtn.MouseButton1Click:Connect(function()
		screenGui:Destroy()
	end)

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 30, 0, 30)
	minBtn.Position = UDim2.new(1, -72, 0, 6)
	minBtn.BackgroundColor3 = Bloxium.Theme.Element
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "−"
	minBtn.TextColor3 = Bloxium.Theme.TextMuted
	minBtn.Font = Enum.Font.Gotham
	minBtn.TextSize = 17
	minBtn.AutoButtonColor = false
	minBtn.Parent = topBar

	addCorner(minBtn, 6)

	minBtn.MouseEnter:Connect(function()
		tween(minBtn, {
			BackgroundTransparency = 0,
			TextColor3 = Bloxium.Theme.Text
		}, 0.12):Play()
	end)

	minBtn.MouseLeave:Connect(function()
		tween(minBtn, {
			BackgroundTransparency = 1,
			TextColor3 = Bloxium.Theme.TextMuted
		}, 0.12):Play()
	end)

	local isMinimized = false

	minBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized

		local goal = isMinimized
			and UDim2.new(0, windowSize.X.Offset, 0, 42)
			or windowSize

		tween(mainFrame, { Size = goal }, 0.2, Enum.EasingStyle.Quart):Play()
		minBtn.Text = isMinimized and "+" or "−"
	end)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 158, 1, -42)
	sidebar.Position = UDim2.new(0, 0, 0, 42)
	sidebar.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame

	local sidebarPadding = Instance.new("UIPadding")
	sidebarPadding.PaddingTop = UDim.new(0, 12)
	sidebarPadding.PaddingLeft = UDim.new(0, 10)
	sidebarPadding.PaddingRight = UDim.new(0, 10)
	sidebarPadding.Parent = sidebar

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = sidebar
	tabListLayout.Padding = UDim.new(0, 5)
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(0, 1, 1, -42)
	sidebarDivider.Position = UDim2.new(0, 157, 0, 42)
	sidebarDivider.BackgroundColor3 = Bloxium.Theme.Border
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Parent = mainFrame

	local contentFolder = Instance.new("Frame")
	contentFolder.Name = "ContentArea"
	contentFolder.Size = UDim2.new(1, -178, 1, -62)
	contentFolder.Position = UDim2.new(0, 169, 0, 52)
	contentFolder.BackgroundTransparency = 1
	contentFolder.Parent = mainFrame

	local dragging = false
	local dragStart
	local startPos

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart

			mainFrame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	function Window:CreateTab(name)
		local Tab = {}

		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, 0, 0, 34)
		tabBtn.BackgroundColor3 = Bloxium.Theme.Element
		tabBtn.BackgroundTransparency = 1
		tabBtn.AutoButtonColor = false
		tabBtn.Text = string.upper(name)
		tabBtn.TextColor3 = Bloxium.Theme.TextMuted
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 11
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.Parent = sidebar

		-- Pushes text past the selection indicator bar
		local tabPadding = Instance.new("UIPadding")
		tabPadding.PaddingLeft = UDim.new(0, 24)
		tabPadding.Parent = tabBtn

		addCorner(tabBtn, 7)

		-- Indicator line aligned to far left of the tab button
		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.new(0, 3, 0, 16)
		indicator.Position = UDim2.new(0, 8, 0.5, -8)
		indicator.BackgroundColor3 = Bloxium.Theme.Accent
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.Parent = tabBtn

		addCorner(indicator, 2)

		local pageScroll = Instance.new("ScrollingFrame")
		pageScroll.Size = UDim2.new(1, 0, 1, 0)
		pageScroll.BackgroundTransparency = 1
		pageScroll.BorderSizePixel = 0
		pageScroll.Visible = false
		pageScroll.ScrollBarThickness = 2
		pageScroll.ScrollBarImageColor3 = Bloxium.Theme.BorderLight
		pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		pageScroll.Parent = contentFolder

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingRight = UDim.new(0, 5)
		pagePadding.Parent = pageScroll

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Parent = pageScroll
		pageLayout.Padding = UDim.new(0, 12)
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

		pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 12)
		end)

		local function selectTab()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				tween(t.Button, { BackgroundTransparency = 1, TextColor3 = Bloxium.Theme.TextMuted }, 0.12):Play()
				tween(t.Indicator, { BackgroundTransparency = 1 }, 0.12):Play()
			end

			pageScroll.Visible = true
			tween(tabBtn, { BackgroundTransparency = 0, TextColor3 = Bloxium.Theme.Text }, 0.12):Play()
			tween(indicator, { BackgroundTransparency = 0 }, 0.12):Play()

			Window.ActiveTab = Tab
		end

		tabBtn.MouseButton1Click:Connect(selectTab)

		tabBtn.MouseEnter:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(tabBtn, { BackgroundTransparency = 0.7, TextColor3 = Bloxium.Theme.Text }, 0.1):Play()
			end
		end)

		tabBtn.MouseLeave:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(tabBtn, { BackgroundTransparency = 1, TextColor3 = Bloxium.Theme.TextMuted }, 0.1):Play()
			end
		end)

		Tab.Button = tabBtn
		Tab.Indicator = indicator
		Tab.Page = pageScroll

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			selectTab()
		end

		function Tab:CreateSection(sectionName)
			local Section = {}

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Size = UDim2.new(1, 0, 0, 45)
			sectionFrame.BackgroundColor3 = Bloxium.Theme.Section
			sectionFrame.BorderSizePixel = 0
			sectionFrame.ClipsDescendants = false
			sectionFrame.Parent = pageScroll

			addCorner(sectionFrame, 8)
			addStroke(sectionFrame, Bloxium.Theme.Border, 1, 0)

			local secTitle = Instance.new("TextLabel")
			secTitle.Size = UDim2.new(1, -24, 0, 22)
			secTitle.Position = UDim2.new(0, 12, 0, 7)
			secTitle.BackgroundTransparency = 1
			secTitle.Text = string.upper(sectionName)
			secTitle.TextColor3 = Bloxium.Theme.TextMuted
			secTitle.Font = Enum.Font.GothamBold
			secTitle.TextSize = 10
			secTitle.TextXAlignment = Enum.TextXAlignment.Left
			secTitle.Parent = sectionFrame

			local secLine = Instance.new("Frame")
			secLine.Size = UDim2.new(0, 30, 0, 2)
			secLine.Position = UDim2.new(0, 12, 0, 32)
			secLine.BackgroundColor3 = Bloxium.Theme.Accent
			secLine.BackgroundTransparency = 0.15
			secLine.BorderSizePixel = 0
			secLine.Parent = sectionFrame

			addCorner(secLine, 2)

			local secContainer = Instance.new("Frame")
			secContainer.Size = UDim2.new(1, -24, 1, -44)
			secContainer.Position = UDim2.new(0, 12, 0, 44)
			secContainer.BackgroundTransparency = 1
			secContainer.Parent = sectionFrame

			local secLayout = Instance.new("UIListLayout")
			secLayout.Parent = secContainer
			secLayout.Padding = UDim.new(0, 7)
			secLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local function updateSectionHeight()
				local height = secLayout.AbsoluteContentSize.Y + 56
				sectionFrame.Size = UDim2.new(1, 0, 0, math.max(height, 45))
			end

			secLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionHeight)

			function Section:CreateButton(opts)
				opts = opts or {}

				local btnName = string.upper(opts.Name or "EXECUTE")
				local callback = opts.Callback or function() end

				local btnFrame = Instance.new("Frame")
				btnFrame.Size = UDim2.new(1, 0, 0, 32)
				btnFrame.BackgroundColor3 = Bloxium.Theme.Element
				btnFrame.BorderSizePixel = 0
				btnFrame.Parent = secContainer

				addCorner(btnFrame, 6)
				local btnStroke = addStroke(btnFrame, Bloxium.Theme.Border, 1, 0.35)

				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Text = btnName
				btn.TextColor3 = Bloxium.Theme.Text
				btn.Font = Enum.Font.GothamMedium
				btn.TextSize = 11
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.AutoButtonColor = false
				btn.Parent = btnFrame

				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 12)
				padding.Parent = btn

				btn.MouseEnter:Connect(function()
					tween(btnFrame, { BackgroundColor3 = Bloxium.Theme.ElementHover }, 0.1):Play()
					tween(btnStroke, { Transparency = 0 }, 0.1):Play()
				end)

				btn.MouseLeave:Connect(function()
					tween(btnFrame, { BackgroundColor3 = Bloxium.Theme.Element }, 0.1):Play()
					tween(btnStroke, { Transparency = 0.35 }, 0.1):Play()
				end)

				btn.MouseButton1Click:Connect(function()
					tween(btnFrame, { BackgroundColor3 = Bloxium.Theme.Accent }, 0.06):Play()
					task.delay(0.06, function()
						if btnFrame.Parent then
							tween(btnFrame, { BackgroundColor3 = Bloxium.Theme.Element }, 0.18):Play()
						end
					end)
					task.spawn(callback)
				end)

				return btnFrame
			end

			function Section:CreateToggle(opts)
				opts = opts or {}

				local tglName = string.upper(opts.Name or "OVERRIDE")
				local default = opts.Default or false
				local callback = opts.Callback or function() end

				local toggleFrame = Instance.new("Frame")
				toggleFrame.Size = UDim2.new(1, 0, 0, 34)
				toggleFrame.BackgroundColor3 = Bloxium.Theme.Element
				toggleFrame.BorderSizePixel = 0
				toggleFrame.Parent = secContainer

				addCorner(toggleFrame, 6)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -75, 1, 0)
				label.Position = UDim2.new(0, 12, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = tglName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = toggleFrame

				local toggleBtn = Instance.new("TextButton")
				toggleBtn.Size = UDim2.new(0, 42, 0, 20)
				toggleBtn.Position = UDim2.new(1, -54, 0.5, -10)
				toggleBtn.BackgroundColor3 = Bloxium.Theme.Background
				toggleBtn.BorderSizePixel = 0
				toggleBtn.Text = ""
				toggleBtn.AutoButtonColor = false
				toggleBtn.Parent = toggleFrame

				addCorner(toggleBtn, 10)
				addStroke(toggleBtn, Bloxium.Theme.Border, 1, 0)

				local indicatorFrame = Instance.new("Frame")
				indicatorFrame.Size = UDim2.new(0, 14, 0, 14)
				indicatorFrame.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
				indicatorFrame.BackgroundColor3 = default and Bloxium.Theme.Accent or Bloxium.Theme.BorderLight
				indicatorFrame.BorderSizePixel = 0
				indicatorFrame.Parent = toggleBtn

				addCorner(indicatorFrame, 10)

				local state = default

				local function setState(newState, fireCallback)
					state = newState

					local goalPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
					local goalColor = state and Bloxium.Theme.Accent or Bloxium.Theme.BorderLight

					tween(indicatorFrame, { Position = goalPos, BackgroundColor3 = goalColor }, 0.15):Play()
					tween(toggleBtn, { BackgroundColor3 = state and Color3.fromRGB(28, 28, 28) or Bloxium.Theme.Background }, 0.15):Play()

					if fireCallback then
						callback(state)
					end
				end

				toggleBtn.MouseButton1Click:Connect(function()
					setState(not state, true)
				end)

				setState(state, false)

				return toggleFrame
			end

			function Section:CreateSlider(opts)
				opts = opts or {}

				local sldName = string.upper(opts.Name or "CAPACITY")
				local min = opts.Min or 0
				local max = opts.Max or 100
				local default = opts.Default or min
				local callback = opts.Callback or function() end

				local sliderFrame = Instance.new("Frame")
				sliderFrame.Size = UDim2.new(1, 0, 0, 48)
				sliderFrame.BackgroundColor3 = Bloxium.Theme.Element
				sliderFrame.BorderSizePixel = 0
				sliderFrame.Parent = secContainer

				addCorner(sliderFrame, 6)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.6, 0, 0, 20)
				label.Position = UDim2.new(0, 12, 0, 5)
				label.BackgroundTransparency = 1
				label.Text = sldName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = sliderFrame

				local valLabel = Instance.new("TextLabel")
				valLabel.Size = UDim2.new(0, 70, 0, 20)
				valLabel.Position = UDim2.new(1, -82, 0, 5)
				valLabel.BackgroundTransparency = 1
				valLabel.Text = tostring(default)
				valLabel.TextColor3 = Bloxium.Theme.TextMuted
				valLabel.Font = Enum.Font.GothamMedium
				valLabel.TextSize = 11
				valLabel.TextXAlignment = Enum.TextXAlignment.Right
				valLabel.Parent = sliderFrame

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, -24, 0, 5)
				track.Position = UDim2.new(0, 12, 0, 35)
				track.BackgroundColor3 = Bloxium.Theme.Background
				track.BorderSizePixel = 0
				track.Text = ""
				track.AutoButtonColor = false
				track.Parent = sliderFrame

				addCorner(track, 5)

				local range = math.max(max - min, 1)
				local initialScale = math.clamp((default - min) / range, 0, 1)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new(initialScale, 0, 1, 0)
				fill.BackgroundColor3 = Bloxium.Theme.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track

				addCorner(fill, 5)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.new(0, 10, 0, 10)
				knob.Position = UDim2.new(initialScale, -5, 0.5, -5)
				knob.BackgroundColor3 = Bloxium.Theme.Accent
				knob.BorderSizePixel = 0
				knob.Parent = track

				addCorner(knob, 10)

				local draggingSlider = false

				local function updateSlider(input)
					local scale = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local value = math.floor(min + ((max - min) * scale))

					fill.Size = UDim2.new(scale, 0, 1, 0)
					knob.Position = UDim2.new(scale, -5, 0.5, -5)
					valLabel.Text = tostring(value)

					callback(value)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = true
						updateSlider(input)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = false
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(input)
					end
				end)

				return sliderFrame
			end

			function Section:CreateDropdown(opts)
				opts = opts or {}

				local ddName = string.upper(opts.Name or "SELECT")
				local options = opts.Options or {}
				local selected = opts.Default or options[1] or ""
				local callback = opts.Callback or function() end

				local ddFrame = Instance.new("Frame")
				ddFrame.Size = UDim2.new(1, 0, 0, 34)
				ddFrame.BackgroundColor3 = Bloxium.Theme.Element
				ddFrame.BorderSizePixel = 0
				ddFrame.ClipsDescendants = true
				ddFrame.Parent = secContainer

				addCorner(ddFrame, 6)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.45, 0, 0, 34)
				label.Position = UDim2.new(0, 12, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = ddName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = ddFrame

				local openBtn = Instance.new("TextButton")
				openBtn.Size = UDim2.new(0.45, 0, 0, 24)
				openBtn.Position = UDim2.new(0.52, 0, 0, 5)
				openBtn.BackgroundColor3 = Bloxium.Theme.Background
				openBtn.BorderSizePixel = 0
				openBtn.Text = selected
				openBtn.TextColor3 = Bloxium.Theme.TextMuted
				openBtn.Font = Enum.Font.GothamMedium
				openBtn.TextSize = 10
				openBtn.AutoButtonColor = false
				openBtn.TextXAlignment = Enum.TextXAlignment.Left
				openBtn.Parent = ddFrame

				addCorner(openBtn, 5)

				local dropPadding = Instance.new("UIPadding")
				dropPadding.PaddingLeft = UDim.new(0, 9)
				dropPadding.PaddingRight = UDim.new(0, 24)
				dropPadding.Parent = openBtn

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.new(0, 20, 1, 0)
				arrow.Position = UDim2.new(1, -25, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "⌄"
				arrow.TextColor3 = Bloxium.Theme.TextMuted
				arrow.Font = Enum.Font.Gotham
				arrow.TextSize = 14
				arrow.Parent = openBtn

				local optionContainer = Instance.new("Frame")
				optionContainer.Size = UDim2.new(1, -24, 0, #options * 28)
				optionContainer.Position = UDim2.new(0, 12, 0, 40)
				optionContainer.BackgroundTransparency = 1
				optionContainer.Parent = ddFrame

				local optLayout = Instance.new("UIListLayout")
				optLayout.Parent = optionContainer
				optLayout.Padding = UDim.new(0, 4)

				local isOpen = false

				local function refreshSize()
					local targetHeight = isOpen and (44 + (#options * 28)) or 34
					tween(ddFrame, { Size = UDim2.new(1, 0, 0, targetHeight) }, 0.15):Play()
					task.delay(0.16, updateSectionHeight)
				end

				openBtn.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					arrow.Text = isOpen and "⌃" or "⌄"
					refreshSize()
				end)

				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 24)
					optBtn.BackgroundColor3 = Bloxium.Theme.Background
					optBtn.BorderSizePixel = 0
					optBtn.Text = opt
					optBtn.TextColor3 = Bloxium.Theme.Text
					optBtn.Font = Enum.Font.GothamMedium
					optBtn.TextSize = 10
					optBtn.TextXAlignment = Enum.TextXAlignment.Left
					optBtn.AutoButtonColor = false
					optBtn.Parent = optionContainer

					addCorner(optBtn, 5)

					local optPadding = Instance.new("UIPadding")
					optPadding.PaddingLeft = UDim.new(0, 9)
					optPadding.Parent = optBtn

					optBtn.MouseEnter:Connect(function()
						tween(optBtn, { BackgroundColor3 = Bloxium.Theme.ElementHover }, 0.1):Play()
					end)

					optBtn.MouseLeave:Connect(function()
						tween(optBtn, { BackgroundColor3 = Bloxium.Theme.Background }, 0.1):Play()
					end)

					optBtn.MouseButton1Click:Connect(function()
						selected = opt
						openBtn.Text = selected
						isOpen = false
						arrow.Text = "⌄"
						refreshSize()
						callback(opt)
					end)
				end
			end

			function Section:CreateTextInput(opts)
				opts = opts or {}

				local txtName = string.upper(opts.Name or "INPUT")
				local placeholder = opts.Placeholder or "Enter value..."
				local callback = opts.Callback or function() end

				local inputFrame = Instance.new("Frame")
				inputFrame.Size = UDim2.new(1, 0, 0, 34)
				inputFrame.BackgroundColor3 = Bloxium.Theme.Element
				inputFrame.BorderSizePixel = 0
				inputFrame.Parent = secContainer

				addCorner(inputFrame, 6)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.42, 0, 1, 0)
				label.Position = UDim2.new(0, 12, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = txtName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = inputFrame

				local textBox = Instance.new("TextBox")
				textBox.Size = UDim2.new(0.5, 0, 0, 24)
				textBox.Position = UDim2.new(0.47, 0, 0.5, -12)
				textBox.BackgroundColor3 = Bloxium.Theme.Background
				textBox.BorderSizePixel = 0
				textBox.Text = ""
				textBox.PlaceholderText = placeholder
				textBox.TextColor3 = Bloxium.Theme.Text
				textBox.PlaceholderColor3 = Bloxium.Theme.TextDim
				textBox.Font = Enum.Font.GothamMedium
				textBox.TextSize = 10
				textBox.ClearTextOnFocus = false
				textBox.Parent = inputFrame

				addCorner(textBox, 5)

				local inputPadding = Instance.new("UIPadding")
				inputPadding.PaddingLeft = UDim.new(0, 8)
				inputPadding.PaddingRight = UDim.new(0, 8)
				inputPadding.Parent = textBox

				textBox.Focused:Connect(function()
					tween(textBox, { BackgroundColor3 = Color3.fromRGB(24, 24, 24) }, 0.1):Play()
				end)

				textBox.FocusLost:Connect(function(enterPressed)
					tween(textBox, { BackgroundColor3 = Bloxium.Theme.Background }, 0.1):Play()
					callback(textBox.Text, enterPressed)
				end)

				return inputFrame
			end

			function Section:CreateKeybind(opts)
				opts = opts or {}

				local kbName = string.upper(opts.Name or "BIND")
				local defaultKey = opts.Default or Enum.KeyCode.E
				local callback = opts.Callback or function() end

				local bindFrame = Instance.new("Frame")
				bindFrame.Size = UDim2.new(1, 0, 0, 34)
				bindFrame.BackgroundColor3 = Bloxium.Theme.Element
				bindFrame.BorderSizePixel = 0
				bindFrame.Parent = secContainer

				addCorner(bindFrame, 6)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(1, -115, 1, 0)
				label.Position = UDim2.new(0, 12, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = kbName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamMedium
				label.TextSize = 11
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = bindFrame

				local bindBtn = Instance.new("TextButton")
				bindBtn.Size = UDim2.new(0, 85, 0, 24)
				bindBtn.Position = UDim2.new(1, -97, 0.5, -12)
				bindBtn.BackgroundColor3 = Bloxium.Theme.Background
				bindBtn.BorderSizePixel = 0
				bindBtn.Text = string.upper(defaultKey.Name)
				bindBtn.TextColor3 = Bloxium.Theme.TextMuted
				bindBtn.Font = Enum.Font.GothamMedium
				bindBtn.TextSize = 10
				bindBtn.AutoButtonColor = false
				bindBtn.Parent = bindFrame

				addCorner(bindBtn, 5)

				local currentKey = defaultKey
				local isListening = false

				bindBtn.MouseEnter:Connect(function()
					if not isListening then
						tween(bindBtn, { BackgroundColor3 = Bloxium.Theme.ElementHover, TextColor3 = Bloxium.Theme.Text }, 0.1):Play()
					end
				end)

				bindBtn.MouseLeave:Connect(function()
					if not isListening then
						tween(bindBtn, { BackgroundColor3 = Bloxium.Theme.Background, TextColor3 = Bloxium.Theme.TextMuted }, 0.1):Play()
					end
				end)

				bindBtn.MouseButton1Click:Connect(function()
					isListening = true
					bindBtn.Text = "PRESS KEY"
					bindBtn.TextColor3 = Bloxium.Theme.Accent
					tween(bindBtn, { BackgroundColor3 = Color3.fromRGB(28, 28, 28) }, 0.1):Play()
				end)

				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							isListening = false
							bindBtn.Text = string.upper(currentKey.Name)
							bindBtn.TextColor3 = Bloxium.Theme.TextMuted
							bindBtn.BackgroundColor3 = Bloxium.Theme.Background
							return
						end

						currentKey = input.KeyCode
						isListening = false
						bindBtn.Text = string.upper(currentKey.Name)
						bindBtn.TextColor3 = Bloxium.Theme.TextMuted
						tween(bindBtn, { BackgroundColor3 = Bloxium.Theme.Background }, 0.1):Play()

					elseif not isListening and input.KeyCode == currentKey and not gameProcessed then
						callback(currentKey)
					end
				end)

				return bindFrame
			end

			return Section
		end

		return Tab
	end

	return Window
end

return Bloxium
