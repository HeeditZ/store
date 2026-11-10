--[[\
    Muye-Hub UI Library v1.1 (True Glassmorphic Edition)
    Novoline-Tier Architecture & Animation System
--]]

local userInputService = game:GetService("UserInputService")
local tweenService     = game:GetService("TweenService")
local players          = game:GetService("Players")
local coreGui          = game:GetService("CoreGui")
local localPlayer      = players.LocalPlayer

local MuyeHub = {}

-- Design System Colors (High Contrast & Crisp)
local C = {
    TEXT    = Color3.fromRGB(255, 255, 255),
    SUBTLE  = Color3.fromRGB(170, 170, 178),
    INK     = Color3.fromRGB(24, 24, 30),
    WHITE   = Color3.new(1, 1, 1),
    OFF     = Color3.fromRGB(65, 65, 72),
}

-- Tint Pairs (Glass Tint, Accent Glow)[cite: 1]
local TINTS = {
    blue   = { Color3.fromRGB(20,  50,  70), Color3.fromRGB(64,  186, 255) },
    purple = { Color3.fromRGB(45,  32,  75), Color3.fromRGB(168, 120, 255) },
    teal   = { Color3.fromRGB(18,  58,  50), Color3.fromRGB(56,  224, 186) },
    orange = { Color3.fromRGB(75,  45,  20), Color3.fromRGB(255, 150, 50)  },
    red    = { Color3.fromRGB(75,  25,  30), Color3.fromRGB(255, 96,  96)  },
    yellow = { Color3.fromRGB(68,  55,  15), Color3.fromRGB(245, 197, 66)  },
}

-- Scaling System[cite: 1]
local vp = workspace.CurrentCamera.ViewportSize
local sc = math.clamp(math.min((vp.X - 32) / 560, (vp.Y - 40) / 400), 0.55, 1)

local function P(n)  return math.floor(n * sc + 0.5) end
local function TS(n) return math.max(9, math.floor(n * sc + 0.5)) end

-- True Glass Surface Foundation[cite: 1]
local function applyGlass(frame, radius, customTransparency)
    radius = radius or 14
    frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    frame.BackgroundTransparency = customTransparency or 0.35 -- True translucent glass

    local bg = Instance.new("UIGradient")
    bg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 56)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 28)),
    })
    bg.Rotation = 90
    bg.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.75
    stroke.Parent = frame

    local rimGrad = Instance.new("UIGradient")
    rimGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.50),  -- Top bright highlight edge
        NumberSequenceKeypoint.new(0.4, 0.85),
        NumberSequenceKeypoint.new(1.0, 0.95),  -- Bottom fade
    })
    rimGrad.Rotation = 90
    rimGrad.Parent = stroke

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, P(radius))
    corner.Parent = frame

    return frame
end

