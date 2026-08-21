local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
	return nil
end

local Bloxium = {}

Bloxium.Version = "2.1.0"

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
	BorderLight = Color3.fromRGB(54, 54, 54),
	Danger = Color3.fromRGB(235, 75, 75),
	Font = Enum.Font.Gotham,
	FontMedium = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold
}

Bloxium.Defaults = {
	Title = "BLOXIUM",
	Subtitle = "",
	Size = UDim2.fromOffset(650, 430)
}

local function corner(parent, radius)
	local object = Instance.new("UICorner")
	object.CornerRadius = UDim.new(0, radius or 6)
	object.Parent = parent
	return object
end

local function stroke(parent, color, thickness, transparency)
	local object = Instance.new("UIStroke")
	object.Color = color or Bloxium.Theme.Border
	object.Thickness = thickness or 1
	object.Transparency = transparency or 0
	object.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	object.Parent = parent
	return object
end

local function padding(parent, left, right, top, bottom)
	local object = Instance.new("UIPadding")
	object.PaddingLeft = UDim.new(0, left or 0)
	object.PaddingRight = UDim.new(0, right or 0)
	object.PaddingTop = UDim.new(0, top or 0)
	object.PaddingBottom = UDim.new(0, bottom or 0)
	object.Parent = parent
	return object
end

local function label(parent, properties)
	local object = Instance.new("TextLabel")

	for property, value in pairs(properties or {}) do
		object[property] = value
	end

	object.BackgroundTransparency = 1
	object.Parent = parent

	return object
end

local function tween(object, properties, duration, style, direction)
	if not object or not object.Parent then
		return nil
	end

	local animation = TweenService:Create(
		object,
		TweenInfo.new(
			duration or 0.15,
			style or Enum.EasingStyle.Quad,
			direction or Enum.EasingDirection.Out
		),
		properties
	)

	animation:Play()

	return animation
end

local function connect(list, signal, callback)
	local connection = signal:Connect(callback)

	if list then
		table.insert(list, connection)
	end

	return connection
end

local function disconnect(list)
	for i = #list, 1, -1 do
		local connection = list[i]

		if connection then
			pcall(function()
				connection:Disconnect()
			end)
		end

		list[i] = nil
	end
end

