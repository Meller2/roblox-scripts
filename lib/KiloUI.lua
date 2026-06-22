-- // KiloUI v1.0 — Custom UI Library for Roblox
-- // Lightweight, animated, dark theme with gold accent

-- // Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- // Theme
local Theme = {
    Background = Color3.fromRGB(18, 18, 32),
    BackgroundGradient = ColorSequence.new{
        TweenService and Color3.fromRGB(18, 18, 32) or Color3.new(),
        Color3.fromRGB(22, 28, 48)
    },
    Sidebar = Color3.fromRGB(14, 14, 26),
    SidebarHover = Color3.fromRGB(24, 24, 42),
    SidebarActive = Color3.fromRGB(30, 30, 52),
    Accent = Color3.fromRGB(240, 165, 0),
    AccentDark = Color3.fromRGB(207, 117, 0),
    AccentGradient = ColorSequence.new{
        Color3.fromRGB(255, 190, 50),
        Color3.fromRGB(240, 140, 0)
    },
    TextPrimary = Color3.fromRGB(235, 235, 245),
    TextSecondary = Color3.fromRGB(160, 160, 180),
    TextMuted = Color3.fromRGB(100, 100, 120),
    Border = Color3.fromRGB(40, 40, 65),
    BorderAccent = Color3.fromRGB(240, 165, 0),
    ToggleOff = Color3.fromRGB(50, 50, 70),
    ToggleOn = Color3.fromRGB(240, 165, 0),
    SliderBg = Color3.fromRGB(35, 35, 55),
    SliderFill = Color3.fromRGB(240, 165, 0),
    ButtonBg = Color3.fromRGB(30, 30, 50),
    ButtonHover = Color3.fromRGB(40, 40, 65),
    NotifySuccess = Color3.fromRGB(40, 180, 80),
    NotifyError = Color3.fromRGB(220, 60, 60),
    NotifyInfo = Color3.fromRGB(240, 165, 0),
    Shadow = Color3.fromRGB(0, 0, 0),
}

