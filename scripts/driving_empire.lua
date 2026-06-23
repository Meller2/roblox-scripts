-- // Driving Empire Auto Farm v4
-- // Реальная логика на основе RemoteEvents

print("[DE v4] Загрузка скрипта...")

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/Fluent.lua?v="..os.time()))()

-- Фикс __namecall для корректной работы методов вкладок в Solara
if Fluent and Fluent.Elements and Fluent.Elements.__namecall then
    local Elements = Fluent.Elements
    Elements.__namecall = function(a, b, ...)
        if type(a) == "table" and type(b) == "string" then
            return Elements[b](a, ...)
        elseif type(b) == "table" and type(a) == "string" then
            return Elements[a](b, ...)
        end
        return Elements[b](a, ...)
    end
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Window = Fluent:CreateWindow({
    Title = "Driving Empire",
    SubTitle = "by KiloUI v4",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm = Window:AddTab({ Title = "Автофарм", Icon = "coins" }),
    Race = Window:AddTab({ Title = "Гонки", Icon = "flag" }),
    Teleport = Window:AddTab({ Title = "Телепорт", Icon = "map-pin" }),
    Vehicle = Window:AddTab({ Title = "Машина", Icon = "car" }),
    Quest = Window:AddTab({ Title = "Квесты", Icon = "scroll" }),
    Stats = Window:AddTab({ Title = "Статы", Icon = "bar-chart-3" }),
    Log = Window:AddTab({ Title = "Логи", Icon = "scroll-text" })
}

-- Прямые методы для обхода __namecall в Solara
for _, tab in pairs(Tabs) do
    if type(tab) == "table" then
        for name, method in pairs(Fluent.Elements) do
            if type(method) == "function" and name:sub(1, 3) == "Add" then
                tab[name] = function(...)
                    return method(tab, ...)
                end
            end
        end
    end
end

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

local uiSuccess, uiErr = pcall(function()

-- // Farm Tab
Tabs.Farm:AddParagraph({
    Title = "Driving Empire Farm v4",
    Content = "Автоматизация через RemoteEvents\nby KiloUI"
})

Tabs.Farm:AddSection("Авто-гонки")

local RaceTypeDropdown = Tabs.Farm:AddDropdown("RaceType", {
    Title = "Тип гонки",
    Values = {"Circuit", "CrossCountry", "Highway", "Drag", "Drawbridge"},
    Multi = false,
    Default = 1,
})

RaceTypeDropdown:SetValue("Circuit")

RaceTypeDropdown:OnChanged(function(value)
    autoRaceType = value
    log("Тип гонки изменён: " .. value)
end)

local AutoRaceToggle = Tabs.Farm:AddToggle("AutoRace", {
    Title = "Авто-гонки",
    Default = false
})

AutoRaceToggle:OnChanged(function(v)
    if v then
        startAutoRace()
    else
        stopAutoRace()
    end
end)

Tabs.Farm:AddButton({
    Title = "Быстрый рестарт",
    Description = "Перезапустить текущую гонку",
    Callback = function()
        quickRestartRace()
    end
})

Tabs.Farm:AddButton({
    Title = "Забрать награды",
    Description = "Получить награды за гонку",
    Callback = function()
        claimRaceRewards()
    end
})

Tabs.Farm:AddSection("Авто-доставки")

local AutoDeliveryToggle = Tabs.Farm:AddToggle("AutoDelivery", {
    Title = "Авто-доставки",
    Default = false
})

AutoDeliveryToggle:OnChanged(function(v)
    if v then
        startAutoDelivery()
    else
        stopAutoDelivery()
    end
end)

Tabs.Farm:AddSection("Сбор денег")

Tabs.Farm:AddButton({
    Title = "Собрать деньги рядом",
    Description = "Собрать все деньги в радиусе 50м",
    Callback = function()
        collectNearbyCash()
    end
})

-- // Race Tab
Tabs.Race:AddParagraph({
    Title = "Управление гонками",
    Content = "Ручное управление гонками"
})

Tabs.Race:AddSection("Встать в очередь")

local raceTypes = {"Circuit", "CrossCountry", "Highway", "Drag", "Drawbridge"}
for _, rt in ipairs(raceTypes) do
    Tabs.Race:AddButton({
        Title = rt .. " Race",
        Description = "Встать в очередь на " .. rt,
        Callback = function()
            joinRaceQueue(rt)
        end
    })
end

Tabs.Race:AddSection("Управление")

Tabs.Race:AddButton({
    Title = "Выйти из очереди",
    Callback = function()
        leaveRaceQueue()
    end
})

Tabs.Race:AddButton({
    Title = "Быстрый рестарт",
    Callback = function()
        quickRestartRace()
    end
})

Tabs.Race:AddButton({
    Title = "Забрать награды",
    Callback = function()
        claimRaceRewards()
    end
})

Tabs.Race:AddSection("Лидерборд")

Tabs.Race:AddButton({
    Title = "Обновить лидерборд",
    Callback = function()
        local data = getRaceLeaderboard()
        if data then
            log("Лидерборд: " .. tostring(data))
        end
    end
})

-- // Teleport Tab
Tabs.Teleport:AddParagraph({
    Title = "Телепортация",
    Content = "Быстрое перемещение по карте"
})

Tabs.Teleport:AddSection("Дилершипы")

local dealerships = {
    {"Cars & Motorcycles", "CarDealership"},
    {"Boats", "BoatDealership"},
    {"Planes & Helicopters", "PlaneDealership"}
}

for _, d in ipairs(dealerships) do
    Tabs.Teleport:AddButton({
        Title = d[1],
        Callback = function()
            teleportToDestination(d[2])
        end
    })
end

Tabs.Teleport:AddSection("Гонки")

local raceTeleports = {
    {"Circuit Race", "CircuitRace"},
    {"Cross Country", "CrossCountry"},
    {"Highway Race", "HighwayRace"},
    {"Drag Race", "DragRace"}
}

for _, r in ipairs(raceTeleports) do
    Tabs.Teleport:AddButton({
        Title = r[1],
        Callback = function()
            teleportToDestination(r[2])
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
        teleportToCoords(x, y, z)
    end
})

-- // Vehicle Tab
Tabs.Vehicle:AddParagraph({
    Title = "Управление машиной",
    Content = "Функции для транспорта"
})

Tabs.Vehicle:AddSection("Спавн")

Tabs.Vehicle:AddButton({
    Title = "Заспавнить стартовую машину",
    Callback = function()
        spawnStarterCar()
    end
})

Tabs.Vehicle:AddSection("Информация")

Tabs.Vehicle:AddButton({
    Title = "Получить статы машины",
    Callback = function()
        local stats = getVehicleStats()
        if stats then
            log("Статы машины: " .. tostring(stats))
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

-- // Quest Tab
Tabs.Quest:AddParagraph({
    Title = "Квесты",
    Content = "Управление квестами"
})

Tabs.Quest:AddSection("Награды")

Tabs.Quest:AddButton({
    Title = "Забрать все награды",
    Description = "Получить награды за завершённые квесты",
    Callback = function()
        claimAllQuestRewards()
    end
})

-- // Stats Tab
Tabs.Stats:AddParagraph({
    Title = "Статистика",
    Content = "Данные аккаунта и прогресс"
})

Tabs.Stats:AddSection("Данные игрока")

Tabs.Stats:AddButton({
    Title = "Обновить данные",
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
        end
    end
})

Tabs.Stats:AddButton({
    Title = "Обновить статы",
    Callback = function()
        local stats = getPlayerStats()
        if stats then
            log("Статы: " .. tostring(stats))
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

Tabs.Stats:AddSection("Статистика фарма")

Tabs.Stats:AddParagraph({
    Title = "Прогресс",
    Content = "Гонок завершено: " .. raceCount .. "\nВсего заработано: " .. totalEarnings
})

-- // Log Tab
Tabs.Log:AddParagraph({
    Title = "Лог событий",
    Content = "Все действия скрипта"
})

end)

if not uiSuccess then
    warn("[DE v4] UI ERROR: " .. tostring(uiErr))
    log("UI ERROR: " .. tostring(uiErr))
    Fluent:Notify({
        Title = "UI Error",
        Content = tostring(uiErr),
        Duration = 10
    })
end

-- // ============ STARTUP ============

Window:SelectTab(1)

Fluent:Notify({
    Title = "Driving Empire v4",
    Content = "Скрипт загружен успешно",
    SubContent = "RemoteEvents активны",
    Duration = 5
})

log("Скрипт v4 загружен")
log("RemoteEvents найдены: " .. #Remotes:GetChildren())
