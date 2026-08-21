local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Bloxium = {}

Bloxium.Theme = {
	Background = Color3.fromRGB(10, 10, 10),
	Sidebar = Color3.fromRGB(13, 13, 13),
	TopBar = Color3.fromRGB(8, 8, 8),
	Element = Color3.fromRGB(20, 20, 20),
	ElementHover = Color3.fromRGB(27, 27, 27),
	Accent = Color3.fromRGB(220, 220, 220),
	Text = Color3.fromRGB(240, 240, 240),
	TextMuted = Color3.fromRGB(115, 115, 115),
	TextDim = Color3.fromRGB(80, 80, 80),
	Border = Color3.fromRGB(40, 40, 40),
	BorderLight = Color3.fromRGB(54, 54, 54)
}

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function stroke(parent, color, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or Bloxium.Theme.Border
	s.Thickness = 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

local function tween(object, properties, duration)
	return TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		properties
	)
end

local function destroyExisting()
	local existing = playerGui:FindFirstChild("Bloxium")
	if existing then
		existing:Destroy()
	end
end

local function makeLabel(parent, text, size, position)
	local label = Instance.new("TextLabel")
	label.Size = size
	label.Position = position or UDim2.new()
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Bloxium.Theme.Text
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

function Bloxium:Notify(options)
	options = options or {}

	local titleText = string.upper(options.Title or "SYSTEM ALERT")
	local description = options.Description or ""
	local duration = options.Duration or 3

	local gui = playerGui:FindFirstChild("Bloxium")
	if not gui then
		return
	end

	local host = gui:FindFirstChild("NotificationHost")

	if not host then
		host = Instance.new("Frame")
		host.Name = "NotificationHost"
		host.Size = UDim2.new(0, 280, 1, -20)
		host.Position = UDim2.new(1, -290, 0, 10)
		host.BackgroundTransparency = 1
		host.Parent = gui

		local layout = Instance.new("UIListLayout")
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.Padding = UDim.new(0, 8)
		layout.Parent = host
	end

	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(1, 0, 0, 66)
	toast.BackgroundColor3 = Bloxium.Theme.Element
	toast.BackgroundTransparency = 1
	toast.BorderSizePixel = 0
	toast.Parent = host
	corner(toast, 8)

	local toastStroke = stroke(toast, Bloxium.Theme.Border, 1)

	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 3, 1, -20)
	accent.Position = UDim2.new(0, 8, 0, 10)
	accent.BackgroundColor3 = Bloxium.Theme.Accent
	accent.BackgroundTransparency = 1
	accent.BorderSizePixel = 0
	accent.Parent = toast
	corner(accent, 3)

	local title = makeLabel(
		toast,
		titleText,
		UDim2.new(1, -32, 0, 20),
		UDim2.new(0, 20, 0, 8)
	)

	title.Font = Enum.Font.GothamBold
	title.TextSize = 11
	title.TextTransparency = 1

	local desc = makeLabel(
		toast,
		description,
		UDim2.new(1, -32, 0, 30),
		UDim2.new(0, 20, 0, 29)
	)

	desc.Font = Enum.Font.GothamMedium
	desc.TextSize = 10
	desc.TextColor3 = Bloxium.Theme.TextMuted
	desc.TextWrapped = true
	desc.TextYAlignment = Enum.TextYAlignment.Top
	desc.TextTransparency = 1

	tween(toast, {
		BackgroundTransparency = 0
	}, 0.2):Play()

	tween(toastStroke, {
		Transparency = 0
	}, 0.2):Play()

	tween(accent, {
		BackgroundTransparency = 0
	}, 0.2):Play()

	tween(title, {
		TextTransparency = 0
	}, 0.2):Play()

	tween(desc, {
		TextTransparency = 0
	}, 0.2):Play()

	task.delay(duration, function()
		if not toast.Parent then
			return
		end

		tween(toast, {
			BackgroundTransparency = 1
		}, 0.2):Play()

		tween(toastStroke, {
			Transparency = 1
		}, 0.2):Play()

		tween(accent, {
			BackgroundTransparency = 1
		}, 0.2):Play()

		tween(title, {
			TextTransparency = 1
		}, 0.2):Play()

		local fade = tween(desc, {
			TextTransparency = 1
		}, 0.2)

		fade:Play()
		fade.Completed:Wait()

		if toast.Parent then
			toast:Destroy()
		end
	end)
