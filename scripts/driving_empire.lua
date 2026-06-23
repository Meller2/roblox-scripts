-- // Driving Empire Auto Farm v2
-- // Реальная логика на основе диагностики

print("[DE] Загрузка скрипта...")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Window = Fluent:CreateWindow({
    Title = "Driving Empire",
    SubTitle = "by KiloUI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Автофарм", Icon = "coins" }),
    Teleport = Window:AddTab({ Title = "Телепорт", Icon = "map-pin" }),
    Vehicle = Window:AddTab({ Title = "Машина", Icon = "car" }),
    Stats = Window:AddTab({ Title = "Статы", Icon = "bar-chart-3" }),
    Log = Window:AddTab({ Title = "Логи", Icon = "scroll-text" })
}

-- // Логирование
local logBuffer = {}
local function log(msg)
    local t = os.date("%H:%M:%S")
    local full = "[" .. t .. "] " .. msg
    print("[DE] " .. msg)
    table.insert(logBuffer, full)
    if #logBuffer > 100 then table.remove(logBuffer, 1) end
end

-- // Получить данные игрока
local function getPlayerData()
    local gpd = ReplicatedStorage:FindFirstChild("GetPlayerData")
    if gpd and gpd:IsA("RemoteFunction") then
        local ok, data = pcall(function() return gpd:InvokeServer() end)
        if ok then return data end
    end
    return nil
end

