--[[
    ─────────────────────────────────────────────────────────────
    MUYE UI  ·  glassy cyan Roblox UI library
    single-file · loadstring-ready
    Made by deepseek ♥
    ─────────────────────────────────────────────────────────────
]]

local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local Players           = game:GetService("Players")
local CoreGui           = game:GetService("CoreGui")
local RunService        = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ── gui parent (CoreGui when possible, else PlayerGui) ─────────
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

-- ── palette ─────────────────────────────────────────────────────
local C = {
    TEXT    = Color3.fromRGB(242, 242, 244),
    SUBTLE  = Color3.fromRGB(150, 150, 156),
    INK     = Color3.fromRGB(12, 16, 20),
    WHITE   = Color3.new(1, 1, 1),
    OFF     = Color3.fromRGB(58, 58, 62),
    CYAN    = Color3.fromRGB(64, 220, 255),
    CYAN_DK = Color3.fromRGB(10, 32, 40),
    CYAN_MD = Color3.fromRGB(20, 60, 76),
    RIM     = Color3.fromRGB(160, 232, 255),
}

local TINTS = {
    cyan   = { Color3.fromRGB(10, 32, 40),  Color3.fromRGB(64, 220, 255) },
    blue   = { Color3.fromRGB(13, 40, 51),  Color3.fromRGB(64, 186, 255) },
    purple = { Color3.fromRGB(38, 28, 62),  Color3.fromRGB(168, 120, 255) },
    teal   = { Color3.fromRGB(14, 46, 40),  Color3.fromRGB(56, 224, 186) },
    orange = { Color3.fromRGB(62, 36, 16),  Color3.fromRGB(255, 150, 50) },
    red    = { Color3.fromRGB(62, 20, 24),  Color3.fromRGB(255, 96, 96) },
    yellow = { Color3.fromRGB(56, 46, 12),  Color3.fromRGB(245, 197, 66) },
}

-- ── scale ───────────────────────────────────────────────────────
local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local SCALE = math.clamp(math.min((viewport.X - 32) / 900, (viewport.Y - 40) / 620), 0.5, 1)
local function P(n)  return math.floor(n * SCALE + 0.5) end
local function TS(n) return math.max(9, math.floor(n * SCALE + 0.5)) end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ── glass surface ───────────────────────────────────────────────
local function applyGlass(frame, radius, topColor, bottomColor, rimColor)
    radius      = radius      or 14
    topColor    = topColor    or Color3.fromRGB(22, 30, 36)
    bottomColor = bottomColor or Color3.fromRGB(10, 14, 18)
    rimColor    = rimColor    or C.RIM

    local bg = Instance.new("UIGradient")
    bg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, topColor),
        ColorSequenceKeypoint.new(1, bottomColor),
    })
    bg.Rotation = 90
    bg.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = rimColor
    stroke.Thickness = 1
    stroke.Transparency = 0.84
    stroke.Parent = frame

    local rim = Instance.new("UIGradient")
    rim.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,    0.84),
        NumberSequenceKeypoint.new(0.45, 0.95),
        NumberSequenceKeypoint.new(1,    0.98),
    })
    rim.Rotation = 90
    rim.Parent = stroke

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, P(radius))
    corner.Parent = frame
    return frame
end

-- ── press feedback ──────────────────────────────────────────────
local function makePressable(obj, amount)
    amount = amount or 0.97
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

