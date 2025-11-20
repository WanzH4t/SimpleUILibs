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
        for k, v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local function tween(obj, props, time, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir   = dir   or Enum.EasingDirection.Out
    TweenService:Create(obj, TweenInfo.new(time or 0.18, style, dir), props):Play()
end

local function clamp(v, a, b) return math.max(a, math.min(b, v)) end

-- PRESETS
AUL2.Presets = {
    Neon   = {Accent = Color3.fromRGB(0,230,190), Bg = Color3.fromRGB(22,22,28)},
    Violet = {Accent = Color3.fromRGB(168,78,255), Bg = Color3.fromRGB(18,16,24)},
    Sunset = {Accent = Color3.fromRGB(255,120,80), Bg = Color3.fromRGB(24,18,20)},
}
AUL2.DefaultPreset = "Neon"

-- PARENT
local function get_parent()
    return PlayerGui
end

--========================================================
--  WINDOW CREATION
--========================================================
function AUL2:CreateWindow(opts)
    opts = opts or {}
    local title  = opts.Title or "AUL2 Window"
    local size   = opts.Size or UDim2.new(0,420,0,360)
    local preset = self.Presets[opts.Preset or self.DefaultPreset]

    local ScreenGui = new("ScreenGui", {
        Name = "AUL2_" .. tostring(title),
        ResetOnSpawn = false,
        Parent = get_parent()
    })

    local Main = new("Frame", {
        Parent = ScreenGui,
        Size = size,
        Position = opts.Position or UDim2.new(0.5,-size.X.Offset/2,0.45,-size.Y.Offset/2),
        AnchorPoint = Vector2.new(0.5,0.5),
        BackgroundColor3 = preset.Bg,
        BorderSizePixel = 0
    })
    new("UICorner",{Parent=Main,CornerRadius=UDim.new(0,12)})

    local AccentBar = new("Frame",{
        Parent = Main,
        Size = UDim2.new(1,0,0,8),
        BackgroundColor3 = preset.Accent,
        BorderSizePixel=0
    })
    new("UICorner",{Parent=AccentBar,CornerRadius=UDim.new(0,12)})

    -- Titlebar
    local TitleBar = new("Frame",{Parent=Main,Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,Position=UDim2.new(0,0,0,6)})
    local TitleLbl = new("TextLabel",{
        Parent = TitleBar,
        Text = title,
        Size = UDim2.new(1,-20,1,0),
        Position = UDim2.new(0,14,0,0),
        TextColor3 = Color3.fromRGB(235,235,235),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Tabs left
    local Content = new("Frame",{Parent=Main,Size=UDim2.new(1,-16,1,-56),Position=UDim2.new(0,8,0,44),BackgroundTransparency=1})

    local TabsCol = new("Frame",{Parent=Content,Size=UDim2.new(0,120,1,0),BackgroundTransparency=1})
    local TabsList = new("UIListLayout",{Parent=TabsCol,Padding=UDim.new(0,8)})

    -- Pages
    local Pages = new("Frame",{Parent=Content,Size=UDim2.new(1,-128,1,0),Position=UDim2.new(0,128,0,0),BackgroundTransparency=1})

    local tabButtons = {}
    local pageFrames = {}
    local activeTab = nil

    --========================================================
    --  ADD TAB
    --========================================================
    local function addTab(name, icon)
        local tbtn = new("TextButton",{
            Parent=TabsCol,
            Text="",
            Size=UDim2.new(1,-8,0,40),
            BackgroundTransparency=1
        })
        local bg = new("Frame",{
            Parent=tbtn,
            Size=UDim2.new(1,0,1,0),
            BackgroundColor3=Color3.fromRGB(28,28,34),
            BorderSizePixel=0
        })
        new("UICorner",{Parent=bg,CornerRadius=UDim.new(0,6)})

        local label = new("TextLabel",{
            Parent=bg,
            Text=name,
            Size=UDim2.new(1,-46,1,0),
            Position=UDim2.new(0,46,0,0),
            Font=Enum.Font.Gotham,
            TextSize=14,
            BackgroundTransparency=1,
            TextColor3=Color3.fromRGB(220,220,220),
            TextXAlignment=Enum.TextXAlignment.Left
        })

        local iconObj
        if icon then
            if tonumber(icon) then
                iconObj = new("ImageLabel",{
                    Parent=bg,
                    Image = "rbxassetid://" .. tostring(icon),
                    Size = UDim2.new(0,30,0,30),
                    Position=UDim2.new(0,8,0.5,-15),
                    BackgroundTransparency=1
                })
            else
                iconObj = new("TextLabel",{
                    Parent=bg,
                    Text = icon,
                    Size=UDim2.new(0,30,0,30),
                    Position=UDim2.new(0,8,0.5,-15),
                    BackgroundTransparency=1,
                    TextColor3=Color3.fromRGB(230,230,230),
                    Font=Enum.Font.GothamBold,
                    TextSize=16
                })
            end
        end

        local indicator = new("Frame",{
            Parent=bg,
            Size=UDim2.new(0,4,1,0),
            BackgroundColor3=preset.Accent,
            BorderSizePixel=0,
            Visible=false
        })

        local page = new("ScrollingFrame",{
            Parent=Pages,
            ScrollBarThickness=6,
            BackgroundTransparency=1,
            Size=UDim2.new(1,0,1,0),
            Visible=false
        })
        new("UIListLayout",{Parent=page,Padding=UDim.new(0,10)})

        tbtn.MouseButton1Click:Connect(function()
            if activeTab then
                tabButtons[activeTab].Indicator.Visible=false
                pageFrames[activeTab].Visible=false
            end
            activeTab = name
            indicator.Visible=true
            page.Visible=true
        end)

        tabButtons[name] = {Button=tbtn,Indicator=indicator,Page=page}
        pageFrames[name] = page

        if not activeTab then
            activeTab = name
            indicator.Visible=true
            page.Visible=true
        end

        return page
    end

    --========================================================
    --  SECTION + CONTROLS
    --========================================================
    local function makeSection(parent, title)
        local secHead = new("Frame",{
            Parent=parent,
            Size=UDim2.new(1,-16,0,36),
            BackgroundColor3=Color3.fromRGB(28,28,36),
            BorderSizePixel=0
        })
        new("UICorner",{Parent=secHead,CornerRadius=UDim.new(0,8)})

        local lbl = new("TextLabel",{
            Parent=secHead,
            Text=title,
            Size=UDim2.new(1,-12,1,0),
            Position=UDim2.new(0,12,0,0),
            BackgroundTransparency=1,
            TextColor3=Color3.fromRGB(235,235,235),
            Font=Enum.Font.GothamBold,
            TextSize=14,
            TextXAlignment=Enum.TextXAlignment.Left
        })

        local api = {}

        -------------------------------------------------------
        --  BUTTON
        -------------------------------------------------------
        function api:AddButton(text, callback)
            local btn = new("TextButton",{
                Parent=parent,
                Text = text,
                Size=UDim2.new(1,-16,0,36),
                BackgroundColor3=Color3.fromRGB(36,36,44),
                BorderSizePixel=0,
                Font=Enum.Font.Gotham,
                TextSize=14,
                TextColor3=Color3.fromRGB(240,240,240)
            })
            new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,8)})
            btn.MouseButton1Click:Connect(function()
                if callback then callback() end
            end)
            return btn
        end

        -------------------------------------------------------
        --  TOGGLE
        -------------------------------------------------------
        function api:AddToggle(text, default, callback)
            local frame = new("Frame",{
                Parent=parent,
                Size=UDim2.new(1,-16,0,36),
                BackgroundColor3=Color3.fromRGB(36,36,44)
            })
            new("UICorner",{Parent=frame,CornerRadius=UDim.new(0,8)})

            new("TextLabel",{
                Parent=frame,
                Text=text,
                Size=UDim2.new(1,-90,1,0),
                Position=UDim2.new(0,12,0,0),
                BackgroundTransparency=1,
                TextColor3=Color3.fromRGB(235,235,235),
                Font=Enum.Font.Gotham,
                TextSize=14,
                TextXAlignment=Enum.TextXAlignment.Left
            })

            local sw = new("TextButton",{
                Parent=frame,
                Size=UDim2.new(0,56,0,24),
                Position=UDim2.new(1,-70,0.5,-12),
                BackgroundColor3=Color3.fromRGB(55,55,62),
                BorderSizePixel=0,
                Text=""
            })
            new("UICorner",{Parent=sw,CornerRadius=UDim.new(1,0)})

            local dot = new("Frame",{
                Parent=sw,
                Size=UDim2.new(0,20,0,20),
                Position = default and UDim2.new(1,-22,0.5,-10) or UDim2.new(0,4,0.5,-10),
                BackgroundColor3 = default and preset.Accent or Color3.fromRGB(120,120,120)
            })
            new("UICorner",{Parent=dot,CornerRadius=UDim.new(1,0)})

            local state = default

            local function toggle()
                state = not state
                if state then
                    tween(dot,{Position=UDim2.new(1,-22,0.5,-10)},0.12)
                    tween(dot,{BackgroundColor3=preset.Accent},0.12)
                else
                    tween(dot,{Position=UDim2.new(0,4,0.5,-10)},0.12)
                    tween(dot,{BackgroundColor3=Color3.fromRGB(120,120,120)},0.12)
                end
                if callback then callback(state) end
            end

            sw.MouseButton1Click:Connect(toggle)

            return {
                Set=function(_,v) if state~=v then toggle() end end,
                Get=function() return state end
            }
        end

        -------------------------------------------------------
        --  SLIDER
        -------------------------------------------------------
        function api:AddSlider(text, min, max, default, callback)
            min=min or 0
            max=max or 100
            default=default or min

            local frame = new("Frame",{
                Parent=parent,
                Size=UDim2.new(1,-16,0,62),
                BackgroundColor3=Color3.fromRGB(36,36,44)
            })
            new("UICorner",{Parent=frame,CornerRadius=UDim.new(0,8)})

            local label = new("TextLabel",{
                Parent=frame,
                Text=text.." : "..default,
                Size=UDim2.new(1,-20,0,20),
                Position=UDim2.new(0,10,0,6),
                BackgroundTransparency=1,
                TextColor3=Color3.fromRGB(235,235,235),
                Font=Enum.Font.Gotham,
                TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left
            })

            local bar = new("Frame",{
                Parent=frame,
                Size=UDim2.new(1,-40,0,10),
                Position=UDim2.new(0,20,0,34),
                BackgroundColor3=Color3.fromRGB(24,24,28)
            })
            new("UICorner",{Parent=bar,CornerRadius=UDim.new(0,6)})

            local fill = new("Frame",{
                Parent=bar,
                Size=UDim2.new((default-min)/(max-min),0,1,0),
                BackgroundColor3=preset.Accent
            })
            new("UICorner",{Parent=fill,CornerRadius=UDim.new(0,6)})

            local dragging=false

            local function update(x)
                local abs = x - bar.AbsolutePosition.X
                local ratio = clamp(abs/bar.AbsoluteSize.X,0,1)
                local value = math.floor(min + (max-min)*ratio + 0.5)
                fill.Size = UDim2.new(ratio,0,1,0)
                label.Text = text.." : "..tostring(value)
                if callback then callback(value) end
            end

            bar.InputBegan:Connect(function(inp)
                if inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=true
                    update(inp.Position.X)
                end
            end)
            UserInputService.InputChanged:Connect(function(inp)
                if dragging and inp.UserInputType==Enum.UserInputType.MouseMovement then
                    update(inp.Position.X)
                end
            end)
            UserInputService.InputEnded:Connect(function(inp)
                if dragging and inp.UserInputType==Enum.UserInputType.MouseButton1 then
                    dragging=false
                end
            end)

            return {
                Set=function(_,v)
                    local r=clamp((v-min)/(max-min),0,1)
                    fill.Size=UDim2.new(r,0,1,0)
                    label.Text = text.." : "..tostring(v)
                end
            }
        end

        -------------------------------------------------------
        --  DROPDOWN
        -------------------------------------------------------
        function api:AddDropdown(text, list, callback)
            list = list or {}

            local frame = new("Frame",{
                Parent=parent,
                Size=UDim2.new(1,-16,0,40),
                BackgroundColor3=Color3.fromRGB(36,36,44)
            })
            new("UICorner",{Parent=frame,CornerRadius=UDim.new(0,8)})

            local label = new("TextLabel",{
                Parent=frame,
                Text=text,
                Size=UDim2.new(1,-40,1,0),
                Position=UDim2.new(0,12,0,0),
                BackgroundTransparency=1,
                TextColor3=Color3.fromRGB(235,235,235),
                Font=Enum.Font.Gotham,
                TextSize=14,
                TextXAlignment=Enum.TextXAlignment.Left
            })

            local arrow = new("TextLabel",{
                Parent=frame,
                Text="▾",
                Size=UDim2.new(0,28,1,0),
                Position=UDim2.new(1,-36,0,0),
                BackgroundTransparency=1,
                TextColor3=Color3.fromRGB(200,200,200),
                Font=Enum.Font.Gotham,
                TextSize=16
            })

            local listFrame = new("Frame",{
                Parent=parent,
                Size=UDim2.new(1,-16,0,0),
                BackgroundColor3=Color3.fromRGB(22,22,28),
                Visible=false
            })
            new("UICorner",{Parent=listFrame,CornerRadius=UDim.new(0,8)})

            local scroll = new("ScrollingFrame",{
                Parent=listFrame,
                ScrollBarThickness=6,
                BackgroundTransparency=1,
                Size=UDim2.new(1,0,1,0)
            })
            local ui = new("UIListLayout",{Parent=scroll,Padding=UDim.new(0,6)})

            local open = false

            local function refresh()
                scroll:ClearAllChildren()
                for _,v in ipairs(list) do
                    local item = new("TextButton",{
                        Parent=scroll,
                        Text = tostring(v),
                        Size=UDim2.new(1,-12,0,30),
                        BackgroundColor3=Color3.fromRGB(30,30,36),
                        BorderSizePixel=0,
                        TextColor3=Color3.fromRGB(230,230,230),
                        Font=Enum.Font.Gotham,
                        TextSize=13
                    })
                    new("UICorner",{Parent=item,CornerRadius=UDim.new(0,6)})
                    item.MouseButton1Click:Connect(function()
                        label.Text = text.." : "..tostring(v)
                        if callback then callback(v) end
                        open=false
                        listFrame.Visible=false
                        tween(listFrame,{Size=UDim2.new(1,-16,0,0)},0.12)
                    end)
                end
            end
            refresh()

            frame.MouseButton1Click:Connect(function()
                open = not open
                listFrame.Visible = open
                if open then
                    local h = math.min(#list*34+8,180)
                    tween(listFrame,{Size=UDim2.new(1,-16,0,h)},0.16)
                else
                    tween(listFrame,{Size=UDim2.new(1,-16,0,0)},0.12)
                    task.delay(0.12,function()
                        if listFrame then listFrame.Visible=false end
                    end)
                end
            end)

            return {
                SetItems=function(_,arr) list=arr; refresh() end
            }
        end

        -------------------------------------------------------
        --  COLOR PRESETS
        -------------------------------------------------------
        function api:AddColorPresets(callback)
            local frame = new("Frame",{
                Parent=parent,
                Size=UDim2.new(1,-16,0,48),
                BackgroundColor3=Color3.fromRGB(36,36,44)
            })
            new("UICorner",{Parent=frame,CornerRadius=UDim.new(0,8)})

            local x=8
            for name,p in pairs(AUL2.Presets) do
                local btn = new("TextButton",{
                    Parent=frame,
                    Size=UDim2.new(0,36,0,36),
                    Position=UDim2.new(0,x,0,6),
                    BackgroundColor3=p.Accent,
                    Text="",
                    BorderSizePixel=0
                })
                new("UICorner",{Parent=btn,CornerRadius=UDim.new(0,6)})

                btn.MouseButton1Click:Connect(function()
                    AccentBar.BackgroundColor3 = p.Accent
                    preset = p
                    if callback then callback(name,p) end
                end)

                x = x + 44
            end
        end

        return api
    end

    --========================================================
    --  PUBLIC API
    --========================================================
    local api = {}

    function api:AddTab(name, icon)
        return addTab(name, icon)
    end

    function api:Section(tabName, title)
        local page = pageFrames[tabName]
        return makeSection(page, title)
    end

    return api
end

return AUL2
