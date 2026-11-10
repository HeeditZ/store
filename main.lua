--[[
    ─────────────────────────────────────────────────────────────
    MUYE UI  ·  Premium Glassmorphism
    Single-file · loadstring-ready
    ─────────────────────────────────────────────────────────────
]]

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ── gui parent ─────────────────────────────────────────────────
local function getGuiParent()
    local ok = pcall(function()
        local t = Instance.new("ScreenGui")
        t.Parent = CoreGui
        t:Destroy()
    end)
    if ok then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local GUI_PARENT = getGuiParent()

-- ── scale ──────────────────────────────────────────────────────
local vp  = workspace.CurrentCamera.ViewportSize
local sc  = math.clamp(math.min((vp.X - 32) / 740, (vp.Y - 40) / 520), 0.55, 1)
local function P(n)  return math.floor(n * sc + 0.5) end
local function TS(n) return math.max(9, math.floor(n * sc + 0.5)) end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ── palette (glassy cyan) ──────────────────────────────────────
local C = {
    TEXT    = Color3.fromRGB(242, 242, 244),
    SUBTLE  = Color3.fromRGB(150, 150, 156),
    INK     = Color3.fromRGB(12, 14, 18),
    CYAN    = Color3.fromRGB(64, 220, 255),
    CYAN_DK = Color3.fromRGB(10, 32, 40),
    OFF     = Color3.fromRGB(58, 58, 62),
    RIM     = Color3.new(1, 1, 1),
}

local TINTS = {
    cyan   = { Color3.fromRGB(10, 32, 40),  Color3.fromRGB(64, 220, 255) },
    blue   = { Color3.fromRGB(13, 40, 51),  Color3.fromRGB(64, 186, 255) },
    purple = { Color3.fromRGB(38, 28, 62),  Color3.fromRGB(168, 120, 255) },
    teal   = { Color3.fromRGB(14, 46, 40),  Color3.fromRGB(56, 224, 186) },
    orange = { Color3.fromRGB(62, 36, 16),  Color3.fromRGB(255, 150, 50) },
    red    = { Color3.fromRGB(62, 20, 24),  Color3.fromRGB(255, 96, 96) },
}

-- ── Glass Surface (STRICT SKILL IMPLEMENTATION) ────────────────
local function applyGlass(frame, radius, tintMode)
    radius = radius or 14

    -- Custom gradient for the glassy cyan vibe
    local bg = Instance.new("UIGradient")
    if tintMode == "cyan" then
        bg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 40, 48)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 14, 18)),
        })
    else
        bg.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 30, 36)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 15, 18)),
        })
    end
    bg.Rotation = 90
    bg.Parent = frame

    -- Rim stroke (top bright, bottom invisible)
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = C.RIM
    stroke.Thickness = 1
    stroke.Transparency = 0.86
    stroke.Parent = frame

    local rimGrad = Instance.new("UIGradient")
    rimGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0.86),
        NumberSequenceKeypoint.new(0.4,  0.96),
        NumberSequenceKeypoint.new(1.0,  0.97),
    })
    rimGrad.Rotation = 90
    rimGrad.Parent = stroke

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, P(radius))
    corner.Parent = frame

    return frame
end

-- ── Press Feedback ─────────────────────────────────────────────
local function makePressable(obj, amount)
    amount = amount or 0.96
    local us = Instance.new("UIScale")
    us.Scale = 1
    us.Parent = obj
    obj.MouseButton1Down:Connect(function()
        tween(us, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = amount})
    end)
    obj.MouseButton1Up:Connect(function()
        tween(us, TweenInfo.new(0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1})
    end)
    obj.MouseLeave:Connect(function()
        tween(us, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Scale = 1})
    end)
end

