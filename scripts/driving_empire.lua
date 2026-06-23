-- // Driving Empire Auto Farm v5.2
-- // Реальная логика на основе RemoteEvents

print("[DE v5.2] Загрузка скрипта...")

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/WindUI.lua?v="..os.time()))()

local Window = WindUI:CreateWindow({
    Title = "Driving Empire v5.2",
    Folder = "KiloUI",
    Icon = "car",
    NewElements = true,
    OpenButton = {
        Enabled = false,
    }
})

local FarmTab = Window:Tab({ Title = "Автофарм", Icon = "coins" })
local RaceTab = Window:Tab({ Title = "Гонки", Icon = "flag" })
local TeleportTab = Window:Tab({ Title = "Телепорт", Icon = "map-pin" })
local VehicleTab = Window:Tab({ Title = "Машина", Icon = "car" })
local QuestTab = Window:Tab({ Title = "Квесты", Icon = "scroll" })
local StatsTab = Window:Tab({ Title = "Статы", Icon = "bar-chart-3" })
local LogTab = Window:Tab({ Title = "Логи", Icon = "scroll-text" })

-- // СЕРВИСЫ
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

-- // Логирование
local logBuffer = {}
local function log(msg)
    local t = os.date("%H:%M:%S")
    local full = "[" .. t .. "] " .. msg
    print("[DE] " .. msg)
    table.insert(logBuffer, full)
    if #logBuffer > 100 then table.remove(logBuffer, 1) end
end

-- // ============ RACE FUNCTIONS ============

local RaceRemotes = {
    JoinQueue = Remotes:FindFirstChild("JoinRacingQueue"),
    LeaveQueue = Remotes:FindFirstChild("LeaveRacingQueue"),
    QueueUpdate = Remotes:FindFirstChild("UpdatePlayerQueueState"),
    RaceJoined = Remotes:FindFirstChild("RaceJoined"),
    RaceLeft = Remotes:FindFirstChild("RaceLeft"),
    RaceState = Remotes:FindFirstChild("RaceStateUpdate"),
    RacePlacement = Remotes:FindFirstChild("RacePlacementUpdate"),
    RaceFinished = Remotes:FindFirstChild("RaceFinished"),
    RaceDNF = Remotes:FindFirstChild("RaceDNF"),
    RaceCheckpoint = Remotes:FindFirstChild("RaceCheckpoint"),
    RaceFinishLine = Remotes:FindFirstChild("RaceFinishLine"),
    RaceQuickRestart = Remotes:FindFirstChild("RaceQuickRestart"),
    RaceStartTimeTrial = Remotes:FindFirstChild("RaceStartTimeTrial"),
    GetLeaderboard = Remotes:FindFirstChild("GetRaceLeaderboardData"),
    GetUserPlacement = Remotes:FindFirstChild("GetRaceLeaderboardUserPlacement"),
    ClaimRewards = Remotes:FindFirstChild("RaceLeaderboardClaimRewards"),
    RaceQueue = Remotes:FindFirstChild("RaceQueue"),
    MultiplierScore = Remotes:FindFirstChild("MultiplierRaceScore")
}

local currentRaceState = "none"
local raceCount = 0
local totalEarnings = 0

-- // Встать в очередь на гонку
local function joinRaceQueue(raceType)
    if RaceRemotes.JoinQueue and RaceRemotes.JoinQueue:IsA("RemoteFunction") then
        local ok, result = pcall(function()
            return RaceRemotes.JoinQueue:InvokeServer(raceType or "Circuit")
        end)
        if ok then
            log("Встал в очередь на гонку: " .. tostring(raceType))
            return result
        else
            log("Ошибка входа в очередь: " .. tostring(result))
        end
    elseif RaceRemotes.RaceQueue and RaceRemotes.RaceQueue:IsA("RemoteEvent") then
        RaceRemotes.RaceQueue:FireServer(raceType or "Circuit")
        log("Отправлен запрос на гонку: " .. tostring(raceType))
        return true
    end
    return false
end

-- // Выйти из очереди
local function leaveRaceQueue()
    if RaceRemotes.LeaveQueue then
        RaceRemotes.LeaveQueue:FireServer()
        log("Вышел из очереди гонок")
    end
end

-- // Быстрый рестарт гонки
local function quickRestartRace()
    if RaceRemotes.RaceQuickRestart then
        RaceRemotes.RaceQuickRestart:FireServer()
        log("Быстрый рестарт гонки")
    end