-- ── row base ────────────────────────────────────────────────────
local function newRow(parent, height, order)
    local row = Instance.new("TextButton")
    row.Name = "Row"
    row.Parent = parent
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.Size = UDim2.new(1, 0, 0, P(height))
    row.LayoutOrder = order or 0
    row.ZIndex = 5

    local lift = Instance.new("Frame")
    lift.Name = "Lift"
    lift.Parent = row
    lift.BackgroundColor3 = Color3.new(1, 1, 1)
    lift.BackgroundTransparency = 1
    lift.BorderSizePixel = 0
    lift.Size = UDim2.fromScale(1, 1)
    lift.ZIndex = 6
    Instance.new("UICorner", lift).CornerRadius = UDim.new(0, P(8))

    row.MouseEnter:Connect(function()
        tween(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.95})
    end)
    row.MouseLeave:Connect(function()
        tween(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    end)

    return row, lift
end

local function rowLabels(row, title, sub, leftPad, rightPad)
    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = TS(13)
    lbl.TextColor3 = C.TEXT
    lbl.Text = title or ""
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 7
    if sub and sub ~= "" then
        lbl.Position = UDim2.fromOffset(leftPad, P(8))
        lbl.Size = UDim2.new(1, -(leftPad + rightPad), 0, P(16))
    else
        lbl.Position = UDim2.fromOffset(leftPad, 0)
        lbl.Size = UDim2.new(1, -(leftPad + rightPad), 1, 0)
    end
    lbl.Parent = row

    if sub and sub ~= "" then
        local s = Instance.new("TextLabel")
        s.BackgroundTransparency = 1
        s.Font = Enum.Font.GothamMedium
        s.TextSize = TS(11)
        s.TextColor3 = C.SUBTLE
        s.Text = sub
        s.TextXAlignment = Enum.TextXAlignment.Left
        s.TextTruncate = Enum.TextTruncate.AtEnd
        s.Position = UDim2.fromOffset(leftPad, P(26))
        s.Size = UDim2.new(1, -(leftPad + rightPad), 0, P(13))
        s.ZIndex = 7
        s.Parent = row
    end
    return lbl
end

-- ── round icon button (window controls) ─────────────────────────
local function roundButton(parent, size, glyph, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(P(size), P(size))
    b.BackgroundColor3 = Color3.fromRGB(30, 36, 42)
    b.BorderSizePixel = 0
    b.Text = glyph
    b.TextColor3 = C.TEXT
    b.Font = Enum.Font.GothamBold
    b.TextSize = TS(12)
    b.AutoButtonColor = false
    b.ZIndex = 60
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.RIM
    stroke.Thickness = 1
    stroke.Transparency = 0.86
    stroke.Parent = b

    local lift = Instance.new("Frame")
    lift.BackgroundColor3 = Color3.new(1, 1, 1)
    lift.BackgroundTransparency = 1
    lift.BorderSizePixel = 0
    lift.Size = UDim2.fromScale(1, 1)
    lift.ZIndex = 61
    lift.Parent = b
    Instance.new("UICorner", lift).CornerRadius = UDim.new(1, 0)

    b.MouseEnter:Connect(function()
        tween(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.92})
    end)
    b.MouseLeave:Connect(function()
        tween(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
    end)
    makePressable(b, 0.9)
    b.MouseButton1Click:Connect(callback or function() end)
    return b
end

-- ═══════════════════════════════════════════════════════════════
--  COMPONENTS
-- ═══════════════════════════════════════════════════════════════

-- Toggle ────────────────────────────────────────────────────────
local function makeToggle(parent, opts, order)
    opts = opts or {}
    local row = newRow(parent, 48, order)
    rowLabels(row, opts.Title or "Toggle", opts.Description, P(14), P(70))

    local sw, sh = P(44), P(24)
    local track = Instance.new("Frame")
    track.Parent = row
    track.BackgroundColor3 = opts.Value and C.CYAN or C.OFF
    track.BorderSizePixel = 0
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, -P(14), 0.5, 0)
    track.Size = UDim2.fromOffset(sw, sh)
    track.ZIndex = 7
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Parent = track
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.Size = UDim2.fromOffset(P(18), P(18))
    knob.Position = opts.Value and UDim2.new(1, -P(21), 0.5, 0) or UDim2.new(0, P(3), 0.5, 0)
    knob.ZIndex = 8
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local value = opts.Value and true or false
    local function set(v, animate)
        value = v and true or false
        local info = animate and TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) or TweenInfo.new(0)
        tween(track, info, {BackgroundColor3 = value and C.CYAN or C.OFF})
        tween(knob, info, {
            Position = value and UDim2.new(1, -P(21), 0.5, 0) or UDim2.new(0, P(3), 0.5, 0)
        })
        if opts.Callback then task.spawn(opts.Callback, value) end
    end

    row.MouseButton1Click:Connect(function() set(not value, true) end)
    makePressable(row, 0.985)

    return {
        Set = function(_, v) set(v, true) end,
        Get = function() return value end,
        Row = row,
    }
end

-- Slider ────────────────────────────────────────────────────────
local function makeSlider(parent, opts, order)
    opts = opts or {}
    local minV = opts.Min or 0
    local maxV = opts.Max or 100
    local rounding = opts.Rounding or 1
    local value = opts.Value or minV

    local row = newRow(parent, 56, order)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = TS(13)
    lbl.TextColor3 = C.TEXT
    lbl.Text = opts.Title or "Slider"
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Position = UDim2.fromOffset(P(14), P(8))
    lbl.Size = UDim2.new(1, -P(120), 0, P(16))
    lbl.ZIndex = 7
    lbl.Parent = row

    local valLbl = Instance.new("TextLabel")
    valLbl.BackgroundTransparency = 1
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = TS(12)
    valLbl.TextColor3 = C.CYAN
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Position = UDim2.new(1, -P(90), 0, P(8))
    valLbl.Size = UDim2.fromOffset(P(76), P(16))
    valLbl.ZIndex = 7
    valLbl.Parent = row

    local trackY = P(38)
    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, P(14), 0, trackY)
    track.Size = UDim2.new(1, -P(28), 0, P(5))
    track.BackgroundColor3 = Color3.new(1, 1, 1)
    track.BackgroundTransparency = 0.9
    track.BorderSizePixel = 0
    track.ZIndex = 7
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = C.CYAN
    fill.BorderSizePixel = 0
    fill.ZIndex = 8
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(0, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(P(12), P(12))
    knob.BackgroundColor3 = Color3.new(1, 1, 1)
    knob.BorderSizePixel = 0
    knob.ZIndex = 9
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
    hit.ZIndex = 10
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
        Row = row,
    }
end