-- ── Hover Lift ─────────────────────────────────────────────────
local function applyLift(btn, cornerRadius)
    local lift = Instance.new("Frame")
    lift.BackgroundColor3 = Color3.new(1, 1, 1)
    lift.BackgroundTransparency = 1
    lift.BorderSizePixel = 0
    lift.Size = UDim2.fromScale(1, 1)
    lift.ZIndex = btn.ZIndex + 1
    Instance.new("UICorner", lift).CornerRadius = UDim.new(0, P(cornerRadius or 8))
    lift.Parent = btn

    btn.MouseEnter:Connect(function()
        tween(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.95})
    end)
    btn.MouseLeave:Connect(function()
        tween(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    end)
    return lift
end

-- ── softButton ─────────────────────────────────────────────────
local function softButton(parent, x, y, w, h, bgColor, cornerRadius)
    cornerRadius = cornerRadius or math.floor(h / 2)
    bgColor = bgColor or Color3.fromRGB(28, 28, 32)

    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = bgColor
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Position = UDim2.fromOffset(P(x), P(y))
    btn.Size = UDim2.fromOffset(P(w), P(h))
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.ZIndex = 10
    btn.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 38, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(24, 24, 28)),
    })
    grad.Rotation = 90
    grad.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.new(1, 1, 1)
    stroke.Thickness = 1
    stroke.Transparency = 0.86
    stroke.Parent = btn

    local rimG = Instance.new("UIGradient")
    rimG.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.86),
        NumberSequenceKeypoint.new(0.4, 0.96),
        NumberSequenceKeypoint.new(1.0, 0.97),
    })
    rimG.Rotation = 90
    rimG.Parent = stroke

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, P(cornerRadius))

    applyLift(btn, cornerRadius)
    makePressable(btn)
    return btn
end

-- ── Group Container ────────────────────────────────────────────
local function makeGroup(parent, y, h, cornerRadius)
    cornerRadius = cornerRadius or 14
    local g = Instance.new("Frame")
    g.BackgroundColor3 = Color3.new(1, 1, 1)
    g.BackgroundTransparency = 0.955
    g.BorderSizePixel = 0
    g.Position = UDim2.fromOffset(0, P(y))
    g.Size = UDim2.new(1, 0, 0, P(h))
    g.ZIndex = 20
    Instance.new("UICorner", g).CornerRadius = UDim.new(0, P(cornerRadius))
    g.Parent = parent
    return g
end

-- ═══════════════════════════════════════════════════════════════
--  COMPONENTS
-- ═══════════════════════════════════════════════════════════════

-- Toggle Row ───────────────────────────────────────────────────
local function makeToggleRow(parent, opts)
    opts = opts or {}
    local row = Instance.new("TextButton")
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Size = UDim2.new(1, 0, 0, P(48))
    row.ZIndex = 21
    row.Parent = parent
    applyLift(row, 8)
    makePressable(row, 0.985)

    local mainLbl = Instance.new("TextLabel")
    mainLbl.BackgroundTransparency = 1
    mainLbl.Font = Enum.Font.GothamBold
    mainLbl.TextSize = TS(13)
    mainLbl.TextColor3 = C.TEXT
    mainLbl.Text = opts.Title or "Toggle"
    mainLbl.TextXAlignment = Enum.TextXAlignment.Left
    mainLbl.TextTruncate = Enum.TextTruncate.AtEnd
    mainLbl.Position = UDim2.fromOffset(P(14), P(8))
    mainLbl.Size = UDim2.new(1, -P(80), 0, P(16))
    mainLbl.ZIndex = 22
    mainLbl.Parent = row

    if opts.Description then
        local subLbl = Instance.new("TextLabel")
        subLbl.BackgroundTransparency = 1
        subLbl.Font = Enum.Font.GothamMedium
        subLbl.TextSize = TS(11)
        subLbl.TextColor3 = C.SUBTLE
        subLbl.Text = opts.Description
        subLbl.TextXAlignment = Enum.TextXAlignment.Left
        subLbl.TextTruncate = Enum.TextTruncate.AtEnd
        subLbl.Position = UDim2.fromOffset(P(14), P(26))
        subLbl.Size = UDim2.new(1, -P(80), 0, P(13))
        subLbl.ZIndex = 22
        subLbl.Parent = row
    end

    local switchW, switchH = P(44), P(26)
    local track = Instance.new("Frame")
    track.BackgroundColor3 = opts.Value and TINTS.cyan[2] or C.OFF
    track.BorderSizePixel = 0
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -P(14), 0.5, 0)
    track.Size = UDim2.fromOffset(switchW, switchH)
    track.ZIndex = 22
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, switchH / 2)

    local knob = Instance.new("Frame")
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.fromOffset(P(20), P(20))
    knob.Position = opts.Value and UDim2.new(1, -(P(20) + P(3)), 0.5, 0) or UDim2.fromOffset(P(3), 0)
    knob.ZIndex = 23
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0.5, 0)

    local active = opts.Value and true or false
    local function setState(v, animate)
        active = v and true or false
        local info = animate and TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) or TweenInfo.new(0)
        tween(track, info, {BackgroundColor3 = active and TINTS.cyan[2] or C.OFF})
        tween(knob, info, {
            Position = active and UDim2.new(1, -(P(20) + P(3)), 0.5, 0) or UDim2.fromOffset(P(3), 0)
        })
        if opts.Callback then task.spawn(opts.Callback, active) end
    end

    row.MouseButton1Click:Connect(function() setState(not active, true) end)
    
    return {
        Set = function(_, v) setState(v, true) end,
        Get = function() return active end,
        Row = row
    }
