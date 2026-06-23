-- // 1. ЗАГРУЗКА FLuent UI
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

-- // 2. ИНИЦИАЛИЗАЦИЯ ОКНА
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
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

local Options = Fluent.Options

-- // НАСТРОЙКИ ФАРМА
getgenv().GoldFarmActive = false
getgenv().TimeBetweenStages = 2.5

-- // СЕРВИСЫ
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

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

-- // Фоновый цикл
task.spawn(function()
    while true do
        task.wait(1)
        if getgenv().GoldFarmActive then
            local success, err = pcall(startGoldFarm)
            if not success then
                warn("[BABFT] Ошибка фарма: " .. tostring(err))
            end
        end
    end
end)

-- // UI ЭЛЕМЕНТЫ
Tabs.Farm:AddParagraph({
    Title = "BABFT Gold Farm",
    Content = "Автоматический сбор золота\nВерсия: 1.1 (Fluent UI)"
})

Tabs.Farm:AddSection("Управление")

local FarmToggle = Tabs.Farm:AddToggle("GoldFarm", {
    Title = "Активировать фарм золота",
    Default = false
})

FarmToggle:OnChanged(function(Value)
    getgenv().GoldFarmActive = Value
    if Value then
        Fluent:Notify({
            Title = "Фарм запущен!",
            Content = "Персонаж начал сбор золота",
            SubContent = "Не закрывайте игру",
            Duration = 4
        })
    else
        Fluent:Notify({
            Title = "Фарм остановлен",
            Content = "Автоматизация завершена",
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
    end
})

-- // Settings tab
SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("BABFT_GoldFarm")
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "BABFT Gold Farm",
    Content = "Скрипт загружен успешно",
    Duration = 5
})
