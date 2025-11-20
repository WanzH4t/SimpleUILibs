local AUL2 = {}

-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- HELPERS
local function new(class, props)
    local obj = Instance.new(class)
    if props then
        for k, v in pairs(props) do obj[k] = v end
    end
    return obj
end

local function tween(obj, props, time, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(time or 0.18, style, dir), props):Play()
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- DEFAULT THEME / PRESETS
AUL2.Presets = {
    ["Neon"] = {Accent = Color3.fromRGB(0, 230, 190), Bg = Color3.fromRGB(22,22,28)},
    ["Violet"] = {Accent = Color3.fromRGB(168, 78, 255), Bg = Color3.fromRGB(18,16,24)},
    ["Sunset"] = {Accent = Color3.fromRGB(255,120,80), Bg = Color3.fromRGB(24,18,20)},
}
AUL2.DefaultPreset = "Neon"

-- INTERNAL: safe screengui name (prevent duplicates)
local function get_parent()
    -- prefer CoreGui in Xeno? but PlayerGui is safe for executor
    return PlayerGui
end

-- Create window
function AUL2:CreateWindow(opts)
    opts = opts or {}
    local title = opts.Title or "AUL2 Window"
    local size = opts.Size or UDim2.new(0, 420, 0, 360)
    local preset = self.Presets[opts.Preset or self.DefaultPreset] or self.Presets[self.DefaultPreset]
    local enableBlur = opts.EnableBlur or false
    local allowResize = opts.Resize or true
    local useIcons = opts.IconSupport ~= false

    -- optional blur (affects whole game, toggle safely)
    local blurEffect
    if enableBlur then
        blurEffect = Instance.new("BlurEffect")
        blurEffect.Name = "AUL2_Blur"
        blurEffect.Parent = Lighting
        blurEffect.Size = 0
        tween(blurEffect, {Size = 16}, 0.35)
    end

    -- ScreenGui
    local ScreenGui = new("ScreenGui", {
        Name = ("AUL2_%s"):format(title:gsub("%s","_")),
        ResetOnSpawn = false,
        Parent = get_parent()
    })

    -- MAIN FRAME
    local Main = new("Frame", {
        Name = "Main",
        Size = size,
        Position = opts.Position or UDim2.new(0.5, -size.X.Offset/2, 0.45, -size.Y.Offset/2),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = preset.Bg,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    new("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Main})
    new("UIStroke", {Transparency = 0.85, Thickness = 1, Parent = Main})

    -- subtle gradient background
    local bgGrad = new("UIGradient", {Parent = Main})
    bgGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, preset.Bg),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15,15,20))
    }
    bgGrad.Rotation = 0

    -- glow: inner accent strip
    local AccentBar = new("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(1,0,0,8),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 0,
        BackgroundColor3 = preset.Accent,
        BorderSizePixel = 0,
        Parent = Main
    })
    new("UICorner", {CornerRadius = UDim.new(0, 12), Parent = AccentBar})
    local stroke = new("UIStroke", {Parent = AccentBar, Color = preset.Accent, Thickness = 6, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
    stroke.Transparency = 0.85

    -- Title bar
    local TitleBar = new("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1,0,0,36),
        Position = UDim2.new(0,0,0,6),
        BackgroundTransparency = 1,
        Parent = Main
    })
    local TitleLbl = new("TextLabel", {
        Name = "Title",
        Text = title,
        Size = UDim2.new(0.6,0,1,0),
        Position = UDim2.new(0,14,0,0),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(235,235,235),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Top-right controls (close/minimize)
    local ctrlFrame = new("Frame", {Parent = TitleBar, Size = UDim2.new(0.4, -18, 1, 0), Position = UDim2.new(0.6, 0, 0,0), BackgroundTransparency = 1})
    local function makeIconBtn(text, tooltip)
        local b = new("TextButton", {
            Size = UDim2.new(0, 36, 0, 24),
            BackgroundTransparency = 0.8,
            BackgroundColor3 = Color3.fromRGB(30,30,30),
            Text = text,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240,240,240),
            Parent = ctrlFrame
        })
        new("UICorner", {CornerRadius = UDim.new(0,6), Parent = b})
        return b
    end
    local MinimizeBtn = makeIconBtn("-", "Minimize")
    MinimizeBtn.Position = UDim2.new(1, -80, 0, 6)
    local CloseBtn = makeIconBtn("x", "Close")
    CloseBtn.Position = UDim2.new(1, -40, 0, 6)

    -- content area (below title)
    local Content = new("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -16, 1, -56),
        Position = UDim2.new(0,8,0,44),
        BackgroundTransparency = 1,
        Parent = Main
    })
    new("UICorner", {CornerRadius = UDim.new(0,8), Parent = Content})

    -- Left: Tabs
    local TabsCol = new("Frame", {
        Name = "TabsCol",
        Size = UDim2.new(0, 120, 1, 0),
        BackgroundTransparency = 1,
        Parent = Content
    })
    local TabsList = new("UIListLayout", {Parent = TabsCol, Padding = UDim.new(0,8)})
    TabsList.Padding = UDim.new(0,8)

    -- Right: Panel area (pages)
    local Pages = new("Frame", {
        Name = "Pages",
        Size = UDim2.new(1, -128, 1, 0),
        Position = UDim2.new(0,128,0,0),
        BackgroundTransparency = 1,
        Parent = Content
    })

    -- Store tabs/pages
    local tabButtons = {}
    local pageFrames = {}

    local activeTab = nil
    local function addTab(name, icon)
        local tbtn = new("TextButton", {
            Parent = TabsCol,
            Size = UDim2.new(1, -8, 0, 40),
            BackgroundTransparency = 1,
            Text = "",
        })
        new("UICorner", {CornerRadius = UDim.new(0,6), Parent = tbtn})
        local bg = new("Frame", {Parent = tbtn, Size = UDim2.new(1,0,1,0), BackgroundColor3 = Color3.fromRGB(28,28,34), BorderSizePixel = 0})
        new("UICorner", {CornerRadius = UDim.new(0,6), Parent = bg})
        local iconLabel
        if icon and tonumber(icon) then
            iconLabel = new("ImageLabel", {Parent = bg, Size = UDim2.new(0, 30, 0, 30), Position = UDim2.new(0,8,0.5,-15), BackgroundTransparency = 1, Image = "rbxassetid://"..tostring(icon)})
        else
            iconLabel = new("TextLabel", {Parent = bg, Size = UDim2.new(0,30,0,30), Position = UDim2.new(0,8,0.5,-15), BackgroundTransparency = 1, Text = icon or "", Font = Enum.Font.GothamBold, TextSize = 16, TextColor3 = Color3.fromRGB(230,230,230)})
        end
        local lbl = new("TextLabel", {Parent = bg, Text = name, Position = UDim2.new(0,46,0,0), Size = UDim2.new(1,-46,1,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(220,220,220), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        local indicator = new("Frame", {Parent = bg, Size = UDim2.new(0,4,1,0), Position = UDim2.new(0,0,0,0), BackgroundColor3 = Color3.fromRGB(0,0,0), BorderSizePixel = 0})
        indicator.Visible = false

        local page = new("ScrollingFrame", {Parent = Pages, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 6, Visible = false})
        new("UIListLayout", {Parent = page, Padding = UDim.new(0,10)})

        tbtn.MouseButton1Click:Connect(function()
            -- deactivate previous
            if activeTab and tabButtons[activeTab] then
                tabButtons[activeTab].Indicator.Visible = false
                pageFrames[activeTab].Visible = false
            end
            -- activate this
            activeTab = name
            indicator.Visible = true
            page.Visible = true
        end)

        tabButtons[name] = {Button = tbtn, Indicator = indicator, Page = page}
        pageFrames[name] = page

        -- if first tab, activate
        if not activeTab then
            activeTab = name
            indicator.Visible = true
            page.Visible = true
        end

        -- return page for adding sections
        return page
    end

    -- Draggable window (mouse + touch)
    do
        local dragging = false
        local dragStart = Vector2.new(0,0)
        local startPos = Main.Position

        local function beginDrag(pos)
            dragging = true
            dragStart = pos
            startPos = Main.Position
        end
        local function endDrag()
            dragging = false
        end
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                beginDrag(input.Position)
            end
        end)
        TitleBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(
                    clamp(startPos.X.Scale,0,1),
                    startPos.X.Offset + delta.X,
                    clamp(startPos.Y.Scale,0,1),
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Minimize / Close
    MinimizeBtn.MouseButton1Click:Connect(function()
        local visible = Pages.Visible
        Pages.Visible = not visible
        TabsCol.Visible = not visible
        TitleLbl.Visible = not visible
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        if blurEffect then tween(blurEffect, {Size = 0}, 0.25); task.delay(0.3, function() if blurEffect and blurEffect.Parent then blurEffect:Destroy() end end) end
        ScreenGui:Destroy()
    end)

    -- API for controls inside pages
    local api = {}
    function api:AddTab(name, icon)
        return addTab(name, (useIcons and icon) and icon or (icon and tostring(icon) or nil))
    end

    -- create default tab if none provided
    if not opts.Tabs or #opts.Tabs == 0 then
        addTab("Main", nil)
    else
        for i, t in ipairs(opts.Tabs) do
            addTab(t.Name or ("Tab"..i), t.Icon)
        end
    end

    -- UI ELEMENT FACTORIES
    local function makeSection(parent, title)
        local sec = new("Frame", {Parent = parent, Size = UDim2.new(1, -16, 0, 28), BackgroundColor3 = Color3.fromRGB(28,28,36), BorderSizePixel = 0})
        new("UICorner", {CornerRadius = UDim.new(0,8), Parent = sec})
        local lbl = new("TextLabel", {Parent = sec, Text = title or "Section", Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.GothamBold, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
        -- container for items
        local items = new("Frame", {Parent = parent, Size = UDim2.new(1, -16, 0, 6), BackgroundTransparency = 1})
        return {
            Frame = sec,
            Items = items,
            AddButton = function(self, txt, cb, icon)
                local btn = new("TextButton", {Parent = parent, Size = UDim2.new(1,-16,0,36), Text = "", BackgroundColor3 = Color3.fromRGB(36,36,44), BorderSizePixel = 0})
                new("UICorner", {Parent = btn, CornerRadius = UDim.new(0,8)})
                local label = new("TextLabel", {Parent = btn, Text = txt, Size = UDim2.new(1,-12,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(240,240,240), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                if icon then
                    if tonumber(icon) then
                        new("ImageLabel", {Parent = btn, Image = "rbxassetid://"..tostring(icon), Size = UDim2.new(0,26,0,26), Position = UDim2.new(0,8,0.5,-13), BackgroundTransparency = 1})
                    else
                        new("TextLabel", {Parent = btn, Text = icon, Size = UDim2.new(0,26,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 16})
                    end
                end
                btn.MouseButton1Click:Connect(function() if cb then cb() end end)
                return btn
            end,
            AddToggle = function(self, txt, default, cb)
                local container = new("Frame", {Parent = parent, Size = UDim2.new(1,-16,0,36), BackgroundColor3 = Color3.fromRGB(36,36,44)})
                new("UICorner", {Parent = container, CornerRadius = UDim.new(0,8)})
                local label = new("TextLabel", {Parent = container, Text = txt, Size = UDim2.new(1,-90,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                local sw = new("TextButton", {Parent = container, Size = UDim2.new(0,56,0,24), Position = UDim2.new(1,-70,0.5,-12), BackgroundColor3 = Color3.fromRGB(55,55,62), Text = "", BorderSizePixel = 0})
                new("UICorner", {Parent = sw, CornerRadius = UDim.new(1,0)})
                local dot = new("Frame", {Parent = sw, Size = UDim2.new(0,20,0,20), Position = UDim2.new(default and 1 or 0, default and -22 or 4, 0.5, -10), BackgroundColor3 = default and preset.Accent or Color3.fromRGB(120,120,120)})
                new("UICorner", {Parent = dot, CornerRadius = UDim.new(1,0)})
                local state = default or false
                local function toggle()
                    state = not state
                    if state then
                        tween(dot, {Position = UDim2.new(1,-22,0.5,-10)}, 0.12)
                        tween(dot, {BackgroundColor3 = preset.Accent}, 0.12)
                    else
                        tween(dot, {Position = UDim2.new(0,4,0.5,-10)}, 0.12)
                        tween(dot, {BackgroundColor3 = Color3.fromRGB(120,120,120)}, 0.12)
                    end
                    if cb then cb(state) end
                end
                sw.MouseButton1Click:Connect(toggle)
                -- mobile touch
                sw.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.Touch then toggle() end end)
                return {Set = function(_,v) if state~=v then toggle() end end, Get = function() return state end}
            end,
            AddSlider = function(self, txt, min, max, default, cb)
                min = min or 0; max = max or 100; default = default or min
                local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,-16,0,62), BackgroundColor3 = Color3.fromRGB(36,36,44)})
                new("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})
                new("TextLabel", {Parent = frame, Text = txt.." : "..tostring(default), Size = UDim2.new(1,-20,0,20), Position = UDim2.new(0,10,0,6), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.Gotham, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
                local bar = new("Frame", {Parent = frame, Size = UDim2.new(1,-40,0,10), Position = UDim2.new(0,20,0,34), BackgroundColor3 = Color3.fromRGB(24,24,28)})
                new("UICorner", {Parent = bar, CornerRadius = UDim.new(0,6)})
                local fill = new("Frame", {Parent = bar, Size = UDim2.new((default-min)/(max-min), 0, 1, 0), BackgroundColor3 = preset.Accent})
                new("UICorner", {Parent = fill, CornerRadius = UDim.new(0,6)})
                -- drag support
                local dragging = false
                local function updateFromPos(x)
                    local abs = x - bar.AbsolutePosition.X
                    local ratio = clamp(abs / bar.AbsoluteSize.X, 0, 1)
                    local value = math.floor(min + (max-min) * ratio + 0.5)
                    fill.Size = UDim2.new(ratio, 0, 1, 0)
                    frame:FindFirstChildWhichIsA("TextLabel").Text = txt.." : "..tostring(value)
                    if cb then cb(value) end
                end
                bar.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateFromPos(inp.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                        updateFromPos(inp.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false
                    end
                end)
                return {
                    Set = function(_,v)
                        local r = clamp((v-min)/(max-min),0,1)
                        fill.Size = UDim2.new(r,0,1,0)
                    end
                }
            end,
            AddDropdown = function(self, txt, items, cb)
                items = items or {}
                local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,-16,0,40), BackgroundColor3 = Color3.fromRGB(36,36,44)})
                new("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})
                local label = new("TextLabel", {Parent = frame, Text = txt, Size = UDim2.new(1,-40,1,0), Position = UDim2.new(0,12,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(235,235,235), Font = Enum.Font.Gotham, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left})
                local arrow = new("TextLabel", {Parent = frame, Text = "▾", Size = UDim2.new(0,28,1,0), Position = UDim2.new(1,-36,0,0), BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(200,200,200), Font = Enum.Font.Gotham, TextSize = 16})
                local list = new("Frame", {Parent = parent, Size = UDim2.new(1,-16,0,0), BackgroundColor3 = Color3.fromRGB(22,22,28), Visible = false})
                new("UICorner", {Parent = list, CornerRadius = UDim.new(0,8)})
                local scroll = new("ScrollingFrame", {Parent = list, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, ScrollBarThickness = 6})
                local layout = new("UIListLayout", {Parent = scroll, Padding = UDim.new(0,6)})
                local open = false
                local function refresh()
                    scroll:ClearAllChildren()
                    for i,v in ipairs(items) do
                        local it = new("TextButton", {Parent = scroll, Text = tostring(v), Size = UDim2.new(1,-12,0,30), BackgroundColor3 = Color3.fromRGB(30,30,36)})
                        new("UICorner", {Parent = it, CornerRadius = UDim.new(0,6)})
                        it.MouseButton1Click:Connect(function()
                            label.Text = txt.." : "..tostring(v)
                            if cb then cb(v) end
                            open = false
                            list.Visible = false
                            list.Size = UDim2.new(1,-16,0,0)
                        end)
                    end
                end
                refresh()
                frame.MouseButton1Click:Connect(function()
                    open = not open
                    list.Visible = open
                    if open then
                        local h = math.min(#items * 34 + 8, 180)
                        tween(list, {Size = UDim2.new(1,-16,0,h)}, 0.16)
                    else
                        tween(list, {Size = UDim2.new(1,-16,0,0)}, 0.12)
                        task.delay(0.12, function() if list and list.Parent then list.Visible = false end end)
                    end
                end)
                return {
                    SetItems = function(_,arr) items = arr; refresh() end
                }
            end,
            AddColorPresets = function(self, cb)
                local frame = new("Frame", {Parent = parent, Size = UDim2.new(1,-16,0,48), BackgroundColor3 = Color3.fromRGB(36,36,44)})
                new("UICorner", {Parent = frame, CornerRadius = UDim.new(0,8)})
                local x = 8
                for name,p in pairs(AUL2.Presets) do
                    local sw = new("TextButton", {Parent = frame, Size = UDim2.new(0,36,0,36), Position = UDim2.new(0,x,0,6), BackgroundColor3 = p.Accent, Text = "", BorderSizePixel = 0})
                    new("UICorner", {Parent = sw, CornerRadius = UDim.new(0,6)})
                    sw.MouseButton1Click:Connect(function()
                        -- apply globally (accent color)
                        AccentBar.BackgroundColor3 = p.Accent
                        stroke.Color = p.Accent
                        -- update preset for controls that read it (not exhaustive)
                        preset = p
                        if cb then cb(name, p) end
                    end)
                    x = x + 44
                end
            end
        }
    end

    -- convenience: get active page to add items
    function api:GetPage(name)
        return pageFrames[name] or nil
    end

    function api:Section(pageName, title)
        local page = pageFrames[pageName or activeTab] or pageFrames[activeTab]
        if not page then return nil end
        local container = new("Frame", {Parent = page, Size = UDim2.new(1,0,0,10), BackgroundTransparency = 1})
        local secTitle = new("Frame", {Parent = container, Size = UDim2.new(1,0,0,36), BackgroundTransparency = 1})
        new("UICorner", {Parent = secTitle, CornerRadius = UDim.new(0,6)})
        local section = makeSection(container, title)
        return section
    end

    -- return api and raw references for advanced customization
    return api, {
        ScreenGui = ScreenGui,
        Main = Main,
        Pages = Pages,
        Tabs = TabsCol,
        AccentBar = AccentBar,
        Preset = preset
    }
end

return AUL2
