-- // BABFT Gold Farm с диагностикой
print("[BABFT] Загрузка Fluent UI...")

local Fluent
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/Fluent.lua"))()
end)

if not success or not Fluent then
    print("[BABFT] Ошибка загрузки Fluent: " .. tostring(err))
    -- Fallback на официальный URL
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end

print("[BABFT] Fluent загружен: " .. tostring(Fluent))

local Window = Fluent:CreateWindow({
    Title = "BABFT Gold Farm",
    SubTitle = "by KiloUI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Автофарм", Icon = "coins" }),
    Log = Window:AddTab({ Title = "Логи", Icon = "scroll-text" })
}

local Options = Fluent.Options

-- // НАСТРОЙКИ
getgenv().GoldFarmActive = false
getgenv().TimeBetweenStages = 2.5

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
    if logLabel then
        logLabel.Text = table.concat(logBuffer, "\n")
    end
end

-- // Функция создания платформы
local function createTempPlatform(position)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = position - Vector3.new(0, 3.5, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.CanCollide = true
    platform.Parent = Workspace
    return platform
end

-- // Основная логика фарма
local function startGoldFarm()
    log("Начало цикла фарма")
    
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    log("Персонаж найден: " .. tostring(hrp.Position))
    
    local normalStages = Workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages")
    
    for i = 1, 10 do
        if not getgenv().GoldFarmActive then 
            log("Фарм остановлен на этапе " .. i)
            return 
        end

        local stageName = "CaveStage" .. i
        log("Переход к этапу: " .. stageName)
        
        local stage = normalStages:FindFirstChild(stageName)

        if stage then
            local darknessPart = stage:FindFirstChild("DarknessPart")
            if darknessPart then
                log("Телепорт к DarknessPart " .. i)
                
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = darknessPart.CFrame

                local platform = createTempPlatform(hrp.Position)
                log("Платформа создана")

                local waited = 0
                while waited < getgenv().TimeBetweenStages do
                    if not getgenv().GoldFarmActive then
                        platform:Destroy()
                        log("Фарм остановлен во время ожидания")
                        return
                    end
                    task.wait(0.1)
                    waited = waited + 0.1
                end

                platform:Destroy()
                log("Этап " .. i .. " завершён")
            else
                log("ОШИБКА: DarknessPart не найден на этапе " .. i)
            end
        else
            log("ОШИБКА: " .. stageName .. " не найден")
        end
    end

    if getgenv().GoldFarmActive then
        log("Переход к TheEnd")
        local theEnd = normalStages:FindFirstChild("TheEnd")
        if theEnd then
            local chest = theEnd:FindFirstChild("GoldenChest")
            if chest then
                local trigger = chest:FindFirstChild("Trigger")
                if trigger then
                    log("Телепорт к Trigger")
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = trigger.CFrame + Vector3.new(0, 3, 0)

                    task.wait(1)
                    if firetouchinterest then
                        log("Использование firetouchinterest")
                        firetouchinterest(hrp, trigger, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, trigger, 1)
                    else
                        log("ОШИБКА: firetouchinterest недоступен!")
                    end
                end
            end
        end
    end

    log("Ожидание респавна...")
    local respawned = false
    local connection
    connection = LocalPlayer.CharacterAdded:Connect(function()
        respawned = true
        connection:Disconnect()
        log("Респавн произошёл")
    end)

    task.delay(10, function()
        if not respawned and humanoid then
            log("Принудительная смерть персонажа")
            humanoid.Health = 0
        end
    end)

    repeat
        if not getgenv().GoldFarmActive then 
            log("Фарм остановлен во время ожидания респавна")
            return 
        end
        task.wait()
    until respawned
    task.wait(2)
    log("Цикл фарма завершён")
end

-- // Фоновый цикл
task.spawn(function()
    log("Фоновый цикл запущен")
    while true do
        task.wait(1)
        if getgenv().GoldFarmActive then
            local success, err = pcall(startGoldFarm)
            if not success then
                log("ОШИБКА: " .. tostring(err))
            end
        end
    end
end)

-- // UI ЭЛЕМЕНТЫ
Tabs.Farm:AddParagraph({
    Title = "BABFT Gold Farm",
    Content = "Автоматический сбор золота\nВерсия: 1.2 (Fluent UI + Logs)"
})

Tabs.Farm:AddSection("Управление")

local FarmToggle = Tabs.Farm:AddToggle("GoldFarm", {
    Title = "Активировать фарм золота",
    Default = false
})

FarmToggle:OnChanged(function(Value)
    getgenv().GoldFarmActive = Value
    log("Toggle изменён: " .. tostring(Value))
    if Value then
        Fluent:Notify({
            Title = "Фарм запущен!",
            Content = "Смотри вкладку Логи",
            Duration = 4
        })
    else
        Fluent:Notify({
            Title = "Фарм остановлен",
            Duration = 3
        })
    end
end)

Tabs.Farm:AddSection("Настройки")

local SpeedSlider = Tabs.Farm:AddSlider("FarmSpeed", {
    Title = "Задержка на этапах",
    Description = "Меньше 2.5 сек не рекомендуется",
    Default = 2.5,
    Min = 1.5,
    Max = 5.0,
    Rounding = 1,
    Callback = function(Value)
        getgenv().TimeBetweenStages = Value
        log("Задержка изменена: " .. Value .. " сек")
    end
})

-- // Лог таб
Tabs.Log:AddParagraph({
    Title = "Лог событий",
    Content = "Здесь отображаются все действия скрипта"
})

local logLabel = Tabs.Log.Frame:FindFirstChildOfClass("TextLabel")
if logLabel then
    logLabel.TextXAlignment = Enum.TextXAlignment.Left
    logLabel.TextYAlignment = Enum.TextYAlignment.Top
    logLabel.Size = UDim2.new(1, -20, 1, -20)
    logLabel.Position = UDim2.new(0, 10, 0, 10)
    logLabel.TextWrapped = true
end

Window:SelectTab(1)

Fluent:Notify({
    Title = "BABFT Gold Farm",
    Content = "Скрипт загружен. Включи фарм и смотри логи.",
    Duration = 5
})