-- Button ───────────────────────────────────────────────────────
local function makeButton(parent, opts, order)
    opts = opts or {}
    local row = newRow(parent, 44, order)
    rowLabels(row, opts.Title or "Button", opts.Description, P(14), P(30))

    local chev = Instance.new("TextLabel")
    chev.BackgroundTransparency = 1
    chev.Font = Enum.Font.GothamBold
    chev.TextSize = TS(14)
    chev.TextColor3 = C.SUBTLE
    chev.Text = "›"
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -P(14), 0.5, 0)
    chev.Size = UDim2.fromOffset(P(14), P(16))
    chev.ZIndex = 7
    chev.Parent = row

    makePressable(row, 0.97)
    row.MouseButton1Click:Connect(function()
        if opts.Callback then task.spawn(opts.Callback) end
    end)

    return { Row = row }
end

-- Input ────────────────────────────────────────────────────────
local function makeInput(parent, opts, order)
    opts = opts or {}
    local row = newRow(parent, 48, order)
    rowLabels(row, opts.Title or "Input", opts.Description, P(14), P(190))

    local box = Instance.new("TextBox")
    box.AnchorPoint = Vector2.new(0, 0.5)
    box.Position = UDim2.new(1, -P(174), 0.5, 0)
    box.Size = UDim2.fromOffset(P(160), P(28))
    box.BackgroundColor3 = Color3.new(1, 1, 1)
    box.BackgroundTransparency = 0.94
    box.BorderSizePixel = 0
    box.Font = Enum.Font.GothamMedium
    box.TextSize = TS(13)
    box.TextColor3 = C.TEXT
    box.PlaceholderText = opts.Placeholder or ""
    box.PlaceholderColor3 = C.SUBTLE
    box.Text = opts.Value or ""
    box.ClearTextOnFocus = false
    box.ZIndex = 7
    box.Parent = row
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, P(8))

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.RIM
    stroke.Thickness = 1
    stroke.Transparency = 0.9
    stroke.Parent = box

    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, P(10))
    pad.PaddingRight = UDim.new(0, P(10))
    pad.Parent = box

    box.FocusLost:Connect(function()
        if opts.Callback then task.spawn(opts.Callback, box.Text) end
    end)

    return {
        Set = function(_, v) box.Text = tostring(v) end,
        Get = function() return box.Text end,
        Row = row,
    }
end

-- Dropdown ─────────────────────────────────────────────────────
local function makeDropdown(parent, opts, order)
    opts = opts or {}
    local options = opts.Options or {}
    local multi = opts.Multi or false
    local selected = multi and (opts.Value or {}) or (opts.Value or options[1])
    local expanded = false

    local row = Instance.new("Frame")
    row.Name = "Dropdown"
    row.Parent = parent
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, P(46))
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.LayoutOrder = order or 0
    row.ZIndex = 5

    local rl = Instance.new("UIListLayout")
    rl.SortOrder = Enum.SortOrder.LayoutOrder
    rl.Padding = UDim.new(0, P(2))
    rl.Parent = row

    local header = newRow(row, 46, 1)
    header.Size = UDim2.new(1, 0, 0, P(46))
    rowLabels(header, opts.Title or "Dropdown", opts.Description, P(14), P(180))

    local valueLbl = Instance.new("TextLabel")
    valueLbl.BackgroundTransparency = 1
    valueLbl.Font = Enum.Font.GothamMedium
    valueLbl.TextSize = TS(12)
    valueLbl.TextColor3 = C.CYAN
    valueLbl.TextXAlignment = Enum.TextXAlignment.Right
    valueLbl.TextTruncate = Enum.TextTruncate.AtEnd
    valueLbl.AnchorPoint = Vector2.new(1, 0.5)
    valueLbl.Position = UDim2.new(1, -P(38), 0.5, 0)
    valueLbl.Size = UDim2.fromOffset(P(160), P(16))
    valueLbl.ZIndex = 7
    valueLbl.Parent = header

    local chev = Instance.new("TextLabel")
    chev.BackgroundTransparency = 1
    chev.Font = Enum.Font.GothamBold
    chev.TextSize = TS(12)
    chev.TextColor3 = C.SUBTLE
    chev.Text = "▾"
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.new(1, -P(14), 0.5, 0)
    chev.Size = UDim2.fromOffset(P(14), P(14))
    chev.ZIndex = 7
    chev.Parent = header

    local list = Instance.new("Frame")
    list.Size = UDim2.new(1, 0, 0, 0)
    list.AutomaticSize = Enum.AutomaticSize.Y
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.Visible = false
    list.LayoutOrder = 2
    list.ZIndex = 6
    list.Parent = row

    local ll = Instance.new("UIListLayout")
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, P(3))
    ll.Parent = list

    local function updateLabel()
        if multi then
            if #selected == 0 then
                valueLbl.Text = "None"
            elseif #selected <= 2 then
                valueLbl.Text = table.concat(selected, ", ")
            else
                valueLbl.Text = tostring(#selected) .. " selected"
            end
        else
            valueLbl.Text = tostring(selected or "")
        end
    end

    local function setValue(v)
        selected = v
        updateLabel()
        if opts.Callback then task.spawn(opts.Callback, v) end
    end

    local optionButtons = {}
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Size = UDim2.new(1, -P(16), 0, P(30))
        ob.BackgroundColor3 = Color3.new(1, 1, 1)
        ob.BackgroundTransparency = 0.96
        ob.BorderSizePixel = 0
        ob.Text = ""
        ob.AutoButtonColor = false
        ob.LayoutOrder = i
        ob.ZIndex = 7
        ob.Parent = list
        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, P(6))

        local olbl = Instance.new("TextLabel")
        olbl.BackgroundTransparency = 1
        olbl.Font = Enum.Font.GothamMedium
        olbl.TextSize = TS(12)
        olbl.TextColor3 = C.TEXT
        olbl.Text = tostring(opt)
        olbl.TextXAlignment = Enum.TextXAlignment.Left
        olbl.Position = UDim2.fromOffset(P(10), 0)
        olbl.Size = UDim2.new(1, -P(20), 1, 0)
        olbl.ZIndex = 8
        olbl.Parent = ob

        local lift = Instance.new("Frame")
        lift.BackgroundColor3 = Color3.new(1, 1, 1)
        lift.BackgroundTransparency = 1
        lift.BorderSizePixel = 0
        lift.Size = UDim2.fromScale(1, 1)
        lift.ZIndex = 8
        lift.Parent = ob
        Instance.new("UICorner", lift).CornerRadius = UDim.new(0, P(6))

        ob.MouseEnter:Connect(function()
            tween(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.93})
        end)
        ob.MouseLeave:Connect(function()
            tween(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
        end)

        ob.MouseButton1Click:Connect(function()
            if multi then
                local found = table.find(selected, opt)
                if found then
                    table.remove(selected, found)
                else
                    table.insert(selected, opt)
                end
                setValue(selected)
            else
                setValue(opt)
                expanded = false
                list.Visible = false
            end
        end)
        optionButtons[i] = ob
    end

    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        list.Visible = expanded
    end)

    updateLabel()

    return {
        Set = function(_, v) setValue(v) end,
        Get = function() return selected end,
        Row = row,
    }