end

-- // Забрать награды
local function claimRaceRewards()
    if RaceRemotes.ClaimRewards then
        RaceRemotes.ClaimRewards:FireServer()
        log("Награды за гонку забраны")
    end
end

-- // Получить данные лидерборда
local function getRaceLeaderboard()
    if RaceRemotes.GetLeaderboard and RaceRemotes.GetLeaderboard:IsA("RemoteFunction") then
        local ok, data = pcall(function()
            return RaceRemotes.GetLeaderboard:InvokeServer()
        end)
        if ok then
            log("Данные лидерборда получены")
            return data
        end
    end
    return nil
end

-- // Авто-гонки
local autoRaceActive = false
local autoRaceType = "Circuit"

local function startAutoRace()
    autoRaceActive = true
    log("Авто-гонки запущены (тип: " .. autoRaceType .. ")")
    
    task.spawn(function()
        while autoRaceActive do
            -- Встаём в очередь
            joinRaceQueue(autoRaceType)
            
            -- Ждём начала гонки
            local waited = 0
            while autoRaceActive and currentRaceState == "none" and waited < 30 do
                task.wait(1)
                waited = waited + 1
            end
            
            if currentRaceState ~= "none" then
                log("Гонка началась!")
                
                -- Ждём окончания гонки
                while autoRaceActive and currentRaceState ~= "finished" and currentRaceState ~= "dnf" do
                    task.wait(1)
                end
                
                if currentRaceState == "finished" then
                    raceCount = raceCount + 1
                    log("Гонка #" .. raceCount .. " завершена!")
                    claimRaceRewards()
                elseif currentRaceState == "dnf" then
                    log("Гонка не завершена (DNF)")
                end
                
                -- Быстрый рестарт
                task.wait(2)
                quickRestartRace()
                currentRaceState = "none"
            else
                log("Таймаут ожидания гонки, выход из очереди")
                leaveRaceQueue()
            end
            
            task.wait(3)
        end
    end)
end

local function stopAutoRace()
    autoRaceActive = false
    leaveRaceQueue()
    log("Авто-гонки остановлены")
end

-- // Слушаем события гонок
if RaceRemotes.RaceState then
    RaceRemotes.RaceState:Connect(function(state)
        currentRaceState = tostring(state)
        log("Состояние гонки: " .. currentRaceState)
    end)
end

if RaceRemotes.RaceFinished then
    RaceRemotes.RaceFinished:Connect(function(data)
        log("Гонка финиширована!")
        if data then
            log("Данные финиша: " .. tostring(data))
        end
    end)
end

if RaceRemotes.RaceDNF then
    RaceRemotes.RaceDNF:Connect(function()
        currentRaceState = "dnf"
        log("Гонка не завершена (DNF)")
    end)
end

if RaceRemotes.RacePlacement then
    RaceRemotes.RacePlacement:Connect(function(position)
        log("Позиция в гонке: " .. tostring(position))
    end)
end

-- // ============ MONEY FUNCTIONS ============

local CollectCash = Remotes:FindFirstChild("CollectCashDrop")

local function collectNearbyCash()
    if CollectCash then
        -- Ищем деньги рядом с игроком
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:lower():find("cash") or obj.Name:lower():find("money") or obj.Name:lower():find("drop") then
                if obj:IsA("BasePart") then
                    local dist = (obj.Position - hrp.Position).Magnitude
                    if dist < 50 then
                        CollectCash:FireServer(obj)
                        log("Собрал деньги: " .. obj.Name)
                    end
                end
            end
        end
    end
end

-- // ============ DELIVERY FUNCTIONS ============

local DeliveryRemotes = {
    Pickup = Remotes:FindFirstChild("AttemptDeliveryPickup"),
    Complete = Remotes:FindFirstChild("AttemptDeliveryComplete"),
    StateChanged = Remotes:FindFirstChild("DeliveryStateChanged"),
    Completed = Remotes:FindFirstChild("DeliveryCompleted"),
    LocationInteracted = Remotes:FindFirstChild("DeliveryLocationInteracted"),
    LocationLeft = Remotes:FindFirstChild("DeliveryLocationLeft"),
    PackageStolen = Remotes:FindFirstChild("DeliveryPackageStolen")
}

local autoDeliveryActive = false