end

-- Slider ───────────────────────────────────────────────────────
local function makeSlider(parent, opts)
    opts = opts or {}
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local rounding = opts.Rounding or 1
    local value = opts.Value or minV

    local row = Instance.new("TextButton")
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Size = UDim2.new(1, 0, 0, P(56))
    row.ZIndex = 21
    row.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = TS(13)
    lbl.TextColor3 = C.TEXT
    lbl.Text = opts.Title or "Slider"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.fromOffset(P(14), P(8))
    lbl.Size = UDim2.new(1, -P(120), 0, P(16))
    lbl.ZIndex = 22
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = TS(12)
    valLbl.TextColor3 = C.CYAN
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Position = UDim2.new(1, -P(90), 0, P(8))
    valLbl.Size = UDim2.fromOffset(P(76), P(16))
    valLbl.ZIndex = 22
    valLbl.Parent = row

    local trackY = P(38)
    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, P(14), 0, trackY)
    track.Size = UDim2.new(1, -P(28), 0, P(5))
    track.BackgroundColor3 = Color3.new(1, 1, 1)
    track.BackgroundTransparency = 0.9
    track.BorderSizePixel = 0
    track.ZIndex = 22
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.CYAN
    fill.BorderSizePixel = 0
    fill.ZIndex = 23
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(P(12), P(12))
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 24
    knob.Parent = track
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local kstroke = Instance.new("UIStroke")
    kstroke.Color = C.CYAN
    kstroke.Thickness = 2
    kstroke.Transparency = 0
    kstroke.Parent = knob

    local function fmt(v)
        if rounding >= 1 then return tostring(math.floor(v + 0.5)) end
        return string.format("%.2f", v)
    end

    local function set(v, animate, silent)
        v = math.clamp(v, minV, maxV)
        if rounding > 0 then v = math.floor(v / rounding + 0.5) * rounding end
        value = v
        local span = maxV - minV
        local a = span ~= 0 and (v - minV) / span or 0
        local info = animate and TweenInfo.new(0.12, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) or TweenInfo.new(0)
        tween(fill, info, {Size = UDim2.new(a, 0, 1, 0)})
        tween(knob, info, {Position = UDim2.new(a, 0, 0.5, 0)})
        valLbl.Text = fmt(v)
        if not silent and opts.Callback then task.spawn(opts.Callback, v) end
    end

    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.AutoButtonColor = false
    hit.Position = UDim2.new(0, 0, 0, trackY - P(9))
    hit.Size = UDim2.new(1, 0, 0, P(24))
    hit.ZIndex = 25
    hit.Parent = row

    local dragging = false
    local function applyInput(input)
        local ax = track.AbsolutePosition.X
        local aw = track.AbsoluteSize.X
        if aw <= 0 then return end
        local rel = math.clamp((input.Position.X - ax) / aw, 0, 1)
        set(minV + (maxV - minV) * rel, true)
    end

    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            applyInput(input)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            applyInput(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    set(value, false, true)

    return {
        Set = function(_, v) set(v, true) end,
        Get = function() return value end,
        Row = row
    }
end

-- Button Row ───────────────────────────────────────────────────
local function makeButtonRow(parent, opts)
    opts = opts or {}
    local row = Instance.new("TextButton")
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Size = UDim2.new(1, 0, 0, P(44))
    row.ZIndex = 21
    row.Parent = parent
    applyLift(row, 8)
    makePressable(row, 0.97)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = TS(13)
    lbl.TextColor3 = C.TEXT
    lbl.Text = opts.Title or "Button"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Position = UDim2.fromOffset(P(14), 0)
    lbl.Size = UDim2.new(1, -P(30), 1, 0)
    lbl.ZIndex = 22
    lbl.Parent = row

    local chev = Instance.new("TextLabel")
    chev.BackgroundTransparency = 1
    chev.Font = Enum.Font.GothamBold
    chev.TextSize = TS(14)
    chev.TextColor3 = C.SUBTLE
    chev.Text = "›"
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -P(14), 0.5, 0)
    chev.Size = UDim2.fromOffset(P(14), P(16))
    chev.ZIndex = 22
    chev.Parent = row

    row.MouseButton1Click:Connect(function()
        if opts.Callback then task.spawn(opts.Callback) end
    end)

    return { Row = row }