end

-- Keybind ──────────────────────────────────────────────────────
local function makeKeybind(parent, opts, order)
    opts = opts or {}
    local row = newRow(parent, 48, order)
    rowLabels(row, opts.Title or "Keybind", opts.Description, P(14), P(120))

    local value = opts.Value or Enum.KeyCode.Unknown
    local listening = false

    local btn = Instance.new("TextButton")
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -P(14), 0.5, 0)
    btn.Size = UDim2.fromOffset(P(88), P(26))
    btn.BackgroundColor3 = Color3.new(1, 1, 1)
    btn.BackgroundTransparency = 0.94
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = TS(11)
    btn.TextColor3 = C.TEXT
    btn.Text = value.Name
    btn.AutoButtonColor = false
    btn.ZIndex = 7
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, P(8))

    local st = Instance.new("UIStroke")
    st.Color = C.RIM
    st.Thickness = 1
    st.Transparency = 0.9
    st.Parent = btn

    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "Press…"
        btn.TextColor3 = C.CYAN
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if not listening then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        listening = false
        value = input.KeyCode
        btn.Text = value.Name
        btn.TextColor3 = C.TEXT
        if opts.Callback then task.spawn(opts.Callback, value) end
    end)

    return {
        Set = function(_, v) value = v; btn.Text = v.Name end,
        Get = function() return value end,
        Row = row,
    }
end

-- Colorpicker ──────────────────────────────────────────────────
local PALETTE_COLORS = {
    Color3.fromRGB(64, 220, 255),
    Color3.fromRGB(64, 186, 255),
    Color3.fromRGB(168, 120, 255),
    Color3.fromRGB(56, 224, 186),
    Color3.fromRGB(245, 197, 66),
    Color3.fromRGB(255, 150, 50),
    Color3.fromRGB(255, 96, 96),
    Color3.fromRGB(255, 255, 255),
    Color3.fromRGB(150, 150, 156),
    Color3.fromRGB(30, 30, 34),
}