-- Press & Hover Feedback Helpers[cite: 1]
local function makePressable(button, scaleAmount)
    scaleAmount = scaleAmount or 0.96
    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 1
    uiScale.Parent = button

    button.MouseButton1Down:Connect(function()
        tweenService:Create(uiScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = scaleAmount}):Play()
    end)
    button.MouseButton1Up:Connect(function()
        tweenService:Create(uiScale, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
    button.MouseLeave:Connect(function()
        tweenService:Create(uiScale, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1}):Play()
    end)
end

local function addHover(button)
    local lift = Instance.new("Frame")
    lift.BackgroundColor3 = Color3.new(1, 1, 1)
    lift.BackgroundTransparency = 1
    lift.BorderSizePixel = 0
    lift.Size = UDim2.fromScale(1, 1)
    lift.ZIndex = button.ZIndex + 1
    
    local corner = button:FindFirstChildOfClass("UICorner")
    if corner then
        local cCopy = corner:Clone()
        cCopy.Parent = lift
    end
    lift.Parent = button

    button.MouseEnter:Connect(function()
        tweenService:Create(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.90}):Play()
    end)
    button.MouseLeave:Connect(function()
        tweenService:Create(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
    end)
end

-- Notification Toast System[cite: 1]
function MuyeHub:Notify(title, message, tintKey)
    local t = TINTS[tintKey] or TINTS.purple
    local W, H = P(260), P(64)
    local PILL_W, PILL_H = P(120), P(30)

    local cg = Instance.new("CanvasGroup")
    cg.Name = "Toast"
    cg.Parent = coreGui:FindFirstChild("MuyeHubGui") or coreGui
    cg.BackgroundTransparency = 0
    cg.BorderSizePixel = 0
    cg.GroupTransparency = 1
    cg.Size = UDim2.fromOffset(PILL_W, PILL_H)
    cg.AnchorPoint = Vector2.new(0.5, 0)
    cg.Position = UDim2.new(0.5, 0, 0, P(16))
    cg.ZIndex = 200

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, PILL_H / 2)
    corner.Parent = cg
    applyGlass(cg, PILL_H / 2, 0.25)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Parent = cg
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = TS(13)
    titleLbl.TextColor3 = C.TEXT
    titleLbl.Text = title
    titleLbl.Position = UDim2.fromOffset(P(14), P(10))
    titleLbl.Size = UDim2.new(1, -P(28), 0, TS(14))
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 201

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Name = "Message"
    msgLbl.Parent = cg
    msgLbl.BackgroundTransparency = 1
    msgLbl.TextTransparency = 1
    msgLbl.Font = Enum.Font.GothamMedium
    msgLbl.TextSize = TS(11)
    msgLbl.TextColor3 = C.SUBTLE
    msgLbl.Text = message
    msgLbl.Position = UDim2.fromOffset(P(14), P(28))
    msgLbl.Size = UDim2.new(1, -P(28), 0, TS(13))
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.ZIndex = 201

    -- Open Animation
    tweenService:Create(cg, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(W, H)}):Play()
    tweenService:Create(corner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, P(16))}):Play()
    tweenService:Create(cg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0}):Play()
    
    task.delay(0.12, function()
        local info = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tweenService:Create(titleLbl, info, {TextTransparency = 0}):Play()
        tweenService:Create(msgLbl, info, {TextTransparency = 0}):Play()
    end)

    -- Auto Dismiss
    task.delay(3.5, function()
        tweenService:Create(titleLbl, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        tweenService:Create(msgLbl, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        task.delay(0.1, function()
            tweenService:Create(cg, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.fromOffset(PILL_W, PILL_H)}):Play()
            tweenService:Create(corner, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, PILL_H / 2)}):Play()
            tweenService:Create(cg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
        end)
        task.delay(0.5, function() cg:Destroy() end)
    end)
end