local function startAutoDelivery()
    autoDeliveryActive = true
    log("Авто-доставки запущены")
    
    task.spawn(function()
        while autoDeliveryActive do
            if DeliveryRemotes.Pickup and DeliveryRemotes.Pickup:IsA("RemoteFunction") then
                local ok, result = pcall(function()
                    return DeliveryRemotes.Pickup:InvokeServer()
                end)
                if ok then
                    log("Доставка взята")
                    task.wait(5) -- Ждём доставку
                    
                    if DeliveryRemotes.Complete and DeliveryRemotes.Complete:IsA("RemoteFunction") then
                        local ok2, result2 = pcall(function()
                            return DeliveryRemotes.Complete:InvokeServer()
                        end)
                        if ok2 then
                            log("Доставка завершена")
                        end
                    end
                else
                    log("Ошибка доставки: " .. tostring(result))
                end
            end
            task.wait(10)
        end
    end)
end

local function stopAutoDelivery()
    autoDeliveryActive = false
    log("Авто-доставки остановлены")
end

-- // ============ QUEST FUNCTIONS ============

local QuestRemotes = {
    Update = Remotes:FindFirstChild("QuestsUpdate"),
    Claimed = Remotes:FindFirstChild("QuestClaimed"),
    ClaimReward = Remotes:FindFirstChild("ClaimQuestReward"),
    SetTracked = Remotes:FindFirstChild("SetTrackedQuest"),
    PinQuest = Remotes:FindFirstChild("PinQuest")
}

local function claimAllQuestRewards()
    if QuestRemotes.ClaimReward then
        QuestRemotes.ClaimReward:FireServer()
        log("Награды за квесты забраны")
    end
end

-- // ============ TELEPORT FUNCTIONS ============

local TeleportRemote = Remotes:FindFirstChild("Teleport")
local GetDestCFrame = Remotes:FindFirstChild("GetDestinationCFrame")

local function teleportToDestination(destName)
    if TeleportRemote then
        TeleportRemote:FireServer(destName)
        log("Телепорт к: " .. tostring(destName))
    end
end

local function teleportToCoords(x, y, z)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    hrp.CFrame = CFrame.new(x, y, z)
    log("Телепорт к координатам: " .. x .. ", " .. y .. ", " .. z)
end

-- // ============ VEHICLE FUNCTIONS ============

local VehicleRemotes = {
    GetChassis = Remotes:FindFirstChild("GetChassis"),
    ChangeCarStuff = Remotes:FindFirstChild("ChangeCarStuff"),
    VehicleEvent = Remotes:FindFirstChild("VehicleEvent"),
    Chassis = Remotes:FindFirstChild("Chassis"),
    StarterCar = Remotes:FindFirstChild("StarterCar"),
    SellCar = Remotes:FindFirstChild("SellCar"),
    GetStats = Remotes:FindFirstChild("GetVehicleStats")
}

local function spawnStarterCar()
    if VehicleRemotes.StarterCar and VehicleRemotes.StarterCar:IsA("RemoteFunction") then
        local ok, result = pcall(function()
            return VehicleRemotes.StarterCar:InvokeServer()
        end)
        if ok then
            log("Стартовая машина заспавнена")
            return result
        else
            log("Ошибка спавна машины: " .. tostring(result))
        end
    end
end

local function getVehicleStats()
    if VehicleRemotes.GetStats and VehicleRemotes.GetStats:IsA("RemoteFunction") then
        local ok, data = pcall(function()
            return VehicleRemotes.GetStats:InvokeServer()
        end)
        if ok then
            log("Статы машины получены")
            return data
        end
    end
    return nil
end

-- // ============ PLAYER DATA ============

local GetPlayerData = ReplicatedStorage:FindFirstChild("VoldexAdmin")
    and ReplicatedStorage.VoldexAdmin:FindFirstChild("RemoteFunctions")
    and ReplicatedStorage.VoldexAdmin.RemoteFunctions:FindFirstChild("GetPlayerData")

local function getPlayerData()
    if GetPlayerData and GetPlayerData:IsA("RemoteFunction") then
        local ok, data = pcall(function()
            return GetPlayerData:InvokeServer()
        end)
        if ok then
            log("Данные игрока получены")
            return data
        else
            log("Ошибка получения данных: " .. tostring(data))
        end
    end
    return nil
end

local GetStatsRemote = Remotes:FindFirstChild("GetStats")