local function makeColorpicker(parent, opts, order)
    opts = opts or {}
    local value = opts.Value or C.CYAN
    local expanded = false

    local row = Instance.new("Frame")
    row.Name = "Colorpicker"
    row.Parent = parent
    row.BackgroundTransparency = 1
    row.BorderSizePixel = 0
    row.Size = UDim2.new(1, 0, 0, P(46))
    row.AutomaticSize = Enum.AutomaticSize.Y
    row.LayoutOrder = order or 0
    row.ZIndex = 5

    local rl = Instance.new("UIListLayout")
    rl.SortOrder = Enum.SortOrder.LayoutOrder
    rl.Padding = UDim.new(0, P(2))
    rl.Parent = row

    local header = newRow(row, 46, 1)
    header.Size = UDim2.new(1, 0, 0, P(46))
    rowLabels(header, opts.Title or "Color", opts.Description, P(14), P(60))

    local swatch = Instance.new("Frame")
    swatch.AnchorPoint = Vector2.new(1, 0.5)
    swatch.Position = UDim2.new(1, -P(14), 0.5, 0)
    swatch.Size = UDim2.fromOffset(P(22), P(22))
    swatch.BackgroundColor3 = value
    swatch.BorderSizePixel = 0
    swatch.ZIndex = 7
    swatch.Parent = header
    Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, P(6))

    local swStroke = Instance.new("UIStroke")
    swStroke.Color = Color3.new(1, 1, 1)
    swStroke.Thickness = 1
    swStroke.Transparency = 0.7
    swStroke.Parent = swatch

    local palette = Instance.new("Frame")
    palette.Size = UDim2.new(1, 0, 0, 0)
    palette.AutomaticSize = Enum.AutomaticSize.Y
    palette.BackgroundTransparency = 1
    palette.BorderSizePixel = 0
    palette.Visible = false
    palette.LayoutOrder = 2
    palette.ZIndex = 6
    palette.Parent = row

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.fromOffset(P(22), P(22))
    grid.CellPadding = UDim2.fromOffset(P(6), P(6))
    grid.SortOrder = Enum.SortOrder.LayoutOrder
    grid.Parent = palette

    local ppad = Instance.new("UIPadding")
    ppad.PaddingLeft = UDim.new(0, P(16))
    ppad.PaddingRight = UDim.new(0, P(16))
    ppad.PaddingTop = UDim.new(0, P(4))
    ppad.PaddingBottom = UDim.new(0, P(8))
    ppad.Parent = palette

    local function setValue(c)
        value = c
        swatch.BackgroundColor3 = c
        if opts.Callback then task.spawn(opts.Callback, c) end
    end

    for i, col in ipairs(PALETTE_COLORS) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.fromOffset(P(22), P(22))
        b.BackgroundColor3 = col
        b.BorderSizePixel = 0
        b.Text = ""
        b.AutoButtonColor = false
        b.LayoutOrder = i
        b.ZIndex = 7
        b.Parent = palette
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)

        local bs = Instance.new("UIStroke")
        bs.Color = Color3.new(1, 1, 1)
        bs.Thickness = 1
        bs.Transparency = 0.75
        bs.Parent = b

        b.MouseButton1Click:Connect(function()
            setValue(col)
            expanded = false
            palette.Visible = false
        end)
    end

    header.MouseButton1Click:Connect(function()
        expanded = not expanded
        palette.Visible = expanded
    end)

    return {
        Set = function(_, c) setValue(c) end,
        Get = function() return value end,
        Row = row,
    }
end

-- ═══════════════════════════════════════════════════════════════
--  GROUP
-- ═══════════════════════════════════════════════════════════════
local function makeGroup(parent, title, order)
    local g = Instance.new("Frame")
    g.Name = "Group"
    g.Parent = parent
    g.BackgroundColor3 = Color3.new(1, 1, 1)
    g.BackgroundTransparency = 0.955
    g.BorderSizePixel = 0
    g.Size = UDim2.new(1, 0, 0, P(20))
    g.AutomaticSize = Enum.AutomaticSize.Y
    g.LayoutOrder = order or 0
    g.ZIndex = 4
    Instance.new("UICorner", g).CornerRadius = UDim.new(0, P(12))

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, P(2))
    layout.Parent = g

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, P(10))
    pad.PaddingBottom = UDim.new(0, P(10))
    pad.PaddingLeft = UDim.new(0, P(6))
    pad.PaddingRight = UDim.new(0, P(6))
    pad.Parent = g

    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -P(8), 0, P(20))
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamBold
    t.TextSize = TS(12)
    t.TextColor3 = C.SUBTLE
    t.Text = string.upper(title or "Group")
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.LayoutOrder = 0
    t.ZIndex = 5
    t.Parent = g

    local counter = 0
    local function nextOrder()
        counter = counter + 1
        return counter
    end

    local Group = {}
    function Group:Toggle(o)   return makeToggle(g, o, nextOrder())   end
    function Group:Slider(o)   return makeSlider(g, o, nextOrder())   end
    function Group:Button(o)   return makeButton(g, o, nextOrder())   end
    function Group:Input(o)    return makeInput(g, o, nextOrder())    end
    function Group:Dropdown(o) return makeDropdown(g, o, nextOrder()) end
    function Group:Keybind(o)  return makeKeybind(g, o, nextOrder())  end
    function Group:Colorpicker(o) return makeColorpicker(g, o, nextOrder()) end
    function Group:Frame() return g end

    return Group
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

local function repositionToasts(animate)
    for i, rec in ipairs(toasts) do
        local y = P(18) + (i - 1) * (P(66) + P(8))
        local target = UDim2.new(1, -P(18), 0, y)
        if animate then
            tween(rec.cg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = target})
        else
            rec.cg.Position = target
        end
    end
end