local function activate(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function callback(fn, ...)
	if typeof(fn) ~= "function" then
		return
	end

	local args = table.pack(...)

	task.spawn(function()
		fn(table.unpack(args, 1, args.n))
	end)
end

local function getParent(customParent)
	if typeof(customParent) == "Instance" then
		if customParent:IsA("PlayerGui") then
			return customParent
		end

		if customParent:IsA("ScreenGui") then
			return customParent
		end
	end

	return LocalPlayer:WaitForChild("PlayerGui")
end

function Bloxium:CreateWindow(config)
	config = config or {}

	local Window = {
		Tabs = {},
		ActiveTab = nil,
		Destroyed = false,
		Minimized = false,
		Connections = {}
	}

	local size = config.Size or Bloxium.Defaults.Size
	local titleText = tostring(config.Title or Bloxium.Defaults.Title)
	local subtitleText = tostring(config.Subtitle or "")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = tostring(config.Name or "Bloxium")
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = tonumber(config.DisplayOrder) or 100
	screenGui.Parent = getParent(config.Parent)

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = size
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.BackgroundColor3 = Bloxium.Theme.Background
	main.BorderSizePixel = 0
	main.Active = true
	main.ClipsDescendants = true
	main.Parent = screenGui

	corner(main, 10)
	stroke(main, Bloxium.Theme.Border, 1, 0)

	Window.ScreenGui = screenGui
	Window.MainFrame = main

	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 42)
	topBar.BackgroundColor3 = Bloxium.Theme.TopBar
	topBar.BorderSizePixel = 0
	topBar.Active = true
	topBar.Parent = main

	corner(topBar, 10)

	local topPatch = Instance.new("Frame")
	topPatch.Size = UDim2.new(1, 0, 0, 10)
	topPatch.Position = UDim2.new(0, 0, 1, -10)
	topPatch.BackgroundColor3 = Bloxium.Theme.TopBar
	topPatch.BorderSizePixel = 0
	topPatch.Parent = topBar

	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -32, 0, 1)
	divider.Position = UDim2.new(0, 16, 1, -1)
	divider.BackgroundColor3 = Bloxium.Theme.Border
	divider.BorderSizePixel = 0
	divider.Parent = topBar

	local title = label(topBar, {
		Name = "Title",
		Size = UDim2.new(1, -110, 1, 0),
		Position = UDim2.fromOffset(16, 0),
		TextColor3 = Bloxium.Theme.Text,
		Font = Bloxium.Theme.FontBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = true
	})

	local function updateTitle()
		local text = string.upper(titleText)

		if subtitleText ~= "" then
			text = text .. "  <font color='#707070'>" .. string.upper(subtitleText) .. "</font>"
		end

		title.Text = text
	end

	updateTitle()

	local minimize = Instance.new("TextButton")
	minimize.Size = UDim2.fromOffset(30, 30)
	minimize.Position = UDim2.new(1, -72, 0, 6)
	minimize.BackgroundColor3 = Bloxium.Theme.Element
	minimize.BackgroundTransparency = 1
	minimize.Text = "−"
	minimize.TextColor3 = Bloxium.Theme.TextMuted
	minimize.Font = Bloxium.Theme.Font
	minimize.TextSize = 18
	minimize.AutoButtonColor = false
	minimize.Parent = topBar

	corner(minimize, 6)

	local close = Instance.new("TextButton")
	close.Size = UDim2.fromOffset(30, 30)
	close.Position = UDim2.new(1, -38, 0, 6)
	close.BackgroundColor3 = Bloxium.Theme.Element
	close.BackgroundTransparency = 1
	close.Text = "×"
	close.TextColor3 = Bloxium.Theme.TextMuted
	close.Font = Bloxium.Theme.Font
	close.TextSize = 18
	close.AutoButtonColor = false
	close.Parent = topBar

	corner(close, 6)

	connect(Window.Connections, minimize.MouseEnter, function()
		if Window.Destroyed then
			return
		end

		tween(minimize, {
			BackgroundTransparency = 0,
			TextColor3 = Bloxium.Theme.Text
		}, 0.12)
	end)

	connect(Window.Connections, minimize.MouseLeave, function()
		if Window.Destroyed then
			return
		end

		tween(minimize, {
			BackgroundTransparency = 1,
			TextColor3 = Bloxium.Theme.TextMuted
		}, 0.12)
	end)

	connect(Window.Connections, close.MouseEnter, function()
		if Window.Destroyed then
			return
		end

		tween(close, {
			BackgroundTransparency = 0,
			BackgroundColor3 = Color3.fromRGB(55, 20, 20),
			TextColor3 = Bloxium.Theme.Danger
		}, 0.12)
	end)

	connect(Window.Connections, close.MouseLeave, function()
		if Window.Destroyed then
			return
		end

		tween(close, {
			BackgroundTransparency = 1,
			TextColor3 = Bloxium.Theme.TextMuted
		}, 0.12)
	end)

	local normalSize = size

	function Window:SetMinimized(state)
		if Window.Destroyed then
			return
		end

		state = state == true

		if Window.Minimized == state then
			return
		end

		Window.Minimized = state

		if state then
			normalSize = main.Size

			tween(main, {
				Size = UDim2.new(
					normalSize.X.Scale,
					normalSize.X.Offset,
					0,
					42
				)
			}, 0.2, Enum.EasingStyle.Quart)

			minimize.Text = "+"
		else
			tween(main, {
				Size = normalSize
			}, 0.2, Enum.EasingStyle.Quart)

			minimize.Text = "−"
		end
	end

	connect(Window.Connections, minimize.Activated, function()
		Window:SetMinimized(not Window.Minimized)
	end)

	connect(Window.Connections, close.Activated, function()
		Window:Destroy()
	end)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 158, 1, -42)
	sidebar.Position = UDim2.fromOffset(0, 42)
	sidebar.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main

	corner(sidebar, 10)

	local sidebarPatch = Instance.new("Frame")
	sidebarPatch.Size = UDim2.new(1, 0, 0, 10)
	sidebarPatch.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebarPatch.BorderSizePixel = 0
	sidebarPatch.Parent = sidebar

	local sidebarRight = Instance.new("Frame")
	sidebarRight.Size = UDim2.fromOffset(10, 42)
	sidebarRight.Position = UDim2.new(1, -10, 0, 0)
	sidebarRight.BackgroundColor3 = Bloxium.Theme.Sidebar
	sidebarRight.BorderSizePixel = 0
	sidebarRight.Parent = sidebar

	local tabContainer = Instance.new("ScrollingFrame")
	tabContainer.Name = "Tabs"
	tabContainer.Size = UDim2.fromScale(1, 1)
	tabContainer.BackgroundTransparency = 1
	tabContainer.BorderSizePixel = 0
	tabContainer.ScrollBarThickness = 2
	tabContainer.ScrollBarImageColor3 = Bloxium.Theme.BorderLight
	tabContainer.CanvasSize = UDim2.fromOffset(0, 0)
	tabContainer.Parent = sidebar

	padding(tabContainer, 10, 10, 12, 10)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabContainer

	connect(Window.Connections, tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		tabContainer.CanvasSize = UDim2.fromOffset(
			0,
			tabLayout.AbsoluteContentSize.Y + 20
		)
	end)

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(0, 1, 1, -42)
	sidebarDivider.Position = UDim2.fromOffset(157, 42)
	sidebarDivider.BackgroundColor3 = Bloxium.Theme.Border
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Parent = main

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -178, 1, -52)
	content.Position = UDim2.fromOffset(169, 42)
	content.BackgroundTransparency = 1
	content.Parent = main

	Window.Content = content

	local dragging = false
	local dragStart
	local startPosition

	connect(Window.Connections, topBar.InputBegan, function(input)
		if not activate(input) then
			return
		end

		dragging = true
		dragStart = input.Position
		startPosition = main.Position
	end)

	connect(Window.Connections, UserInputService.InputChanged, function(input)
		if not dragging then
			return
		end

		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
	end)

	connect(Window.Connections, UserInputService.InputEnded, function(input)
		if activate(input) then
			dragging = false
		end
	end)

	local notificationHost = Instance.new("Frame")
	notificationHost.Name = "Notifications"
	notificationHost.Size = UDim2.fromOffset(300, 0)
	notificationHost.AutomaticSize = Enum.AutomaticSize.Y
	notificationHost.AnchorPoint = Vector2.new(1, 1)
	notificationHost.Position = UDim2.new(1, -14, 1, -14)
	notificationHost.BackgroundTransparency = 1
	notificationHost.BorderSizePixel = 0
	notificationHost.Parent = screenGui

	local notificationLayout = Instance.new("UIListLayout")
	notificationLayout.Padding = UDim.new(0, 8)
	notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationLayout.Parent = notificationHost

	Window.NotificationHost = notificationHost

	function Window:Notify(options)
		if Window.Destroyed then
			return
		end

		options = options or {}

		local notification = Instance.new("Frame")
		notification.Size = UDim2.fromOffset(280, 66)
		notification.BackgroundColor3 = Bloxium.Theme.Element
		notification.BackgroundTransparency = 1
		notification.BorderSizePixel = 0
		notification.Parent = notificationHost

		corner(notification, 8)

		local notificationStroke = stroke(
			notification,
			Bloxium.Theme.Border,
			1,
			1
		)

		local accent = Instance.new("Frame")
		accent.Size = UDim2.new(0, 3, 1, -20)
		accent.Position = UDim2.fromOffset(8, 10)
		accent.BackgroundColor3 = Bloxium.Theme.Accent
		accent.BackgroundTransparency = 1
		accent.BorderSizePixel = 0
		accent.Parent = notification

		corner(accent, 3)

		local notificationTitle = label(notification, {
			Size = UDim2.new(1, -38, 0, 20),
			Position = UDim2.fromOffset(20, 8),
			Text = string.upper(tostring(options.Title or "SYSTEM ALERT")),
			TextColor3 = Bloxium.Theme.Text,
			Font = Bloxium.Theme.FontBold,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTransparency = 1
		})

		local description = label(notification, {
			Size = UDim2.new(1, -38, 0, 28),
			Position = UDim2.fromOffset(20, 29),
			Text = tostring(options.Description or ""),
			TextColor3 = Bloxium.Theme.TextMuted,
			Font = Bloxium.Theme.FontMedium,
			TextSize = 10,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextTransparency = 1
		})

		tween(notification, {
			BackgroundTransparency = 0
		}, 0.2)

		tween(notificationStroke, {
			Transparency = 0
		}, 0.2)

		tween(accent, {
			BackgroundTransparency = 0
		}, 0.2)

		tween(notificationTitle, {
			TextTransparency = 0
		}, 0.2)

		tween(description, {
			TextTransparency = 0
		}, 0.2)

		local duration = math.max(
			tonumber(options.Duration) or 3,
			0.25
		)

		task.delay(duration, function()
			if not notification.Parent then
				return
			end

			tween(notification, {
				BackgroundTransparency = 1
			}, 0.2)

			tween(notificationStroke, {
				Transparency = 1
			}, 0.2)

			tween(accent, {
				BackgroundTransparency = 1
			}, 0.2)

			tween(notificationTitle, {
				TextTransparency = 1
			}, 0.2)

			local fade = tween(description, {
				TextTransparency = 1
			}, 0.2)

			if fade then
				fade.Completed:Wait()
			end

			if notification then
				notification:Destroy()
			end
		end)
	end

	function Window:SetTitle(newTitle, newSubtitle)
		if Window.Destroyed then
			return
		end

		titleText = tostring(newTitle or titleText)

		if newSubtitle ~= nil then
			subtitleText = tostring(newSubtitle)
		end

		updateTitle()
	end

	function Window:SetVisible(state)
		if Window.Destroyed then
			return
		end

		screenGui.Enabled = state == true
	end

	function Window:IsVisible()
		if Window.Destroyed then
			return false
		end

		return screenGui.Enabled
	end

	function Window:SetPosition(position)
		if Window.Destroyed then
			return
		end

		if typeof(position) == "UDim2" then
			main.Position = position
		end
	end

	function Window:SetSize(newSize)
		if Window.Destroyed then
			return
		end

		if typeof(newSize) ~= "UDim2" then
			return
		end

		normalSize = newSize

		if not Window.Minimized then
			main.Size = newSize
		end
	end

	function Window:SelectTab(tab)
		if Window.Destroyed or not tab then
			return
		end

		if tab.Select then
			tab:Select()
		end
	end

	function Window:Destroy()
		if Window.Destroyed then
			return
		end

		Window.Destroyed = true

		disconnect(Window.Connections)

		for _, tab in ipairs(Window.Tabs) do
			if tab.Connections then
				disconnect(tab.Connections)
			end

			for _, section in ipairs(tab.Sections) do
				if section.Connections then
					disconnect(section.Connections)
				end

				for _, element in ipairs(section.Elements) do
					if element.Connections then
						disconnect(element.Connections)
					end
				end
			end
		end

		if screenGui then
			screenGui:Destroy()
		end

		table.clear(Window.Tabs)
		Window.ActiveTab = nil
	end

	function Window:CreateTab(name)
		if Window.Destroyed then
			return nil
		end

		local Tab = {
			Name = tostring(name or "TAB"),
			Sections = {},
			Connections = {}
		}

		local tabButton = Instance.new("TextButton")
		tabButton.Size = UDim2.new(1, 0, 0, 34)
		tabButton.BackgroundColor3 = Bloxium.Theme.Element
		tabButton.BackgroundTransparency = 1
		tabButton.BorderSizePixel = 0
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

		local tabText = label(tabButton, {
			Size = UDim2.new(1, -30, 1, 0),
			Position = UDim2.fromOffset(24, 0),
			Text = string.upper(Tab.Name),
			TextColor3 = Bloxium.Theme.TextMuted,
			Font = Bloxium.Theme.FontMedium,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center
		})

		local page = Instance.new("ScrollingFrame")
		page.Name = Tab.Name .. "Page"
		page.Size = UDim2.fromScale(1, 1)
		page.BackgroundTransparency = 1
		page.BorderSizePixel = 0
		page.ScrollBarThickness = 2
		page.ScrollBarImageColor3 = Bloxium.Theme.BorderLight
		page.CanvasSize = UDim2.fromOffset(0, 0)
		page.Visible = false
		page.Parent = content

		padding(page, 0, 6, 0, 12)

		local pageLayout = Instance.new("UIListLayout")
		pageLayout.Padding = UDim.new(0, 8)
		pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		pageLayout.Parent = page

		connect(Tab.Connections, pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			if page.Parent then
				page.CanvasSize = UDim2.fromOffset(
					0,
					pageLayout.AbsoluteContentSize.Y + 15
				)
			end
		end)

		Tab.Button = tabButton
		Tab.Text = tabText
		Tab.Indicator = indicator
		Tab.Page = page

		function Tab:Select()
			if Window.Destroyed then
				return
			end

			for _, other in ipairs(Window.Tabs) do
				other.Page.Visible = false

				tween(other.Button, {
					BackgroundTransparency = 1
				}, 0.12)

				tween(other.Text, {
					TextColor3 = Bloxium.Theme.TextMuted
				}, 0.12)

				tween(other.Indicator, {
					BackgroundTransparency = 1
				}, 0.12)
			end

			page.Visible = true

			tween(tabButton, {
				BackgroundTransparency = 0
			}, 0.12)

			tween(tabText, {
				TextColor3 = Bloxium.Theme.Text
			}, 0.12)

			tween(indicator, {
				BackgroundTransparency = 0
			}, 0.12)

			Window.ActiveTab = Tab
		end

		connect(Tab.Connections, tabButton.Activated, function()
			Tab:Select()
		end)

		connect(Tab.Connections, tabButton.MouseEnter, function()
			if Window.ActiveTab ~= Tab then
				tween(tabButton, {
					BackgroundTransparency = 0.7
				}, 0.1)

				tween(tabText, {
					TextColor3 = Bloxium.Theme.Text
				}, 0.1)
			end
		end)

		connect(Tab.Connections, tabButton.MouseLeave, function()
			if Window.ActiveTab ~= Tab then
				tween(tabButton, {
					BackgroundTransparency = 1
				}, 0.1)

				tween(tabText, {
					TextColor3 = Bloxium.Theme.TextMuted
				}, 0.1)
			end
		end)

		function Tab:CreateSection(name)
			local Section = {
				Name = tostring(name or "SECTION"),
				Elements = {},
				Connections = {}
			}

			local sectionFrame = Instance.new("Frame")
			sectionFrame.Name = "Section"
			sectionFrame.Size = UDim2.new(1, 0, 0, 0)
			sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			sectionFrame.BackgroundTransparency = 1
			sectionFrame.BorderSizePixel = 0
			sectionFrame.Parent = page

			local sectionTitle = label(sectionFrame, {
				Size = UDim2.new(1, 0, 0, 24),
				Text = string.upper(Section.Name),
				TextColor3 = Bloxium.Theme.TextMuted,
				Font = Bloxium.Theme.FontBold,
				TextSize = 10,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center
			})

			local sectionLine = Instance.new("Frame")
			sectionLine.Size = UDim2.new(1, -75, 0, 1)
			sectionLine.Position = UDim2.new(0, 75, 0, 12)
			sectionLine.BackgroundColor3 = Bloxium.Theme.Border
			sectionLine.BorderSizePixel = 0
			sectionLine.Parent = sectionFrame

			local elements = Instance.new("Frame")
			elements.Name = "Elements"
			elements.Size = UDim2.new(1, 0, 0, 0)
			elements.Position = UDim2.fromOffset(0, 24)
			elements.AutomaticSize = Enum.AutomaticSize.Y
			elements.BackgroundTransparency = 1
			elements.BorderSizePixel = 0
			elements.Parent = sectionFrame

			local elementLayout = Instance.new("UIListLayout")
			elementLayout.Padding = UDim.new(0, 7)
			elementLayout.SortOrder = Enum.SortOrder.LayoutOrder
			elementLayout.Parent = elements

			Section.Frame = sectionFrame
			Section.ElementsFrame = elements

			function Section:_add(object)
				table.insert(self.Elements, object)
				return object
			end

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
					1,
					0.35
				)

				local button = Instance.new("TextButton")
				button.Size = UDim2.fromScale(1, 1)
				button.BackgroundTransparency = 1
				button.BorderSizePixel = 0
				button.Text = string.upper(tostring(options.Name or "BUTTON"))
				button.TextColor3 = Bloxium.Theme.Text
				button.Font = Bloxium.Theme.FontMedium
				button.TextSize = 11
				button.TextXAlignment = Enum.TextXAlignment.Left
				button.AutoButtonColor = false
				button.Parent = frame

				padding(button, 12, 12, 0, 0)

				local connections = {}

				connect(connections, button.MouseEnter, function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.ElementHover
					}, 0.1)

					tween(frameStroke, {
						Transparency = 0
					}, 0.1)
				end)

				connect(connections, button.MouseLeave, function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.Element
					}, 0.1)

					tween(frameStroke, {
						Transparency = 0.35
					}, 0.1)
				end)

				connect(connections, button.Activated, function()
					tween(frame, {
						BackgroundColor3 = Bloxium.Theme.Accent
					}, 0.05)

					task.delay(0.06, function()
						if frame.Parent then
							tween(frame, {
								BackgroundColor3 = Bloxium.Theme.Element
							}, 0.15)
						end
					end)

					callback(options.Callback)
				end)

				local object = {
					Frame = frame,
					Button = button,
					Connections = connections
				}

				function object:SetText(text)
					button.Text = string.upper(tostring(text))
				end

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			function Section:CreateToggle(options)
				options = options or {}

				local state = options.Default == true

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 36)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements

				corner(frame, 6)

				local text = label(frame, {
					Size = UDim2.new(1, -75, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					Text = string.upper(tostring(options.Name or "TOGGLE")),
					TextColor3 = Bloxium.Theme.Text,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local toggle = Instance.new("TextButton")
				toggle.Size = UDim2.fromOffset(42, 20)
				toggle.Position = UDim2.new(1, -54, 0.5, -10)
				toggle.BackgroundColor3 = Bloxium.Theme.Background
				toggle.BorderSizePixel = 0
				toggle.Text = ""
				toggle.AutoButtonColor = false
				toggle.Parent = frame

				corner(toggle, 10)
				stroke(toggle, Bloxium.Theme.Border, 1, 0)

				local knob = Instance.new("Frame")
				knob.Size = UDim2.fromOffset(14, 14)
				knob.BorderSizePixel = 0
				knob.Parent = toggle

				corner(knob, 10)

				local connections = {}

				local object = {
					Frame = frame,
					Button = toggle,
					Connections = connections
				}

				local function update(fire)
					local position
					local color

					if state then
						position = UDim2.new(1, -17, 0.5, -7)
						color = Bloxium.Theme.Accent
					else
						position = UDim2.new(0, 3, 0.5, -7)
						color = Bloxium.Theme.BorderLight
					end

					tween(knob, {
						Position = position,
						BackgroundColor3 = color
					}, 0.15)

					tween(toggle, {
						BackgroundColor3 = state
							and Color3.fromRGB(28, 28, 28)
							or Bloxium.Theme.Background
					}, 0.15)

					if fire then
						callback(options.Callback, state)
					end
				end

				function object:SetValue(value, fire)
					state = value == true
					update(fire ~= false)
				end

				function object:GetValue()
					return state
				end

				connect(connections, toggle.Activated, function()
					state = not state
					update(true)
				end)

				update(false)

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			function Section:CreateSlider(options)
				options = options or {}

				local minimum = tonumber(options.Min) or 0
				local maximum = tonumber(options.Max) or 100

				if maximum < minimum then
					minimum, maximum = maximum, minimum
				end

				local value = tonumber(options.Default)

				if value == nil then
					value = minimum
				end

				value = math.clamp(value, minimum, maximum)

				local precision = tonumber(options.Precision) or 0

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 50)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements

				corner(frame, 6)

				local nameLabel = label(frame, {
					Size = UDim2.new(1, -80, 0, 27),
					Position = UDim2.fromOffset(12, 1),
					Text = string.upper(tostring(options.Name or "SLIDER")),
					TextColor3 = Bloxium.Theme.Text,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local valueLabel = label(frame, {
					Size = UDim2.fromOffset(60, 27),
					Position = UDim2.new(1, -72, 0, 1),
					TextColor3 = Bloxium.Theme.TextMuted,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Right,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local track = Instance.new("TextButton")
				track.Size = UDim2.new(1, -24, 0, 4)
				track.Position = UDim2.fromOffset(12, 35)
				track.BackgroundColor3 = Bloxium.Theme.Background
				track.BorderSizePixel = 0
				track.Text = ""
				track.AutoButtonColor = false
				track.Parent = frame

				corner(track, 4)

				local fill = Instance.new("Frame")
				fill.Size = UDim2.new(0, 0, 1, 0)
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

				local connections = {}
				local draggingSlider = false

				local function format(valueToFormat)
					if precision <= 0 then
						return tostring(math.round(valueToFormat))
					end

					local multiplier = 10 ^ precision
					local rounded = math.round(valueToFormat * multiplier) / multiplier

					return tostring(rounded)
				end

				local function updateVisual()
					local range = maximum - minimum
					local scale = 0

					if range > 0 then
						scale = (value - minimum) / range
					end

					fill.Size = UDim2.new(scale, 0, 1, 0)
					knob.Position = UDim2.new(scale, -5, 0.5, -5)
					valueLabel.Text = format(value)
				end

				local function setFromInput(input)
					local width = track.AbsoluteSize.X

					if width <= 0 then
						return
					end

					local scale = math.clamp(
						(input.Position.X - track.AbsolutePosition.X) / width,
						0,
						1
					)

					local newValue = minimum + ((maximum - minimum) * scale)

					if precision <= 0 then
						newValue = math.round(newValue)
					else
						local multiplier = 10 ^ precision
						newValue = math.round(newValue * multiplier) / multiplier
					end

					value = math.clamp(newValue, minimum, maximum)

					updateVisual()
					callback(options.Callback, value)
				end

				local object = {
					Frame = frame,
					Track = track,
					Connections = connections
				}

				function object:SetValue(newValue, fire)
					newValue = tonumber(newValue)

					if not newValue then
						return
					end

					value = math.clamp(newValue, minimum, maximum)
					updateVisual()

					if fire ~= false then
						callback(options.Callback, value)
					end
				end

				function object:GetValue()
					return value
				end

				connect(connections, track.InputBegan, function(input)
					if not activate(input) then
						return
					end

					draggingSlider = true
					setFromInput(input)
				end)

				connect(connections, UserInputService.InputChanged, function(input)
					if not draggingSlider then
						return
					end

					if input.UserInputType ~= Enum.UserInputType.MouseMovement
						and input.UserInputType ~= Enum.UserInputType.Touch then
						return
					end

					setFromInput(input)
				end)

				connect(connections, UserInputService.InputEnded, function(input)
					if activate(input) then
						draggingSlider = false
					end
				end)

				updateVisual()

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			function Section:CreateDropdown(options)
				options = options or {}

				local values = {}

				for _, option in ipairs(options.Options or {}) do
					table.insert(values, option)
				end

				local selected = options.Default

				if selected == nil then
					selected = values[1]
				end

				local open = false
				local connections = {}

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 36)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.ClipsDescendants = true
				frame.Parent = elements

				corner(frame, 6)

				local nameLabel = label(frame, {
					Size = UDim2.new(0.42, 0, 0, 36),
					Position = UDim2.fromOffset(12, 0),
					Text = string.upper(tostring(options.Name or "DROPDOWN")),
					TextColor3 = Bloxium.Theme.Text,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local openButton = Instance.new("TextButton")
				openButton.Size = UDim2.new(0.47, 0, 0, 26)
				openButton.Position = UDim2.new(0.5, 0, 0, 5)
				openButton.BackgroundColor3 = Bloxium.Theme.Background
				openButton.BorderSizePixel = 0
				openButton.Text = tostring(selected or "")
				openButton.TextColor3 = Bloxium.Theme.TextMuted
				openButton.Font = Bloxium.Theme.FontMedium
				openButton.TextSize = 10
				openButton.TextXAlignment = Enum.TextXAlignment.Left
				openButton.AutoButtonColor = false
				openButton.Parent = frame

				corner(openButton, 5)
				padding(openButton, 9, 25, 0, 0)

				local arrow = label(openButton, {
					Size = UDim2.fromOffset(20, 26),
					Position = UDim2.new(1, -22, 0, 0),
					Text = "v",
					TextColor3 = Bloxium.Theme.TextMuted,
					Font = Bloxium.Theme.FontBold,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local optionContainer = Instance.new("Frame")
				optionContainer.Size = UDim2.new(1, -24, 0, 0)
				optionContainer.Position = UDim2.fromOffset(12, 42)
				optionContainer.BackgroundTransparency = 1
				optionContainer.Parent = frame

				local optionLayout = Instance.new("UIListLayout")
				optionLayout.Padding = UDim.new(0, 4)
				optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
				optionLayout.Parent = optionContainer

				local function refresh()
					local target = open and (44 + (#values * 28)) or 36

					tween(frame, {
						Size = UDim2.new(1, 0, 0, target)
					}, 0.15)
				end

				local object = {
					Frame = frame,
					Button = openButton,
					Connections = connections
				}

				function object:SetValue(value, fire)
					selected = value
					openButton.Text = tostring(selected or "")

					if fire ~= false then
						callback(options.Callback, selected)
					end
				end

				function object:GetValue()
					return selected
				end

				function object:SetOptions(newOptions)
					values = {}

					for _, option in ipairs(newOptions or {}) do
						table.insert(values, option)
					end

					for _, child in ipairs(optionContainer:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end

					for _, option in ipairs(values) do
						local optionButton = Instance.new("TextButton")
						optionButton.Size = UDim2.new(1, 0, 0, 24)
						optionButton.BackgroundColor3 = Bloxium.Theme.Background
						optionButton.BorderSizePixel = 0
						optionButton.Text = tostring(option)
						optionButton.TextColor3 = Bloxium.Theme.Text
						optionButton.Font = Bloxium.Theme.FontMedium
						optionButton.TextSize = 10
						optionButton.TextXAlignment = Enum.TextXAlignment.Left
						optionButton.AutoButtonColor = false
						optionButton.Parent = optionContainer

						corner(optionButton, 5)
						padding(optionButton, 9, 0, 0, 0)

						connect(connections, optionButton.MouseEnter, function()
							tween(optionButton, {
								BackgroundColor3 = Bloxium.Theme.ElementHover
							}, 0.1)
						end)

						connect(connections, optionButton.MouseLeave, function()
							tween(optionButton, {
								BackgroundColor3 = Bloxium.Theme.Background
							}, 0.1)
						end)

						connect(connections, optionButton.Activated, function()
							selected = option
							open = false
							arrow.Text = "v"
							openButton.Text = tostring(selected)

							refresh()
							callback(options.Callback, selected)
						end)
					end
				end

				connect(connections, openButton.Activated, function()
					open = not open
					arrow.Text = open and "^" or "v"
					refresh()
				end)

				object:SetOptions(values)

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			function Section:CreateTextInput(options)
				options = options or {}

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 36)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements

				corner(frame, 6)

				local nameLabel = label(frame, {
					Size = UDim2.new(0.42, 0, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					Text = string.upper(tostring(options.Name or "INPUT")),
					TextColor3 = Bloxium.Theme.Text,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local box = Instance.new("TextBox")
				box.Size = UDim2.new(0.5, 0, 0, 26)
				box.Position = UDim2.new(0.47, 0, 0.5, -13)
				box.BackgroundColor3 = Bloxium.Theme.Background
				box.BorderSizePixel = 0
				box.Text = tostring(options.Default or "")
				box.PlaceholderText = tostring(options.Placeholder or "Enter value...")
				box.TextColor3 = Bloxium.Theme.Text
				box.PlaceholderColor3 = Bloxium.Theme.TextDim
				box.Font = Bloxium.Theme.FontMedium
				box.TextSize = 10
				box.ClearTextOnFocus = false
				box.Parent = frame

				corner(box, 5)
				padding(box, 8, 8, 0, 0)

				local connections = {}

				connect(connections, box.Focused, function()
					tween(box, {
						BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					}, 0.1)
				end)

				connect(connections, box.FocusLost, function(enterPressed)
					tween(box, {
						BackgroundColor3 = Bloxium.Theme.Background
					}, 0.1)

					callback(
						options.Callback,
						box.Text,
						enterPressed
					)
				end)

				local object = {
					Frame = frame,
					TextBox = box,
					Connections = connections
				}

				function object:SetValue(value, fire)
					box.Text = tostring(value or "")

					if fire then
						callback(
							options.Callback,
							box.Text,
							false
						)
					end
				end

				function object:GetValue()
					return box.Text
				end

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			function Section:CreateKeybind(options)
				options = options or {}

				local currentKey = options.Default or Enum.KeyCode.E
				local listening = false
				local connections = {}

				local frame = Instance.new("Frame")
				frame.Size = UDim2.new(1, 0, 0, 36)
				frame.BackgroundColor3 = Bloxium.Theme.Element
				frame.BorderSizePixel = 0
				frame.Parent = elements

				corner(frame, 6)

				local nameLabel = label(frame, {
					Size = UDim2.new(1, -115, 1, 0),
					Position = UDim2.fromOffset(12, 0),
					Text = string.upper(tostring(options.Name or "KEYBIND")),
					TextColor3 = Bloxium.Theme.Text,
					Font = Bloxium.Theme.FontMedium,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})

				local bindButton = Instance.new("TextButton")
				bindButton.Size = UDim2.fromOffset(85, 26)
				bindButton.Position = UDim2.new(1, -97, 0.5, -13)
				bindButton.BackgroundColor3 = Bloxium.Theme.Background
				bindButton.BorderSizePixel = 0
				bindButton.TextColor3 = Bloxium.Theme.TextMuted
				bindButton.Font = Bloxium.Theme.FontMedium
				bindButton.TextSize = 10
				bindButton.AutoButtonColor = false
				bindButton.Parent = frame

				corner(bindButton, 5)

				local function keyName(key)
					if typeof(key) == "EnumItem" then
						return string.upper(key.Name)
					end

					return "NONE"
				end

				local function update()
					if listening then
						bindButton.Text = "PRESS KEY"
						bindButton.TextColor3 = Bloxium.Theme.Accent
						bindButton.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
					else
						bindButton.Text = keyName(currentKey)
						bindButton.TextColor3 = Bloxium.Theme.TextMuted
						bindButton.BackgroundColor3 = Bloxium.Theme.Background
					end
				end

				local object = {
					Frame = frame,
					Button = bindButton,
					Connections = connections
				}

				function object:SetKey(key)
					if typeof(key) ~= "EnumItem" then
						return
					end

					currentKey = key
					listening = false
					update()
				end

				function object:GetKey()
					return currentKey
				end

				function object:StartListening()
					listening = true
					update()
				end

				function object:Cancel()
					listening = false
					update()
				end

				connect(connections, bindButton.Activated, function()
					object:StartListening()
				end)

				connect(connections, bindButton.MouseEnter, function()
					if listening then
						return
					end

					tween(bindButton, {
						BackgroundColor3 = Bloxium.Theme.ElementHover,
						TextColor3 = Bloxium.Theme.Text
					}, 0.1)
				end)

				connect(connections, bindButton.MouseLeave, function()
					if listening then
						return
					end

					tween(bindButton, {
						BackgroundColor3 = Bloxium.Theme.Background,
						TextColor3 = Bloxium.Theme.TextMuted
					}, 0.1)
				end)

				connect(connections, UserInputService.InputBegan, function(input, processed)
					if listening then
						if input.UserInputType ~= Enum.UserInputType.Keyboard then
							return
						end

						if input.KeyCode == Enum.KeyCode.Escape then
							listening = false
							update()
							return
						end

						currentKey = input.KeyCode
						listening = false
						update()
						return
					end

					if processed then
						return
					end

					if input.UserInputType == Enum.UserInputType.Keyboard
						and input.KeyCode == currentKey then
						callback(options.Callback, currentKey)
					end
				end)

				update()

				function object:Destroy()
					disconnect(connections)
					frame:Destroy()
				end

				return self:_add(object)
			end

			table.insert(Tab.Sections, Section)

			return Section
		end

		table.insert(Window.Tabs, Tab)

		if #Window.Tabs == 1 then
			Tab:Select()
		end

		return Tab
	end

	return Window
end

return Bloxium
