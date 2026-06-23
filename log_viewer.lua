-- // Log Viewer - Просмотрщик логов с возможностью копирования
-- // Перехватывает print() и warn() и отображает в UI окне

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- // Настройки
local MAX_LOGS = 500 -- Максимальное количество логов
local AUTO_SCROLL = true -- Автопрокрутка вниз
local SHOW_TIMESTAMPS = true -- Показывать время

-- // Создаём ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LogViewer_" .. tostring(math.random(1000, 9999))
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- // Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 600)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- // Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- // Исправление нижних углов заголовка
local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- // Текст заголовка
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -40, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📋 Log Viewer"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 16
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

-- // Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- // Панель управления
local ControlBar = Instance.new("Frame")
ControlBar.Size = UDim2.new(1, 0, 0, 35)
ControlBar.Position = UDim2.new(0, 0, 0, 40)
ControlBar.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
ControlBar.BorderSizePixel = 0
ControlBar.Parent = MainFrame

-- // Кнопка очистки
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0, 80, 0, 25)
ClearBtn.Position = UDim2.new(0, 10, 0, 5)
ClearBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
ClearBtn.Text = "Очистить"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.TextSize = 12
ClearBtn.Font = Enum.Font.Gotham
ClearBtn.Parent = ControlBar

local ClearCorner = Instance.new("UICorner")
ClearCorner.CornerRadius = UDim.new(0, 6)
ClearCorner.Parent = ClearBtn

-- // Кнопка копирования
local CopyBtn = Instance.new("TextButton")
CopyBtn.Size = UDim2.new(0, 80, 0, 25)
CopyBtn.Position = UDim2.new(0, 100, 0, 5)
CopyBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 200)
CopyBtn.Text = "Копировать"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.TextSize = 12
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.Parent = ControlBar

local CopyCorner = Instance.new("UICorner")
CopyCorner.CornerRadius = UDim.new(0, 6)
CopyCorner.Parent = CopyBtn

-- // Счётчик логов
local CountLabel = Instance.new("TextLabel")
CountLabel.Size = UDim2.new(0, 150, 0, 25)
CountLabel.Position = UDim2.new(1, -160, 0, 5)
CountLabel.BackgroundTransparency = 1
CountLabel.Text = "Логов: 0"
CountLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
CountLabel.TextSize = 12
CountLabel.Font = Enum.Font.Gotham
CountLabel.TextXAlignment = Enum.TextXAlignment.Right
CountLabel.Parent = ControlBar

-- // ScrollingFrame для логов
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Name = "LogContainer"
ScrollFrame.Size = UDim2.new(1, 0, 1, -75)
ScrollFrame.Position = UDim2.new(0, 0, 0, 75)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.ScrollBarThickness = 6
ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 12)
ScrollCorner.Parent = ScrollFrame

local ScrollPadding = Instance.new("UIPadding")
ScrollPadding.PaddingTop = UDim.new(0, 8)
ScrollPadding.PaddingBottom = UDim.new(0, 8)
ScrollPadding.PaddingLeft = UDim.new(0, 8)
ScrollPadding.PaddingRight = UDim.new(0, 8)
ScrollPadding.Parent = ScrollFrame

local ScrollList = Instance.new("UIListLayout")
ScrollList.Padding = UDim.new(0, 4)
ScrollList.SortOrder = Enum.SortOrder.LayoutOrder
ScrollList.Parent = ScrollFrame

-- // Хранилище логов
local logs = {}
local logCount = 0

-- // Функция добавления лога
local function addLog(text, color)
    logCount = logCount + 1
    
    -- Ограничиваем количество
    if #logs >= MAX_LOGS then
        table.remove(logs, 1)
        if ScrollFrame:FindFirstChild("Log_" .. (logCount - MAX_LOGS)) then
            ScrollFrame["Log_" .. (logCount - MAX_LOGS)]:Destroy()
        end
    end
    
    table.insert(logs, {text = text, color = color, time = os.date("%H:%M:%S")})
    
    -- Создаём UI элемент
    local LogEntry = Instance.new("Frame")
    LogEntry.Name = "Log_" .. logCount
    LogEntry.Size = UDim2.new(1, 0, 0, 0)
    LogEntry.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    LogEntry.BorderSizePixel = 0
    LogEntry.LayoutOrder = logCount
    LogEntry.Parent = ScrollFrame
    
    local LogCorner = Instance.new("UICorner")
    LogCorner.CornerRadius = UDim.new(0, 6)
    LogCorner.Parent = LogEntry
    
    local LogText = Instance.new("TextLabel")
    LogText.Size = UDim2.new(1, -16, 0, 0)
    LogText.Position = UDim2.new(0, 8, 0, 4)
    LogText.BackgroundTransparency = 1
    LogText.Text = (SHOW_TIMESTAMPS and "[" .. os.date("%H:%M:%S") .. "] " or "") .. text
    LogText.TextColor3 = color or Color3.fromRGB(220, 220, 230)
    LogText.TextSize = 12
    LogText.Font = Enum.Font.Code
    LogText.TextXAlignment = Enum.TextXAlignment.Left
    LogText.TextYAlignment = Enum.TextYAlignment.Top
    LogText.TextWrapped = true
    LogText.RichText = false
    LogText.Parent = LogEntry
    
    -- Автоматический размер по содержимому
    local function updateSize()
        local textSize = LogText.TextBounds
        LogEntry.Size = UDim2.new(1, 0, 0, textSize.Y + 8)
        LogText.Size = UDim2.new(1, -16, 0, textSize.Y)
    end
    
    LogText:GetPropertyChangedSignal("Text"):Connect(updateSize)
    updateSize()
    
    -- Обновляем счётчик
    CountLabel.Text = "Логов: " .. #logs
    
    -- Автопрокрутка
    if AUTO_SCROLL then
        task.wait(0.1)
        ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.AbsoluteCanvasSize.Y)
    end