local function createToast(opts)
    opts = opts or {}
    ensureNotifGui()

    local titleText = opts.Title or "Notification"
    local message = opts.Message or ""
    local duration = opts.Duration or 4
    local tint = TINTS[opts.Tint or "cyan"] or TINTS.cyan

    local W, H = P(280), P(66)
    local PILL_W, PILL_H = P(120), P(30)

    local cg = Instance.new("CanvasGroup")
    cg.Name = "Toast"
    cg.BackgroundColor3 = Color3.fromRGB(14, 20, 26)
    cg.BorderSizePixel = 0
    cg.GroupTransparency = 1
    cg.Size = UDim2.fromOffset(PILL_W, PILL_H)
    cg.AnchorPoint = Vector2.new(1, 0)
    cg.Position = UDim2.new(1, -P(18), 0, P(18))
    cg.ZIndex = 100
    cg.Parent = NotificationGui

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(24, 34, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 15, 20)),
    })
    grad.Rotation = 90
    grad.Parent = cg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, P(PILL_H / 2))
    corner.Parent = cg

    local stroke = Instance.new("UIStroke")
    stroke.Color = C.RIM
    stroke.Thickness = 1
    stroke.Transparency = 0.85
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = cg

    local rim = Instance.new("UIGradient")
    rim.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.97),
    })
    rim.Rotation = 90
    rim.Parent = stroke

    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, P(3), 1, -P(16))
    accent.Position = UDim2.new(0, P(12), 0.5, 0)
    accent.AnchorPoint = Vector2.new(0, 0.5)
    accent.BackgroundColor3 = tint[2]
    accent.BorderSizePixel = 0
    accent.ZIndex = 101
    accent.Parent = cg
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)

    local tl = Instance.new("TextLabel")
    tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = TS(13)
    tl.TextColor3 = C.TEXT
    tl.Text = titleText
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.TextTruncate = Enum.TextTruncate.AtEnd
    tl.TextTransparency = 1
    tl.Position = UDim2.fromOffset(P(24), P(12))
    tl.Size = UDim2.new(1, -P(36), 0, P(16))
    tl.ZIndex = 101
    tl.Parent = cg

    local ml = Instance.new("TextLabel")
    ml.BackgroundTransparency = 1
    ml.Font = Enum.Font.GothamMedium
    ml.TextSize = TS(11)
    ml.TextColor3 = C.SUBTLE
    ml.Text = message
    ml.TextXAlignment = Enum.TextXAlignment.Left
    ml.TextTruncate = Enum.TextTruncate.AtEnd
    ml.TextTransparency = 1
    ml.Position = UDim2.fromOffset(P(24), P(32))
    ml.Size = UDim2.new(1, -P(36), 0, P(14))
    ml.ZIndex = 101
    ml.Parent = cg

    local rec = {cg = cg, dismissed = false}
    table.insert(toasts, rec)
    repositionToasts(false)

    -- OPEN — pill morphs to card
    tween(cg, TweenInfo.new(0.55, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(W, H)})
    tween(corner, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {CornerRadius = UDim.new(0, P(14))})
    tween(cg, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 0})
    task.delay(0.12, function()
        local info = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(tl, info, {TextTransparency = 0})
        tween(ml, info, {TextTransparency = 0})
    end)

    local function dismiss()
        if rec.dismissed then return end
        rec.dismissed = true

        for i, r in ipairs(toasts) do
            if r == rec then table.remove(toasts, i); break end
        end

        local info = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(tl, info, {TextTransparency = 1})
        tween(ml, info, {TextTransparency = 1})

        task.delay(0.1, function()
            tween(cg, TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                Size = UDim2.fromOffset(PILL_W, PILL_H),
                GroupTransparency = 1,
            })
            tween(corner, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
                CornerRadius = UDim.new(0, P(PILL_H / 2)),
            })
        end)

        task.delay(0.5, function() cg:Destroy() end)
        repositionToasts(true)
    end

    task.delay(duration, dismiss)
    rec.dismiss = dismiss
    return rec
end

-- ═══════════════════════════════════════════════════════════════
--  LOADING SCREEN — "Muye-Hub" intro
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

    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 22, 28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 6, 10)),
    })
    bgGrad.Rotation = 90
    bgGrad.Parent = cg

    local glow = Instance.new("ImageLabel")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.Size = UDim2.fromOffset(P(760), P(760))
    glow.BackgroundTransparency = 1
    glow.Image = "rbxassetid://6014261993"
    glow.ImageColor3 = C.CYAN
    glow.ImageTransparency = 0.55
    glow.ScaleType = Enum.ScaleType.Slice
    glow.SliceCenter = Rect.new(49, 49, 450, 450)
    glow.Parent = cg

    local title = Instance.new("TextLabel")
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.Position = UDim2.new(0.5, 0, 0.5, -P(40))
    title.Size = UDim2.fromOffset(P(420), P(70))
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
    titleGrad.Offset = Vector2.new(-1, 0) -- hi
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

    local barW = P(240)
    local barBg = Instance.new("Frame")
    barBg.AnchorPoint = Vector2.new(0.5, 0.5)
    barBg.Position = UDim2.new(0.5, 0, 0.5, P(34))
    barBg.Size = UDim2.fromOffset(barW, P(3))
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

    local status = Instance.new("TextLabel")
    status.AnchorPoint = Vector2.new(0.5, 0.5)
    status.Position = UDim2.new(0.5, 0, 0.5, P(54))
    status.Size = UDim2.fromOffset(P(300), P(14))
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.GothamMedium
    status.Text = "Initializing…"
    status.TextSize = TS(11)
    status.TextColor3 = C.SUBTLE
    status.TextTransparency = 1
    status.ZIndex = 2
    status.Parent = cg

    task.spawn(function()
        task.wait(0.05)

        -- title + subtitle fade in
        tween(title, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0})
        task.wait(0.15)
        tween(sub, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
        tween(barBg, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundTransparency = 0.86})
        tween(status, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0})
        task.spawn(function()
            for _ = 1, 3 do
                titleGrad.Offset = Vector2.new(-1, 0)
                tween(titleGrad, TweenInfo.new(1.0, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Offset = Vector2.new(1, 0)})
                task.wait(1.0)
            end
        end)

        -- progress fill
        tween(barFill, TweenInfo.new(2.0, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)})

        task.delay(0.7, function() status.Text = "Loading modules…" end)
        task.delay(1.4, function() status.Text = "Preparing interface…" end)
        task.delay(2.0, function() status.Text = "Almost there…" end)

        task.wait(2.2)
        status.Text = "Ready"

        tween(cg, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {GroupTransparency = 1})
        task.wait(0.5)

        sg:Destroy()
        if onComplete then onComplete() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
