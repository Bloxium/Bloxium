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
		TextMuted = Color3.fromRGB(140, 140, 150),
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
	desc.Position = UDim2.new(0, 10, 0, 28)
	desc.BackgroundTransparency = 1
	desc.Text = descText
	desc.TextColor3 = Bloxium.Theme.TextMuted
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 12
	desc.TextWrapped = true
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextTransparency = 1
	desc.Parent = toast

	TweenService:Create(toast, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 0}):Play()
	TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
	TweenService:Create(desc, TweenInfo.new(0.3), {TextTransparency = 0}):Play()

	task.delay(duration, function()
		local fadeOut = TweenService:Create(toast, TweenInfo.new(0.3), {BackgroundTransparency = 1})
		TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
		TweenService:Create(title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		TweenService:Create(desc, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Wait()
		toast:Destroy()
	end)
end

function Bloxium:CreateWindow(config)
	config = config or {}
	local windowTitle = config.Title or "Bloxium"
	local windowSubtitle = config.Subtitle or ""
	local windowSize = config.Size or UDim2.fromOffset(620, 420)

	local Window = {
		Tabs = {},
		ActiveTab = nil
	}

	-- Root ScreenGui
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "Bloxium"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = guiParent
	
	-- Attach notification host to the newly created gui
	notifyHost.Parent = screenGui 

	-- Main Window Frame
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = windowSize
	mainFrame.Position = UDim2.new(0.5, -windowSize.X.Offset / 2, 0.5, -windowSize.Y.Offset / 2)
	mainFrame.BackgroundColor3 = Bloxium.Theme.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.Active = true
	mainFrame.ClipsDescendants = true
	mainFrame.Parent = screenGui

	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Bloxium.Theme.Border
	mainStroke.Thickness = 1
	mainStroke.Parent = mainFrame

	-- Top Bar Header
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 40)
	topBar.BackgroundColor3 = Bloxium.Theme.TopBar
	topBar.BorderSizePixel = 0
	topBar.Parent = mainFrame

	Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

	local topBarHider = Instance.new("Frame")
	topBarHider.Size = UDim2.new(1, 0, 0, 10)
	topBarHider.Position = UDim2.new(0, 0, 1, -10)
	topBarHider.BackgroundColor3 = Bloxium.Theme.TopBar
	topBarHider.BorderSizePixel = 0
	topBarHider.Parent = topBar

	-- Format Title
	local titleString = windowTitle
	if windowSubtitle ~= "" then
		titleString = windowTitle .. " <font color='#5A78FF'>" .. windowSubtitle .. "</font>"
	end

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = titleString
	title.RichText = true
	title.TextColor3 = Bloxium.Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = topBar

	-- TopBar Control Buttons
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -40, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Bloxium.Theme.TextMuted
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = topBar

	closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = Color3.fromRGB(255, 70, 70) end)
	closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = Bloxium.Theme.TextMuted end)
	closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

	local minBtn = Instance.new("TextButton")
	minBtn.Size = UDim2.new(0, 40, 0, 40)
	minBtn.Position = UDim2.new(1, -80, 0, 0)
	minBtn.BackgroundTransparency = 1
	minBtn.Text = "—"
	minBtn.TextColor3 = Bloxium.Theme.TextMuted
	minBtn.Font = Enum.Font.GothamBold
	minBtn.TextSize = 14
	minBtn.Parent = topBar

	local isMinimized = false
	minBtn.MouseEnter:Connect(function() minBtn.TextColor3 = Bloxium.Theme.Text end)
	minBtn.MouseLeave:Connect(function() minBtn.TextColor3 = Bloxium.Theme.TextMuted end)
	minBtn.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local goal = isMinimized and UDim2.new(0, windowSize.X.Offset, 0, 40) or windowSize
		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = goal}):Play()
	end)

	-- Sidebar Navigation Area
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 150, 1, -40)
	sidebar.Position = UDim2.new(0, 0, 0, 40)
	sidebar.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = mainFrame

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
	sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
	sidebarDivider.BackgroundColor3 = Bloxium.Theme.Border
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Parent = sidebar

	local tabListLayout = Instance.new("UIListLayout")
	tabListLayout.Parent = sidebar
	tabListLayout.Padding = UDim.new(0, 6)
	tabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local tabPadding = Instance.new("UIPadding")
	tabPadding.PaddingTop = UDim.new(0, 12)
	tabPadding.Parent = sidebar

	-- Content Display Area
	local contentFolder = Instance.new("Frame")
	contentFolder.Name = "ContentArea"
	contentFolder.Size = UDim2.new(1, -160, 1, -50)
	contentFolder.Position = UDim2.new(0, 155, 0, 45)
	contentFolder.BackgroundTransparency = 1
	contentFolder.Parent = mainFrame

	-- Window Dragging Logic
	local dragging, dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- TAB CREATION API
	function Window:CreateTab(name)
		local Tab = {}
		
		-- Redesigned Tab Button
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.new(1, -16, 0, 34)
		tabBtn.BackgroundColor3 = Bloxium.Theme.Element
		tabBtn.BackgroundTransparency = 1
		tabBtn.AutoButtonColor = false
		tabBtn.Text = "   " .. name -- Added spaces to act as padding for left alignment
		tabBtn.TextColor3 = Bloxium.Theme.TextMuted
		tabBtn.Font = Enum.Font.GothamSemibold
		tabBtn.TextSize = 13
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.Parent = sidebar

		Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)

		-- Active Tab Indicator Line
		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.new(0, 3, 0, 16)
		indicator.Position = UDim2.new(0, 0, 0.5, -8)
		indicator.BackgroundColor3 = Bloxium.Theme.Accent
		indicator.BorderSizePixel = 0
		indicator.BackgroundTransparency = 1
		indicator.Parent = tabBtn
		
		Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

		local pageScroll = Instance.new("ScrollingFrame")
		pageScroll.Size = UDim2.new(1, 0, 1, 0)
		pageScroll.BackgroundTransparency = 1
		pageScroll.BorderSizePixel = 0
		pageScroll.Visible = false
		pageScroll.ScrollBarThickness = 2
		pageScroll.ScrollBarImageColor3 = Bloxium.Theme.Border
		pageScroll.Parent = contentFolder

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Parent = pageScroll
		pageLayout.Padding = UDim.new(0, 12)
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

		pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 10)
		end)

		local function selectTab()
			for _, t in pairs(Window.Tabs) do
				t.Page.Visible = false
				TweenService:Create(t.Button, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Bloxium.Theme.TextMuted}):Play()
				TweenService:Create(t.Indicator, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			end
			pageScroll.Visible = true
			TweenService:Create(tabBtn, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextColor3 = Bloxium.Theme.Text}):Play()
			TweenService:Create(indicator, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
			Window.ActiveTab = Tab
		end

		tabBtn.MouseButton1Click:Connect(selectTab)

		Tab.Button = tabBtn
		Tab.Indicator = indicator
		Tab.Page = pageScroll
		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then selectTab() end

		-- SECTION CREATION API
		function Tab:CreateSection(sectionName)
			local Section = {}

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Size = UDim2.new(1, -10, 0, 30)
			sectionFrame.BackgroundColor3 = Bloxium.Theme.Section
			sectionFrame.Parent = pageScroll

			Instance.new("UICorner", sectionFrame).CornerRadius = UDim.new(0, 6)

			local secStroke = Instance.new("UIStroke")
			secStroke.Color = Bloxium.Theme.Border
			secStroke.Thickness = 1
			secStroke.Parent = sectionFrame

			local secTitle = Instance.new("TextLabel")
			secTitle.Size = UDim2.new(1, -20, 0, 25)
			secTitle.Position = UDim2.new(0, 10, 0, 5)
			secTitle.BackgroundTransparency = 1
			secTitle.Text = sectionName
			secTitle.TextColor3 = Bloxium.Theme.Accent
			secTitle.Font = Enum.Font.GothamBold
			secTitle.TextSize = 12
			secTitle.TextXAlignment = Enum.TextXAlignment.Left
			secTitle.Parent = sectionFrame

			local secContainer = Instance.new("Frame")
			secContainer.Size = UDim2.new(1, -20, 1, -35)
			secContainer.Position = UDim2.new(0, 10, 0, 30)
			secContainer.BackgroundTransparency = 1
			secContainer.Parent = sectionFrame

			local secLayout = Instance.new("UIListLayout")
			secLayout.Parent = secContainer
			secLayout.Padding = UDim.new(0, 8)
			secLayout.SortOrder = Enum.SortOrder.LayoutOrder

			local function updateSectionHeight()
				sectionFrame.Size = UDim2.new(1, -10, 0, secLayout.AbsoluteContentSize.Y + 40)
			end
			secLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionHeight)

			-- 1. BUTTON
			function Section:CreateButton(opts)
				local btnName = opts.Name or "Button"
				local callback = opts.Callback or function() end

				local btnFrame = Instance.new("Frame")
				btnFrame.Size = UDim2.new(1, 0, 0, 36)
				btnFrame.BackgroundColor3 = Bloxium.Theme.Element
				btnFrame.Parent = secContainer
				Instance.new("UICorner", btnFrame).CornerRadius = UDim.new(0, 4)

				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 1, 0)
				btn.BackgroundTransparency = 1
				btn.Text = btnName
				btn.TextColor3 = Bloxium.Theme.Text
				btn.Font = Enum.Font.GothamSemibold
				btn.TextSize = 13
				btn.Parent = btnFrame

				btn.MouseButton1Click:Connect(function()
					local tween = TweenService:Create(btnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Bloxium.Theme.Accent})
					tween:Play()
					tween.Completed:Wait()
					TweenService:Create(btnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Bloxium.Theme.Element}):Play()
					
					task.spawn(callback)
				end)
			end

			-- 2. TOGGLE
			function Section:CreateToggle(opts)
				local tglName = opts.Name or "Toggle"
				local default = opts.Default or false
				local callback = opts.Callback or function() end

				local toggleFrame = Instance.new("Frame")
				toggleFrame.Size = UDim2.new(1, 0, 0, 32)
				toggleFrame.BackgroundColor3 = Bloxium.Theme.Element
				toggleFrame.Parent = secContainer
				Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.7, 0, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = tglName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = toggleFrame

				local toggleBtn = Instance.new("TextButton")
				toggleBtn.Size = UDim2.new(0, 36, 0, 18)
				toggleBtn.Position = UDim2.new(1, -46, 0.5, -9)
				toggleBtn.BackgroundColor3 = default and Bloxium.Theme.Accent or Color3.fromRGB(45, 45, 50)
				toggleBtn.Text = ""
				toggleBtn.Parent = toggleFrame
				Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

				local indicatorFrame = Instance.new("Frame")
				indicatorFrame.Size = UDim2.new(0, 12, 0, 12)
				indicatorFrame.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
				indicatorFrame.BackgroundColor3 = Bloxium.Theme.Text
				indicatorFrame.Parent = toggleBtn
				Instance.new("UICorner", indicatorFrame).CornerRadius = UDim.new(1, 0)

				local state = default
				toggleBtn.MouseButton1Click:Connect(function()
					state = not state
					local goalPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
					local goalColor = state and Bloxium.Theme.Accent or Color3.fromRGB(45, 45, 50)

					TweenService:Create(indicatorFrame, TweenInfo.new(0.2), {Position = goalPos}):Play()
					TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = goalColor}):Play()
					callback(state)
				end)
			end

			-- 3. SLIDER
			function Section:CreateSlider(opts)
				local sldName = opts.Name or "Slider"
				local min = opts.Min or 0
				local max = opts.Max or 100
				local default = opts.Default or min
				local callback = opts.Callback or function() end

				local sliderFrame = Instance.new("Frame")
				sliderFrame.Size = UDim2.new(1, 0, 0, 48)
				sliderFrame.BackgroundColor3 = Bloxium.Theme.Element
				sliderFrame.Parent = secContainer
				Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.5, 0, 0, 22)
				label.Position = UDim2.new(0, 10, 0, 4)
				label.BackgroundTransparency = 1
				label.Text = sldName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = sliderFrame

				local valLabel = Instance.new("TextLabel")
				valLabel.Size = UDim2.new(0.5, -10, 0, 22)
				valLabel.Position = UDim2.new(0.5, 0, 0, 4)
				valLabel.BackgroundTransparency = 1
				valLabel.Text = tostring(default)
				valLabel.TextColor3 = Bloxium.Theme.TextMuted
				valLabel.Font = Enum.Font.Gotham
				valLabel.TextSize = 13
				valLabel.TextXAlignment = Enum.TextXAlignment.Right
				valLabel.Parent = sliderFrame

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, -20, 0, 6)
				track.Position = UDim2.new(0, 10, 0, 32)
				track.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
				track.Text = ""
				track.AutoButtonColor = false
				track.Parent = sliderFrame
				Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
				fill.BackgroundColor3 = Bloxium.Theme.Accent
				fill.Parent = track
				Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

				local dragging = false
				local function updateSlider(input)
					local scale = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
					local value = math.floor(min + ((max - min) * scale))
					fill.Size = UDim2.new(scale, 0, 1, 0)
					valLabel.Text = tostring(value)
					callback(value)
				end

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						updateSlider(input)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						updateSlider(input)
					end
				end)
			end

			-- 4. DROPDOWN
			function Section:CreateDropdown(opts)
				local ddName = opts.Name or "Dropdown"
				local options = opts.Options or {}
				local default = opts.Default or options[1] or ""
				local callback = opts.Callback or function() end

				local ddFrame = Instance.new("Frame")
				ddFrame.Size = UDim2.new(1, 0, 0, 36)
				ddFrame.BackgroundColor3 = Bloxium.Theme.Element
				ddFrame.ClipsDescendants = true
				ddFrame.Parent = secContainer
				Instance.new("UICorner", ddFrame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.5, 0, 0, 36)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = ddName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = ddFrame

				local openBtn = Instance.new("TextButton")
				openBtn.Size = UDim2.new(0.5, -10, 0, 26)
				openBtn.Position = UDim2.new(0.5, 0, 0, 5)
				openBtn.BackgroundColor3 = Bloxium.Theme.Section
				openBtn.Text = default .. " ▾"
				openBtn.TextColor3 = Bloxium.Theme.TextMuted
				openBtn.Font = Enum.Font.Gotham
				openBtn.TextSize = 12
				openBtn.Parent = ddFrame
				Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 4)

				local optionContainer = Instance.new("Frame")
				optionContainer.Size = UDim2.new(1, -20, 0, #options * 26)
				optionContainer.Position = UDim2.new(0, 10, 0, 40)
				optionContainer.BackgroundTransparency = 1
				optionContainer.Parent = ddFrame

				local optLayout = Instance.new("UIListLayout")
				optLayout.Parent = optionContainer
				optLayout.Padding = UDim.new(0, 2)

				local isOpen = false
				openBtn.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					local targetHeight = isOpen and (42 + #options * 28) or 36
					TweenService:Create(ddFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
					task.delay(0.2, updateSectionHeight)
				end)

				for _, opt in ipairs(options) do
					local optBtn = Instance.new("TextButton")
					optBtn.Size = UDim2.new(1, 0, 0, 26)
					optBtn.BackgroundColor3 = Bloxium.Theme.Section
					optBtn.Text = opt
					optBtn.TextColor3 = Bloxium.Theme.Text
					optBtn.Font = Enum.Font.Gotham
					optBtn.TextSize = 12
					optBtn.Parent = optionContainer
					Instance.new("UICorner", optBtn).CornerRadius = UDim.new(0, 4)

					optBtn.MouseButton1Click:Connect(function()
						isOpen = false
						openBtn.Text = opt .. " ▾"
						TweenService:Create(ddFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 36)}):Play()
						task.delay(0.2, updateSectionHeight)
						callback(opt)
					end)
				end
			end

			-- 5. TEXT BOX
			function Section:CreateTextInput(opts)
				local txtName = opts.Name or "Textbox"
				local placeholder = opts.Placeholder or "Type..."
				local callback = opts.Callback or function() end

				local inputFrame = Instance.new("Frame")
				inputFrame.Size = UDim2.new(1, 0, 0, 36)
				inputFrame.BackgroundColor3 = Bloxium.Theme.Element
				inputFrame.Parent = secContainer
				Instance.new("UICorner", inputFrame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.5, 0, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = txtName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = inputFrame

				local textBox = Instance.new("TextBox")
				textBox.Size = UDim2.new(0.45, 0, 0, 24)
				textBox.Position = UDim2.new(0.52, 0, 0.5, -12)
				textBox.BackgroundColor3 = Bloxium.Theme.Section
				textBox.Text = ""
				textBox.PlaceholderText = placeholder
				textBox.TextColor3 = Bloxium.Theme.Text
				textBox.PlaceholderColor3 = Bloxium.Theme.TextMuted
				textBox.Font = Enum.Font.Gotham
				textBox.TextSize = 12
				textBox.Parent = inputFrame
				Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 4)

				textBox.FocusLost:Connect(function(enterPressed)
					callback(textBox.Text, enterPressed)
				end)
			end

			-- 6. KEYBIND
			function Section:CreateKeybind(opts)
				local kbName = opts.Name or "Keybind"
				local defaultKey = opts.Default or Enum.KeyCode.E
				local callback = opts.Callback or function() end

				local bindFrame = Instance.new("Frame")
				bindFrame.Size = UDim2.new(1, 0, 0, 36)
				bindFrame.BackgroundColor3 = Bloxium.Theme.Element
				bindFrame.Parent = secContainer
				Instance.new("UICorner", bindFrame).CornerRadius = UDim.new(0, 4)

				local label = Instance.new("TextLabel")
				label.Size = UDim2.new(0.5, 0, 1, 0)
				label.Position = UDim2.new(0, 10, 0, 0)
				label.BackgroundTransparency = 1
				label.Text = kbName
				label.TextColor3 = Bloxium.Theme.Text
				label.Font = Enum.Font.GothamSemibold
				label.TextSize = 13
				label.TextXAlignment = Enum.TextXAlignment.Left
				label.Parent = bindFrame

				local bindBtn = Instance.new("TextButton")
				bindBtn.Size = UDim2.new(0, 80, 0, 24)
				bindBtn.Position = UDim2.new(1, -90, 0.5, -12)
				bindBtn.BackgroundColor3 = Bloxium.Theme.Section
				bindBtn.Text = defaultKey.Name
				bindBtn.TextColor3 = Bloxium.Theme.TextMuted
				bindBtn.Font = Enum.Font.GothamBold
				bindBtn.TextSize = 12
				bindBtn.Parent = bindFrame
				Instance.new("UICorner", bindBtn).CornerRadius = UDim.new(0, 4)

				local currentKey = defaultKey
				local isListening = false

				bindBtn.MouseButton1Click:Connect(function()
					isListening = true
					bindBtn.Text = ". . ."
					bindBtn.TextColor3 = Bloxium.Theme.Accent
				end)

				UserInputService.InputBegan:Connect(function(input, gameProcessed)
					if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							bindBtn.Text = currentKey.Name
						else
							currentKey = input.KeyCode
							bindBtn.Text = currentKey.Name
						end
						
						bindBtn.TextColor3 = Bloxium.Theme.TextMuted
						isListening = false
						
					elseif not isListening and not gameProcessed then
						if input.KeyCode == currentKey then
							callback(currentKey)
						end
					end
				end)
			end

			return Section
		end

		return Tab
	end

	return Window
end

return Bloxium