-- Create Window & Core UI Layout[cite: 1]
function MuyeHub:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Name or "Muye-Hub"
    local tintKey = config.Tint or "purple"
    local accent = TINTS[tintKey] or TINTS.purple

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MuyeHubGui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() screenGui.Parent = coreGui end)
    if not screenGui.Parent then screenGui.Parent = localPlayer:WaitForChild("PlayerGui") end

    -- Main Translucent Glass Window
    local window = Instance.new("CanvasGroup")
    window.Name = "Window"
    window.Parent = screenGui
    window.BorderSizePixel = 0
    window.GroupTransparency = 1
    local wW, wH = P(580), P(380)
    window.Size = UDim2.fromOffset(wW, wH)
    window.Position = UDim2.new(0.5, -wW/2, 0.5, -wH/2 + P(10))
    window.ZIndex = 50
    applyGlass(window, 14, 0.32) -- Gorgeous frosted glass transparency

    -- Drop Shadow[cite: 1]
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Parent = window
    shadow.BackgroundTransparency = 1
    shadow.BorderSizePixel = 0
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, P(50), 1, P(50))
    shadow.ZIndex = window.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.new(0, 0, 0)
    shadow.ImageTransparency = 0.35
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)

    -- Entrance animation[cite: 1]
    tweenService:Create(window, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -wW/2, 0.5, -wH/2),
        GroupTransparency = 0
    }):Play()

    -- Title Bar & Dragging
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Parent = window
    titleBar.BackgroundTransparency = 1
    titleBar.Size = UDim2.new(1, 0, 0, P(46))
    titleBar.ZIndex = 51

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Parent = titleBar
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = TS(15)
    titleLbl.TextColor3 = C.TEXT
    titleLbl.Text = windowTitle
    titleLbl.Position = UDim2.fromOffset(P(16), 0)
    titleLbl.Size = UDim2.new(0, P(200), 1, 0)
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 52

    local badge = Instance.new("Frame")
    badge.Name = "Badge"
    badge.Parent = titleBar
    badge.BackgroundColor3 = accent[1]
    badge.BackgroundTransparency = 0.2
    badge.BorderSizePixel = 0
    badge.Position = UDim2.fromOffset(P(16) + titleLbl.TextBounds.X + P(10), P(15))
    badge.Size = UDim2.fromOffset(P(54), P(18))
    badge.ZIndex = 52
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, P(6))

    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Parent = badge
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Font = Enum.Font.GothamBold
    badgeLbl.TextSize = TS(10)
    badgeLbl.TextColor3 = accent[2]
    badgeLbl.Text = "V1.1"
    badgeLbl.Size = UDim2.fromScale(1, 1)
    badgeLbl.ZIndex = 53

    -- Dragging Handler
    local dragging, dragInput, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end
    end)

    -- Sidebar (Tabs Navigation)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = window
    sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    sidebar.BackgroundTransparency = 0.5
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.fromOffset(P(12), P(48))
    sidebar.Size = UDim2.new(0, P(140), 1, -P(60))
    sidebar.ZIndex = 51
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, P(10))

    local tabsList = Instance.new("ScrollingFrame")
    tabsList.Name = "TabsList"
    tabsList.Parent = sidebar
    tabsList.BackgroundTransparency = 1
    tabsList.BorderSizePixel = 0
    tabsList.Position = UDim2.fromOffset(P(6), P(6))
    tabsList.Size = UDim2.new(1, -P(12), 1, -P(12))
    tabsList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsList.ScrollBarThickness = 0
    tabsList.ZIndex = 52

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabsList
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, P(6))

    -- Pages Container Frame
    local pagesContainer = Instance.new("Frame")
    pagesContainer.Name = "PagesContainer"
    pagesContainer.Parent = window
    pagesContainer.BackgroundTransparency = 1
    pagesContainer.BorderSizePixel = 0
    pagesContainer.Position = UDim2.fromOffset(P(162), P(48))
    pagesContainer.Size = UDim2.new(1, -P(174), 1, -P(60))
    pagesContainer.ZIndex = 51

    local windowObj = {
        TabsList = tabsList,
        PagesContainer = pagesContainer,
        Accent = accent,
        ActiveTab = nil,
        TabCount = 0
    }

    -- Tab System API
    function windowObj:AddTab(tabName)
        windowObj.TabCount = windowObj.TabCount + 1
        local index = windowObj.TabCount

        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabName
        tabBtn.Parent = windowObj.TabsList
        tabBtn.BackgroundColor3 = Color3.new(1, 1, 1)
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Size = UDim2.new(1, 0, 0, P(36))
        tabBtn.AutoButtonColor = false
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = TS(12)
        tabBtn.TextColor3 = C.SUBTLE
        tabBtn.Text = "  " .. tabName
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        tabBtn.ZIndex = 53
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, P(8))
        addHover(tabBtn)
        makePressable(tabBtn, 0.97)

        local page = Instance.new("CanvasGroup")
        page.Name = "Page_" .. tabName
        page.Parent = windowObj.PagesContainer
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.fromScale(1, 1)
        page.Visible = false
        page.GroupTransparency = 1
        page.ZIndex = 52

        local pageScroll = Instance.new("ScrollingFrame")
        pageScroll.Name = "Content"
        pageScroll.Parent = page
        pageScroll.BackgroundTransparency = 1
        pageScroll.BorderSizePixel = 0
        pageScroll.Size = UDim2.fromScale(1, 1)
        pageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        pageScroll.ScrollBarThickness = P(3)
        pageScroll.ScrollBarImageColor3 = accent[2]
        pageScroll.ZIndex = 53

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Parent = pageScroll
        pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        pageLayout.Padding = UDim.new(0, P(8))
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            pageScroll.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + P(10))
        end)

        local function selectTab()
            if windowObj.ActiveTab == tabName then return end
            windowObj.ActiveTab = tabName

            for _, child in ipairs(windowObj.PagesContainer:GetChildren()) do
                if child:IsA("CanvasGroup") then
                    if child.Visible then
                        tweenService:Create(child, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {GroupTransparency = 1}):Play()
                        task.delay(0.15, function() child.Visible = false end)
                    end
                end
            end

            for _, btn in ipairs(windowObj.TabsList:GetChildren()) do
                if btn:IsA("TextButton") then
                    tweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                        TextColor3 = C.SUBTLE,
                        BackgroundTransparency = 1
                    }):Play()
                end
            end

            tweenService:Create(tabBtn, TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                TextColor3 = C.TEXT,
                BackgroundTransparency = 0.75
            }):Play()
            tabBtn.BackgroundColor3 = accent[2]

            page.Visible = true
            page.Position = UDim2.fromOffset(0, P(8))
            page.GroupTransparency = 1

            tweenService:Create(page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.fromOffset(0, 0),
                GroupTransparency = 0
            }):Play()
        end

        tabBtn.MouseButton1Click:Connect(selectTab)
        if index == 1 then selectTab() end

        local tabObj = {}

        -- Glass Toggle Component
        function tabObj:AddToggle(label, subLabel, default, callback)
            local ROW_H = P(46)
            local row = Instance.new("TextButton")
            row.Name = "Toggle_" .. label
            row.Parent = pageScroll
            row.BackgroundTransparency = 0.65
            row.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            row.BorderSizePixel = 0
            row.Text = ""
            row.AutoButtonColor = false
            row.Size = UDim2.new(1, 0, 0, ROW_H)
            row.ZIndex = 54
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, P(10))
            makePressable(row, 0.985)
            addHover(row)

            local mainLbl = Instance.new("TextLabel")
            mainLbl.Parent = row
            mainLbl.BackgroundTransparency = 1
            mainLbl.Font = Enum.Font.GothamBold
            mainLbl.TextSize = TS(12)
            mainLbl.TextColor3 = C.TEXT
            mainLbl.Text = label
            mainLbl.TextXAlignment = Enum.TextXAlignment.Left
            mainLbl.ZIndex = 55

            if subLabel then
                mainLbl.Position = UDim2.fromOffset(P(12), math.floor(ROW_H / 2) - TS(14))
                mainLbl.Size = UDim2.new(1, -P(70), 0, TS(14))
                local subLbl = Instance.new("TextLabel")
                subLbl.Parent = row
                subLbl.BackgroundTransparency = 1
                subLbl.Font = Enum.Font.GothamMedium
                subLbl.TextSize = TS(10)
                subLbl.TextColor3 = C.SUBTLE
                subLbl.Text = subLabel
                subLbl.TextXAlignment = Enum.TextXAlignment.Left
                subLbl.Position = UDim2.fromOffset(P(12), math.floor(ROW_H / 2) + 2)
                subLbl.Size = UDim2.new(1, -P(70), 0, TS(12))
                subLbl.ZIndex = 55
            else
                mainLbl.Position = UDim2.fromOffset(P(12), 0)
                mainLbl.Size = UDim2.new(1, -P(70), 1, 0)
            end

            local trackW, trackH = P(40), P(22)
            local track = Instance.new("Frame")
            track.Parent = row
            track.BackgroundColor3 = default and accent[2] or C.OFF
            track.BorderSizePixel = 0
            track.AnchorPoint = Vector2.new(1, 0.5)
            track.Position = UDim2.new(1, -P(12), 0.5, 0)
            track.Size = UDim2.fromOffset(trackW, trackH)
            track.ZIndex = 55
            Instance.new("UICorner", track).CornerRadius = UDim.new(0, trackH / 2)

            local knob = Instance.new("Frame")
            knob.Parent = track
            knob.BackgroundColor3 = Color3.new(1, 1, 1)
            knob.BorderSizePixel = 0
            knob.AnchorPoint = Vector2.new(0, 0.5)
            knob.Size = UDim2.fromOffset(P(16), P(16))
            knob.Position = default and UDim2.new(1, -(P(16) + P(3)), 0.5, 0) or UDim2.fromOffset(P(3), 0)
            knob.ZIndex = 56
            Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

            local active = default and true or false
            local function setState(v)
                active = v
                local tInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                tweenService:Create(track, tInfo, {BackgroundColor3 = v and accent[2] or C.OFF}):Play()
                tweenService:Create(knob, tInfo, {
                    Position = v and UDim2.new(1, -(P(16) + P(3)), 0.5, 0) or UDim2.fromOffset(P(3), 0)
                }):Play()
                if callback then pcall(callback, v) end
            end

            row.MouseButton1Click:Connect(function() setState(not active) end)
            return {Set = setState}
        end

        -- Glass Button Component
        function tabObj:AddButton(label, callback)
            local btnH = P(40)
            local btn = Instance.new("TextButton")
            btn.Name = "Button_" .. label
            btn.Parent = pageScroll
            btn.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            btn.BackgroundTransparency = 0.65
            btn.BorderSizePixel = 0
            btn.Size = UDim2.new(1, 0, 0, btnH)
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.ZIndex = 54
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, P(10))
            makePressable(btn, 0.98)
            addHover(btn)

            local lbl = Instance.new("TextLabel")
            lbl.Parent = btn
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = TS(12)
            lbl.TextColor3 = C.TEXT
            lbl.Text = label
            lbl.Size = UDim2.fromScale(1, 1)
            lbl.ZIndex = 55

            btn.MouseButton1Click:Connect(function()
                if callback then pcall(callback) end
            end)
        end

        -- Glass Slider Component
        function tabObj:AddSlider(label, min, max, default, callback)
            local sliderH = P(54)
            local row = Instance.new("Frame")
            row.Name = "Slider_" .. label
            row.Parent = pageScroll
            row.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
            row.BackgroundTransparency = 0.65
            row.BorderSizePixel = 0
            row.Size = UDim2.new(1, 0, 0, sliderH)
            row.ZIndex = 54
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, P(10))

            local lbl = Instance.new("TextLabel")
            lbl.Parent = row
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = TS(12)
            lbl.TextColor3 = C.TEXT
            lbl.Text = label
            lbl.Position = UDim2.fromOffset(P(12), P(8))
            lbl.Size = UDim2.new(1, -P(24), 0, TS(14))
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex = 55

            local valLbl = Instance.new("TextLabel")
            valLbl.Parent = row
            valLbl.BackgroundTransparency = 1
            valLbl.Font = Enum.Font.GothamBold
            valLbl.TextSize = TS(11)
            valLbl.TextColor3 = accent[2]
            valLbl.Text = tostring(default)
            valLbl.Position = UDim2.new(1, -P(50), 0, P(8))
            valLbl.Size = UDim2.new(0, P(38), 0, TS(14))
            valLbl.TextXAlignment = Enum.TextXAlignment.Right
            valLbl.ZIndex = 55

            local trackBar = Instance.new("TextButton")
            trackBar.Parent = row
            trackBar.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
            trackBar.BorderSizePixel = 0
            trackBar.Position = UDim2.fromOffset(P(12), P(34))
            trackBar.Size = UDim2.new(1, -P(24), 0, P(6))
            trackBar.AutoButtonColor = false
            trackBar.Text = ""
            trackBar.ZIndex = 55
            Instance.new("UICorner", trackBar).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame")
            fill.Parent = trackBar
            fill.BackgroundColor3 = accent[2]
            fill.BorderSizePixel = 0
            fill.Size = UDim2.new(math.clamp((default - min) / (max - min), 0, 1), 0, 1, 0)
            fill.ZIndex = 56
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local dragging = false
            local function updateSlider(input)
                local pos = math.clamp((input.Position.X - trackBar.AbsolutePosition.X) / trackBar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ((max - min) * pos))
                fill.Size = UDim2.new(pos, 0, 1, 0)
                valLbl.Text = tostring(val)
                if callback then pcall(callback, val) end
            end

            trackBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    updateSlider(input)
                end
            end)
            userInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input)
                end
            end)
            userInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end

        return tabObj
    end

    return windowObj
end

return MuyeHub
