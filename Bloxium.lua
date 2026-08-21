--[[
    BLOXIUM UI LIBRARY
    Cleaned / Reworked Edition

    Example:

    local Bloxium = require(path.To.Bloxium)

    local Window = Bloxium:CreateWindow({
        Title = "BLOXIUM",
        Subtitle = "CONTROL PANEL",
        Size = UDim2.fromOffset(650, 430),
    })

    local Main = Window:CreateTab("Main")

    local General = Main:CreateSection("General")

    General:CreateButton({
        Name = "Execute",
        Callback = function()
            print("Executed")
        end
    })

    General:CreateToggle({
        Name = "Enabled",
        Default = false,
        Callback = function(value)
            print("Enabled:", value)
        end
    })

    General:CreateSlider({
        Name = "Power",
        Min = 0,
        Max = 100,
        Default = 50,
        Callback = function(value)
            print("Power:", value)
        end
    })

    General:CreateDropdown({
        Name = "Mode",
        Options = {"Normal", "Fast", "Safe"},
        Default = "Normal",
        Callback = function(value)
            print("Mode:", value)
        end
    })

    General:CreateTextInput({
        Name = "Username",
        Placeholder = "Enter username...",
        Callback = function(text, enterPressed)
            print(text, enterPressed)
        end
    })

    General:CreateKeybind({
        Name = "Toggle",
        Default = Enum.KeyCode.RightShift,
        Callback = function(key)
            print("Pressed:", key.Name)
        end
    })

    Window:Notify({
        Title = "READY",
        Description = "Bloxium initialized.",
        Duration = 3
    })
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    error("Bloxium must be loaded from a LocalScript.")
end

local Bloxium = {}

Bloxium.Version = "2.0.0"

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
    Success = Color3.fromRGB(90, 210, 130),

    Font = Enum.Font.Gotham,
    FontMedium = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
}

Bloxium.Defaults = {
    Title = "BLOXIUM",
    Subtitle = "",
    Size = UDim2.fromOffset(650, 430),
    MinimumSize = Vector2.new(450, 300),
}

---------------------------------------------------------------------
-- UTILITIES
---------------------------------------------------------------------

local function clampNumber(value, minValue, maxValue)
    if typeof(value) ~= "number" then
        value = minValue
    end

    return math.clamp(value, minValue, maxValue)
end

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

local function addPadding(instance, left, right, top, bottom)
    local padding = Instance.new("UIPadding")

    padding.PaddingLeft = UDim.new(0, left or 0)
    padding.PaddingRight = UDim.new(0, right or 0)
    padding.PaddingTop = UDim.new(0, top or 0)
    padding.PaddingBottom = UDim.new(0, bottom or 0)

    padding.Parent = instance

    return padding
end

local function tween(instance, properties, duration, style, direction)
    if not instance or not instance.Parent then
        return nil
    end

    local info = TweenInfo.new(
        duration or 0.15,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    local object = TweenService:Create(instance, info, properties)
    object:Play()

    return object
end

local function connect(signal, callback, connectionList)
    local connection = signal:Connect(callback)

    if connectionList then
        table.insert(connectionList, connection)
    end

    return connection
end

local function disconnectAll(connectionList)
    for i = #connectionList, 1, -1 do
        local connection = connectionList[i]

        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end

        connectionList[i] = nil
    end
end

local function isActivationInput(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end

local function safeCallback(callback, ...)
    if typeof(callback) ~= "function" then
        return
    end

    task.spawn(function()
        local success, err = xpcall(
            function()
                callback(...)
            end,
            debug.traceback
        )

        if not success then
            warn("[Bloxium] Callback error:\n" .. tostring(err))
        end
    end)
end

local function makeTextLabel(parent, properties)
    local label = Instance.new("TextLabel")

    for property, value in pairs(properties or {}) do
        label[property] = value
    end

    label.BackgroundTransparency = 1
    label.Parent = parent

    return label
end

local function getGuiParent(customParent)
    if customParent and customParent:IsA("GuiBase2d") then
        return customParent
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    if not playerGui then
        playerGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    return playerGui
end

---------------------------------------------------------------------
-- WINDOW
---------------------------------------------------------------------

function Bloxium:CreateWindow(config)
    config = config or {}

    local Window = {
        Tabs = {},
        ActiveTab = nil,

        _connections = {},
        _destroyed = false,
        _minimized = false,

        _normalSize = config.Size or self.Defaults.Size,
        _minimumSize = config.MinimumSize or self.Defaults.MinimumSize,
    }

    local windowTitle = tostring(config.Title or self.Defaults.Title)
    local windowSubtitle = tostring(config.Subtitle or "")

    -----------------------------------------------------------------
    -- SCREEN GUI
    -----------------------------------------------------------------

    local screenGui = Instance.new("ScreenGui")

    screenGui.Name = config.Name or "Bloxium"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = config.DisplayOrder or 100

    pcall(function()
        screenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
    end)

    screenGui.Parent = getGuiParent(config.Parent)

    Window.ScreenGui = screenGui

    -----------------------------------------------------------------
    -- SCALE
    -----------------------------------------------------------------

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = config.Scale or 1
    uiScale.Parent = screenGui

    Window.UIScale = uiScale

    -----------------------------------------------------------------
    -- MAIN FRAME
    -----------------------------------------------------------------

    local mainFrame = Instance.new("Frame")

    mainFrame.Name = "MainFrame"
    mainFrame.Size = Window._normalSize
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.BackgroundColor3 = Bloxium.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true

    mainFrame.Parent = screenGui

    addCorner(mainFrame, 10)
    addStroke(mainFrame, Bloxium.Theme.Border, 1, 0)

    Window.MainFrame = mainFrame

    -----------------------------------------------------------------
    -- TOP BAR
    -----------------------------------------------------------------

    local topBar = Instance.new("Frame")

    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = Bloxium.Theme.TopBar
    topBar.BorderSizePixel = 0
    topBar.Active = true
    topBar.Parent = mainFrame

    addCorner(topBar, 10)

    local topPatch = Instance.new("Frame")

    topPatch.Size = UDim2.new(1, 0, 0, 10)
    topPatch.Position = UDim2.new(0, 0, 1, -10)
    topPatch.BackgroundColor3 = Bloxium.Theme.TopBar
    topPatch.BorderSizePixel = 0
    topPatch.Parent = topBar

    local topDivider = Instance.new("Frame")

    topDivider.Size = UDim2.new(1, -32, 0, 1)
    topDivider.Position = UDim2.new(0, 16, 1, -1)
    topDivider.BackgroundColor3 = Bloxium.Theme.Border
    topDivider.BorderSizePixel = 0
    topDivider.Parent = topBar

    -----------------------------------------------------------------
    -- TITLE
    -----------------------------------------------------------------

    local titleLabel = makeTextLabel(topBar, {
        Name = "Title",

        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.fromOffset(16, 0),

        TextColor3 = Bloxium.Theme.Text,
        Font = Bloxium.Theme.FontBold,
        TextSize = 12,

        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,

        RichText = true,
    })

    local function updateTitle()
        local text = string.upper(windowTitle)

        if windowSubtitle ~= "" then
            text = text
                .. "  <font color='#707070'>"
                .. string.upper(windowSubtitle)
                .. "</font>"
        end

        titleLabel.Text = text
    end

    updateTitle()

    Window.TitleLabel = titleLabel

    -----------------------------------------------------------------
    -- TOP BAR BUTTON CREATOR
    -----------------------------------------------------------------

    local function createTopButton(name, text, position)
        local button = Instance.new("TextButton")

        button.Name = name
        button.Size = UDim2.fromOffset(30, 30)
        button.Position = position

        button.BackgroundColor3 = Bloxium.Theme.Element
        button.BackgroundTransparency = 1

        button.Text = text
        button.TextColor3 = Bloxium.Theme.TextMuted

        button.Font = Bloxium.Theme.Font
        button.TextSize = 18

        button.AutoButtonColor = false

        button.Parent = topBar

        addCorner(button, 6)

        return button
    end

    local minimizeButton = createTopButton(
        "Minimize",
        "−",
        UDim2.new(1, -72, 0, 6)
    )

    local closeButton = createTopButton(
        "Close",
        "×",
        UDim2.new(1, -38, 0, 6)
    )

    connect(minimizeButton.MouseEnter, function()
        if Window._destroyed then
            return
        end

        tween(minimizeButton, {
            BackgroundTransparency = 0,
            TextColor3 = Bloxium.Theme.Text,
        }, 0.12)
    end, Window._connections)

    connect(minimizeButton.MouseLeave, function()
        if Window._destroyed then
            return
        end

        tween(minimizeButton, {
            BackgroundTransparency = 1,
            TextColor3 = Bloxium.Theme.TextMuted,
        }, 0.12)
    end, Window._connections)

    connect(closeButton.MouseEnter, function()
        if Window._destroyed then
            return
        end

        tween(closeButton, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(55, 20, 20),
            TextColor3 = Bloxium.Theme.Danger,
        }, 0.12)
    end, Window._connections)

    connect(closeButton.MouseLeave, function()
        if Window._destroyed then
            return
        end

        tween(closeButton, {
            BackgroundTransparency = 1,
            TextColor3 = Bloxium.Theme.TextMuted,
        }, 0.12)
    end, Window._connections)

    -----------------------------------------------------------------
    -- MINIMIZE
    -----------------------------------------------------------------

    function Window:SetMinimized(state)
        if Window._destroyed then
            return
        end

        state = state == true

        if Window._minimized == state then
            return
        end

        Window._minimized = state

        if state then
            Window._normalSize = mainFrame.Size

            tween(
                mainFrame,
                {
                    Size = UDim2.new(
                        Window._normalSize.X.Scale,
                        Window._normalSize.X.Offset,
                        0,
                        42
                    )
                },
                0.2,
                Enum.EasingStyle.Quart
            )

            minimizeButton.Text = "+"
        else
            tween(
                mainFrame,
                {
                    Size = Window._normalSize
                },
                0.2,
                Enum.EasingStyle.Quart
            )

            minimizeButton.Text = "−"
        end
    end

    connect(minimizeButton.Activated, function()
        Window:SetMinimized(not Window._minimized)
    end, Window._connections)

    connect(closeButton.Activated, function()
        Window:Destroy()
    end, Window._connections)

    -----------------------------------------------------------------
    -- SIDEBAR
    -----------------------------------------------------------------

    local sidebar = Instance.new("Frame")

    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 158, 1, -42)
    sidebar.Position = UDim2.fromOffset(0, 42)

    sidebar.BackgroundColor3 = Bloxium.Theme.Sidebar
    sidebar.BorderSizePixel = 0

    sidebar.Parent = mainFrame

    addCorner(sidebar, 10)

    local sidebarTopPatch = Instance.new("Frame")

    sidebarTopPatch.Size = UDim2.new(1, 0, 0, 10)
    sidebarTopPatch.BackgroundColor3 = Bloxium.Theme.Sidebar
    sidebarTopPatch.BorderSizePixel = 0
    sidebarTopPatch.Parent = sidebar

    local sidebarRightPatch = Instance.new("Frame")

    sidebarRightPatch.Size = UDim2.fromOffset(10, 42)
    sidebarRightPatch.Position = UDim2.new(1, -10, 0, 0)
    sidebarRightPatch.BackgroundColor3 = Bloxium.Theme.Sidebar
    sidebarRightPatch.BorderSizePixel = 0
    sidebarRightPatch.Parent = sidebar

    local tabContainer = Instance.new("ScrollingFrame")

    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, 0)

    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0

    tabContainer.ScrollBarThickness = 2
    tabContainer.ScrollBarImageColor3 = Bloxium.Theme.BorderLight

    tabContainer.CanvasSize = UDim2.fromOffset(0, 0)

    tabContainer.Parent = sidebar

    addPadding(tabContainer, 10, 10, 12, 10)

    local tabLayout = Instance.new("UIListLayout")

    tabLayout.Padding = UDim.new(0, 5)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    tabLayout.Parent = tabContainer

    connect(
        tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"),
        function()
            tabContainer.CanvasSize = UDim2.fromOffset(
                0,
                tabLayout.AbsoluteContentSize.Y + 20
            )
        end,
        Window._connections
    )

    -----------------------------------------------------------------
    -- SIDEBAR DIVIDER
    -----------------------------------------------------------------

    local sidebarDivider = Instance.new("Frame")

    sidebarDivider.Size = UDim2.new(0, 1, 1, -42)
    sidebarDivider.Position = UDim2.new(0, 157, 0, 42)

    sidebarDivider.BackgroundColor3 = Bloxium.Theme.Border
    sidebarDivider.BorderSizePixel = 0

    sidebarDivider.Parent = mainFrame

    -----------------------------------------------------------------
    -- CONTENT
    -----------------------------------------------------------------

    local contentArea = Instance.new("Frame")

    contentArea.Name = "ContentArea"

    contentArea.Size = UDim2.new(1, -178, 1, -52)
    contentArea.Position = UDim2.fromOffset(169, 42)

    contentArea.BackgroundTransparency = 1

    contentArea.Parent = mainFrame

    Window.ContentArea = contentArea

    -----------------------------------------------------------------
    -- DRAGGING
    -----------------------------------------------------------------

    local dragging = false
    local dragStart
    local dragStartPosition

    local function beginDrag(input)
        if Window._destroyed or Window._minimized then
            -- Minimized windows can still be dragged.
            -- This condition is intentionally not used to block dragging.
        end

        dragging = true
        dragStart = input.Position
        dragStartPosition = mainFrame.Position
    end

    connect(topBar.InputBegan, function(input)
        if not isActivationInput(input) then
            return
        end

        beginDrag(input)
    end, Window._connections)

    connect(UserInputService.InputChanged, function(input)
        if not dragging then
            return
        end

        if input.UserInputType ~= Enum.UserInputType.MouseMovement
            and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta = input.Position - dragStart

        mainFrame.Position = UDim2.new(
            dragStartPosition.X.Scale,
            dragStartPosition.X.Offset + delta.X,
            dragStartPosition.Y.Scale,
            dragStartPosition.Y.Offset + delta.Y
        )
    end, Window._connections)

    connect(UserInputService.InputEnded, function(input)
        if isActivationInput(input) then
            dragging = false
        end
    end, Window._connections)

    -----------------------------------------------------------------
    -- WINDOW API
    -----------------------------------------------------------------

    function Window:SetTitle(title, subtitle)
        if Window._destroyed then
            return
        end

        windowTitle = tostring(title or windowTitle)

        if subtitle ~= nil then
            windowSubtitle = tostring(subtitle)
        end

        updateTitle()
    end

    function Window:SetVisible(state)
        if Window._destroyed then
            return
        end

        screenGui.Enabled = state == true
    end

    function Window:IsVisible()
        if Window._destroyed then
            return false
        end

        return screenGui.Enabled
    end

    function Window:SetPosition(position)
        if Window._destroyed then
            return
        end

        if typeof(position) == "UDim2" then
            mainFrame.Position = position
        end
    end

    function Window:SetSize(size)
        if Window._destroyed then
            return
        end

        if typeof(size) ~= "UDim2" then
            return
        end

        Window._normalSize = size

        if not Window._minimized then
            mainFrame.Size = size
        end
    end

    function Window:SelectTab(tab)
        if Window._destroyed or not tab then
            return
        end

        if tab._select then
            tab:_select()
        end
    end

    -----------------------------------------------------------------
    -- NOTIFICATIONS
    -----------------------------------------------------------------

    local notificationHost = Instance.new("Frame")

    notificationHost.Name = "NotificationHost"

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
        if Window._destroyed then
            return
        end

        options = options or {}

        local titleText = string.upper(
            tostring(options.Title or "SYSTEM ALERT")
        )

        local descriptionText = tostring(
            options.Description or ""
        )

        local duration = tonumber(options.Duration) or 3

        duration = math.max(duration, 0.25)

        local toast = Instance.new("Frame")

        toast.Name = "Notification"

        toast.Size = UDim2.fromOffset(280, 66)

        toast.BackgroundColor3 = Bloxium.Theme.Element
        toast.BackgroundTransparency = 1

        toast.BorderSizePixel = 0

        toast.Parent = notificationHost

        addCorner(toast, 8)

        local toastStroke = addStroke(
            toast,
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

        accent.Parent = toast

        addCorner(accent, 3)

        local title = makeTextLabel(toast, {
            Size = UDim2.new(1, -38, 0, 20),
            Position = UDim2.fromOffset(20, 8),

            Text = titleText,

            TextColor3 = Bloxium.Theme.Text,
            Font = Bloxium.Theme.FontBold,
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Left,

            TextTransparency = 1,
        })

        local description = makeTextLabel(toast, {
            Size = UDim2.new(1, -38, 0, 28),
            Position = UDim2.fromOffset(20, 29),

            Text = descriptionText,

            TextColor3 = Bloxium.Theme.TextMuted,
            Font = Bloxium.Theme.FontMedium,
            TextSize = 10,

            TextWrapped = true,

            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,

            TextTransparency = 1,
        })

        tween(toast, {
            BackgroundTransparency = 0
        }, 0.2)

        tween(toastStroke, {
            Transparency = 0
        }, 0.2)

        tween(accent, {
            BackgroundTransparency = 0
        }, 0.2)

        tween(title, {
            TextTransparency = 0
        }, 0.2)

        tween(description, {
            TextTransparency = 0
        }, 0.2)

        task.delay(duration, function()
            if not toast.Parent then
                return
            end

            tween(toast, {
                BackgroundTransparency = 1
            }, 0.2)

            tween(toastStroke, {
                Transparency = 1
            }, 0.2)

            tween(accent, {
                BackgroundTransparency = 1
            }, 0.2)

            tween(title, {
                TextTransparency = 1
            }, 0.2)

            local fade = tween(description, {
                TextTransparency = 1
            }, 0.2)

            if fade then
                fade.Completed:Wait()
            end

            if toast then
                toast:Destroy()
            end
        end)
    end

    -----------------------------------------------------------------
    -- DESTROY
    -----------------------------------------------------------------

    function Window:Destroy()
        if Window._destroyed then
            return
        end

        Window._destroyed = true

        disconnectAll(Window._connections)

        for _, tab in ipairs(Window.Tabs) do
            if tab._connections then
                disconnectAll(tab._connections)
            end
        end

        if screenGui then
            screenGui:Destroy()
        end

        table.clear(Window.Tabs)
        Window.ActiveTab = nil
    end

    -----------------------------------------------------------------
    -- TAB
    -----------------------------------------------------------------

    function Window:CreateTab(name)
        if Window._destroyed then
            return nil
        end

        local Tab = {
            Name = tostring(name or "TAB"),
            Sections = {},
            _connections = {},
        }

        -----------------------------------------------------------------
        -- TAB BUTTON
        -----------------------------------------------------------------

        local tabButton = Instance.new("TextButton")

        tabButton.Name = "TabButton"

        tabButton.Size = UDim2.new(1, 0, 0, 34)

        tabButton.BackgroundColor3 = Bloxium.Theme.Element
        tabButton.BackgroundTransparency = 1

        tabButton.BorderSizePixel = 0

        tabButton.Text = ""

        tabButton.AutoButtonColor = false

        tabButton.Parent = tabContainer

        addCorner(tabButton, 7)

        local indicator = Instance.new("Frame")

        indicator.Size = UDim2.fromOffset(3, 16)
        indicator.Position = UDim2.new(0, 8, 0.5, -8)

        indicator.BackgroundColor3 = Bloxium.Theme.Accent
        indicator.BackgroundTransparency = 1

        indicator.BorderSizePixel = 0

        indicator.Parent = tabButton

        addCorner(indicator, 2)

        local tabText = makeTextLabel(tabButton, {
            Size = UDim2.new(1, -30, 1, 0),
            Position = UDim2.fromOffset(24, 0),

            Text = string.upper(Tab.Name),

            TextColor3 = Bloxium.Theme.TextMuted,
            Font = Bloxium.Theme.FontMedium,
            TextSize = 11,

            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        })

        -----------------------------------------------------------------
        -- PAGE
        -----------------------------------------------------------------

        local page = Instance.new("ScrollingFrame")

        page.Name = Tab.Name .. "Page"

        page.Size = UDim2.fromScale(1, 1)

        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0

        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Bloxium.Theme.BorderLight

        page.CanvasSize = UDim2.fromOffset(0, 0)

        page.Visible = false

        page.Parent = contentArea

        addPadding(page, 0, 6, 0, 12)

        local pageLayout = Instance.new("UIListLayout")

        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        pageLayout.Parent = page

        connect(
            pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"),
            function()
                if page.Parent then
                    page.CanvasSize = UDim2.fromOffset(
                        0,
                        pageLayout.AbsoluteContentSize.Y + 15
                    )
                end
            end,
            Tab._connections
        )

        -----------------------------------------------------------------
        -- SELECT TAB
        -----------------------------------------------------------------

        function Tab:_select()
            if Window._destroyed then
                return
            end

            for _, otherTab in ipairs(Window.Tabs) do
                otherTab.Page.Visible = false

                tween(otherTab.Button, {
                    BackgroundTransparency = 1
                }, 0.12)

                tween(otherTab.Text, {
                    TextColor3 = Bloxium.Theme.TextMuted
                }, 0.12)

                tween(otherTab.Indicator, {
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

        connect(tabButton.Activated, function()
            Tab:_select()
        end, Tab._connections)

        connect(tabButton.MouseEnter, function()
            if Window.ActiveTab == Tab then
                return
            end

            tween(tabButton, {
                BackgroundTransparency = 0.72
            }, 0.1)

            tween(tabText, {
                TextColor3 = Bloxium.Theme.Text
            }, 0.1)
        end, Tab._connections)

        connect(tabButton.MouseLeave, function()
            if Window.ActiveTab == Tab then
                return
            end

            tween(tabButton, {
                BackgroundTransparency = 1
            }, 0.1)

            tween(tabText, {
                TextColor3 = Bloxium.Theme.TextMuted
            }, 0.1)
        end, Tab._connections)

        Tab.Button = tabButton
        Tab.Text = tabText
        Tab.Indicator = indicator
        Tab.Page = page

        table.insert(Window.Tabs, Tab)

        -----------------------------------------------------------------
        -- SECTION
        -----------------------------------------------------------------

        function Tab:CreateSection(sectionName)
            if Window._destroyed then
                return nil
            end

            local Section = {
                Name = tostring(sectionName or "SECTION"),
                Elements = {},
            }

            local sectionFrame = Instance.new("Frame")

            sectionFrame.Name = "Section"

            sectionFrame.Size = UDim2.new(1, 0, 0, 30)

            sectionFrame.BackgroundTransparency = 1

            sectionFrame.BorderSizePixel = 0

            sectionFrame.Parent = page

            local sectionTitle = makeTextLabel(sectionFrame, {
                Size = UDim2.new(0, 140, 1, 0),
                Position = UDim2.fromOffset(2, 0),

                Text = string.upper(Section.Name),

                TextColor3 = Bloxium.Theme.TextMuted,
                Font = Bloxium.Theme.FontBold,
                TextSize = 10,

                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
            })

            local line = Instance.new("Frame")

            line.Size = UDim2.new(1, -150, 0, 1)
            line.Position = UDim2.new(0, 150, 0.5, 0)

            line.BackgroundColor3 = Bloxium.Theme.Border

            line.BorderSizePixel = 0

            line.Parent = sectionFrame

            Section.Frame = sectionFrame

            -----------------------------------------------------------------
            -- GENERIC ELEMENT ROUTING
            -----------------------------------------------------------------

            function Section:_add(element)
                table.insert(Section.Elements, element)
                return element
            end

            -----------------------------------------------------------------
            -- BUTTON
            -----------------------------------------------------------------

            function Section:CreateButton(options)
                options = options or {}

                local buttonFrame = Instance.new("Frame")

                buttonFrame.Size = UDim2.new(1, 0, 0, 34)

                buttonFrame.BackgroundColor3 = Bloxium.Theme.Element
                buttonFrame.BorderSizePixel = 0

                buttonFrame.Parent = page

                addCorner(buttonFrame, 6)

                local stroke = addStroke(
                    buttonFrame,
                    Bloxium.Theme.Border,
                    1,
                    0.35
                )

                local button = Instance.new("TextButton")

                button.Size = UDim2.fromScale(1, 1)

                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0

                button.Text = string.upper(
                    tostring(options.Name or "EXECUTE")
                )

                button.TextColor3 = Bloxium.Theme.Text

                button.Font = Bloxium.Theme.FontMedium
                button.TextSize = 11

                button.TextXAlignment = Enum.TextXAlignment.Left

                button.AutoButtonColor = false

                button.Parent = buttonFrame

                addPadding(button, 12, 12, 0, 0)

                local connectionList = {}

                connect(button.MouseEnter, function()
                    tween(buttonFrame, {
                        BackgroundColor3 = Bloxium.Theme.ElementHover
                    }, 0.1)

                    tween(stroke, {
                        Transparency = 0
                    }, 0.1)
                end, connectionList)

                connect(button.MouseLeave, function()
                    tween(buttonFrame, {
                        BackgroundColor3 = Bloxium.Theme.Element
                    }, 0.1)

                    tween(stroke, {
                        Transparency = 0.35
                    }, 0.1)
                end, connectionList)

                connect(button.Activated, function()
                    tween(buttonFrame, {
                        BackgroundColor3 = Bloxium.Theme.Accent
                    }, 0.05)

                    task.delay(0.06, function()
                        if buttonFrame.Parent then
                            tween(buttonFrame, {
                                BackgroundColor3 = Bloxium.Theme.Element
                            }, 0.15)
                        end
                    end)

                    safeCallback(options.Callback)
                end, connectionList)

                local object = {
                    Frame = buttonFrame,
                    Button = button,
                    _connections = connectionList,
                }

                function object:SetText(text)
                    button.Text = string.upper(tostring(text))
                end

                function object:Destroy()
                    disconnectAll(connectionList)

                    if buttonFrame then
                        buttonFrame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- TOGGLE
            -----------------------------------------------------------------

            function Section:CreateToggle(options)
                options = options or {}

                local state = options.Default == true

                local frame = Instance.new("Frame")

                frame.Size = UDim2.new(1, 0, 0, 36)

                frame.BackgroundColor3 = Bloxium.Theme.Element
                frame.BorderSizePixel = 0

                frame.Parent = page

                addCorner(frame, 6)

                local label = makeTextLabel(frame, {
                    Size = UDim2.new(1, -75, 1, 0),
                    Position = UDim2.fromOffset(12, 0),

                    Text = string.upper(
                        tostring(options.Name or "TOGGLE")
                    ),

                    TextColor3 = Bloxium.Theme.Text,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local toggle = Instance.new("TextButton")

                toggle.Size = UDim2.fromOffset(42, 20)

                toggle.Position = UDim2.new(1, -54, 0.5, -10)

                toggle.BackgroundColor3 = Bloxium.Theme.Background

                toggle.BorderSizePixel = 0

                toggle.Text = ""

                toggle.AutoButtonColor = false

                toggle.Parent = frame

                addCorner(toggle, 10)

                addStroke(toggle, Bloxium.Theme.Border, 1, 0)

                local knob = Instance.new("Frame")

                knob.Size = UDim2.fromOffset(14, 14)

                knob.BorderSizePixel = 0

                knob.Parent = toggle

                addCorner(knob, 10)

                local connectionList = {}

                local object = {
                    Frame = frame,
                    Button = toggle,
                }

                function object:SetValue(value, fireCallback)
                    value = value == true

                    state = value

                    local targetPosition

                    if state then
                        targetPosition = UDim2.new(
                            1, -17,
                            0.5, -7
                        )
                    else
                        targetPosition = UDim2.new(
                            0, 3,
                            0.5, -7
                        )
                    end

                    tween(knob, {
                        Position = targetPosition,

                        BackgroundColor3 = state
                            and Bloxium.Theme.Accent
                            or Bloxium.Theme.BorderLight,
                    }, 0.15)

                    tween(toggle, {
                        BackgroundColor3 = state
                            and Color3.fromRGB(28, 28, 28)
                            or Bloxium.Theme.Background,
                    }, 0.15)

                    if fireCallback ~= false then
                        safeCallback(options.Callback, state)
                    end
                end

                function object:GetValue()
                    return state
                end

                connect(toggle.Activated, function()
                    object:SetValue(not state, true)
                end, connectionList)

                object._connections = connectionList

                object:SetValue(state, false)

                function object:Destroy()
                    disconnectAll(connectionList)

                    if frame then
                        frame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- SLIDER
            -----------------------------------------------------------------

            function Section:CreateSlider(options)
                options = options or {}

                local minValue = tonumber(options.Min) or 0
                local maxValue = tonumber(options.Max) or 100

                if maxValue < minValue then
                    minValue, maxValue = maxValue, minValue
                end

                local defaultValue = tonumber(options.Default)

                if defaultValue == nil then
                    defaultValue = minValue
                end

                defaultValue = clampNumber(
                    defaultValue,
                    minValue,
                    maxValue
                )

                local precision = tonumber(options.Precision) or 0

                local frame = Instance.new("Frame")

                frame.Size = UDim2.new(1, 0, 0, 50)

                frame.BackgroundColor3 = Bloxium.Theme.Element
                frame.BorderSizePixel = 0

                frame.Parent = page

                addCorner(frame, 6)

                local label = makeTextLabel(frame, {
                    Size = UDim2.new(1, -80, 0, 26),
                    Position = UDim2.fromOffset(12, 1),

                    Text = string.upper(
                        tostring(options.Name or "VALUE")
                    ),

                    TextColor3 = Bloxium.Theme.Text,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local valueLabel = makeTextLabel(frame, {
                    Size = UDim2.fromOffset(60, 26),
                    Position = UDim2.new(1, -72, 0, 1),

                    TextColor3 = Bloxium.Theme.TextMuted,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local track = Instance.new("TextButton")

                track.Size = UDim2.new(1, -24, 0, 5)

                track.Position = UDim2.fromOffset(12, 34)

                track.BackgroundColor3 = Bloxium.Theme.Background

                track.BorderSizePixel = 0

                track.Text = ""

                track.AutoButtonColor = false

                track.Parent = frame

                addCorner(track, 5)

                local fill = Instance.new("Frame")

                fill.Size = UDim2.fromScale(0, 1)

                fill.BackgroundColor3 = Bloxium.Theme.Accent

                fill.BorderSizePixel = 0

                fill.Parent = track

                addCorner(fill, 5)

                local knob = Instance.new("Frame")

                knob.Size = UDim2.fromOffset(10, 10)

                knob.AnchorPoint = Vector2.new(0.5, 0.5)

                knob.BackgroundColor3 = Bloxium.Theme.Accent

                knob.BorderSizePixel = 0

                knob.Parent = track

                addCorner(knob, 10)

                local connectionList = {}

                local value = defaultValue
                local draggingSlider = false

                local function formatValue(number)
                    if precision <= 0 then
                        return tostring(math.round(number))
                    end

                    return string.format(
                        "%." .. tostring(precision) .. "f",
                        number
                    )
                end

                local function updateVisual()
                    local range = maxValue - minValue

                    local scale = 0

                    if range > 0 then
                        scale = (value - minValue) / range
                    end

                    scale = math.clamp(scale, 0, 1)

                    fill.Size = UDim2.new(
                        scale,
                        0,
                        1,
                        0
                    )

                    knob.Position = UDim2.new(
                        scale,
                        0,
                        0.5,
                        0
                    )

                    valueLabel.Text = formatValue(value)
                end

                local function updateFromInput(input)
                    if track.AbsoluteSize.X <= 0 then
                        return
                    end

                    local scale = (
                        input.Position.X
                        - track.AbsolutePosition.X
                    ) / track.AbsoluteSize.X

                    scale = math.clamp(scale, 0, 1)

                    local newValue =
                        minValue
                        + ((maxValue - minValue) * scale)

                    if precision <= 0 then
                        newValue = math.round(newValue)
                    else
                        local multiplier = 10 ^ precision
                        newValue =
                            math.round(newValue * multiplier)
                            / multiplier
                    end

                    value = newValue

                    updateVisual()

                    safeCallback(
                        options.Callback,
                        value
                    )
                end

                local object = {
                    Frame = frame,
                    Track = track,
                }

                function object:SetValue(newValue, fireCallback)
                    newValue = tonumber(newValue)

                    if not newValue then
                        return
                    end

                    value = clampNumber(
                        newValue,
                        minValue,
                        maxValue
                    )

                    updateVisual()

                    if fireCallback ~= false then
                        safeCallback(
                            options.Callback,
                            value
                        )
                    end
                end

                function object:GetValue()
                    return value
                end

                connect(track.InputBegan, function(input)
                    if not isActivationInput(input) then
                        return
                    end

                    draggingSlider = true

                    updateFromInput(input)
                end, connectionList)

                connect(UserInputService.InputChanged, function(input)
                    if not draggingSlider then
                        return
                    end

                    if input.UserInputType ~= Enum.UserInputType.MouseMovement
                        and input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end

                    updateFromInput(input)
                end, connectionList)

                connect(UserInputService.InputEnded, function(input)
                    if isActivationInput(input) then
                        draggingSlider = false
                    end
                end, connectionList)

                object._connections = connectionList

                object:SetValue(value, false)

                function object:Destroy()
                    disconnectAll(connectionList)

                    if frame then
                        frame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- DROPDOWN
            -----------------------------------------------------------------

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

                local isOpen = false

                local frame = Instance.new("Frame")

                frame.Size = UDim2.new(1, 0, 0, 36)

                frame.BackgroundColor3 = Bloxium.Theme.Element
                frame.BorderSizePixel = 0

                frame.ClipsDescendants = true

                frame.Parent = page

                addCorner(frame, 6)

                local label = makeTextLabel(frame, {
                    Size = UDim2.new(0.42, 0, 0, 36),
                    Position = UDim2.fromOffset(12, 0),

                    Text = string.upper(
                        tostring(options.Name or "SELECT")
                    ),

                    TextColor3 = Bloxium.Theme.Text,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local openButton = Instance.new("TextButton")

                openButton.Size = UDim2.new(0.47, 0, 0, 26)

                openButton.Position = UDim2.new(
                    0.5,
                    0,
                    0,
                    5
                )

                openButton.BackgroundColor3 = Bloxium.Theme.Background

                openButton.BorderSizePixel = 0

                openButton.Text = tostring(selected or "")

                openButton.TextColor3 = Bloxium.Theme.TextMuted

                openButton.Font = Bloxium.Theme.FontMedium
                openButton.TextSize = 10

                openButton.TextXAlignment = Enum.TextXAlignment.Left

                openButton.AutoButtonColor = false

                openButton.Parent = frame

                addCorner(openButton, 5)
                addPadding(openButton, 9, 25, 0, 0)

                local arrow = makeTextLabel(openButton, {
                    Size = UDim2.fromOffset(20, 26),
                    Position = UDim2.new(1, -22, 0, 0),

                    Text = "v",

                    TextColor3 = Bloxium.Theme.TextMuted,

                    Font = Bloxium.Theme.FontBold,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
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

                local connectionList = {}

                local object = {
                    Frame = frame,
                    Button = openButton,
                }

                local function calculateHeight()
                    if not isOpen then
                        return 36
                    end

                    return 48 + (#values * 28)
                end

                local function refresh()
                    arrow.Text = isOpen and "^" or "v"

                    optionContainer.Size = UDim2.new(
                        1,
                        -24,
                        0,
                        #values * 28
                    )

                    tween(frame, {
                        Size = UDim2.new(
                            1,
                            0,
                            0,
                            calculateHeight()
                        )
                    }, 0.15)
                end

                local function rebuild()
                    for _, child in ipairs(optionContainer:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for index, option in ipairs(values) do
                        local optionButton = Instance.new("TextButton")

                        optionButton.Name = "Option_" .. tostring(index)

                        optionButton.Size = UDim2.new(
                            1,
                            0,
                            0,
                            24
                        )

                        optionButton.BackgroundColor3 =
                            Bloxium.Theme.Background

                        optionButton.BorderSizePixel = 0

                        optionButton.Text = tostring(option)

                        optionButton.TextColor3 =
                            Bloxium.Theme.Text

                        optionButton.Font =
                            Bloxium.Theme.FontMedium

                        optionButton.TextSize = 10

                        optionButton.TextXAlignment =
                            Enum.TextXAlignment.Left

                        optionButton.AutoButtonColor = false

                        optionButton.Parent = optionContainer

                        addCorner(optionButton, 5)
                        addPadding(optionButton, 9, 5, 0, 0)

                        connect(
                            optionButton.MouseEnter,
                            function()
                                tween(optionButton, {
                                    BackgroundColor3 =
                                        Bloxium.Theme.ElementHover
                                }, 0.1)
                            end,
                            connectionList
                        )

                        connect(
                            optionButton.MouseLeave,
                            function()
                                tween(optionButton, {
                                    BackgroundColor3 =
                                        Bloxium.Theme.Background
                                }, 0.1)
                            end,
                            connectionList
                        )

                        connect(
                            optionButton.Activated,
                            function()
                                selected = option

                                openButton.Text =
                                    tostring(selected)

                                isOpen = false

                                refresh()

                                safeCallback(
                                    options.Callback,
                                    selected
                                )
                            end,
                            connectionList
                        )
                    end

                    refresh()
                end

                function object:SetValue(newValue, fireCallback)
                    selected = newValue

                    openButton.Text =
                        tostring(selected or "")

                    if fireCallback ~= false then
                        safeCallback(
                            options.Callback,
                            selected
                        )
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

                    local found = false

                    for _, option in ipairs(values) do
                        if option == selected then
                            found = true
                            break
                        end
                    end

                    if not found then
                        selected = values[1]
                    end

                    rebuild()
                end

                connect(
                    openButton.Activated,
                    function()
                        isOpen = not isOpen
                        refresh()
                    end,
                    connectionList
                )

                object._connections = connectionList

                rebuild()

                function object:Destroy()
                    disconnectAll(connectionList)

                    if frame then
                        frame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- TEXT INPUT
            -----------------------------------------------------------------

            function Section:CreateTextInput(options)
                options = options or {}

                local frame = Instance.new("Frame")

                frame.Size = UDim2.new(1, 0, 0, 36)

                frame.BackgroundColor3 = Bloxium.Theme.Element
                frame.BorderSizePixel = 0

                frame.Parent = page

                addCorner(frame, 6)

                local label = makeTextLabel(frame, {
                    Size = UDim2.new(0.42, 0, 1, 0),
                    Position = UDim2.fromOffset(12, 0),

                    Text = string.upper(
                        tostring(options.Name or "INPUT")
                    ),

                    TextColor3 = Bloxium.Theme.Text,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local textBox = Instance.new("TextBox")

                textBox.Size = UDim2.new(0.5, 0, 0, 26)

                textBox.Position = UDim2.new(
                    0.47,
                    0,
                    0.5,
                    -13
                )

                textBox.BackgroundColor3 =
                    Bloxium.Theme.Background

                textBox.BorderSizePixel = 0

                textBox.Text = tostring(
                    options.Default or ""
                )

                textBox.PlaceholderText =
                    tostring(
                        options.Placeholder
                        or "Enter value..."
                    )

                textBox.PlaceholderColor3 =
                    Bloxium.Theme.TextDim

                textBox.TextColor3 =
                    Bloxium.Theme.Text

                textBox.Font =
                    Bloxium.Theme.FontMedium

                textBox.TextSize = 10

                textBox.ClearTextOnFocus = false

                textBox.TextXAlignment =
                    Enum.TextXAlignment.Left

                textBox.Parent = frame

                addCorner(textBox, 5)
                addPadding(textBox, 8, 8, 0, 0)

                local connectionList = {}

                local object = {
                    Frame = frame,
                    TextBox = textBox,
                }

                connect(textBox.Focused, function()
                    tween(textBox, {
                        BackgroundColor3 =
                            Color3.fromRGB(24, 24, 24)
                    }, 0.1)
                end, connectionList)

                connect(textBox.FocusLost, function(enterPressed)
                    tween(textBox, {
                        BackgroundColor3 =
                            Bloxium.Theme.Background
                    }, 0.1)

                    safeCallback(
                        options.Callback,
                        textBox.Text,
                        enterPressed
                    )
                end, connectionList)

                function object:SetValue(value, fireCallback)
                    textBox.Text = tostring(value or "")

                    if fireCallback then
                        safeCallback(
                            options.Callback,
                            textBox.Text,
                            false
                        )
                    end
                end

                function object:GetValue()
                    return textBox.Text
                end

                object._connections = connectionList

                function object:Destroy()
                    disconnectAll(connectionList)

                    if frame then
                        frame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- KEYBIND
            -----------------------------------------------------------------

            function Section:CreateKeybind(options)
                options = options or {}

                local currentKey =
                    options.Default
                    or Enum.KeyCode.E

                local listening = false

                local frame = Instance.new("Frame")

                frame.Size = UDim2.new(1, 0, 0, 36)

                frame.BackgroundColor3 =
                    Bloxium.Theme.Element

                frame.BorderSizePixel = 0

                frame.Parent = page

                addCorner(frame, 6)

                local label = makeTextLabel(frame, {
                    Size = UDim2.new(1, -115, 1, 0),
                    Position = UDim2.fromOffset(12, 0),

                    Text = string.upper(
                        tostring(options.Name or "BIND")
                    ),

                    TextColor3 = Bloxium.Theme.Text,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 11,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local bindButton = Instance.new("TextButton")

                bindButton.Size = UDim2.fromOffset(85, 26)

                bindButton.Position = UDim2.new(
                    1,
                    -97,
                    0.5,
                    -13
                )

                bindButton.BackgroundColor3 =
                    Bloxium.Theme.Background

                bindButton.BorderSizePixel = 0

                bindButton.TextColor3 =
                    Bloxium.Theme.TextMuted

                bindButton.Font =
                    Bloxium.Theme.FontMedium

                bindButton.TextSize = 10

                bindButton.AutoButtonColor = false

                bindButton.Parent = frame

                addCorner(bindButton, 5)

                local connectionList = {}

                local function getKeyName(key)
                    if typeof(key) == "EnumItem" then
                        return string.upper(key.Name)
                    end

                    return "NONE"
                end

                local function updateButton()
                    if listening then
                        bindButton.Text = "PRESS KEY"
                        bindButton.TextColor3 =
                            Bloxium.Theme.Accent

                        bindButton.BackgroundColor3 =
                            Color3.fromRGB(28, 28, 28)
                    else
                        bindButton.Text =
                            getKeyName(currentKey)

                        bindButton.TextColor3 =
                            Bloxium.Theme.TextMuted

                        bindButton.BackgroundColor3 =
                            Bloxium.Theme.Background
                    end
                end

                local object = {
                    Frame = frame,
                    Button = bindButton,
                }

                function object:SetKey(key)
                    if typeof(key) ~= "EnumItem" then
                        return
                    end

                    currentKey = key

                    listening = false

                    updateButton()
                end

                function object:GetKey()
                    return currentKey
                end

                function object:StartListening()
                    listening = true
                    updateButton()
                end

                function object:Cancel()
                    listening = false
                    updateButton()
                end

                connect(bindButton.MouseEnter, function()
                    if listening then
                        return
                    end

                    tween(bindButton, {
                        BackgroundColor3 =
                            Bloxium.Theme.ElementHover,

                        TextColor3 =
                            Bloxium.Theme.Text,
                    }, 0.1)
                end, connectionList)

                connect(bindButton.MouseLeave, function()
                    if listening then
                        return
                    end

                    tween(bindButton, {
                        BackgroundColor3 =
                            Bloxium.Theme.Background,

                        TextColor3 =
                            Bloxium.Theme.TextMuted,
                    }, 0.1)
                end, connectionList)

                connect(bindButton.Activated, function()
                    object:StartListening()
                end, connectionList)

                connect(
                    UserInputService.InputBegan,
                    function(input, gameProcessed)
                        if listening then
                            if input.UserInputType
                                ~= Enum.UserInputType.Keyboard then
                                return
                            end

                            if input.KeyCode
                                == Enum.KeyCode.Escape then
                                object:Cancel()
                                return
                            end

                            currentKey = input.KeyCode

                            listening = false

                            updateButton()

                            safeCallback(
                                options.Changed,
                                currentKey
                            )

                            return
                        end

                        if gameProcessed then
                            return
                        end

                        if input.UserInputType
                            ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        if input.KeyCode == currentKey then
                            safeCallback(
                                options.Callback,
                                currentKey
                            )
                        end
                    end,
                    connectionList
                )

                object._connections = connectionList

                updateButton()

                function object:Destroy()
                    disconnectAll(connectionList)

                    if frame then
                        frame:Destroy()
                    end
                end

                return self:_add(object)
            end

            -----------------------------------------------------------------
            -- LABEL
            -----------------------------------------------------------------

            function Section:CreateLabel(text)
                local labelFrame = Instance.new("Frame")

                labelFrame.Size = UDim2.new(1, 0, 0, 28)

                labelFrame.BackgroundTransparency = 1

                labelFrame.Parent = page

                local label = makeTextLabel(labelFrame, {
                    Size = UDim2.new(1, -12, 1, 0),
                    Position = UDim2.fromOffset(6, 0),

                    Text = tostring(text or ""),

                    TextColor3 = Bloxium.Theme.TextMuted,

                    Font = Bloxium.Theme.FontMedium,
                    TextSize = 10,

                    TextWrapped = true,

                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                })

                local object = {
                    Frame = labelFrame,
                    Label = label,
                }

                function object:SetText(newText)
                    label.Text = tostring(newText or "")
                end

                function object:Destroy()
                    if labelFrame then
                        labelFrame:Destroy()
                    end
                end

                return self:_add(object)
            end

            table.insert(Tab.Sections, Section)

            return Section
        end

        -----------------------------------------------------------------
        -- BACKWARDS COMPATIBILITY
        -----------------------------------------------------------------

        function Tab:CreateButton(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateButton(options)
        end

        function Tab:CreateToggle(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateToggle(options)
        end

        function Tab:CreateSlider(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateSlider(options)
        end

        function Tab:CreateDropdown(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateDropdown(options)
        end

        function Tab:CreateTextInput(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateTextInput(options)
        end

        function Tab:CreateKeybind(options)
            if #self.Sections == 0 then
                self:CreateSection("CONTROLS")
            end

            return self.Sections[#self.Sections]:CreateKeybind(options)
        end

        function Tab:CreateLabel(text)
            if #self.Sections == 0 then
                self:CreateSection("INFO")
            end

            return self.Sections[#self.Sections]:CreateLabel(text)
        end

        -----------------------------------------------------------------
        -- TAB OBJECT
        -----------------------------------------------------------------

        if #Window.Tabs == 1 then
            Tab:_select()
        end

        return Tab
    end

    -----------------------------------------------------------------
    -- RETURN WINDOW
    -----------------------------------------------------------------

    return Window
end

return Bloxium
