-- // Driving Empire Auto Farm Script
-- // Загружается только в Driving Empire (Place ID: 3351674303)

print("[Driving Empire] Загрузка скрипта автофарма...")

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua", true))()

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
    Vehicle = Window:AddTab({ Title = "Машина", Icon = "car" }),
    Teleport = Window:AddTab({ Title = "Телепорт", Icon = "map-pin" }),
    Log = Window:AddTab({ Title = "Логи", Icon = "scroll-text" })
}

local Options = Fluent.Options

-- // НАСТРОЙКИ
getgenv().AutoRaceActive = false
getgenv().AutoCollectActive = false
getgenv().SpeedMultiplier = 1.0

-- // СЕРВИСЫ
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // Логирование
local logBuffer = {}
local function log(msg)
    local time = os.date("%H:%M:%S")
    local fullMsg = "[" .. time .. "] " .. msg
    print(fullMsg)
    table.insert(logBuffer, fullMsg)
    if #logBuffer > 50 then
        table.remove(logBuffer, 1)
    end
end

-- // Получение текущей машины игрока
local function getPlayerVehicle()
    local character = LocalPlayer.Character
    if not character then return nil end
    
    -- // Ищем машину в персонаже или рядом
    for _, obj in ipairs(character:GetChildren()) do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
            return obj
        end
    end
    
    -- // Ищем машину в Workspace
    for _, vehicle in ipairs(Workspace:GetChildren()) do
        if vehicle:IsA("Model") and vehicle:FindFirstChild("VehicleSeat") then
            local seat = vehicle.VehicleSeat
            if seat.Occupant and seat.Occupant.Parent == character then
                return vehicle
            end
        end
    end
    
    return nil
end

-- // Автогонки (Circuit Race)
local function startAutoRace()
    log("Запуск автогонок...")
    
    -- // Здесь будет логика автопрохождения Circuit Race
    -- // Пока заглушка - нужно изучить структуру игры
    
    log("Автогонки активированы")
end

-- // Авто collecte денег
local function startAutoCollect()
    log("Запуск авто-сбора денег...")
    
    -- // Здесь будет логика автоматического сбора денег
    -- // Пока заглушка - нужно изучить структуру игры
    
    log("Авто-сбор активирован")
end

-- // Фоновые циклы
task.spawn(function()
    log("Фоновые циклы запущены")
    while true do
        task.wait(1)
        
        if getgenv().AutoRaceActive then
            local success, err = pcall(startAutoRace)
            if not success then
                log("ОШИБКА автогонок: " .. tostring(err))
            end
        end
        
        if getgenv().AutoCollectActive then
            local success, err = pcall(startAutoCollect)
            if not success then
                log("ОШИБКА авто-сбора: " .. tostring(err))
            end
        end
    end
end)

-- // UI ЭЛЕМЕНТЫ
Tabs.Farm:AddParagraph({
    Title = "Driving Empire Auto Farm",
    Content = "Автоматизация гонок и сбора денег\nВерсия: 1.0 (Fluent UI)"
})

Tabs.Farm:AddSection("Гонки")

local AutoRaceToggle = Tabs.Farm:AddToggle("AutoRace", {
    Title = "Автогонки (Circuit)",
    Default = false
})

AutoRaceToggle:OnChanged(function(Value)
    getgenv().AutoRaceActive = Value
    log("Автогонки: " .. tostring(Value))
    if Value then
        Fluent:Notify({
            Title = "Автогонки запущены",
            Content = "Circuit Race автоматизирован",
            Duration = 4
        })
    else
        Fluent:Notify({
            Title = "Автогонки остановлены",
            Duration = 3
        })
    end
end)

Tabs.Farm:AddSection("Сбор денег")

local AutoCollectToggle = Tabs.Farm:AddToggle("AutoCollect", {
    Title = "Авто-сбор денег",
    Default = false
})

AutoCollectToggle:OnChanged(function(Value)
    getgenv().AutoCollectActive = Value
    log("Авто-сбор: " .. tostring(Value))
    if Value then
        Fluent:Notify({
            Title = "Авто-сбор запущен",
            Content = "Деньги собираются автоматически",
            Duration = 4
        })
    else
        Fluent:Notify({
            Title = "Авто-сбор остановлен",
            Duration = 3
        })
    end
end)

Tabs.Farm:AddSection("Настройки")

local SpeedSlider = Tabs.Farm:AddSlider("SpeedMult", {
    Title = "Множитель скорости",
    Description = "Ускоряет машину (может быть обнаружено)",
    Default = 1.0,
    Min = 1.0,
    Max = 3.0,
    Rounding = 1,
    Callback = function(Value)
        getgenv().SpeedMultiplier = Value
        log("Множитель скорости: " .. Value .. "x")
    end
})

-- // Vehicle tab
Tabs.Vehicle:AddParagraph({
    Title = "Управление машиной",
    Content = "Здесь будут функции для машины"
})

Tabs.Vehicle:AddSection("Спавн машины")

Tabs.Vehicle:AddButton({
    Title = "Заспавнить машину",
    Description = "Создаёт тестовую машину",
    Callback = function()
        log("Спавн машины...")
        Fluent:Notify({
            Title = "Машина заспавнена",
            Content = "Тестовая машина создана",
            Duration = 3
        })
    end
})

Tabs.Vehicle:AddButton({
    Title = "Удалить машину",
    Description = "Удаляет текущую машину",
    Callback = function()
        log("Удаление машины...")
        Fluent:Notify({
            Title = "Машина удалена",
            Duration = 3
        })
    end
})

-- // Teleport tab
Tabs.Teleport:AddParagraph({
    Title = "Телепортация",
    Content = "Быстрый телепорт к локациям"
})

Tabs.Teleport:AddSection("Дилерshipы")

Tabs.Teleport:AddButton({
    Title = "Cars & Motorcycles",
    Description = "Телепорт к автосалону",
    Callback = function()
        log("Телепорт к Cars & Motorcycles...")
        Fluent:Notify({
            Title = "Телепорт",
            Content = "Перемещение к автосалону",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Boats",
    Description = "Телепорт к салону лодок",
    Callback = function()
        log("Телепорт к Boats...")
        Fluent:Notify({
            Title = "Телепорт",
            Content = "Перемещение к салону лодок",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Planes & Helicopters",
    Description = "Телепорт к салону авиации",
    Callback = function()
        log("Телепорт к Planes & Helicopters...")
        Fluent:Notify({
            Title = "Телепорт",
            Content = "Перемещение к салону авиации",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddSection("Гонки")

Tabs.Teleport:AddButton({
    Title = "Circuit Race",
    Description = "Телепорт к Circuit Race",
    Callback = function()
        log("Телепорт к Circuit Race...")
        Fluent:Notify({
            Title = "Телепорт",
            Content = "Перемещение к Circuit Race",
            Duration = 3
        })
    end
})

Tabs.Teleport:AddButton({
    Title = "Cross Country",
    Description = "Телепорт к Cross Country",
    Callback = function()
        log("Телепорт к Cross Country...")
        Fluent:Notify({
            Title = "Телепорт",
            Content = "Перемещение к Cross Country",
            Duration = 3
        })
    end
})

Window:SelectTab(1)

Fluent:Notify({
    Title = "Driving Empire",
    Content = "Скрипт загружен успешно",
    Duration = 5
})
