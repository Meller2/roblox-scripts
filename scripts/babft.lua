-- // BABFT Gold Farm Script v5.2
-- // Загружается только в Build a Boat for Treasure (Place ID: 189707)

print("[BABFT v5.2] Загрузка скрипта фарма золота...")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/WindUI.lua?v="..os.time()))()

local Window = WindUI:CreateWindow({
    Title = "BABFT Gold Farm v5.2",
    Folder = "KiloUI",
    Icon = "coins",
    NewElements = true,
    OpenButton = {
        Enabled = false,
    }
})

local FarmTab = Window:Tab({ Title = "Автофарм", Icon = "coins" })
local LogTab = Window:Tab({ Title = "Логи", Icon = "scroll-text" })

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
task.spawn(function()
    local uiSuccess, uiErr = pcall(function()
        FarmTab:Paragraph({
            Title = "BABFT Gold Farm v5.2",
            Desc = "Автоматический сбор золота\nВерсия: v5.2 (WindUI)"
        })

    FarmTab:Section({ Title = "Управление" })

    FarmTab:Toggle({
        Title = "Активировать фарм золота",
        Value = false,
        Callback = function(Value)
            getgenv().GoldFarmActive = Value
            log("Toggle изменён: " .. tostring(Value))
            if Value then
                WindUI:Notify({
                    Title = "Фарм запущен!",
                    Content = "Персонаж начал сбор золота",
                    Duration = 4
                })
            else
                WindUI:Notify({
                    Title = "Фарм остановлен",
                    Duration = 3
                })
            end
        end
    })

    FarmTab:Section({ Title = "Настройки" })

    FarmTab:Slider({
        Title = "Задержка на этапах",
        Desc = "Меньше 2.5 сек не рекомендуется",
        Value = {
            Min = 1.5,
            Max = 5.0,
            Default = 2.5,
        },
        Step = 0.1,
        Callback = function(Value)
            getgenv().TimeBetweenStages = Value
            log("Задержка изменена: " .. Value .. " сек")
        end
    })

    LogTab:Paragraph({
        Title = "Лог событий",
        Desc = "Все действия скрипта"
    })

    -- // Диагностика: сколько детей в каждой вкладке
    local function countTabChildren(tab)
        local cf = tab and tab.UIElements and tab.UIElements.ContainerFrame
        return cf and #cf:GetChildren() or 0
    end
    local diag = {}
    for _, t in ipairs({FarmTab, LogTab}) do
        table.insert(diag, t.Title .. ": " .. countTabChildren(t))
    end
    WindUI:Notify({
        Title = "BABFT v5.2 Debug",
        Content = table.concat(diag, " | "),
        Duration = 8
    })
end)

if not uiSuccess then
    warn("[BABFT v5.2] UI ERROR: " .. tostring(uiErr))
    log("UI ERROR: " .. tostring(uiErr))
    WindUI:Notify({
        Title = "UI Error",
        Content = tostring(uiErr),
        Duration = 10
    })
end
end)

WindUI:Notify({
    Title = "BABFT Gold Farm v5.2",
    Content = "Скрипт загружен успешно",
    Duration = 5
})
