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

-- // Кнопка сохранения в файл
local SaveBtn = Instance.new("TextButton")
SaveBtn.Size = UDim2.new(0, 100, 0, 25)
SaveBtn.Position = UDim2.new(0, 190, 0, 5)
SaveBtn.BackgroundColor3 = Color3.fromRGB(40, 160, 80)
SaveBtn.Text = "В файл (UTF-8)"
SaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SaveBtn.TextSize = 12
SaveBtn.Font = Enum.Font.Gotham
SaveBtn.Parent = ControlBar

local SaveCorner = Instance.new("UICorner")
SaveCorner.CornerRadius = UDim.new(0, 6)
SaveCorner.Parent = SaveBtn

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

-- // Кнопка сохранения в файл (UTF-8 с BOM для кириллицы)
SaveBtn.MouseButton1Click:Connect(function()
    if #logs == 0 then
        addLog("Нет логов для сохранения", Color3.fromRGB(255, 100, 100))
        return
    end
    
    if not writefile then
        addLog("⚠ writefile() недоступен в этом executor", Color3.fromRGB(255, 200, 50))
        return
    end
    
    local allText = ""
    for _, log in ipairs(logs) do
        allText = allText .. (SHOW_TIMESTAMPS and "[" .. log.time .. "] " or "") .. log.text .. "\n"
    end
    
    local filePath = "kilo_logs_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
    -- UTF-8 BOM для корректного отображения кириллицы в Windows
    local utf8Bom = "\239\187\191"
    
    local success, err = pcall(function()
        writefile(filePath, utf8Bom .. allText)
    end)
    
    if success then
        addLog("✓ Сохранено: " .. filePath, Color3.fromRGB(100, 255, 100))
        addLog("  Файл в папке executor, откройте блокнотом", Color3.fromRGB(180, 180, 200))
    else
        addLog("⚠ Ошибка сохранения: " .. tostring(err), Color3.fromRGB(255, 100, 100))
    end
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
    
    -- Метод 1: Запись в файл с UTF-8 BOM (самый надёжный для кириллицы)
    if writefile then
        local filePath = "kilo_logs_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
        -- Добавляем UTF-8 BOM для корректного отображения кириллицы
        local utf8Bom = "\239\187\191"
        local success, err = pcall(function()
            writefile(filePath, utf8Bom .. allText)
        end)
        if success then
            addLog("✓ Логи сохранены в файл: " .. filePath, Color3.fromRGB(100, 255, 100))
            addLog("  Откройте файл и скопируйте текст", Color3.fromRGB(180, 180, 200))
            
            -- Пытаемся также скопировать через setclipboard
            if setclipboard then
                local clipSuccess = pcall(function()
                    setclipboard(allText)
                end)
                if clipSuccess then
                    addLog("✓ Также скопировано в буфер обмена", Color3.fromRGB(100, 255, 100))
                else
                    addLog("⚠ setclipboard() не сработал, используйте файл", Color3.fromRGB(255, 200, 50))
                end
            end
            return
        else
            addLog("⚠ Ошибка записи файла: " .. tostring(err), Color3.fromRGB(255, 200, 50))
        end
    end
    
    -- Метод 2: setclipboard (может иметь проблемы с кириллицей)
    if setclipboard then
        local success = pcall(function()
            setclipboard(allText)
        end)
        if success then
            addLog("✓ Скопировано в буфер обмена (" .. #logs .. " логов)", Color3.fromRGB(100, 255, 100))
            addLog("⚠ Если кириллица с артефактами - используйте запись в файл", Color3.fromRGB(255, 200, 50))
        else
            addLog("⚠ setclipboard() не доступен", Color3.fromRGB(255, 200, 50))
        end
    end
    
    -- Метод 3: TextBox для ручного копирования
    addLog("Создаю окно для ручного копирования...", Color3.fromRGB(180, 180, 200))
    
    -- Удаляем старое окно если есть
    if ScreenGui:FindFirstChild("CopyTextBox") then
        ScreenGui.CopyTextBox:Destroy()
    end
    
    local CopyFrame = Instance.new("Frame")
    CopyFrame.Name = "CopyTextBox"
    CopyFrame.Size = UDim2.new(0, 500, 0, 400)
    CopyFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
    CopyFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    CopyFrame.BorderSizePixel = 0
    CopyFrame.ZIndex = 100
    CopyFrame.Parent = ScreenGui
    
    local CopyFrameCorner = Instance.new("UICorner")
    CopyFrameCorner.CornerRadius = UDim.new(0, 10)
    CopyFrameCorner.Parent = CopyFrame
    
    local CopyFrameStroke = Instance.new("UIStroke")
    CopyFrameStroke.Color = Color3.fromRGB(100, 100, 150)
    CopyFrameStroke.Thickness = 2
    CopyFrameStroke.Parent = CopyFrame
    
    local CopyTitle = Instance.new("TextLabel")
    CopyTitle.Size = UDim2.new(1, -40, 0, 30)
    CopyTitle.Position = UDim2.new(0, 10, 0, 5)
    CopyTitle.BackgroundTransparency = 1
    CopyTitle.Text = "Выделите текст и нажмите Ctrl+C"
    CopyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyTitle.TextSize = 13
    CopyTitle.Font = Enum.Font.GothamBold
    CopyTitle.TextXAlignment = Enum.TextXAlignment.Left
    CopyTitle.ZIndex = 101
    CopyTitle.Parent = CopyFrame
    
    local CloseCopyBtn = Instance.new("TextButton")
    CloseCopyBtn.Size = UDim2.new(0, 25, 0, 25)
    CloseCopyBtn.Position = UDim2.new(1, -30, 0, 5)
    CloseCopyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    CloseCopyBtn.Text = "X"
    CloseCopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseCopyBtn.TextSize = 12
    CloseCopyBtn.Font = Enum.Font.GothamBold
    CloseCopyBtn.ZIndex = 101
    CloseCopyBtn.Parent = CopyFrame
    
    local CloseCopyCorner = Instance.new("UICorner")
    CloseCopyCorner.CornerRadius = UDim.new(0, 6)
    CloseCopyCorner.Parent = CloseCopyBtn
    
    CloseCopyBtn.MouseButton1Click:Connect(function()
        CopyFrame:Destroy()
    end)
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -20, 1, -40)
    TextBox.Position = UDim2.new(0, 10, 0, 35)
    TextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    TextBox.Text = allText
    TextBox.TextColor3 = Color3.fromRGB(220, 220, 230)
    TextBox.TextSize = 11
    TextBox.Font = Enum.Font.Code
    TextBox.TextWrapped = true
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.TextYAlignment = Enum.TextYAlignment.Top
    TextBox.ClearTextOnFocus = false
    TextBox.MultiLine = true
    TextBox.ZIndex = 101
    TextBox.Parent = CopyFrame
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 6)
    TextBoxCorner.Parent = TextBox
    
    TextBox.MouseButton1Click:Connect(function()
        TextBox.SelectionStart = 1
        TextBox.CursorPosition = #TextBox.Text + 1
    end)
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