end

-- // Перехват print() и warn()
local oldPrint = print
local oldWarn = warn

print = function(...)
    local args = {...}
    local text = ""
    for i, v in ipairs(args) do
        text = text .. tostring(v) .. (i < #args and " " or "")
    end
    oldPrint("[LogViewer] " .. text)
    addLog(text, Color3.fromRGB(220, 220, 230))
end

warn = function(...)
    local args = {...}
    local text = ""
    for i, v in ipairs(args) do
        text = text .. tostring(v) .. (i < #args and " " or "")
    end
    oldWarn("[LogViewer] " .. text)
    addLog("⚠ " .. text, Color3.fromRGB(255, 200, 50))
end

-- // Кнопка очистки
ClearBtn.MouseButton1Click:Connect(function()
    logs = {}
    logCount = 0
    for _, child in ipairs(ScrollFrame:GetChildren()) do
        if child.Name:find("^Log_") then
            child:Destroy()
        end
    end
    CountLabel.Text = "Логов: 0"
end)

-- // Кнопка копирования
CopyBtn.MouseButton1Click:Connect(function()
    if #logs == 0 then
        addLog("Нет логов для копирования", Color3.fromRGB(255, 100, 100))
        return
    end
    
    local allText = ""
    for _, log in ipairs(logs) do
        allText = allText .. (SHOW_TIMESTAMPS and "[" .. log.time .. "] " or "") .. log.text .. "\n"
    end
    
    -- Пытаемся скопировать в буфер обмена
    if setclipboard then
        setclipboard(allText)
        addLog("✓ Скопировано в буфер обмена (" .. #logs .. " логов)", Color3.fromRGB(100, 255, 100))
    else
        -- Если setclipboard недоступен, создаём TextBox для ручного копирования
        addLog("⚠ setclipboard() недоступен. Используйте F9 для копирования", Color3.fromRGB(255, 200, 50))
        
        local TempBox = Instance.new("TextBox")
        TempBox.Size = UDim2.new(0, 400, 0, 300)
        TempBox.Position = UDim2.new(0.5, -200, 0.5, -150)
        TempBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        TempBox.Text = allText
        TempBox.TextColor3 = Color3.fromRGB(220, 220, 230)
        TempBox.TextSize = 11
        TempBox.Font = Enum.Font.Code
        TempText.TextWrapped = true
        TempBox.TextXAlignment = Enum.TextXAlignment.Left
        TempBox.TextYAlignment = Enum.TextYAlignment.Top
        TempBox.ClearTextOnFocus = false
        TempBox.MultiLine = true
        TempBox.Parent = ScreenGui
        
        local TempCorner = Instance.new("UICorner")
        TempCorner.CornerRadius = UDim.new(0, 8)
        TempCorner.Parent = TempBox
        
        local TempStroke = Instance.new("UIStroke")
        TempStroke.Color = Color3.fromRGB(100, 100, 120)
        TempStroke.Thickness = 2
        TempStroke.Parent = TempBox
        
        task.delay(10, function()
            if TempBox.Parent then
                TempBox:Destroy()
            end
        end)
    end
end)

-- // Кнопка закрытия
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- // Горячая клавиша для показа/скрытия (Ctrl+L)
local visible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.L and input.Ctrl then
        visible = not visible
        MainFrame.Visible = visible
    end
end)

-- // Приветственное сообщение
addLog("═══════════════════════════════════", Color3.fromRGB(100, 100, 150))
addLog("Log Viewer загружен!", Color3.fromRGB(100, 200, 255))
addLog("Перехватывает print() и warn()", Color3.fromRGB(180, 180, 200))
addLog("═══════════════════════════════════", Color3.fromRGB(100, 100, 150))
addLog("Горячие клавиши:", Color3.fromRGB(200, 200, 100))
addLog("  Ctrl+L - Показать/скрыть окно", Color3.fromRGB(180, 180, 200))
addLog("═══════════════════════════════════", Color3.fromRGB(100, 100, 150))

print("Log Viewer активен!")
