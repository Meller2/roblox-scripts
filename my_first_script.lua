-- // 1. ЗАГРУЗКА UI БИБЛИОТЕКИ KiloUI
local KiloUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/KiloUI.lua"))()

-- // 2. ИНИЦИАЛИЗАЦИЯ ОКНА
local Window = KiloUI:CreateWindow({
    Name = "BABFT Gold Farm Hub",
    LoadingTitle = "Запуск интерфейса...",
    LoadingSubtitle = "by KiloUI",
    Theme = "Default",
})

-- // НАСТРОЙКИ ФАРМА (Глобальные переменные)
getgenv().GoldFarmActive = false
getgenv().TimeBetweenStages = 2.5

-- // СЕРВИСЫ ROBLOX
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- // Функция создания невидимой платформы под ногами
local function createTempPlatform(position)
    local platform = Instance.new("Part")
    platform.Size = Vector3.new(10, 1, 10)
    platform.Position = position - Vector3.new(0, 3.5, 0)
    platform.Anchored = true
    platform.Transparency = 1
    platform.Parent = Workspace
    return platform
end

-- // Основная логика одного круга фарма
local function startGoldFarm()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    local normalStages = Workspace:WaitForChild("BoatStages"):WaitForChild("NormalStages")

    for i = 1, 10 do
        if not getgenv().GoldFarmActive then return end

        local stageName = "CaveStage" .. i
        local stage = normalStages:FindFirstChild(stageName)

        if stage then
            local darknessPart = stage:FindFirstChild("DarknessPart")
            if darknessPart then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = darknessPart.CFrame

                local platform = createTempPlatform(hrp.Position)

                local waited = 0
                while waited < getgenv().TimeBetweenStages do
                    if not getgenv().GoldFarmActive then
                        platform:Destroy()
                        return
                    end
                    task.wait(0.1)
                    waited = waited + 0.1
                end

                platform:Destroy()
            end
        end
    end

    if getgenv().GoldFarmActive then
        local theEnd = normalStages:FindFirstChild("TheEnd")
        if theEnd then
            local chest = theEnd:FindFirstChild("GoldenChest")
            if chest then
                local trigger = chest:FindFirstChild("Trigger")
                if trigger then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.CFrame = trigger.CFrame + Vector3.new(0, 3, 0)

                    task.wait(1)
                    if firetouchinterest then
                        firetouchinterest(hrp, trigger, 0)
                        task.wait(0.1)
                        firetouchinterest(hrp, trigger, 1)
                    end
                end
            end
        end
    end

    local respawned = false
    local connection
    connection = LocalPlayer.CharacterAdded:Connect(function()
        respawned = true
        connection:Disconnect()
    end)

    task.delay(10, function()
        if not respawned and humanoid then
            humanoid.Health = 0
        end
    end)

    repeat
        if not getgenv().GoldFarmActive then return end
        task.wait()
    until respawned
    task.wait(2)
end

-- // Фоновый цикл фарма
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().GoldFarmActive then
            local success, err = pcall(startGoldFarm)
            if not success then
                warn("Ошибка фарма: " .. tostring(err))
            end
        end
    end
end)

-- // 3. СОЗДАНИЕ ВКЛАДОК
local FarmTab = Window:CreateTab("Автофарм", 4483362458)

FarmTab:CreateSection("Управление")

local FarmToggle = FarmTab:CreateToggle({
    Name = "Активировать фарм золота",
    CurrentValue = false,
    Flag = "GoldFarmToggle",
    Callback = function(Value)
        getgenv().GoldFarmActive = Value

        if Value then
            Window:Notify({
                Title = "Фарм запущен!",
                Content = "Персонаж начал сбор. Не закрывайте игру.",
                Duration = 4,
                Image = 4483362458,
            })
        else
            Window:Notify({
                Title = "Фарм остановлен",
                Content = "Автоматизация завершена. Вы можете играть сами.",
                Duration = 4,
                Image = 4483362458,
            })
        end
    end,
})

FarmTab:CreateSection("Настройки")

local SpeedSlider = FarmTab:CreateSlider({
    Name = "Задержка на этапах",
    Info = "Меньше 2.5 сек ставить не рекомендуется",
    Min = 1.5,
    Max = 5.0,
    Default = 2.5,
    Increment = 0.5,
    ValueName = "сек.",
    Flag = "SpeedSlider",
    Callback = function(Value)
        getgenv().TimeBetweenStages = Value
    end,
})