end

-- ═══════════════════════════════════════════════════════════════
--  NOTIFICATIONS
-- ═══════════════════════════════════════════════════════════════
local NotificationGui
local toasts = {}

local function ensureNotifGui()
    if NotificationGui and NotificationGui.Parent then return NotificationGui end
    NotificationGui = Instance.new("ScreenGui")
    NotificationGui.Name = "MuyeNotifications"
    NotificationGui.ResetOnSpawn = false
    NotificationGui.IgnoreGuiInset = true
    NotificationGui.DisplayOrder = 200
    NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    NotificationGui.Parent = GUI_PARENT
    return NotificationGui
end

local function createToast(opts)
    opts = opts or {}
    ensureNotifGui()

    local titleText = opts.Title or "Notification"
    local message = opts.Message or ""
    local duration = opts.Duration or 4
    local tint = TINTS[opts.Tint or "cyan"] or TINTS.cyan

    local W, H = P(280), P(64)
    local PILL_W, PILL_H = P(120), P(30)

    local cg = Instance.new("CanvasGroup")
    cg.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    cg.BorderSizePixel = 0
    cg.GroupTransparency = 1
    cg.Size = UDim2.fromOffset(PILL_W, PILL_H)
    cg.AnchorPoint = Vector2.new(1, 0)
    cg.Position = UDim2.new(1, -P(18), 0, P(18))
    cg.ZIndex = 100
    cg.Parent = NotificationGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, PILL_H / 2)
    corner.Parent = cg
    applyGlass(cg, PILL_H / 2)

    local tl = Instance.new("TextLabel")
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = TS(13)
    tl.TextColor3 = C.TEXT
    tl.Text = titleText
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextTransparency = 1
    tl.Position = UDim2.fromOffset(P(14), P(10))
    tl.Size = UDim2.new(1, -P(28), 0, TS(14))
    tl.ZIndex = 101
    tl.Parent = cg

    local ml = Instance.new("TextLabel")
    ml.BackgroundTransparency = 1
    ml.Font = Enum.Font.GothamMedium
    ml.TextSize = TS(11)
    ml.TextColor3 = C.SUBTLE
    ml.Text = message
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.TextTransparency = 1
    ml.Position = UDim2.fromOffset(P(14), P(28))
    ml.Size = UDim2.new(1, -P(28), 0, TS(13))
    ml.ZIndex = 101
    ml.Parent = cg

    tween(cg, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(W, H)})
    tween(corner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, P(16))})
    tween(cg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0})
    
    task.delay(0.12, function()
        local info = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(tl, info, {TextTransparency = 0})
        tween(ml, info, {TextTransparency = 0})
    end)

    local function dismiss()
        local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(tl, info, {TextTransparency = 1})
        tween(ml, info, {TextTransparency = 1})
        task.delay(0.1, function()
            tween(cg, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {Size = UDim2.fromOffset(PILL_W, PILL_H), GroupTransparency = 1})
            tween(corner, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {CornerRadius = UDim.new(0, PILL_H / 2)})
        end)
        task.delay(0.5, function() cg:Destroy() end)
    end

    task.delay(duration, dismiss)
    return { dismiss = dismiss }