-- // Utility functions
local function make(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            inst[k] = v
        end
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function tween(obj, time, props, style, dir)
    style = style or Enum.EasingStyle.Quint
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, style, dir)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function tweenLinear(obj, time, props)
    local info = TweenInfo.new(time, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function rippleEffect(frame, x, y, color)
    local ripple = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color or Theme.Accent,
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        ZIndex = frame.ZIndex + 1,
        Parent = frame,
    }, {
        make("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })

    tween(ripple, 0.4, {
        Size = UDim2.new(1, 40, 1, 40),
        BackgroundTransparency = 1,
        Position = UDim2.new(0, x - 20, 0, y - 20),
    })

    task.delay(0.4, function()
        ripple:Destroy()
    end)
end

-- // KiloUI Module
local KiloUI = {}
KiloUI.__index = KiloUI

local activeWindows = {}
local notifyIndex = 0

-- // CreateWindow
function KiloUI:CreateWindow(config)
    config = config or {}
    local title = config.Name or "KiloUI"
    local subtitle = config.LoadingSubtitle or ""
    local themeName = config.Theme or "Default"

    -- // Apply theme overrides
    if themeName == "AmberGlow" or themeName == "Default" then
        -- Default gold theme, no changes needed
    elseif themeName == "Ocean" then
        Theme.Accent = Color3.fromRGB(0, 160, 220)
        Theme.AccentDark = Color3.fromRGB(0, 120, 180)
        Theme.AccentGradient = ColorSequence.new{Color3.fromRGB(50, 190, 255), Color3.fromRGB(0, 130, 200)}
        Theme.ToggleOn = Color3.fromRGB(0, 160, 220)
        Theme.SliderFill = Color3.fromRGB(0, 160, 220)
        Theme.BorderAccent = Color3.fromRGB(0, 160, 220)
        Theme.NotifyInfo = Color3.fromRGB(0, 160, 220)
    elseif themeName == "Emerald" then
        Theme.Accent = Color3.fromRGB(40, 200, 120)
        Theme.AccentDark = Color3.fromRGB(20, 160, 90)
        Theme.AccentGradient = ColorSequence.new{Color3.fromRGB(80, 230, 150), Color3.fromRGB(30, 180, 100)}
        Theme.ToggleOn = Color3.fromRGB(40, 200, 120)
        Theme.SliderFill = Color3.fromRGB(40, 200, 120)
        Theme.BorderAccent = Color3.fromRGB(40, 200, 120)
        Theme.NotifyInfo = Color3.fromRGB(40, 200, 120)
    elseif themeName == "Serenity" then
        Theme.Accent = Color3.fromRGB(160, 100, 220)
        Theme.AccentDark = Color3.fromRGB(120, 60, 180)
        Theme.AccentGradient = ColorSequence.new{Color3.fromRGB(190, 130, 255), Color3.fromRGB(140, 80, 200)}
        Theme.ToggleOn = Color3.fromRGB(160, 100, 220)
        Theme.SliderFill = Color3.fromRGB(160, 100, 220)
        Theme.BorderAccent = Color3.fromRGB(160, 100, 220)
        Theme.NotifyInfo = Color3.fromRGB(160, 100, 220)
    end

    -- // ScreenGui
    local screenGui = make("ScreenGui", {
        Name = "KiloUI_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })

    -- // Blur background
    local blur = make("BlurEffect", {
        Size = 0,
        Parent = nil,
    })

    -- // Loading screen
    local loadingFrame = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 340, 0, 180),
        ZIndex = 100,
        Parent = screenGui,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, 16)}),
        make("UIStroke", {
            Color = Theme.Border,
            Thickness = 1.5,
            Transparency = 0.3,
        }),
        make("UIGradient", {
            Color = ColorSequence.new{
                Color3.fromRGB(22, 22, 38),
                Color3.fromRGB(18, 18, 32),
            },
            Rotation = 135,
        }),
    })

    local loadingTitle = make("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.LoadingTitle or "Loading...",
        TextColor3 = Theme.TextPrimary,
        TextSize = 20,
        Position = UDim2.new(0.5, 0, 0.35, 0),
        Size = UDim2.new(0.8, 0, 0, 30),
        ZIndex = 101,
        Parent = loadingFrame,
    })

    local loadingSub = make("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = subtitle,
        TextColor3 = Theme.TextSecondary,
        TextSize = 14,
        Position = UDim2.new(0.5, 0, 0.55, 0),
        Size = UDim2.new(0.8, 0, 0, 20),
        ZIndex = 101,
        Parent = loadingFrame,
    })

    -- // Loading bar
    local loadingBarBg = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.SliderBg,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.72, 0),
        Size = UDim2.new(0.7, 0, 0, 6),
        ZIndex = 101,
        Parent = loadingFrame,
    }, {
        make("UICorner", {CornerRadius = UDim.new(1, 0)}),
    })

    local loadingBarFill = make("Frame", {
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 102,
        Parent = loadingBarBg,
    }, {
        make("UICorner", {CornerRadius = UDim.new(1, 0)}),
        make("UIGradient", {
            Color = Theme.AccentGradient,
        }),
    })

    -- // Show loading
    screenGui.Parent = PlayerGui
    loadingFrame.Size = UDim2.new(0, 0, 0, 0)
    loadingFrame.BackgroundTransparency = 1
    tween(loadingFrame, 0.4, {
        Size = UDim2.new(0, 340, 0, 180),
        BackgroundTransparency = 0,
    })

    -- // Animate loading bar
    tween(loadingBarFill, 1.2, {Size = UDim2.new(1, 0, 1, 0)}, Enum.EasingStyle.Quart)

    task.wait(1.4)

    -- // Fade out loading
    tween(loadingFrame, 0.3, {BackgroundTransparency = 1})
    task.wait(0.3)
    loadingFrame:Destroy()

    -- // Main window container
    local mainFrame = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 580, 0, 400),
        Visible = true,
        ZIndex = 10,
        Parent = screenGui,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, 14)}),
        make("UIStroke", {
            Color = Theme.Border,
            Thickness = 1.5,
            Transparency = 0.4,
        }),
        make("UIGradient", {
            Color = ColorSequence.new{
                Color3.fromRGB(22, 22, 40),
                Color3.fromRGB(16, 16, 30),
            },
            Rotation = 160,
        }),
    })

    -- // Outer glow stroke
    make("UIStroke", {
        Color = Theme.Accent,
        Thickness = 1,
        Transparency = 0.85,
        Parent = mainFrame,
    })

    -- // Title bar
    local titleBar = make("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 42),
        ZIndex = 11,
        Parent = mainFrame,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, 14)}),
    })

    -- // Fix bottom corners of title bar
    local titleBarFix = make("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -14),
        Size = UDim2.new(1, 0, 0, 14),
        ZIndex = 11,
        Parent = titleBar,
    })

    -- // Accent line under title bar
    local accentLine = make("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, 0, 1, 0),
        Size = UDim2.new(0, 0, 0, 2),
        ZIndex = 12,
        Parent = titleBar,
    }, {
        make("UIGradient", {Color = Theme.AccentGradient}),
    })

    tween(accentLine, 0.6, {Size = UDim2.new(0.6, 0, 0, 2)}, Enum.EasingStyle.Quart)

    -- // Title text
    make("TextLabel", {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 18, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        ZIndex = 12,
        Parent = titleBar,
    })

    -- // Close button
    local closeBtn = make("TextButton", {
        AnchorPoint = Vector2.new(1, 0),
        AutoButtonColor = false,
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Font = Enum.Font.GothamBold,
        Position = UDim2.new(1, -12, 0, 8),
        Size = UDim2.new(0, 26, 0, 26),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        ZIndex = 13,
        Parent = titleBar,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, 7)}),
        make("UIStroke", {
            Color = Color3.fromRGB(220, 50, 50),
            Thickness = 1,
            Transparency = 0.3,
        }),
    })

    -- // X symbol for close
    make("TextLabel", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 100, 100),
        TextSize = 12,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 14,
        Parent = closeBtn,
    })

    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, 0.15, {BackgroundTransparency = 0.2})
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, 0.15, {BackgroundTransparency = 0.6})
    end)

    -- // Sidebar
    local sidebar = make("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 42),
        Size = UDim2.new(0, 160, 1, -42),
        ZIndex = 11,
        Parent = mainFrame,
    }, {
        make("UICorner", {CornerRadius = UDim.new(0, 14)}),
    })

    -- // Sidebar bottom fix
    local sidebarFix = make("Frame", {
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -14, 0, 0),
        Size = UDim2.new(0, 14, 1, 0),
        ZIndex = 11,
        Parent = sidebar,
    })

    -- // Sidebar vertical accent line
    make("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0, 8),
        Size = UDim2.new(0, 1, 1, -16),
        ZIndex = 12,
        Parent = sidebar,
    })

    local sidebarLayout = make("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sidebar,
    })

    local sidebarPadding = make("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        Parent = sidebar,
    })

    -- // Content area
    local contentArea = make("Frame", {
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 160, 0, 42),
        Size = UDim2.new(1, -160, 1, -42),
        ZIndex = 11,
        Parent = mainFrame,
    })

    local contentPadding = make("UIPadding", {
        PaddingTop = UDim.new(0, 16),
        PaddingLeft = UDim.new(0, 18),
        PaddingRight = UDim.new(0, 18),
        PaddingBottom = UDim.new(0, 16),
        Parent = contentArea,
    })

    -- // Dragging
    local dragging = false
    local dragStart, startPos

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                local delta = input.Position - dragStart
                mainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end
    end)

    -- // Close
    closeBtn.MouseButton1Click:Connect(function()
        tween(mainFrame, 0.3, {
            Size = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
        })
        task.wait(0.35)
        screenGui:Destroy()
    end)

    -- // Window animation
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    mainFrame.BackgroundTransparency = 1
    tween(mainFrame, 0.5, {
        Size = UDim2.new(0, 580, 0, 400),
        BackgroundTransparency = 0,
    }, Enum.EasingStyle.Back)

    -- // Window object
    local window = {}
    local tabs = {}
    local activeTab = nil

    function window:CreateTab(name, iconId)
        local tabBtn = make("TextButton", {
            AutoButtonColor = false,
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamSemibold,
            LayoutOrder = #tabs + 1,
            Size = UDim2.new(1, -4, 0, 38),
            Text = "",
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            ZIndex = 12,
            Parent = sidebar,
        }, {
            make("UICorner", {CornerRadius = UDim.new(0, 10)}),
        })

        -- // Tab icon
        local tabIcon = make("ImageLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Image = iconId and ("rbxassetid://" .. tostring(iconId)) or "",
            ImageColor3 = Theme.TextSecondary,
            Position = UDim2.new(0, 10, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            ZIndex = 13,
            Parent = tabBtn,
        })

        -- // Tab name
        local tabLabel = make("TextLabel", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamSemibold,
            Position = UDim2.new(0, iconId and 36 or 12, 0.5, 0),
            Size = UDim2.new(1, -40, 1, 0),
            Text = name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 13,
            Parent = tabBtn,
        })

        -- // Active indicator bar
        local activeBar = make("Frame", {
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.new(0, 3, 0, 0),
            ZIndex = 13,
            Parent = tabBtn,
        }, {
            make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            make("UIGradient", {Color = Theme.AccentGradient}),
        })

        -- // Content frame for this tab
        local tabContent = make("ScrollingFrame", {
            Active = true,
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 11,
            Parent = contentArea,
        }, {
            make("UIListLayout", {
                Padding = UDim.new(0, 10),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            make("UIPadding", {
                PaddingRight = UDim.new(0, 6),
            }),
        })

        local tab = {Frame = tabContent, Button = tabBtn, ActiveBar = activeBar, Label = tabLabel, Icon = tabIcon}
        local elements = {}

        -- // Hover effect
        tabBtn.MouseEnter:Connect(function()
            if tab ~= activeTab then
                tween(tabBtn, 0.15, {BackgroundColor3 = Theme.SidebarHover, BackgroundTransparency = 0.5})
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if tab ~= activeTab then
                tween(tabBtn, 0.15, {BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.8})
            end
        end)

        local function activateTab()
            if activeTab == tab then return end

            if activeTab then
                local oldBtn = activeTab.Button
                tween(oldBtn, 0.2, {BackgroundColor3 = Theme.Sidebar, BackgroundTransparency = 0.8})
                if activeTab.Label then tween(activeTab.Label, 0.2, {TextColor3 = Theme.TextSecondary}) end
                if activeTab.Icon then tween(activeTab.Icon, 0.2, {ImageColor3 = Theme.TextSecondary}) end
                if activeTab.ActiveBar then tween(activeTab.ActiveBar, 0.2, {Size = UDim2.new(0, 3, 0, 0)}) end
                activeTab.Frame.Visible = false
            end

            activeTab = tab
            tween(tabBtn, 0.2, {BackgroundColor3 = Theme.SidebarActive, BackgroundTransparency = 0.3})
            tween(tabLabel, 0.2, {TextColor3 = Theme.Accent})
            tween(tabIcon, 0.2, {ImageColor3 = Theme.Accent})
            tween(activeBar, 0.25, {Size = UDim2.new(0, 3, 0, 24)}, Enum.EasingStyle.Back)
            tabContent.Visible = true
        end

        tabBtn.MouseButton1Click:Connect(activateTab)

        if #tabs == 0 then
            task.spawn(function()
                task.wait(0.15)
                activateTab()
            end)
        end

        -- // Toggle element
        function tab:CreateToggle(config)
            config = config or {}
            local toggleName = config.Name or "Toggle"
            local default = config.CurrentValue or false
            local callback = config.Callback or function() end
            local flag = config.Flag or ""

            local container = make("Frame", {
                BackgroundColor3 = Theme.ButtonBg,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                LayoutOrder = #elements + 1,
                Size = UDim2.new(1, 0, 0, 44),
                ZIndex = 12,
                Parent = tabContent,
            }, {
                make("UICorner", {CornerRadius = UDim.new(0, 10)}),
                make("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Transparency = 0.5,
                }),
            })

            local toggleLabel = make("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Position = UDim2.new(0, 14, 0.5, 0),
                Size = UDim2.new(1, -70, 1, 0),
                Text = toggleName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
                Parent = container,
            })

            local toggleBg = make("Frame", {
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff,
                BorderSizePixel = 0,
                Position = UDim2.new(1, -12, 0.5, 0),
                Size = UDim2.new(0, 42, 0, 22),
                ZIndex = 13,
                Parent = container,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            })

            local toggleCircle = make("Frame", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = default and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 14,
                Parent = toggleBg,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
                make("UIStroke", {
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1,
                    Transparency = 0.8,
                }),
            })

            local toggleState = default

            local function updateToggle(state)
                toggleState = state
                if state then
                    tween(toggleBg, 0.25, {BackgroundColor3 = Theme.ToggleOn})
                    tween(toggleCircle, 0.25, {Position = UDim2.new(1, -19, 0.5, 0)}, Enum.EasingStyle.Back)
                else
                    tween(toggleBg, 0.25, {BackgroundColor3 = Theme.ToggleOff})
                    tween(toggleCircle, 0.25, {Position = UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back)
                end
                callback(state)
            end

            local toggleBtn = make("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 15,
                Parent = container,
            })

            toggleBtn.MouseButton1Click:Connect(function()
                updateToggle(not toggleState)
            end)

            container.MouseEnter:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.1})
            end)
            container.MouseLeave:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.3})
            end)

            table.insert(elements, {Type = "Toggle", Update = updateToggle})
            return {
                Set = function(self, value) updateToggle(value) end,
                Get = function(self) return toggleState end,
            }
        end

        -- // Slider element
        function tab:CreateSlider(config)
            config = config or {}
            local sliderName = config.Name or "Slider"
            local info = config.Info or ""
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local callback = config.Callback or function() end
            local valueName = config.ValueName or ""

            local container = make("Frame", {
                BackgroundColor3 = Theme.ButtonBg,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                LayoutOrder = #elements + 1,
                Size = UDim2.new(1, 0, 0, info ~= "" and 68 or 48),
                ZIndex = 12,
                Parent = tabContent,
            }, {
                make("UICorner", {CornerRadius = UDim.new(0, 10)}),
                make("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Transparency = 0.5,
                }),
            })

            local sliderLabel = make("TextLabel", {
                AnchorPoint = Vector2.new(0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Position = UDim2.new(0, 14, 0, 8),
                Size = UDim2.new(1, -80, 0, 20),
                Text = sliderName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
                Parent = container,
            })

            local valueLabel = make("TextLabel", {
                AnchorPoint = Vector2.new(1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Position = UDim2.new(1, -12, 0, 8),
                Size = UDim2.new(0, 60, 0, 20),
                Text = tostring(default) .. " " .. valueName,
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 13,
                Parent = container,
            })

            if info ~= "" then
                make("TextLabel", {
                    AnchorPoint = Vector2.new(0, 0),
                    BackgroundTransparency = 1,
                    Font = Enum.Font.Gotham,
                    Position = UDim2.new(0, 14, 0, 26),
                    Size = UDim2.new(1, -28, 0, 14),
                    Text = info,
                    TextColor3 = Theme.TextMuted,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 13,
                    Parent = container,
                })
            end

            local sliderYOffset = info ~= "" and 46 or 32

            local sliderBg = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = Theme.SliderBg,
                BorderSizePixel = 0,
                Position = UDim2.new(0.5, 0, 0, sliderYOffset),
                Size = UDim2.new(1, -28, 0, 8),
                ZIndex = 13,
                Parent = container,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            })

            local fillPercent = (default - min) / (max - min)

            local sliderFill = make("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Size = UDim2.new(fillPercent, 0, 1, 0),
                ZIndex = 14,
                Parent = sliderBg,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
                make("UIGradient", {Color = Theme.AccentGradient}),
            })

            local sliderKnob = make("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                Position = UDim2.new(fillPercent, 0, 0.5, 0),
                Size = UDim2.new(0, 16, 0, 16),
                ZIndex = 15,
                Parent = sliderBg,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
                make("UIStroke", {
                    Color = Theme.Accent,
                    Thickness = 2,
                    Transparency = 0,
                }),
            })

            local sliderValue = default
            local sliding = false

            local function updateSlider(inputX)
                local absPos = sliderBg.AbsolutePosition.X
                local absSize = sliderBg.AbsoluteSize.X
                local rel = math.clamp((inputX - absPos) / absSize, 0, 1)
                local raw = min + rel * (max - min)
                local snapped = math.floor(raw / increment + 0.5) * increment
                snapped = math.clamp(snapped, min, max)
                sliderValue = snapped

                local pct = (snapped - min) / (max - min)
                tween(sliderFill, 0.08, {Size = UDim2.new(pct, 0, 1, 0)})
                tween(sliderKnob, 0.08, {Position = UDim2.new(pct, 0, 0.5, 0)})
                valueLabel.Text = tostring(snapped) .. " " .. valueName
                callback(snapped)
            end

            local sliderInput = make("TextButton", {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, sliderYOffset - 6),
                Size = UDim2.new(1, 0, 0, 20),
                Text = "",
                ZIndex = 16,
                Parent = container,
            })

            sliderInput.MouseButton1Down:Connect(function()
                sliding = true
            end)

            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)

            container.MouseEnter:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.1})
            end)
            container.MouseLeave:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.3})
            end)

            table.insert(elements, {Type = "Slider"})
            return {
                Set = function(self, value)
                    value = math.clamp(value, min, max)
                    sliderValue = value
                    local pct = (value - min) / (max - min)
                    tween(sliderFill, 0.2, {Size = UDim2.new(pct, 0, 1, 0)})
                    tween(sliderKnob, 0.2, {Position = UDim2.new(pct, 0, 0.5, 0)})
                    valueLabel.Text = tostring(value) .. " " .. valueName
                    callback(value)
                end,
                Get = function(self) return sliderValue end,
            }
        end

        -- // Button element
        function tab:CreateButton(config)
            config = config or {}
            local btnName = config.Name or "Button"
            local callback = config.Callback or function() end

            local container = make("TextButton", {
                AutoButtonColor = false,
                BackgroundColor3 = Theme.ButtonBg,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                Font = Enum.Font.GothamSemibold,
                LayoutOrder = #elements + 1,
                Size = UDim2.new(1, 0, 0, 40),
                Text = "",
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                ZIndex = 12,
                Parent = tabContent,
            }, {
                make("UICorner", {CornerRadius = UDim.new(0, 10)}),
                make("UIStroke", {
                    Color = Theme.Border,
                    Thickness = 1,
                    Transparency = 0.5,
                }),
            })

            -- // Accent left bar
            make("Frame", {
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 0, 6),
                Size = UDim2.new(0, 3, 1, -12),
                ZIndex = 13,
                Parent = container,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            })

            make("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamSemibold,
                Position = UDim2.new(0, 16, 0.5, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Text = btnName,
                TextColor3 = Theme.TextPrimary,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
                Parent = container,
            })

            container.MouseEnter:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.05, BackgroundColor3 = Theme.ButtonHover})
            end)
            container.MouseLeave:Connect(function()
                tween(container, 0.15, {BackgroundTransparency = 0.3, BackgroundColor3 = Theme.ButtonBg})
            end)

            container.MouseButton1Click:Connect(function()
                rippleEffect(container, container.AbsoluteSize.X / 2, container.AbsoluteSize.Y / 2, Theme.Accent)
                callback()
            end)

            table.insert(elements, {Type = "Button"})
            return container
        end

        -- // Label element
        function tab:CreateLabel(text)
            local container = make("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = #elements + 1,
                Size = UDim2.new(1, 0, 0, 24),
                ZIndex = 12,
                Parent = tabContent,
            })

            make("TextLabel", {
                BackgroundTransparency = 1,
                Font = Enum.Font.Gotham,
                Position = UDim2.new(0, 4, 0, 0),
                Size = UDim2.new(1, -8, 1, 0),
                Text = text or "",
                TextColor3 = Theme.TextSecondary,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 13,
                Parent = container,
            })

            table.insert(elements, {Type = "Label"})
            return container
        end

        -- // Section separator
        function tab:CreateSection(title)
            local container = make("Frame", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder = #elements + 1,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 12,
                Parent = tabContent,
            })

            make("TextLabel", {
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Font = Enum.Font.GothamBold,
                Position = UDim2.new(0, 4, 0.5, 0),
                Size = UDim2.new(1, -8, 0, 18),
                Text = title or "",
                TextColor3 = Theme.Accent,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTransparency = 0.2,
                ZIndex = 13,
                Parent = container,
            })

            make("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 4, 1, -2),
                Size = UDim2.new(0, 40, 0, 2),
                ZIndex = 13,
                Parent = container,
            }, {
                make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            })

            table.insert(elements, {Type = "Section"})
            return container
        end

        table.insert(tabs, tab)
        return tab
    end

    -- // Notify function
    function window:Notify(config)
        config = config or {}
        local notifyTitle = config.Title or "Notification"
        local content = config.Content or ""
        local duration = config.Duration or 4
        local image = config.Image

        notifyIndex = notifyIndex + 1
        local idx = notifyIndex

        local notifyFrame = make("Frame", {
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = Theme.Background,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Position = UDim2.new(1, 320, 0, 60 + (idx - 1) * 75),
            Size = UDim2.new(0, 300, 0, 65),
            ZIndex = 200,
            Parent = screenGui,
        }, {
            make("UICorner", {CornerRadius = UDim.new(0, 12)}),
            make("UIStroke", {
                Color = Theme.Border,
                Thickness = 1,
                Transparency = 0.4,
            }),
            make("UIGradient", {
                Color = ColorSequence.new{
                    Color3.fromRGB(24, 24, 42),
                    Color3.fromRGB(18, 18, 34),
                },
                Rotation = 135,
            }),
        })

        -- // Accent left bar
        make("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 8),
            Size = UDim2.new(0, 3, 1, -16),
            ZIndex = 201,
            Parent = notifyFrame,
        }, {
            make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            make("UIGradient", {Color = Theme.AccentGradient}),
        })

        -- // Icon
        if image then
            make("ImageLabel", {
                BackgroundTransparency = 1,
                Image = "rbxassetid://" .. tostring(image),
                ImageColor3 = Theme.Accent,
                Position = UDim2.new(0, 14, 0, 10),
                Size = UDim2.new(0, 22, 0, 22),
                ZIndex = 202,
                Parent = notifyFrame,
            })
        end

        local titleOffset = image and 42 or 14

        make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Position = UDim2.new(0, titleOffset, 0, 8),
            Size = UDim2.new(1, -titleOffset - 10, 0, 22),
            Text = notifyTitle,
            TextColor3 = Theme.TextPrimary,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 202,
            Parent = notifyFrame,
        })

        make("TextLabel", {
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Position = UDim2.new(0, titleOffset, 0, 30),
            Size = UDim2.new(1, -titleOffset - 10, 0, 28),
            Text = content,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 202,
            Parent = notifyFrame,
        })

        -- // Progress bar
        local progressBg = make("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            BackgroundColor3 = Theme.SliderBg,
            BorderSizePixel = 0,
            Position = UDim2.new(0.5, 0, 1, -3),
            Size = UDim2.new(0.9, 0, 0, 3),
            ZIndex = 202,
            Parent = notifyFrame,
        }, {
            make("UICorner", {CornerRadius = UDim.new(1, 0)}),
        })

        local progressFill = make("Frame", {
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 1, 0),
            ZIndex = 203,
            Parent = progressBg,
        }, {
            make("UICorner", {CornerRadius = UDim.new(1, 0)}),
            make("UIGradient", {Color = Theme.AccentGradient}),
        })

        -- // Animate in
        tween(notifyFrame, 0.4, {
            Position = UDim2.new(1, -16, 0, 60 + (idx - 1) * 75),
        }, Enum.EasingStyle.Back)

        tween(progressFill, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

        task.delay(duration, function()
            tween(notifyFrame, 0.3, {
                Position = UDim2.new(1, 320, 0, 60 + (idx - 1) * 75),
                BackgroundTransparency = 1,
            })
            task.wait(0.35)
            notifyFrame:Destroy()
        end)
    end

    table.insert(activeWindows, window)
    return window
end

-- // Global notify (works without window reference)
function KiloUI:Notify(config)
    -- Placeholder for global notifications
end

return KiloUI