-- // TeleportMenu кнопки
local function getTeleportButtons()
    local tm = PlayerGui:FindFirstChild("TeleportMenu")
    if not tm then return {} end
    local buttons = {}
    for _, obj in ipairs(tm:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            if obj.Text and obj.Text ~= "" then
                buttons[obj.Text] = obj
            elseif obj.Name and obj.Name ~= "" then
                buttons[obj.Name] = obj
            end
        end
    end
    return buttons
end

-- // Клик по кнопке TeleportMenu
local function clickTeleport(text)
    local buttons = getTeleportButtons()
    for name, btn in pairs(buttons) do
        if name:lower():find(text:lower()) then
            log("Клик по телепорту: " .. name)
            fireclickdetector(btn)
            return true
        end
    end
    log("Телепорт не найден: " .. text)
    return false
end

-- // Телепорт к координатам
local function teleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(pos)
    log("Телепорт к " .. tostring(pos))
end

-- // Авто-вождение (зажим W)
local autoDrive = false
local function startAutoDrive()
    autoDrive = true
    log("Авто-вождение включено")
    task.spawn(function()
        while autoDrive do
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
            -- Симуляция нажатия W
            local args = {
                [1] = "W",
                [2] = true
            }
            -- Пробуем разные методы
            local ok = pcall(function()
                UserInputService:VirtualKeyDown(Enum.KeyCode.W)
            end)
            task.wait(0.1)
        end
    end)
end

local function stopAutoDrive()
    autoDrive = false
    pcall(function() UserInputService:VirtualKeyUp(Enum.KeyCode.W) end)
    log("Авто-вождение выключено")
end

-- // ============ UI ============

Tabs.Farm:AddParagraph({
    Title = "Driving Empire Farm",
    Content = "Автоматизация заработка\nВерсия: 2.0"
})

Tabs.Farm:AddSection("Авто-вождение")

local DriveToggle = Tabs.Farm:AddToggle("AutoDrive", {
    Title = "Авто-вождение (W)",
    Default = false
})

DriveToggle:OnChanged(function(v)
    if v then startAutoDrive() else stopAutoDrive() end
end)

local SpeedSlider = Tabs.Farm:AddSlider("DriveSpeed", {
    Title = "Скорость бота",
    Description = "Задержка между нажатиями",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(v) end
})

Tabs.Farm:AddSection("Гонки")

Tabs.Farm:AddButton({
    Title = "Начать Circuit Race",
    Description = "Телепорт и старт гонки",
    Callback = function()
        log("Запуск Circuit Race...")
        clickTeleport("Circuit")
        Fluent:Notify({Title = "Circuit Race", Content = "Телепорт к гонке...", Duration = 3})
    end
})

Tabs.Farm:AddButton({
    Title = "Начать Cross Country",
    Description = "Телепорт к Cross Country",
    Callback = function()
        log("Запуск Cross Country...")
        clickTeleport("Cross")
        Fluent:Notify({Title = "Cross Country", Content = "Телепорт к гонке...", Duration = 3})
    end
})

Tabs.Farm:AddButton({
    Title = "Начать Highway Race",
    Description = "Телепорт к Highway",
    Callback = function()
        log("Запуск Highway Race...")
        clickTeleport("Highway")
        Fluent:Notify({Title = "Highway Race", Content = "Телепорт к гонке...", Duration = 3})
    end
})

-- // Teleport tab
Tabs.Teleport:AddParagraph({
    Title = "Телепортация",
    Content = "Быстрое перемещение по карте"
})

Tabs.Teleport:AddSection("Дилершипы")

local dLocations = {
    {"Cars & Moto", "Car"},
    {"Boats", "Boat"},
    {"Planes", "Plane"},
    {"Helicopters", "Heli"}
}

for _, d in ipairs(dLocations) do
    Tabs.Teleport:AddButton({
        Title = d[1],
        Callback = function()
            clickTeleport(d[2])
        end
    })
end

Tabs.Teleport:AddSection("Гонки")

local rLocations = {
    {"Circuit Race", "Circuit"},
    {"Cross Country", "Cross"},
    {"Highway Race", "Highway"},
    {"Drag Race", "Drag"}
}

for _, r in ipairs(rLocations) do
    Tabs.Teleport:AddButton({
        Title = r[1],
        Callback = function()
            clickTeleport(r[2])
        end
    })
end

Tabs.Teleport:AddSection("Ручной телепорт")

local XInput = Tabs.Teleport:AddInput("TeleX", {
    Title = "X координата",
    Default = "0",
    Placeholder = "X",
    Numeric = true,
    Callback = function() end
})

local YInput = Tabs.Teleport:AddInput("TeleY", {
    Title = "Y координата",
    Default = "50",
    Placeholder = "Y",
    Numeric = true,
    Callback = function() end
})

local ZInput = Tabs.Teleport:AddInput("TeleZ", {
    Title = "Z координата",
    Default = "0",
    Placeholder = "Z",
    Numeric = true,
    Callback = function() end
})

Tabs.Teleport:AddButton({
    Title = "Телепортироваться",
    Description = "К координатам X, Y, Z",
    Callback = function()
        local x = tonumber(XInput.Value) or 0
        local y = tonumber(YInput.Value) or 50
        local z = tonumber(ZInput.Value) or 0
        teleportTo(Vector3.new(x, y, z))
        Fluent:Notify({Title = "Телепорт", Content = "Перемещение к " .. x .. ", " .. y .. ", " .. z, Duration = 3})
    end
})

-- // Vehicle tab
Tabs.Vehicle:AddParagraph({
    Title = "Управление машиной",
    Content = "Функции для вашего транспорта"
})

Tabs.Vehicle:AddSection("Действия")

Tabs.Vehicle:AddButton({
    Title = "Показать HUD машины",
    Callback = function()
        local hud = PlayerGui:FindFirstChild("ChassisHUD")
        if hud then
            hud.Enabled = true
            log("ChassisHUD включён")
        end
    end
})

Tabs.Vehicle:AddButton({
    Title = "Выйти из машины",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local seat = char:FindFirstChildOfClass("Seat") or char:FindFirstChildOfClass("VehicleSeat")
            if seat then
                seat:Sit(nil)
                log("Вышел из машины")
            end
        end
    end
})

-- // Stats tab
Tabs.Stats:AddParagraph({
    Title = "Статистика",
    Content = "Данные аккаунта"
})

Tabs.Stats:AddButton({
    Title = "Обновить статы",
    Description = "Загрузить данные с сервера",
    Callback = function()
        local data = getPlayerData()
        if data then
            log("Данные получены: " .. tostring(data))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    log("  " .. tostring(k) .. ": " .. tostring(v))
                end
            end
            Fluent:Notify({Title = "Статы", Content = "Данные загружены, смотри логи", Duration = 3})
        else
            log("Не удалось получить данные")
        end
    end
})

Tabs.Stats:AddSection("leaderstats")

local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats then
    local statsText = ""
    for _, stat in ipairs(leaderstats:GetChildren()) do
        statsText = statsText .. stat.Name .. ": " .. tostring(stat.Value) .. "\n"
    end
    Tabs.Stats:AddParagraph({
        Title = "Текущие статы",
        Content = statsText
    })
else
    Tabs.Stats:AddParagraph({
        Title = "Статы",
        Content = "leaderstats не найден"
    })
end

-- // Log tab
Tabs.Log:AddParagraph({
    Title = "Лог событий",
    Content = "Все действия скрипта"
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "Driving Empire",
    Content = "Скрипт v2 загружен",
    SubContent = "by KiloUI",
    Duration = 5
})

log("Скрипт загружен успешно")