end

-- ═══════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local loadingShown = false

local function playLoading(onComplete)
    local sg = Instance.new("ScreenGui")
    sg.Name = "MuyeLoading"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 999
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = GUI_PARENT

    local cg = Instance.new("CanvasGroup")
    cg.Size = UDim2.fromScale(1, 1)
    cg.BackgroundColor3 = Color3.fromRGB(6, 10, 14)
    cg.BorderSizePixel = 0
    cg.GroupTransparency = 0
    cg.Parent = sg

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.new(0.5, 0, 0.5, -P(30))
    title.Size = UDim2.fromOffset(P(400), P(70))
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "MUYE"
    title.TextSize = TS(48)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextTransparency = 1
    title.ZIndex = 2
    title.Parent = cg

    local titleGrad = Instance.new("UIGradient")
    titleGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 240, 255)),
    })
    titleGrad.Offset = Vector2.new(-1, 0) -- FIXED: Vector2 instead of UDim2
    titleGrad.Parent = title

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.Position = UDim2.new(0.5, 0, 0.5, P(6))
    sub.Size = UDim2.fromOffset(P(300), P(16))
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.GothamBold
    sub.Text = "H  U  B"
    sub.TextSize = TS(12)
    sub.TextColor3 = C.SUBTLE
    sub.TextTransparency = 1
    sub.ZIndex = 2
    sub.Parent = cg

    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.Position = UDim2.new(0.5, 0, 0.5, P(34))
    barBg.Size = UDim2.fromOffset(P(240), P(4))
    barBg.BackgroundColor3 = Color3.new(1, 1, 1)
    barBg.BackgroundTransparency = 1
    barBg.BorderSizePixel = 0
    barBg.ZIndex = 2
    barBg.Parent = cg
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = C.CYAN
    barFill.BorderSizePixel = 0
    barFill.ZIndex = 3
    barFill.Parent = barBg
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    task.spawn(function()
        task.wait(0.05)
        tween(title, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0})
        task.wait(0.15)
        tween(sub, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
        tween(barBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.86})

        task.spawn(function()
            for _ = 1, 2 do
                titleGrad.Offset = Vector2.new(-1, 0)
                tween(titleGrad, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)})
                task.wait(1.0)
            end
        end)

        tween(barFill, TweenInfo.new(1.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})
        task.wait(2.0)
        
        tween(cg, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 1})
        task.wait(0.5)
        sg:Destroy()
        if onComplete then onComplete() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY MAIN
-- ═══════════════════════════════════════════════════════════════
local Muye = {}
Muye.__index = Muye