end

function Bloxium:CreateWindow(config)
	config = config or {}

	destroyExisting()

	local titleText = config.Title or "BLOXIUM"
	local subtitle = config.Subtitle or ""
	local windowSize = config.Size or UDim2.fromOffset(650, 430)

	local Window = {
		Tabs = {},
		ActiveTab = nil
	}

	local gui = Instance.new("ScreenGui")
	gui.Name = "Bloxium"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = playerGui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = windowSize
	main.Position = UDim2.new(
		0.5,
		-windowSize.X.Offset / 2,
		0.5,
		-windowSize.Y.Offset / 2
	)
	main.BackgroundColor3 = Bloxium.Theme.Background
	main.BorderSizePixel = 0
	main.Active = true
	main.Parent = gui
	corner(main, 10)
	stroke(main, Bloxium.Theme.Border, 0)

	local top = Instance.new("Frame")
	top.Size = UDim2.new(1, 0, 0, 42)
	top.BackgroundColor3 = Bloxium.Theme.TopBar
	top.BorderSizePixel = 0
	top.Active = true
	top.Parent = main
	corner(top, 10)

	local topPatch = Instance.new("Frame")
	topPatch.Size = UDim2.new(1, 0, 0, 10)
	topPatch.Position = UDim2.new(0, 0, 1, -10)
	topPatch.BackgroundColor3 = Bloxium.Theme.TopBar
	topPatch.BorderSizePixel = 0
	topPatch.Parent = top

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -100, 1, 0)
	title.Position = UDim2.new(0, 16, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = string.upper(titleText)
	title.TextColor3 = Bloxium.Theme.Text
	title.Font = Enum.Font.GothamBold
	title.TextSize = 12
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = top

	if subtitle ~= "" then
		title.Text = string.upper(titleText) .. "  •  " .. string.upper(subtitle)
	end

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(30, 30)
	close.Position = UDim2.new(1, -38, 0, 6)
	close.BackgroundColor3 = Bloxium.Theme.Element
	close.BackgroundTransparency = 1
	close.Text = "×"
	close.TextColor3 = Bloxium.Theme.TextMuted
	close.Font = Enum.Font.Gotham
	close.TextSize = 18
	close.AutoButtonColor = false
	close.Parent = top
	corner(close, 6)

	close.MouseEnter:Connect(function()
		tween(close, {
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(55, 20, 20),
			TextColor3 = Color3.fromRGB(235, 90, 90)
		}, 0.1):Play()
	end)

	close.MouseLeave:Connect(function()
		tween(close, {
			BackgroundTransparency = 1,
			TextColor3 = Bloxium.Theme.TextMuted
		}, 0.1):Play()
	end)

	close.MouseButton1Click:Connect(function()
		gui:Destroy()
	end)

	local minimize = Instance.new("TextButton")
	minimize.Size = UDim2.fromOffset(30, 30)
	minimize.Position = UDim2.new(1, -72, 0, 6)
	minimize.BackgroundColor3 = Bloxium.Theme.Element
	minimize.BackgroundTransparency = 1
	minimize.Text = "−"
	minimize.TextColor3 = Bloxium.Theme.TextMuted
	minimize.Font = Enum.Font.Gotham
	minimize.TextSize = 17
	minimize.AutoButtonColor = false
	minimize.Parent = top
	corner(minimize, 6)

	local minimized = false

	minimize.MouseButton1Click:Connect(function()
		minimized = not minimized

		minimize.Text = minimized and "+" or "−"

		tween(main, {
			Size = minimized and UDim2.fromOffset(
				windowSize.X.Offset,
				42
			) or windowSize
		}, 0.2):Play()
	end)

	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 158, 1, -42)
	sidebar.Position = UDim2.new(0, 0, 0, 42)
	sidebar.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main
	corner(sidebar, 10)

	local sidePatch = Instance.new("Frame")
	sidePatch.Size = UDim2.new(1, 0, 0, 10)
	sidePatch.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidePatch.BorderSizePixel = 0
	sidePatch.Parent = sidebar

	local tabContainer = Instance.new("ScrollingFrame")
	tabContainer.Size = UDim2.new(1, 0, 1, -10)
	tabContainer.Position = UDim2.new(0, 0, 0, 10)
	tabContainer.BackgroundTransparency = 1
	tabContainer.BorderSizePixel = 0
	tabContainer.ScrollBarThickness = 0
	tabContainer.CanvasSize = UDim2.new()
	tabContainer.Parent = sidebar

	local sidePadding = Instance.new("UIPadding")
	sidePadding.PaddingTop = UDim.new(0, 8)
	sidePadding.PaddingLeft = UDim.new(0, 10)
	sidePadding.PaddingRight = UDim.new(0, 10)
	sidePadding.Parent = tabContainer

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabContainer

	tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		tabContainer.CanvasSize = UDim2.new(
			0,
			0,
			0,
			tabLayout.AbsoluteContentSize.Y + 20
		)
	end)

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(0, 1, 1, -42)
	divider.Position = UDim2.new(0, 158, 0, 42)
	divider.BackgroundColor3 = Bloxium.Theme.Border
	divider.BorderSizePixel = 0
	divider.Parent = main

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, -178, 1, -52)
	content.Position = UDim2.new(0, 169, 0, 52)
	content.BackgroundTransparency = 1
	content.Parent = main

	local dragging = false
	local dragStart
	local startPosition

	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			dragging = true
			dragStart = input.Position
			startPosition = main.Position

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		) then

			local delta = input.Position - dragStart

			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	function Window:CreateTab(name)
		local Tab = {
			Name = name
		}

		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(1, 0, 0, 34)
		tabButton.BackgroundColor3 = Bloxium.Theme.Element
		tabButton.BackgroundTransparency = 1
		tabButton.Text = ""
		tabButton.AutoButtonColor = false
		tabButton.Parent = tabContainer
		corner(tabButton, 7)

		local indicator = Instance.new("Frame")
		indicator.Size = UDim2.fromOffset(3, 16)
		indicator.Position = UDim2.new(0, 8, 0.5, -8)
		indicator.BackgroundColor3 = Bloxium.Theme.Accent
		indicator.BackgroundTransparency = 1
		indicator.BorderSizePixel = 0
		indicator.Parent = tabButton
		corner(indicator, 2)

		local tabLabel = makeLabel(
			tabButton,
			string.upper(name),
			UDim2.new(1, -30, 1, 0),
			UDim2.new(0, 24, 0, 0)
		)

		tabLabel.TextColor3 = Bloxium.Theme.TextMuted

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Bloxium.Theme.BorderLight
		page.CanvasSize = UDim2.new()
		page.Visible = false
		page.Parent = content

		local pagePadding = Instance.new("UIPadding")
		pagePadding.PaddingTop = UDim.new(0, 4)
		pagePadding.PaddingRight = UDim.new(0, 5)
		pagePadding.PaddingBottom = UDim.new(0, 10)
		pagePadding.Parent = page

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(
				0,
				0,
				0,
				pageLayout.AbsoluteContentSize.Y + 20
			)
		end)

		function Tab:CreateSection(sectionName)
			local Section = {}

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Size = UDim2.new(1, 0, 0, 32)
			sectionFrame.BackgroundTransparency = 1
			sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			sectionFrame.Parent = page

			local sectionTitle = Instance.new("TextLabel")
			sectionTitle.Size = UDim2.new(1, 0, 0, 22)
			sectionTitle.BackgroundTransparency = 1
			sectionTitle.Text = string.upper(sectionName or "SECTION")
			sectionTitle.TextColor3 = Bloxium.Theme.TextMuted
			sectionTitle.Font = Enum.Font.GothamBold
			sectionTitle.TextSize = 10
			sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			sectionTitle.Parent = sectionFrame

			local line = Instance.new("Frame")
			line.Size = UDim2.new(1, 0, 0, 1)
			line.Position = UDim2.new(0, 0, 0, 26)
			line.BackgroundColor3 = Bloxium.Theme.Border
			line.BorderSizePixel = 0
			line.Parent = sectionFrame

			local elements = Instance.new("Frame")
			elements.Size = UDim2.new(1, 0, 0, 0)
			elements.Position = UDim2.new(0, 0, 0, 32)
			elements.BackgroundTransparency = 1
			elements.AutomaticSize = Enum.AutomaticSize.Y
			elements.Parent = sectionFrame

			local elementLayout = Instance.new("UIListLayout")
			elementLayout.Padding = UDim.new(0, 8)
			elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
			elementLayout.Parent = elements

			elementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				sectionFrame.Size = UDim2.new(
					1,
					0,
					0,
					32 + elementLayout.AbsoluteContentSize.Y
				)
			end)

			function Section:CreateButton(options)
				options = options or {}

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 34)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements
				corner(frame, 6)

				local frameStroke = stroke(
					frame,
					Bloxium.Theme.Border,
					0.35
				)

				local button = Instance.new("TextButton")
				button.Size = UDim2.new(1, 0, 1, 0)
				button.BackgroundTransparency = 1
				button.Text = string.upper(options.Name or "BUTTON")
				button.TextColor3 = Bloxium.Theme.Text
				button.Font = Enum.Font.GothamMedium
				button.TextSize = 11
				button.TextXAlignment = Enum.TextXAlignment.Left
				button.AutoButtonColor = false
				button.Parent = frame

				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 12)
				padding.Parent = button

				button.MouseEnter:Connect(function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.ElementHover
					}, 0.1):Play()
				end)

				button.MouseLeave:Connect(function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.Element
					}, 0.1):Play()
				end)

				button.MouseButton1Click:Connect(function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.Accent
					}, 0.05):Play()

					task.delay(0.06, function()
						if frame.Parent then
							tween(frame, {
								BackgroundColor3 = Bloxium.Theme.Element
							}, 0.15):Play()
						end
					end)

					task.spawn(options.Callback or function() end)
				end)

				return frame
			end

			function Section:CreateToggle(options)
				options = options or {}

				local state = options.Default == true
				local callback = options.Callback or function() end

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 34)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements
				corner(frame, 6)

				makeLabel(
					frame,
					string.upper(options.Name or "TOGGLE"),
					UDim2.new(1, -75, 1, 0),
					UDim2.new(0, 12, 0, 0)
				)

				local toggle = Instance.new("TextButton")
				toggle.Size = UDim2.fromOffset(42, 20)
				toggle.Position = UDim2.new(1, -54, 0.5, -10)
				toggle.BackgroundColor3 = Bloxium.Theme.Background
				toggle.Text = ""
				toggle.AutoButtonColor = false
				toggle.Parent = frame
				corner(toggle, 10)
				stroke(toggle, Bloxium.Theme.Border, 0)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.fromOffset(14, 14)
				knob.BorderSizePixel = 0
				knob.Parent = toggle
				corner(knob, 10)

				local function update(fire)
					knob.Position = state
						and UDim2.new(1, -17, 0.5, -7)
						or UDim2.new(0, 3, 0.5, -7)

					knob.BackgroundColor3 = state
						and Bloxium.Theme.Accent
						or Bloxium.Theme.BorderLight

					if fire then
						task.spawn(callback, state)
					end
				end

				toggle.MouseButton1Click:Connect(function()
					state = not state
					update(true)
				end)

				update(false)

				return frame
			end

			function Section:CreateSlider(options)
				options = options or {}

				local minimum = options.Min or 0
				local maximum = options.Max or 100
				local value = math.clamp(
					options.Default or minimum,
					minimum,
					maximum
				)

				local callback = options.Callback or function() end

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 50)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements
				corner(frame, 6)

				makeLabel(
					frame,
					string.upper(options.Name or "SLIDER"),
					UDim2.new(1, -80, 0, 25),
					UDim2.new(0, 12, 0, 1)
				)

				local valueLabel = makeLabel(
					frame,
					tostring(value),
					UDim2.fromOffset(60, 25),
					UDim2.new(1, -72, 0, 1)
				)

				valueLabel.TextColor3 = Bloxium.Theme.TextMuted
				valueLabel.TextXAlignment = Enum.TextXAlignment.Right

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, -24, 0, 4)
				track.Position = UDim2.new(0, 12, 0, 34)
				track.BackgroundColor3 = Bloxium.Theme.Background
				track.BorderSizePixel = 0
				track.Text = ""
				track.AutoButtonColor = false
				track.Parent = frame
				corner(track, 4)

				local fill = Instance.new("Frame")
				fill.BackgroundColor3 = Bloxium.Theme.Accent
				fill.BorderSizePixel = 0
				fill.Parent = track
				corner(fill, 4)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.fromOffset(10, 10)
				knob.BackgroundColor3 = Bloxium.Theme.Accent
				knob.BorderSizePixel = 0
				knob.Parent = track
				corner(knob, 10)

				local draggingSlider = false

				local function updateFromX(x)
					local alpha = math.clamp(
						(x - track.AbsolutePosition.X) /
						track.AbsoluteSize.X,
						0,
						1
					)

					value = math.floor(
						minimum + (maximum - minimum) * alpha
					)

					fill.Size = UDim2.new(alpha, 0, 1, 0)
					knob.Position = UDim2.new(alpha, -5, 0.5, -5)
					valueLabel.Text = tostring(value)

					task.spawn(callback, value)
				end

				local initialAlpha =
					(value - minimum) /
					math.max(maximum - minimum, 1)

				fill.Size = UDim2.new(initialAlpha, 0, 1, 0)
				knob.Position = UDim2.new(
					initialAlpha,
					-5,
					0.5,
					-5
				)

				track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then

						draggingSlider = true
						updateFromX(input.Position.X)
					end
				end)

				UserInputService.InputChanged:Connect(function(input)
					if draggingSlider and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					) then
						updateFromX(input.Position.X)
					end
				end)

				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1
						or input.UserInputType == Enum.UserInputType.Touch then
						draggingSlider = false
					end
				end)

				return frame
			end

			function Section:CreateDropdown(options)
				options = options or {}

				local values = options.Options or {}
				local selected = options.Default or values[1] or ""
				local callback = options.Callback or function() end
				local opened = false

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 34)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.ClipsDescendants = true
				frame.Parent = elements
				corner(frame, 6)

				makeLabel(
					frame,
					string.upper(options.Name or "DROPDOWN"),
					UDim2.new(0.45, 0, 0, 34),
					UDim2.new(0, 12, 0, 0)
				)

				local selectButton = Instance.new("TextButton")
				selectButton.Size = UDim2.new(0.45, 0, 0, 24)
				selectButton.Position = UDim2.new(0.52, 0, 0, 5)
				selectButton.BackgroundColor3 = Bloxium.Theme.Background
				selectButton.Text = tostring(selected)
				selectButton.TextColor3 = Bloxium.Theme.TextMuted
				selectButton.Font = Enum.Font.GothamMedium
				selectButton.TextSize = 10
				selectButton.TextXAlignment = Enum.TextXAlignment.Left
				selectButton.AutoButtonColor = false
				selectButton.Parent = frame
				corner(selectButton, 5)

				local selectPadding = Instance.new("UIPadding")
				selectPadding.PaddingLeft = UDim.new(0, 9)
				selectPadding.Parent = selectButton

				local arrow = Instance.new("TextLabel")
				arrow.Size = UDim2.fromOffset(20, 24)
				arrow.Position = UDim2.new(1, -25, 0, 0)
				arrow.BackgroundTransparency = 1
				arrow.Text = "▼"
				arrow.TextColor3 = Bloxium.Theme.TextMuted
				arrow.Font = Enum.Font.GothamBold
				arrow.TextSize = 9
				arrow.Parent = selectButton

				local optionContainer = Instance.new("Frame")
				optionContainer.Size = UDim2.new(1, -24, 0, #values * 28)
				optionContainer.Position = UDim2.new(0, 12, 0, 40)
				optionContainer.BackgroundTransparency = 1
				optionContainer.Parent = frame

				local optionLayout = Instance.new("UIListLayout")
				optionLayout.Padding = UDim.new(0, 4)
				optionLayout.Parent = optionContainer

				local function resize()
					local height = opened
						and 44 + (#values * 28)
						or 34

					tween(frame, {
						Size = UDim2.new(1, 0, 0, height)
					}, 0.15):Play()
				end

				selectButton.MouseButton1Click:Connect(function()
					opened = not opened
					arrow.Text = opened and "▲" or "▼"
					resize()
				end)

				for _, option in ipairs(values) do
					local button = Instance.new("TextButton")
					button.Size = UDim2.new(1, 0, 0, 24)
					button.BackgroundColor3 = Bloxium.Theme.Background
					button.Text = tostring(option)
					button.TextColor3 = Bloxium.Theme.Text
					button.Font = Enum.Font.GothamMedium
					button.TextSize = 10
					button.TextXAlignment = Enum.TextXAlignment.Left
					button.AutoButtonColor = false
					button.Parent = optionContainer
					corner(button, 5)

					local padding = Instance.new("UIPadding")
					padding.PaddingLeft = UDim.new(0, 9)
					padding.Parent = button

					button.MouseEnter:Connect(function()
						tween(button, {
							BackgroundColor3 = Bloxium.Theme.ElementHover
						}, 0.1):Play()
					end)

					button.MouseLeave:Connect(function()
						tween(button, {
							BackgroundColor3 = Bloxium.Theme.Background
						}, 0.1):Play()
					end)

					button.MouseButton1Click:Connect(function()
						selected = option
						selectButton.Text = tostring(option)
						opened = false
						arrow.Text = "▼"
						resize()
						task.spawn(callback, option)
					end)
				end

				return frame
			end

			function Section:CreateTextInput(options)
				options = options or {}

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 34)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements
				corner(frame, 6)

				makeLabel(
					frame,
					string.upper(options.Name or "INPUT"),
					UDim2.new(0.42, 0, 1, 0),
					UDim2.new(0, 12, 0, 0)
				)

				local input = Instance.new("TextBox")
				input.Size = UDim2.new(0.5, 0, 0, 24)
				input.Position = UDim2.new(0.47, 0, 0.5, -12)
				input.BackgroundColor3 = Bloxium.Theme.Background
				input.Text = ""
				input.PlaceholderText = options.Placeholder or "Enter value..."
				input.TextColor3 = Bloxium.Theme.Text
				input.PlaceholderColor3 = Bloxium.Theme.TextDim
				input.Font = Enum.Font.GothamMedium
				input.TextSize = 10
				input.ClearTextOnFocus = false
				input.Parent = frame
				corner(input, 5)

				local padding = Instance.new("UIPadding")
				padding.PaddingLeft = UDim.new(0, 8)
				padding.PaddingRight = UDim.new(0, 8)
				padding.Parent = input

				input.FocusLost:Connect(function(enterPressed)
					task.spawn(
						options.Callback or function() end,
						input.Text,
						enterPressed
					)
				end)

				return frame
			end

			function Section:CreateKeybind(options)
				options = options or {}

				local currentKey =
					options.Default or Enum.KeyCode.E

				local listening = false

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 34)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements
				corner(frame, 6)

				makeLabel(
					frame,
					string.upper(options.Name or "KEYBIND"),
					UDim2.new(1, -115, 1, 0),
					UDim2.new(0, 12, 0, 0)
				)

				local button = Instance.new("TextButton")
				button.Size = UDim2.fromOffset(85, 24)
				button.Position = UDim2.new(1, -97, 0.5, -12)
				button.BackgroundColor3 = Bloxium.Theme.Background
				button.Text = string.upper(currentKey.Name)
				button.TextColor3 = Bloxium.Theme.TextMuted
				button.Font = Enum.Font.GothamMedium
				button.TextSize = 10
				button.AutoButtonColor = false
				button.Parent = frame
				corner(button, 5)

				button.MouseButton1Click:Connect(function()
					listening = true
					button.Text = "PRESS KEY"
					button.TextColor3 = Bloxium.Theme.Accent
				end)

				UserInputService.InputBegan:Connect(function(input, processed)
					if listening and input.UserInputType == Enum.UserInputType.Keyboard then
						if input.KeyCode == Enum.KeyCode.Escape then
							listening = false
							button.Text = string.upper(currentKey.Name)
							button.TextColor3 = Bloxium.Theme.TextMuted
							return
						end

						currentKey = input.KeyCode
						listening = false
						button.Text = string.upper(currentKey.Name)
						button.TextColor3 = Bloxium.Theme.TextMuted

					elseif not listening
						and not processed
						and input.KeyCode == currentKey then

						task.spawn(
							options.Callback or function() end,
							currentKey
						)
					end
				end)

				return frame
			end

			return Section
		end

		function Tab:CreateButton(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateButton(options)
		end

		function Tab:CreateToggle(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateToggle(options)
		end

		function Tab:CreateSlider(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateSlider(options)
		end

		function Tab:CreateDropdown(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateDropdown(options)
		end

		function Tab:CreateTextInput(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateTextInput(options)
		end

		function Tab:CreateKeybind(options)
			local section = self:CreateSection("GENERAL")
			return section:CreateKeybind(options)
		end

		local function selectTab()
			for _, existing in ipairs(Window.Tabs) do
				existing.Page.Visible = false

				tween(existing.Button, {
					BackgroundTransparency = 1
				}, 0.1):Play()

				tween(existing.Text, {
					TextColor3 = Bloxium.Theme.TextMuted
				}, 0.1):Play()

				tween(existing.Indicator, {
					BackgroundTransparency = 1
				}, 0.1):Play()
			end

			page.Visible = true

			tween(tabButton, {
				BackgroundTransparency = 0
			}, 0.1):Play()

			tween(tabLabel, {
				TextColor3 = Bloxium.Theme.Text
			}, 0.1):Play()

			tween(indicator, {
				BackgroundTransparency = 0
			}, 0.1):Play()

			Window.ActiveTab = Tab
		end

		tabButton.MouseButton1Click:Connect(selectTab)

		tabButton.MouseEnter:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(tabButton, {
					BackgroundTransparency = 0.7
				}, 0.1):Play()

				tween(tabLabel, {
					TextColor3 = Bloxium.Theme.Text
				}, 0.1):Play()
			end
		end)

		tabButton.MouseLeave:Connect(function()
			if Window.ActiveTab ~= Tab then
				tween(tabButton, {
					BackgroundTransparency = 1
				}, 0.1):Play()

				tween(tabLabel, {
					TextColor3 = Bloxium.Theme.TextMuted
				}, 0.1):Play()
			end
		end)

		Tab.Button = tabButton
		Tab.Text = tabLabel
		Tab.Indicator = indicator
		Tab.Page = page

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			selectTab()
		end

		return Tab
	end

	return Window
end

return Bloxium