local function getPlayerStats()
    if GetStatsRemote and GetStatsRemote:IsA("RemoteFunction") then
        local ok, data = pcall(function()
            return GetStatsRemote:InvokeServer()
        end)
        if ok then
            log("Статы получены")
            return data
        end
    end
    return nil
end

-- // ============ UI ELEMENTS ============

task.spawn(function()
    local uiSuccess, uiErr = pcall(function()
        -- // Farm Tab
        FarmTab:Paragraph({
            Title = "Driving Empire Farm v5.2",
        Desc = "Автоматизация через RemoteEvents\nby KiloUI"
    })

    FarmTab:Section({ Title = "Авто-гонки" })

    FarmTab:Dropdown({
        Title = "Тип гонки",
        Values = {"Circuit", "CrossCountry", "Highway", "Drag", "Drawbridge"},
        Value = "Circuit",
        Callback = function(value)
            autoRaceType = value
            log("Тип гонки изменён: " .. value)
        end
    })

    FarmTab:Toggle({
        Title = "Авто-гонки",
        Value = false,
        Callback = function(v)
            if v then
                startAutoRace()
            else
                stopAutoRace()
            end
        end
    })

    FarmTab:Button({
        Title = "Быстрый рестарт",
        Desc = "Перезапустить текущую гонку",
        Callback = function()
            quickRestartRace()
        end
    })

    FarmTab:Button({
        Title = "Забрать награды",
        Desc = "Получить награды за гонку",
        Callback = function()
            claimRaceRewards()
        end
    })

    FarmTab:Section({ Title = "Авто-доставки" })

    FarmTab:Toggle({
        Title = "Авто-доставки",
        Value = false,
        Callback = function(v)
            if v then
                startAutoDelivery()
            else
                stopAutoDelivery()
            end
        end
    })

    FarmTab:Section({ Title = "Сбор денег" })

    FarmTab:Button({
        Title = "Собрать деньги рядом",
        Desc = "Собрать все деньги в радиусе 50м",
        Callback = function()
            collectNearbyCash()
        end
    })

    -- // Race Tab
    RaceTab:Paragraph({
        Title = "Управление гонками",
        Desc = "Ручное управление гонками"
    })

    RaceTab:Section({ Title = "Встать в очередь" })

    local raceTypes = {"Circuit", "CrossCountry", "Highway", "Drag", "Drawbridge"}
    for _, rt in ipairs(raceTypes) do
        RaceTab:Button({
            Title = rt .. " Race",
            Desc = "Встать в очередь на " .. rt,
            Callback = function()
                joinRaceQueue(rt)
            end
        })
    end

    RaceTab:Section({ Title = "Управление" })

    RaceTab:Button({
        Title = "Выйти из очереди",
        Callback = function()
            leaveRaceQueue()
        end
    })

    RaceTab:Button({
        Title = "Быстрый рестарт",
        Callback = function()
            quickRestartRace()
        end
    })

    RaceTab:Button({
        Title = "Забрать награды",
        Callback = function()
            claimRaceRewards()
        end
    })

    RaceTab:Section({ Title = "Лидерборд" })

    RaceTab:Button({
        Title = "Обновить лидерборд",
        Callback = function()
            local data = getRaceLeaderboard()
            if data then
                log("Лидерборд: " .. tostring(data))
            end
        end
    })

    -- // Teleport Tab
    TeleportTab:Paragraph({
        Title = "Телепортация",
        Desc = "Быстрое перемещение по карте"
    })

    TeleportTab:Section({ Title = "Дилершипы" })

    local dealerships = {
        {"Cars & Motorcycles", "CarDealership"},
        {"Boats", "BoatDealership"},
        {"Planes & Helicopters", "PlaneDealership"}
    }

    for _, d in ipairs(dealerships) do
        TeleportTab:Button({
            Title = d[1],
            Callback = function()
                teleportToDestination(d[2])
            end
        })
    end

    TeleportTab:Section({ Title = "Гонки" })

    local raceTeleports = {
        {"Circuit Race", "CircuitRace"},
        {"Cross Country", "CrossCountry"},
        {"Highway Race", "HighwayRace"},
        {"Drag Race", "DragRace"}
    }

    for _, r in ipairs(raceTeleports) do
        TeleportTab:Button({
            Title = r[1],
            Callback = function()
                teleportToDestination(r[2])
            end
        })
    end

    TeleportTab:Section({ Title = "Ручной телепорт" })

    local teleX, teleY, teleZ = 0, 50, 0

    TeleportTab:Input({
        Title = "X координата",
        Value = "0",
        Placeholder = "X",
        Callback = function(value)
            teleX = tonumber(value) or 0
        end
    })

    TeleportTab:Input({
        Title = "Y координата",
        Value = "50",
        Placeholder = "Y",
        Callback = function(value)
            teleY = tonumber(value) or 50
        end
    })

    TeleportTab:Input({
        Title = "Z координата",
        Value = "0",
        Placeholder = "Z",
        Callback = function(value)
            teleZ = tonumber(value) or 0
        end
    })

    TeleportTab:Button({
        Title = "Телепортироваться",
        Desc = "К координатам X, Y, Z",
        Callback = function()
            teleportToCoords(teleX, teleY, teleZ)
        end
    })

    -- // Vehicle Tab
    VehicleTab:Paragraph({
        Title = "Управление машиной",
        Desc = "Функции для транспорта"
    })

    VehicleTab:Section({ Title = "Спавн" })

    VehicleTab:Button({
        Title = "Заспавнить стартовую машину",
        Callback = function()
            spawnStarterCar()
        end
    })

    VehicleTab:Section({ Title = "Информация" })

    VehicleTab:Button({
        Title = "Получить статы машины",
        Callback = function()
            local stats = getVehicleStats()
            if stats then
                log("Статы машины: " .. tostring(stats))
            end
        end
    })

    VehicleTab:Button({
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

    -- // Quest Tab
    QuestTab:Paragraph({
        Title = "Квесты",
        Desc = "Управление квестами"
    })

    QuestTab:Section({ Title = "Награды" })

    QuestTab:Button({
        Title = "Забрать все награды",
        Desc = "Получить награды за завершённые квесты",
        Callback = function()
            claimAllQuestRewards()
        end
    })

    -- // Stats Tab
    StatsTab:Paragraph({
        Title = "Статистика",
        Desc = "Данные аккаунта и прогресс"
    })

    StatsTab:Section({ Title = "Данные игрока" })

    StatsTab:Button({
        Title = "Обновить данные",
        Desc = "Загрузить данные с сервера",
        Callback = function()
            local data = getPlayerData()
            if data then
                log("Данные получены: " .. tostring(data))
                if type(data) == "table" then
                    for k, v in pairs(data) do
                        log("  " .. tostring(k) .. ": " .. tostring(v))
                    end
                end
            end
        end
    })

    StatsTab:Button({
        Title = "Обновить статы",
        Callback = function()
            local stats = getPlayerStats()
            if stats then
                log("Статы: " .. tostring(stats))
            end
        end
    })

    StatsTab:Section({ Title = "leaderstats" })

    local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        local statsText = ""
        for _, stat in ipairs(leaderstats:GetChildren()) do
            statsText = statsText .. stat.Name .. ": " .. tostring(stat.Value) .. "\n"
        end
        StatsTab:Paragraph({
            Title = "Текущие статы",
            Desc = statsText
        })
    else
        StatsTab:Paragraph({
            Title = "Статы",
            Desc = "leaderstats не найден"
        })
    end

    StatsTab:Section({ Title = "Статистика фарма" })

    StatsTab:Paragraph({
        Title = "Прогресс",
        Desc = "Гонок завершено: " .. raceCount .. "\nВсего заработано: " .. totalEarnings
    })

    -- // Log Tab
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
    for _, t in ipairs({FarmTab, RaceTab, TeleportTab, VehicleTab, QuestTab, StatsTab, LogTab}) do
        table.insert(diag, t.Title .. ": " .. countTabChildren(t))
    end
    WindUI:Notify({
        Title = "DE v5.2 Debug",
        Content = table.concat(diag, " | "),
        Duration = 8
    })
end)

if not uiSuccess then
    warn("[DE v5.2] UI ERROR: " .. tostring(uiErr))
    log("UI ERROR: " .. tostring(uiErr))
    WindUI:Notify({
        Title = "UI Error",
        Content = tostring(uiErr),
        Duration = 10
    })
end
end)

-- // ============ STARTUP ============

WindUI:Notify({
    Title = "Driving Empire v5.2",
    Content = "Скрипт загружен успешно",
    Duration = 5
})

log("Скрипт v5.2 загружен")
log("RemoteEvents найдены: " .. #Remotes:GetChildren())