function Muye:CreateWindow(opts)
    opts = opts or {}

    local titleText    = opts.Title or "Muye-Hub"
    local subtitleText = opts.Subtitle or ""
    local size         = opts.Size or Vector2.new(740, 500)
    local showLoading  = (opts.LoadingScreen ~= false) and (not loadingShown)
    local toggleKey    = opts.ToggleKey or Enum.KeyCode.RightShift

    local W, H = P(size.X), P(size.Y)

    local sg = Instance.new("ScreenGui")
    sg.Name = "MuyeUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 100
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = GUI_PARENT

    -- Background Shadow Glow
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Glow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, P(80), 1, P(80))
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = C.CYAN
    shadow.ImageTransparency = 0.85
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 49
    shadow.Parent = sg

    -- Root (CanvasGroup for unified fade)
    local root = Instance.new("CanvasGroup")
    root.Size = UDim2.fromOffset(W, H)
    root.AnchorPoint = Vector2.new(0.5, 0.5)
    root.Position = UDim2.new(0.5, 0, 0.5, 0)
    root.BackgroundTransparency = 1
    root.BorderSizePixel = 0
    root.GroupTransparency = 1
    root.Visible = false
    root.ZIndex = 50
    root.Parent = sg

    local restPos = UDim2.new(0.5, 0, 0.5, 0)

    -- Main Window Glass
    local win = Instance.new("Frame")
    win.Size = UDim2.fromScale(1, 1)
    win.BackgroundColor3 = C.INK
    win.BorderSizePixel = 0
    win.ZIndex = 50
    win.Parent = root
    applyGlass(win, 16, "cyan") -- Use cyan tint for the main body

    -- Sidebar
    local SIDEBAR_W = P(168)
    local sidebar = Instance.new("Frame")
    sidebar.Size = UDim2.fromOffset(SIDEBAR_W, H)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 51
    sidebar.Parent = win

    -- Sidebar Glass Panel (Adds depth)
    local sidebarGlass = Instance.new("Frame")
    sidebarGlass.Size = UDim2.fromScale(1, 1)
    sidebarGlass.BackgroundColor3 = Color3.new(1, 1, 1)
    sidebarGlass.BackgroundTransparency = 1
    sidebarGlass.BorderSizePixel = 0
    sidebarGlass.ZIndex = 51
    sidebarGlass.Parent = sidebar
    applyGlass(sidebarGlass, 16)

    local logo = Instance.new("TextLabel")
    logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = TS(18)
    logo.TextColor3 = Color3.new(1, 1, 1)
    logo.Text = "MUYE"
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Position = UDim2.fromOffset(P(20), P(18))
    logo.Size = UDim2.new(1, -P(30), 0, P(22))
    logo.ZIndex = 52
    logo.Parent = sidebar

    local logoGrad = Instance.new("UIGradient")
    logoGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 240, 255)),
        ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1)),
    })
    logoGrad.Rotation = 0
    logoGrad.Parent = logo

    local logoSub = Instance.new("TextLabel")
    logoSub.BackgroundTransparency = 1
    logoSub.Font = Enum.Font.GothamBold
    logoSub.TextSize = TS(9)
    logoSub.TextColor3 = C.SUBTLE
    logoSub.Text = "P R E M I U M"
    logoSub.TextXAlignment = Enum.TextXAlignment.Left
    logoSub.Position = UDim2.fromOffset(P(21), P(42))
    logoSub.Size = UDim2.new(1, -P(30), 0, P(12))
    logoSub.ZIndex = 52
    logoSub.Parent = sidebar

    local tabList = Instance.new("ScrollingFrame")
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.Position = UDim2.fromOffset(P(10), P(70))
    tabList.Size = UDim2.new(1, -P(20), 1, -P(100))
    tabList.ScrollBarThickness = P(2)
    tabList.ScrollBarImageColor3 = C.CYAN
    tabList.ScrollBarImageTransparency = 0.7
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabList.ScrollingDirection = Enum.ScrollingDirection.Y
    tabList.ZIndex = 52
    tabList.Parent = sidebar

    local tlLayout = Instance.new("UIListLayout")
    tlLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tlLayout.Padding = UDim.new(0, P(4))
    tlLayout.Parent = tabList

    local vLine = Instance.new("Frame")
    vLine.BackgroundColor3 = Color3.new(1, 1, 1)
    vLine.BackgroundTransparency = 0.94
    vLine.BorderSizePixel = 0
    vLine.Position = UDim2.fromOffset(SIDEBAR_W, P(16))
    vLine.Size = UDim2.new(0, 1, 1, -P(32))
    vLine.ZIndex = 52
    vLine.Parent = win

    -- Content Area
    local content = Instance.new("Frame")
    content.Position = UDim2.fromOffset(SIDEBAR_W, 0)
    content.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ZIndex = 51
    content.Parent = win

    local topbar = Instance.new("Frame")
    topbar.Size = UDim2.new(1, 0, 0, P(60))
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel = 0
    topbar.ZIndex = 52
    topbar.Parent = content

    local winTitle = Instance.new("TextLabel")
    winTitle.BackgroundTransparency = 1
    winTitle.Font = Enum.Font.GothamBold
    winTitle.TextSize = TS(15)
    winTitle.TextColor3 = C.TEXT
    winTitle.Text = titleText
    winTitle.TextXAlignment = Enum.TextXAlignment.Left
    winTitle.Position = UDim2.fromOffset(P(18), P(12))
    winTitle.Size = UDim2.new(1, -P(100), 0, P(18))
    winTitle.ZIndex = 53
    winTitle.Parent = topbar

    if subtitleText ~= "" then
        local ws = Instance.new("TextLabel")
        ws.BackgroundTransparency = 1
        ws.Font = Enum.Font.GothamMedium
        ws.TextSize = TS(10)
        ws.TextColor3 = C.SUBTLE
        ws.Text = subtitleText
        ws.TextXAlignment = Enum.TextXAlignment.Left
        ws.Position = UDim2.fromOffset(P(18), P(30))
        ws.Size = UDim2.new(1, -P(100), 0, P(14))
        ws.ZIndex = 53
        ws.Parent = topbar
    end

    -- Window Controls
    local closeBtn = softButton(topbar, 0, 0, 26, 26)
    closeBtn.Position = UDim2.new(1, -P(14) - P(26), 0, P(16))
    closeBtn.ZIndex = 54
    local closeTxt = Instance.new("TextLabel")
    closeTxt.Size = UDim2.fromScale(1, 1)
    closeTxt.BackgroundTransparency = 1
    closeTxt.Text = "✕"
    closeTxt.TextColor3 = C.TEXT
    closeTxt.Font = Enum.Font.GothamBold
    closeTxt.TextSize = TS(12)
    closeTxt.ZIndex = 55
    closeTxt.Parent = closeBtn

    local minBtn = softButton(topbar, 0, 0, 26, 26)
    minBtn.Position = UDim2.new(1, -P(14) - P(26) - P(8) - P(26), 0, P(16))
    minBtn.ZIndex = 54
    local minTxt = Instance.new("TextLabel")
    minTxt.Size = UDim2.fromScale(1, 1)
    minTxt.BackgroundTransparency = 1
    minTxt.Text = "—"
    minTxt.TextColor3 = C.TEXT
    minTxt.Font = Enum.Font.GothamBold
    minTxt.TextSize = TS(12)
    minTxt.ZIndex = 55
    minTxt.Parent = minBtn

    local pages = Instance.new("Frame")
    pages.Position = UDim2.fromOffset(0, P(60))
    pages.Size = UDim2.new(1, 0, 1, -P(60))
    pages.BackgroundTransparency = 1
    pages.BorderSizePixel = 0
    pages.ZIndex = 52
    pages.Parent = content

    local function setWindowVisible(v)
        if v then
            root.Visible = true
            root.Position = UDim2.new(0.5, 0, 0.5, P(10)) -- 10px drop
            root.GroupTransparency = 1
            tween(root, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = restPos})
            tween(root, TweenInfo.new(0.4,  Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0})
        else
            tween(root, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0.5, P(8)),
                GroupTransparency = 1,
            })
            task.delay(0.22, function() root.Visible = false end)
        end
    end

    closeBtn.MouseButton1Click:Connect(function() setWindowVisible(false) end)
    minBtn.MouseButton1Click:Connect(function() setWindowVisible(false) end)

    -- Dragging
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = root.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Toggle Key
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            if root.Visible then setWindowVisible(false) else setWindowVisible(true) end
        end
    end)

    -- UI Object
    local UI = {}
    UI._tabs = {}

    local pageCount = 0
    local firstTab = nil

    function UI:Tab(tabName, iconId)
        pageCount = pageCount + 1
        local pageOrder = pageCount

        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = P(4)
        page.ScrollBarImageColor3 = C.CYAN
        page.ScrollBarImageTransparency = 0.6
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.Visible = false
        page.ZIndex = 53
        page.Parent = pages

        local pl = Instance.new("UIListLayout")
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Padding = UDim.new(0, P(10))
        pl.Parent = page

        local pp = Instance.new("UIPadding")
        pp.PaddingLeft = UDim.new(0, P(16))
        pp.PaddingRight = UDim.new(0, P(16))
        pp.PaddingTop = UDim.new(0, P(6))
        pp.PaddingBottom = UDim.new(0, P(18))
        pp.Parent = page

        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(1, 0, 0, P(34))
        tabBtn.BackgroundColor3 = Color3.new(1, 1, 1)
        tabBtn.BackgroundTransparency = 1
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.LayoutOrder = pageOrder
        tabBtn.ZIndex = 52
        tabBtn.Parent = tabList
        Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, P(8))
        applyLift(tabBtn, 8)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, P(3), 0, P(16))
        accent.Position = UDim2.new(0, 0, 0.5, 0)
        accent.AnchorPoint = Vector2.new(0, 0.5)
        accent.BackgroundColor3 = C.CYAN
        accent.BorderSizePixel = 0
        accent.Visible = false
        accent.ZIndex = 54
        accent.Parent = tabBtn
        Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

        local tLabel = Instance.new("TextLabel")
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = TS(12)
        tLabel.TextColor3 = C.SUBTLE
        tLabel.Text = tabName
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.Position = UDim2.fromOffset(P(16), 0)
        tLabel.Size = UDim2.new(1, -P(24), 1, 0)
        tLabel.ZIndex = 54
        tLabel.Parent = tabBtn

        local tabRecord = {page = page, btn = tabBtn, accent = accent, label = tLabel}

        local function setActive(active)
            if active then
                tabBtn.BackgroundTransparency = 0.92
                accent.Visible = true
                tLabel.TextColor3 = C.TEXT
                page.Visible = true
            else
                tabBtn.BackgroundTransparency = 1
                accent.Visible = false
                tLabel.TextColor3 = C.SUBTLE
                page.Visible = false
            end
        end
        tabRecord.setActive = setActive

        tabBtn.MouseButton1Click:Connect(function()
            for _, rec in ipairs(UI._tabs) do rec.setActive(rec == tabRecord) end
        end)

        table.insert(UI._tabs, tabRecord)

        local groupCount = 0
        local TabObj = {}
        
        function TabObj:Group(groupTitle)
            groupCount = groupCount + 1
            local groupY = 0
            for _, child in ipairs(page:GetChildren()) do
                if child:IsA("Frame") then groupY = groupY + child.Size.Y.Offset + P(10) end
            end
            
            local g = makeGroup(page, groupY, 20)
            g.AutomaticSize = Enum.AutomaticSize.Y
            
            local gLayout = Instance.new("UIListLayout")
            gLayout.SortOrder = Enum.SortOrder.LayoutOrder
            gLayout.Padding = UDim.new(0, P(2))
            gLayout.Parent = g
            
            local gPad = Instance.new("UIPadding")
            gPad.PaddingTop = UDim.new(0, P(10))
            gPad.PaddingBottom = UDim.new(0, P(10))
            gPad.PaddingLeft = UDim.new(0, P(6))
            gPad.PaddingRight = UDim.new(0, P(6))
            gPad.Parent = g

            local titleLbl = Instance.new("TextLabel")
            titleLbl.Size = UDim2.new(1, -P(8), 0, P(20))
            titleLbl.BackgroundTransparency = 1
            titleLbl.Font = Enum.Font.GothamBold
            titleLbl.TextSize = TS(12)
            titleLbl.TextColor3 = C.SUBTLE
            titleLbl.Text = string.upper(groupTitle)
            titleLbl.TextXAlignment = Enum.TextXAlignment.Left
            titleLbl.LayoutOrder = 0
            titleLbl.ZIndex = 22
            titleLbl.Parent = g

            local compCount = 0
            local function nextOrder()
                compCount = compCount + 1
                return compCount
            end

            local GroupObj = {}
            function GroupObj:Toggle(o)
                local t = makeToggleRow(g, o)
                t.Row.LayoutOrder = nextOrder()
                return t
            end
            function GroupObj:Slider(o)
                local s = makeSlider(g, o)
                s.Row.LayoutOrder = nextOrder()
                return s
            end
            function GroupObj:Button(o)
                local b = makeButtonRow(g, o)
                b.Row.LayoutOrder = nextOrder()
                return b
            end
            
            return GroupObj
        end

        TabObj.Select = function()
            for _, rec in ipairs(UI._tabs) do rec.setActive(rec == tabRecord) end
        end

        if not firstTab then
            firstTab = tabRecord
            setActive(true)
        end

        return TabObj
    end

    function UI:Notify(o) return createToast(o) end
    function UI:Open() setWindowVisible(true) end
    function UI:Close() setWindowVisible(false) end
    function UI:Destroy() pcall(function() sg:Destroy() end) end

    -- Start
    if showLoading then
        loadingShown = true
        playLoading(function() setWindowVisible(true) end)
    else
        setWindowVisible(true)
    end

    return UI
end

function Muye:Notify(o) return createToast(o) end

return Muye