--  LIBRARY
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

    -- ScreenGui ───────────────────────────────────────────────
    local sg = Instance.new("ScreenGui")
    sg.Name = "MuyeUI"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 100
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = GUI_PARENT

    -- Root (CanvasGroup for unified fade) ──────────────────────
    local root = Instance.new("CanvasGroup")
    root.Name = "Root"
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

    -- Shadow glow behind window ────────────────────────────────
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Glow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.fromScale(0.5, 0.5)
    shadow.Size = UDim2.new(1, P(60), 1, P(60))
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = C.CYAN
    shadow.ImageTransparency = 0.82
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = 49
    shadow.Parent = root

    -- Window body ──────────────────────────────────────────────
    local win = Instance.new("Frame")
    win.Name = "Window"
    win.Size = UDim2.fromScale(1, 1)
    win.BackgroundColor3 = C.INK
    win.BorderSizePixel = 0
    win.ZIndex = 50
    win.Parent = root
    applyGlass(win, 16, Color3.fromRGB(22, 32, 38), Color3.fromRGB(9, 13, 17), C.RIM)

    -- Sidebar ─────────────────────────────────────────────────
    local SIDEBAR_W = P(168)
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.fromOffset(SIDEBAR_W, H)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 51
    sidebar.Parent = win

    local logo = Instance.new("TextLabel")
    logo.BackgroundTransparency = 1
    logo.Font = Enum.Font.GothamBlack
    logo.TextSize = TS(17)
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
        ColorSequenceKeypoint.new(0.6, Color3.new(1, 1, 1)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 220, 240)),
    })
    logoGrad.Rotation = 0
    logoGrad.Parent = logo

    local logoSub = Instance.new("TextLabel")
    logoSub.BackgroundTransparency = 1
    logoSub.Font = Enum.Font.GothamBold
    logoSub.TextSize = TS(9)
    logoSub.TextColor3 = C.SUBTLE
    logoSub.Text = "H U B"
    logoSub.TextXAlignment = Enum.TextXAlignment.Left
    logoSub.Position = UDim2.fromOffset(P(21), P(40))
    logoSub.Size = UDim2.new(1, -P(30), 0, P(12))
    logoSub.ZIndex = 52
    logoSub.Parent = sidebar

    local tabList = Instance.new("ScrollingFrame")
    tabList.Name = "TabList"
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.Position = UDim2.fromOffset(P(10), P(64))
    tabList.Size = UDim2.new(1, -P(20), 1, -P(100))
    tabList.ScrollBarThickness = P(3)
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

    local footer = Instance.new("TextLabel")
    footer.BackgroundTransparency = 1
    footer.Font = Enum.Font.GothamMedium
    footer.TextSize = TS(9)
    footer.TextColor3 = C.SUBTLE
    footer.Text = "v1.0 · glass"
    footer.TextXAlignment = Enum.TextXAlignment.Left
    footer.Position = UDim2.new(0, P(20), 1, -P(24))
    footer.Size = UDim2.new(1, -P(30), 0, P(12))
    footer.ZIndex = 52
    footer.Parent = sidebar

    -- Vertical separator ───────────────────────────────────────
    local vLine = Instance.new("Frame")
    vLine.BackgroundColor3 = Color3.new(1, 1, 1)
    vLine.BackgroundTransparency = 0.94
    vLine.BorderSizePixel = 0
    vLine.Position = UDim2.fromOffset(SIDEBAR_W, P(16))
    vLine.Size = UDim2.new(0, 1, 1, -P(32))
    vLine.ZIndex = 52
    vLine.Parent = win

    -- Content area ─────────────────────────────────────────────
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(SIDEBAR_W, 0)
    content.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ZIndex = 51
    content.Parent = win

    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, P(56))
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
    winTitle.TextTruncate = Enum.TextTruncate.AtEnd
    winTitle.Position = UDim2.fromOffset(P(18), P(10))
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
        ws.TextTruncate = Enum.TextTruncate.AtEnd
        ws.Position = UDim2.fromOffset(P(18), P(28))
        ws.Size = UDim2.new(1, -P(100), 0, P(14))
        ws.ZIndex = 53
        ws.Parent = topbar
    end

    -- window controls
    local closeBtn
    local minBtn

    local function setWindowVisible(v)
        if v then
            root.Visible = true
            root.Position = UDim2.new(0.5, 0, 0.5, P(10))
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

    closeBtn = roundButton(topbar, 26, "✕", function() setWindowVisible(false) end)
    closeBtn.Position = UDim2.new(1, -P(14) - P(26), 0, P(15))

    minBtn = roundButton(topbar, 26, "—", function() setWindowVisible(false) end)
    minBtn.Position = UDim2.new(1, -P(14) - P(26) - P(8) - P(26), 0, P(15))
    -- "minimize" also just hides for now; toggle key brings back
    minBtn.MouseButton1Click:Connect(function() setWindowVisible(false) end)

    -- pages container ──────────────────────────────────────────
    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.Position = UDim2.fromOffset(0, P(56))
    pages.Size = UDim2.new(1, 0, 1, -P(56))
    pages.BackgroundTransparency = 1
    pages.BorderSizePixel = 0
    pages.ZIndex = 52
    pages.Parent = content

    -- draggable ────────────────────────────────────────────────
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

    -- toggle key ───────────────────────────────────────────────
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            if root.Visible then
                setWindowVisible(false)
            else
                setWindowVisible(true)
            end
        end
    end)

    -- ── UI object ─────────────────────────────────────────────
    local UI = {}
    UI._tabs = {}

    local pageCount = 0
    local firstTab = nil

    function UI:Tab(tabName, iconId)
        pageCount = pageCount + 1
        local pageOrder = pageCount

        -- page
        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. tabName
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

        -- tab button
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "Tab_" .. tabName
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

        local tIcon
        local labelX = P(16)
        if iconId then
            tIcon = Instance.new("ImageLabel")
            tIcon.BackgroundTransparency = 1
            tIcon.Size = UDim2.fromOffset(P(14), P(14))
            tIcon.Position = UDim2.fromOffset(P(14), 0)
            tIcon.AnchorPoint = Vector2.new(0, 0.5)
            tIcon.Image = iconId
            tIcon.ImageColor3 = C.SUBTLE
            tIcon.ZIndex = 54
            tIcon.Parent = tabBtn
            labelX = P(36)
        end

        local tLabel = Instance.new("TextLabel")
        tLabel.BackgroundTransparency = 1
        tLabel.Font = Enum.Font.GothamBold
        tLabel.TextSize = TS(12)
        tLabel.TextColor3 = C.SUBTLE
        tLabel.Text = tabName
        tLabel.TextXAlignment = Enum.TextXAlignment.Left
        tLabel.TextTruncate = Enum.TextTruncate.AtEnd
        tLabel.Position = UDim2.fromOffset(labelX, 0)
        tLabel.Size = UDim2.new(1, -labelX - P(8), 1, 0)
        tLabel.ZIndex = 54
        tLabel.Parent = tabBtn

        local lift = Instance.new("Frame")
        lift.BackgroundColor3 = Color3.new(1, 1, 1)
        lift.BackgroundTransparency = 1
        lift.BorderSizePixel = 0
        lift.Size = UDim2.fromScale(1, 1)
        lift.ZIndex = 53
        lift.Parent = tabBtn
        Instance.new("UICorner", lift).CornerRadius = UDim.new(0, P(8))

        tabBtn.MouseEnter:Connect(function()
            tween(lift, TweenInfo.new(0.15, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.95})
        end)
        tabBtn.MouseLeave:Connect(function()
            tween(lift, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
        end)

        local tabRecord = {page = page, btn = tabBtn, accent = accent, label = tLabel, icon = tIcon}

        local function setActive(active)
            if active then
                tabBtn.BackgroundTransparency = 0.92
                accent.Visible = true
                tLabel.TextColor3 = C.TEXT
                if tIcon then tIcon.ImageColor3 = C.CYAN end
                page.Visible = true
            else
                tabBtn.BackgroundTransparency = 1
                accent.Visible = false
                tLabel.TextColor3 = C.SUBTLE
                if tIcon then tIcon.ImageColor3 = C.SUBTLE end
                page.Visible = false
            end
        end
        tabRecord.setActive = setActive

        tabBtn.MouseButton1Click:Connect(function()
            for _, rec in ipairs(UI._tabs) do
                rec.setActive(rec == tabRecord)
            end
        end)

        table.insert(UI._tabs, tabRecord)

        -- group factory
        local groupCount = 0
        local TabObj = {}
        function TabObj:Group(groupTitle)
            groupCount = groupCount + 1
            return makeGroup(page, groupTitle, groupCount)
        end
        function TabObj:Select()
            for _, rec in ipairs(UI._tabs) do
                rec.setActive(rec == tabRecord)
            end
        end
        TabObj.Page = page
        TabObj.Button = tabBtn

        if not firstTab then
            firstTab = tabRecord
            setActive(true)
        end

        return TabObj
    end

    function UI:Notify(o)
        return createToast(o)
    end
    function UI:Toast(o) return createToast(o) end

    function UI:Open()  setWindowVisible(true)  end
    function UI:Close() setWindowVisible(false) end
    function UI:Toggle() if root.Visible then setWindowVisible(false) else setWindowVisible(true) end end

    function UI:SetToggleKey(key) toggleKey = key end

    function UI:Destroy()
        pcall(function() sg:Destroy() end)
    end

    -- reveal ────────────────────────────────────────────────────
    if showLoading then
        loadingShown = true
        playLoading(function() setWindowVisible(true) end)
    else
        setWindowVisible(true)
    end

    return UI
end

function Muye:Notify(o)
    return createToast(o)
end
function Muye:Toast(o)
    return createToast(o)
end

return Muye
