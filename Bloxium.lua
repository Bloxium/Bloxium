local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Bloxium = {
    Theme = {
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
}

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Bloxium.Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = object
    return s
end

local function tween(object, properties, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.15,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )

    return TweenService:Create(object, info, properties)
end

local function disconnectAll(connections)
    for _, connection in ipairs(connections) do
        if connection and connection.Connected then
            connection:Disconnect()
        end
    end
end

function Bloxium:Notify(options)
    options = options or {}

    if not self._notificationHost or not self._notificationHost.Parent then
        return
    end

    local titleText = string.upper(options.Title or "SYSTEM ALERT")
    local descriptionText = options.Description or ""
    local duration = tonumber(options.Duration) or 3

    local toast = Instance.new("Frame")
    toast.Name = "Notification"
    toast.Size = UDim2.new(1, 0, 0, 66)
    toast.BackgroundColor3 = self.Theme.Element
    toast.BackgroundTransparency = 1
    toast.BorderSizePixel = 0
    toast.Parent = self._notificationHost

    corner(toast, 8)

    local toastStroke = stroke(toast, self.Theme.Border, 1, 1)

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 1, -20)
    accent.Position = UDim2.new(0, 8, 0, 10)
    accent.BackgroundColor3 = self.Theme.Accent
    accent.BackgroundTransparency = 1
    accent.BorderSizePixel = 0
    accent.Parent = toast

    corner(accent, 3)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -34, 0, 20)
    title.Position = UDim2.new(0, 20, 0, 8)
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextColor3 = self.Theme.Text
    title.Font = Enum.Font.MontserratBold
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextTransparency = 1
    title.Parent = toast

    local description = Instance.new("TextLabel")
    description.Size = UDim2.new(1, -34, 0, 30)
    description.Position = UDim2.new(0, 20, 0, 29)
    description.BackgroundTransparency = 1
    description.Text = descriptionText
    description.TextColor3 = self.Theme.TextMuted
    description.Font = Enum.Font.MontserratMedium
    description.TextSize = 10
    description.TextWrapped = true
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextTransparency = 1
    description.Parent = toast

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

    tween(description, {
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

        local fade = tween(description, {
            TextTransparency = 1
        }, 0.2)

        fade:Play()
        fade.Completed:Wait()

        if toast then
            toast:Destroy()
        end
    end)
end

function Bloxium:CreateWindow(config)
    config = config or {}

    local titleText = config.Title or "BLOXIUM"
    local subtitleText = config.Subtitle or ""
    local windowSize = config.Size or UDim2.fromOffset(650, 430)

    if self._screenGui then
        self._screenGui:Destroy()
    end

    self._connections = {}

    local Window = {
        Tabs = {},
        ActiveTab = nil
    }

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Bloxium"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    self._screenGui = screenGui

    local notificationHost = Instance.new("Frame")
    notificationHost.Name = "NotificationHost"
    notificationHost.Size = UDim2.fromOffset(280, 1)
    notificationHost.AutomaticSize = Enum.AutomaticSize.Y
    notificationHost.AnchorPoint = Vector2.new(1, 1)
    notificationHost.Position = UDim2.new(1, -15, 1, -15)
    notificationHost.BackgroundTransparency = 1
    notificationHost.BorderSizePixel = 0
    notificationHost.Parent = screenGui

    local notificationLayout = Instance.new("UIListLayout")
    notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notificationLayout.Padding = UDim.new(0, 8)
    notificationLayout.Parent = notificationHost

    self._notificationHost = notificationHost

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = windowSize
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Position = UDim2.fromScale(0.5, 0.5)
    mainFrame.BackgroundColor3 = self.Theme.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    corner(mainFrame, 10)
    stroke(mainFrame, self.Theme.Border, 1, 0)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 42)
    topBar.BackgroundColor3 = self.Theme.TopBar
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame

    corner(topBar, 10)

    local topBarPatch = Instance.new("Frame")
    topBarPatch.Size = UDim2.new(1, 0, 0, 10)
    topBarPatch.Position = UDim2.new(0, 0, 1, -10)
    topBarPatch.BackgroundColor3 = self.Theme.TopBar
    topBarPatch.BorderSizePixel = 0
    topBarPatch.Parent = topBar

    local topDivider = Instance.new("Frame")
    topDivider.Size = UDim2.new(1, -32, 0, 1)
    topDivider.Position = UDim2.new(0, 16, 1, -1)
    topDivider.BackgroundColor3 = self.Theme.Border
    topDivider.BorderSizePixel = 0
    topDivider.Parent = topBar

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -110, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.RichText = true
    title.Text = string.upper(titleText) ..
        (subtitleText ~= "" and "  <font color='#707070'>" .. string.upper(subtitleText) .. "</font>" or "")
    title.TextColor3 = self.Theme.Text
    title.Font = Enum.Font.MontserratBold
    title.TextSize = 12
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topBar

    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.fromOffset(30, 30)
    minimizeButton.Position = UDim2.new(1, -72, 0, 6)
    minimizeButton.BackgroundColor3 = self.Theme.Element
    minimizeButton.BackgroundTransparency = 1
    minimizeButton.Text = "−"
    minimizeButton.TextColor3 = self.Theme.TextMuted
    minimizeButton.Font = Enum.Font.Montserrat
    minimizeButton.TextSize = 17
    minimizeButton.AutoButtonColor = false
    minimizeButton.Parent = topBar

    corner(minimizeButton, 6)

    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.fromOffset(30, 30)
    closeButton.Position = UDim2.new(1, -38, 0, 6)
    closeButton.BackgroundColor3 = self.Theme.Element
    closeButton.BackgroundTransparency = 1
    closeButton.Text = "×"
    closeButton.TextColor3 = self.Theme.TextMuted
    closeButton.Font = Enum.Font.Montserrat
    closeButton.TextSize = 18
    closeButton.AutoButtonColor = false
    closeButton.Parent = topBar

    corner(closeButton, 6)

    closeButton.MouseEnter:Connect(function()
        tween(closeButton, {
            BackgroundTransparency = 0,
            BackgroundColor3 = Color3.fromRGB(55, 20, 20),
            TextColor3 = Color3.fromRGB(235, 90, 90)
        }, 0.12):Play()
    end)

    closeButton.MouseLeave:Connect(function()
        tween(closeButton, {
            BackgroundTransparency = 1,
            TextColor3 = self.Theme.TextMuted
        }, 0.12):Play()
    end)

    closeButton.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        self._screenGui = nil
        self._notificationHost = nil
        disconnectAll(self._connections)
    end)

    minimizeButton.MouseEnter:Connect(function()
        tween(minimizeButton, {
            BackgroundTransparency = 0,
            TextColor3 = self.Theme.Text
        }, 0.12):Play()
    end)

    minimizeButton.MouseLeave:Connect(function()
        tween(minimizeButton, {
            BackgroundTransparency = 1,
            TextColor3 = self.Theme.TextMuted
        }, 0.12):Play()
    end)

    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 158, 1, -42)
    sidebar.Position = UDim2.new(0, 0, 0, 42)
    sidebar.BackgroundColor3 = self.Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = mainFrame

    corner(sidebar, 10)

    local sidebarPatch = Instance.new("Frame")
    sidebarPatch.Size = UDim2.new(1, 0, 0, 12)
    sidebarPatch.BackgroundColor3 = self.Theme.Sidebar
    sidebarPatch.BorderSizePixel = 0
    sidebarPatch.Parent = sidebar

    local sidebarPatchRight = Instance.new("Frame")
    sidebarPatchRight.Size = UDim2.fromOffset(10, 1)
    sidebarPatchRight.Position = UDim2.new(1, -10, 0, 0)
    sidebarPatchRight.BackgroundColor3 = self.Theme.Sidebar
    sidebarPatchRight.BorderSizePixel = 0
    sidebarPatchRight.Parent = sidebar

    local tabContainer = Instance.new("ScrollingFrame")
    tabContainer.Name = "TabContainer"
    tabContainer.Size = UDim2.new(1, 0, 1, 0)
    tabContainer.BackgroundTransparency = 1
    tabContainer.BorderSizePixel = 0
    tabContainer.ScrollBarThickness = 0
    tabContainer.CanvasSize = UDim2.new()
    tabContainer.Parent = sidebar

    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 12)
    tabPadding.PaddingLeft = UDim.new(0, 10)
    tabPadding.PaddingRight = UDim.new(0, 10)
    tabPadding.PaddingBottom = UDim.new(0, 10)
    tabPadding.Parent = tabContainer

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

    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Size = UDim2.new(0, 1, 1, -42)
    sidebarDivider.Position = UDim2.new(0, 157, 0, 42)
    sidebarDivider.BackgroundColor3 = self.Theme.Border
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Parent = mainFrame

    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -178, 1, -52)
    contentArea.Position = UDim2.new(0, 169, 0, 52)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = mainFrame

    local dragging = false
    local dragStart
    local startPosition

    local dragConnection = topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPosition = mainFrame.Position

            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end
    end)

    table.insert(self._connections, dragConnection)

    local inputChangedConnection = UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            mainFrame.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    table.insert(self._connections, inputChangedConnection)

    local minimized = false

    minimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            tween(mainFrame, {
                Size = UDim2.new(0, windowSize.X.Offset, 0, 42)
            }, 0.2, Enum.EasingStyle.Quart):Play()

            minimizeButton.Text = "+"
        else
            tween(mainFrame, {
                Size = windowSize
            }, 0.2, Enum.EasingStyle.Quart):Play()

            minimizeButton.Text = "−"
        end
    end)

    function Window:CreateTab(name)
        local Tab = {
            Sections = {}
        }

        local tabButton = Instance.new("TextButton")
        tabButton.Name = "Tab"
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

        local tabText = Instance.new("TextLabel")
        tabText.Size = UDim2.new(1, -30, 1, 0)
        tabText.Position = UDim2.new(0, 24, 0, 0)
        tabText.BackgroundTransparency = 1
        tabText.Text = string.upper(name or "TAB")
        tabText.TextColor3 = Bloxium.Theme.TextMuted
        tabText.Font = Enum.Font.MontserratMedium
        tabText.TextSize = 11
        tabText.TextXAlignment = Enum.TextXAlignment.Left
        tabText.Parent = tabButton

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page"
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = Bloxium.Theme.BorderLight
        page.CanvasSize = UDim2.new()
        page.Visible = false
        page.Parent = contentArea

        local pagePadding = Instance.new("UIPadding")
        pagePadding.PaddingTop = UDim.new(0, 4)
        pagePadding.PaddingBottom = UDim.new(0, 10)
        pagePadding.PaddingRight = UDim.new(0, 5)
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

        local function selectTab()
            for _, other in ipairs(Window.Tabs) do
                other.Page.Visible = false

                tween(other.Button, {
                    BackgroundTransparency = 1
                }, 0.12):Play()

                tween(other.Text, {
                    TextColor3 = Bloxium.Theme.TextMuted
                }, 0.12):Play()

                tween(other.Indicator, {
                    BackgroundTransparency = 1
                }, 0.12):Play()
            end

            page.Visible = true

            tween(tabButton, {
                BackgroundTransparency = 0
            }, 0.12):Play()

            tween(tabText, {
                TextColor3 = Bloxium.Theme.Text
            }, 0.12):Play()

            tween(indicator, {
                BackgroundTransparency = 0
            }, 0.12):Play()

            Window.ActiveTab = Tab
        end

        tabButton.MouseButton1Click:Connect(selectTab)

        tabButton.MouseEnter:Connect(function()
            if Window.ActiveTab ~= Tab then
                tween(tabButton, {
                    BackgroundTransparency = 0.7
                }, 0.1):Play()

                tween(tabText, {
                    TextColor3 = Bloxium.Theme.Text
                }, 0.1):Play()
            end
        end)

        tabButton.MouseLeave:Connect(function()
            if Window.ActiveTab ~= Tab then
                tween(tabButton, {
                    BackgroundTransparency = 1
                }, 0.1):Play()

                tween(tabText, {
                    TextColor3 = Bloxium.Theme.TextMuted
                }, 0.1):Play()
            end
        end)

        Tab.Button = tabButton
        Tab.Text = tabText
        Tab.Indicator = indicator
        Tab.Page = page

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            selectTab()
        end

        function Tab:CreateSection(name)
            local Section = {}

            local sectionFrame = Instance.new("Frame")
            sectionFrame.Name = "Section"
            sectionFrame.Size = UDim2.new(1, 0, 0, 34)
            sectionFrame.BackgroundTransparency = 1
            sectionFrame.BorderSizePixel = 0
            sectionFrame.ClipsDescendants = false
            sectionFrame.Parent = page

            local sectionTitle = Instance.new("TextLabel")
            sectionTitle.Name = "SectionTitle"
            sectionTitle.Size = UDim2.new(1, 0, 0, 24)
            sectionTitle.Position = UDim2.new(0, 2, 0, 0)
            sectionTitle.BackgroundTransparency = 1
            sectionTitle.Text = string.upper(name or "SECTION")
            sectionTitle.TextColor3 = Bloxium.Theme.TextMuted
            sectionTitle.Font = Enum.Font.MontserratBold
            sectionTitle.TextSize = 10
            sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
            sectionTitle.Parent = sectionFrame

            local sectionLine = Instance.new("Frame")
            sectionLine.Size = UDim2.new(1, 0, 0, 1)
            sectionLine.Position = UDim2.new(0, 0, 0, 25)
            sectionLine.BackgroundColor3 = Bloxium.Theme.Border
            sectionLine.BorderSizePixel = 0
            sectionLine.Parent = sectionFrame

            local elements = Instance.new("Frame")
            elements.Name = "Elements"
            elements.Size = UDim2.new(1, 0, 0, 0)
            elements.Position = UDim2.new(0, 0, 0, 32)
            elements.BackgroundTransparency = 1
            elements.BorderSizePixel = 0
            elements.Parent = sectionFrame

            local elementsLayout = Instance.new("UIListLayout")
            elementsLayout.Padding = UDim.new(0, 8)
            elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            elementsLayout.Parent = elements

            local function updateSectionSize()
                local height = elementsLayout.AbsoluteContentSize.Y

                sectionFrame.Size = UDim2.new(
                    1,
                    0,
                    0,
                    height + 32
                )

                elements.Size = UDim2.new(
                    1,
                    0,
                    0,
                    height
                )
            end

            elementsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSectionSize)

            local function createElementFrame(height)
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, height)
                frame.BackgroundColor3 = Bloxium.Theme.Element
                frame.BorderSizePixel = 0
                frame.Parent = elements

                corner(frame, 6)

                return frame
            end

            function Section:CreateButton(options)
                options = options or {}

                local frame = createElementFrame(34)
                local frameStroke = stroke(frame, Bloxium.Theme.Border, 1, 0.35)

                local button = Instance.new("TextButton")
                button.Size = UDim2.fromScale(1, 1)
                button.BackgroundTransparency = 1
                button.BorderSizePixel = 0
                button.Text = string.upper(options.Name or "BUTTON")
                button.TextColor3 = Bloxium.Theme.Text
                button.Font = Enum.Font.MontserratMedium
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

                    tween(frameStroke, {
                        Transparency = 0
                    }, 0.1):Play()
                end)

                button.MouseLeave:Connect(function()
                    tween(frame, {
                        BackgroundColor3 = Bloxium.Theme.Element
                    }, 0.1):Play()

                    tween(frameStroke, {
                        Transparency = 0.35
                    }, 0.1):Play()
                end)

                button.MouseButton1Click:Connect(function()
                    tween(frame, {
                        BackgroundColor3 = Bloxium.Theme.Accent
                    }, 0.06):Play()

                    task.delay(0.06, function()
                        if frame.Parent then
                            tween(frame, {
                                BackgroundColor3 = Bloxium.Theme.Element
                            }, 0.15):Play()
                        end
                    end)

                    if typeof(options.Callback) == "function" then
                        task.spawn(options.Callback)
                    end
                end)

                return frame
            end

            function Section:CreateToggle(options)
                options = options or {}

                local state = options.Default == true
                local callback = typeof(options.Callback) == "function" and options.Callback or function() end

                local frame = createElementFrame(36)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -75, 1, 0)
                label.Position = UDim2.new(0, 12, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = string.upper(options.Name or "TOGGLE")
                label.TextColor3 = Bloxium.Theme.Text
                label.Font = Enum.Font.MontserratMedium
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

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

                local function setState(value, fire)
                    state = value == true

                    tween(knob, {
                        Position = state
                            and UDim2.new(1, -17, 0.5, -7)
                            or UDim2.new(0, 3, 0.5, -7),

                        BackgroundColor3 = state
                            and Bloxium.Theme.Accent
                            or Bloxium.Theme.BorderLight
                    }, 0.15):Play()

                    tween(toggle, {
                        BackgroundColor3 = state
                            and Color3.fromRGB(28, 28, 28)
                            or Bloxium.Theme.Background
                    }, 0.15):Play()

                    if fire then
                        task.spawn(callback, state)
                    end
                end

                toggle.MouseButton1Click:Connect(function()
                    setState(not state, true)
                end)

                setState(state, false)

                Section:SetToggle = function(_, value)
                    setState(value, true)
                end

                Section:GetToggle = function()
                    return state
                end

                return frame
            end

            function Section:CreateSlider(options)
                options = options or {}

                local minimum = tonumber(options.Min) or 0
                local maximum = tonumber(options.Max) or 100

                if maximum <= minimum then
                    maximum = minimum + 1
                end

                local value = tonumber(options.Default) or minimum
                value = math.clamp(value, minimum, maximum)

                local callback = typeof(options.Callback) == "function" and options.Callback or function() end

                local frame = createElementFrame(50)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -85, 0, 26)
                label.Position = UDim2.new(0, 12, 0, 1)
                label.BackgroundTransparency = 1
                label.Text = string.upper(options.Name or "SLIDER")
                label.TextColor3 = Bloxium.Theme.Text
                label.Font = Enum.Font.MontserratMedium
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.fromOffset(60, 26)
                valueLabel.Position = UDim2.new(1, -72, 0, 1)
                valueLabel.BackgroundTransparency = 1
                valueLabel.TextColor3 = Bloxium.Theme.TextMuted
                valueLabel.Font = Enum.Font.MontserratMedium
                valueLabel.TextSize = 11
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = frame

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

                local range = maximum - minimum
                local sliderDragging = false

                local function setValue(newValue, fire)
                    value = math.clamp(newValue, minimum, maximum)

                    local scale = (value - minimum) / range

                    fill.Size = UDim2.new(scale, 0, 1, 0)
                    knob.Position = UDim2.new(scale, -5, 0.5, -5)
                    valueLabel.Text = tostring(value)

                    if fire then
                        task.spawn(callback, value)
                    end
                end

                local function updateFromInput(input)
                    if track.AbsoluteSize.X <= 0 then
                        return
                    end

                    local scale = math.clamp(
                        (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                        0,
                        1
                    )

                    local newValue = minimum + range * scale
                    newValue = math.floor(newValue + 0.5)

                    setValue(newValue, true)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then

                        sliderDragging = true
                        updateFromInput(input)
                    end
                end)

                local sliderEnd = UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then

                        sliderDragging = false
                    end
                end)

                table.insert(self._connections, sliderEnd)

                local sliderMove = UserInputService.InputChanged:Connect(function(input)
                    if not sliderDragging then
                        return
                    end

                    if input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch then

                        updateFromInput(input)
                    end
                end)

                table.insert(self._connections, sliderMove)

                setValue(value, false)

                return frame
            end

            function Section:CreateDropdown(options)
                options = options or {}

                local choices = options.Options or {}
                local selected = options.Default

                if selected == nil then
                    selected = choices[1] or ""
                end

                local callback = typeof(options.Callback) == "function" and options.Callback or function() end
                local opened = false

                local frame = createElementFrame(36)
                frame.ClipsDescendants = true

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.42, 0, 0, 36)
                label.Position = UDim2.new(0, 12, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = string.upper(options.Name or "DROPDOWN")
                label.TextColor3 = Bloxium.Theme.Text
                label.Font = Enum.Font.MontserratMedium
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

                local button = Instance.new("TextButton")
                button.Size = UDim2.new(0.48, 0, 0, 24)
                button.Position = UDim2.new(0.48, 0, 0, 6)
                button.BackgroundColor3 = Bloxium.Theme.Background
                button.BorderSizePixel = 0
                button.Text = tostring(selected)
                button.TextColor3 = Bloxium.Theme.TextMuted
                button.Font = Enum.Font.MontserratMedium
                button.TextSize = 10
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.AutoButtonColor = false
                button.Parent = frame

                corner(button, 5)

                local buttonPadding = Instance.new("UIPadding")
                buttonPadding.PaddingLeft = UDim.new(0, 9)
                buttonPadding.PaddingRight = UDim.new(0, 25)
                buttonPadding.Parent = button

                local arrow = Instance.new("TextLabel")
                arrow.Size = UDim2.fromOffset(20, 24)
                arrow.Position = UDim2.new(1, -25, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.Text = "v"
                arrow.TextColor3 = Bloxium.Theme.TextMuted
                arrow.Font = Enum.Font.MontserratBold
                arrow.TextSize = 11
                arrow.Parent = button

                local optionContainer = Instance.new("Frame")
                optionContainer.Size = UDim2.new(1, -24, 0, 0)
                optionContainer.Position = UDim2.new(0, 12, 0, 40)
                optionContainer.BackgroundTransparency = 1
                optionContainer.Parent = frame

                local optionLayout = Instance.new("UIListLayout")
                optionLayout.Padding = UDim.new(0, 4)
                optionLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionLayout.Parent = optionContainer

                local optionButtons = {}

                local function updateSize()
                    local height = opened and (40 + (#choices * 28) + 4) or 36

                    tween(frame, {
                        Size = UDim2.new(1, 0, 0, height)
                    }, 0.15):Play()
                end

                for index, choice in ipairs(choices) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "Option_" .. index
                    optionButton.Size = UDim2.new(1, 0, 0, 24)
                    optionButton.BackgroundColor3 = Bloxium.Theme.Background
                    optionButton.BorderSizePixel = 0
                    optionButton.Text = tostring(choice)
                    optionButton.TextColor3 = Bloxium.Theme.Text
                    optionButton.Font = Enum.Font.MontserratMedium
                    optionButton.TextSize = 10
                    optionButton.TextXAlignment = Enum.TextXAlignment.Left
                    optionButton.AutoButtonColor = false
                    optionButton.Parent = optionContainer

                    corner(optionButton, 5)

                    local optionPadding = Instance.new("UIPadding")
                    optionPadding.PaddingLeft = UDim.new(0, 9)
                    optionPadding.Parent = optionButton

                    optionButton.MouseEnter:Connect(function()
                        tween(optionButton, {
                            BackgroundColor3 = Bloxium.Theme.ElementHover
                        }, 0.1):Play()
                    end)

                    optionButton.MouseLeave:Connect(function()
                        tween(optionButton, {
                            BackgroundColor3 = Bloxium.Theme.Background
                        }, 0.1):Play()
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        selected = choice
                        button.Text = tostring(selected)
                        opened = false
                        arrow.Text = "v"

                        updateSize()

                        task.spawn(callback, selected)
                    end)

                    table.insert(optionButtons, optionButton)
                end

                button.MouseButton1Click:Connect(function()
                    opened = not opened
                    arrow.Text = opened and "^" or "v"
                    updateSize()
                end)

                Section:SetDropdown = function(_, value)
                    for _, choice in ipairs(choices) do
                        if choice == value then
                            selected = value
                            button.Text = tostring(value)
                            task.spawn(callback, value)
                            return
                        end
                    end
                end

                Section:GetDropdown = function()
                    return selected
                end

                return frame
            end

            function Section:CreateTextInput(options)
                options = options or {}

                local callback = typeof(options.Callback) == "function" and options.Callback or function() end

                local frame = createElementFrame(36)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0.42, 0, 1, 0)
                label.Position = UDim2.new(0, 12, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = string.upper(options.Name or "INPUT")
                label.TextColor3 = Bloxium.Theme.Text
                label.Font = Enum.Font.MontserratMedium
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

                local textBox = Instance.new("TextBox")
                textBox.Size = UDim2.new(0.51, 0, 0, 24)
                textBox.Position = UDim2.new(0.46, 0, 0.5, -12)
                textBox.BackgroundColor3 = Bloxium.Theme.Background
                textBox.BorderSizePixel = 0
                textBox.Text = options.Default or ""
                textBox.PlaceholderText = options.Placeholder or "Enter value..."
                textBox.TextColor3 = Bloxium.Theme.Text
                textBox.PlaceholderColor3 = Bloxium.Theme.TextDim
                textBox.Font = Enum.Font.MontserratMedium
                textBox.TextSize = 10
                textBox.ClearTextOnFocus = false
                textBox.TextXAlignment = Enum.TextXAlignment.Left
                textBox.Parent = frame

                corner(textBox, 5)

                local padding = Instance.new("UIPadding")
                padding.PaddingLeft = UDim.new(0, 8)
                padding.PaddingRight = UDim.new(0, 8)
                padding.Parent = textBox

                textBox.Focused:Connect(function()
                    tween(textBox, {
                        BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                    }, 0.1):Play()
                end)

                textBox.FocusLost:Connect(function(enterPressed)
                    tween(textBox, {
                        BackgroundColor3 = Bloxium.Theme.Background
                    }, 0.1):Play()

                    task.spawn(callback, textBox.Text, enterPressed)
                end)

                Section:SetInput = function(_, value)
                    textBox.Text = tostring(value)
                end

                Section:GetInput = function()
                    return textBox.Text
                end

                return frame
            end

            function Section:CreateKeybind(options)
                options = options or {}

                local defaultKey = options.Default or Enum.KeyCode.E
                local callback = typeof(options.Callback) == "function" and options.Callback or function() end

                local frame = createElementFrame(36)

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, -115, 1, 0)
                label.Position = UDim2.new(0, 12, 0, 0)
                label.BackgroundTransparency = 1
                label.Text = string.upper(options.Name or "KEYBIND")
                label.TextColor3 = Bloxium.Theme.Text
                label.Font = Enum.Font.MontserratMedium
                label.TextSize = 11
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.Parent = frame

                local bindButton = Instance.new("TextButton")
                bindButton.Size = UDim2.fromOffset(85, 24)
                bindButton.Position = UDim2.new(1, -97, 0.5, -12)
                bindButton.BackgroundColor3 = Bloxium.Theme.Background
                bindButton.BorderSizePixel = 0
                bindButton.Text = string.upper(defaultKey.Name)
                bindButton.TextColor3 = Bloxium.Theme.TextMuted
                bindButton.Font = Enum.Font.MontserratMedium
                bindButton.TextSize = 10
                bindButton.AutoButtonColor = false
                bindButton.Parent = frame

                corner(bindButton, 5)

                local currentKey = defaultKey
                local listening = false

                bindButton.MouseEnter:Connect(function()
                    if not listening then
                        tween(bindButton, {
                            BackgroundColor3 = Bloxium.Theme.ElementHover,
                            TextColor3 = Bloxium.Theme.Text
                        }, 0.1):Play()
                    end
                end)

                bindButton.MouseLeave:Connect(function()
                    if not listening then
                        tween(bindButton, {
                            BackgroundColor3 = Bloxium.Theme.Background,
                            TextColor3 = Bloxium.Theme.TextMuted
                        }, 0.1):Play()
                    end
                end)

                bindButton.MouseButton1Click:Connect(function()
                    listening = true
                    bindButton.Text = "PRESS KEY"
                    bindButton.TextColor3 = Bloxium.Theme.Accent

                    tween(bindButton, {
                        BackgroundColor3 = Color3.fromRGB(28, 28, 28)
                    }, 0.1):Play()
                end)

                local bindConnection = UserInputService.InputBegan:Connect(function(input, processed)
                    if listening then
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end

                        if input.KeyCode == Enum.KeyCode.Escape then
                            listening = false
                            bindButton.Text = string.upper(currentKey.Name)
                            bindButton.TextColor3 = Bloxium.Theme.TextMuted
                            bindButton.BackgroundColor3 = Bloxium.Theme.Background
                            return
                        end

                        currentKey = input.KeyCode
                        listening = false

                        bindButton.Text = string.upper(currentKey.Name)
                        bindButton.TextColor3 = Bloxium.Theme.TextMuted
                        bindButton.BackgroundColor3 = Bloxium.Theme.Background

                        return
                    end

                    if not processed and input.KeyCode == currentKey then
                        task.spawn(callback, currentKey)
                    end
                end)

                table.insert(self._connections, bindConnection)

                Section:SetKeybind = function(_, key)
                    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
                        currentKey = key
                        bindButton.Text = string.upper(key.Name)
                    end
                end

                Section:GetKeybind = function()
                    return currentKey
                end

                return frame
            end

            table.insert(Tab.Sections, Section)

            task.defer(updateSectionSize)

            return Section
        end

        return Tab
    end

    function Window:Destroy()
        if screenGui and screenGui.Parent then
            screenGui:Destroy()
        end

        disconnectAll(Bloxium._connections)

        if Bloxium._screenGui == screenGui then
            Bloxium._screenGui = nil
            Bloxium._notificationHost = nil
        end
    end

    return Window
end

return Bloxium
