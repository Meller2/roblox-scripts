-- // Driving Empire Deep Diagnostic v2
print("[DE DIAG v2] Глубокая диагностика...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- // 1. Изучаем PersistentRaceSpawns
print("\n[1] PersistentRaceSpawns:")
local prs = Workspace:FindFirstChild("PersistentRaceSpawns")
if prs then
    for _, obj in ipairs(prs:GetChildren()) do
        print("  - " .. obj.Name .. " (" .. obj.ClassName .. ")")
        -- Проверяем дочерние объекты
        for _, child in ipairs(obj:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("Model") then
                print("    - " .. child.Name .. " [" .. child.ClassName .. "] Pos: " .. tostring(child.Position))
            end
        end
    end
end

-- // 2. Изучаем Map/Buildings
print("\n[2] Map/Buildings:")
local map = Workspace:FindFirstChild("Map")
if map then
    local buildings = map:FindFirstChild("Buildings")
    if buildings then
        for _, b in ipairs(buildings:GetChildren()) do
            print("  - " .. b.Name)
            if b:IsA("Model") then
                local primary = b.PrimaryPart
                if primary then
                    print("    PrimaryPart Pos: " .. tostring(primary.Position))
                end
            end
        end
    end
end

-- // 3. Ищем всё с "Race" в имени по всему Workspace
print("\n[3] Поиск 'Race' объектов во всём Workspace:")
local function findRaceObjects(parent, depth)
    depth = depth or 0
    if depth > 3 then return end
    for _, obj in ipairs(parent:GetChildren()) do
        if obj.Name:lower():find("race") or obj.Name:lower():find("circuit") or obj.Name:lower():find("check") then
            local indent = string.rep("  ", depth)
            print(indent .. "- " .. obj.Name .. " (" .. obj.ClassName .. ")")
            if obj:IsA("BasePart") then
                print(indent .. "  Pos: " .. tostring(obj.Position))
            end
        end
        -- Рекурсивно ищем в папках и моделях
        if obj:IsA("Folder") or (obj:IsA("Model") and depth < 2) then
            findRaceObjects(obj, depth + 1)
        end
    end
end
findRaceObjects(Workspace)

-- // 4. Изучаем TeleportMenu в PlayerGui
print("\n[4] TeleportMenu:")
local teleportMenu = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("TeleportMenu")
if teleportMenu then
    for _, obj in ipairs(teleportMenu:GetDescendants()) do
        if obj:IsA("TextButton") or obj:IsA("ImageButton") then
            print("  Button: " .. obj.Name .. " Text: '" .. (obj.Text or "") .. "'")
        end
    end
else
    print("  TeleportMenu не найден в PlayerGui")
end

-- // 5. Cmdr команды - ищем в ReplicatedStorage
print("\n[5] Cmdr структура:")
local cmdrFolder = ReplicatedStorage:FindFirstChild("Cmdr")
if cmdrFolder then
    print("  Cmdr папка найдена!")
    for _, obj in ipairs(cmdrFolder:GetChildren()) do
        print("  - " .. obj.Name .. " (" .. obj.ClassName .. ")")
    end
else
    print("  Cmdr папка не найдена")
    -- Ищем CmdrFunction
    local cmdrFunc = ReplicatedStorage:FindFirstChild("CmdrFunction")
    if cmdrFunc then
        print("  CmdrFunction найден: " .. cmdrFunc.ClassName)
    end
end

-- // 6. Ищем все RemoteEvents с "Race", "Teleport", "Money", "Cash" в имени
print("\n[6] Ключевые RemoteEvents:")
local keywords = {"race", "teleport", "money", "cash", "car", "vehicle", "spawn", "job", "quest", "reward"}
for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local nameLower = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if nameLower:find(kw) then
                print("  - " .. obj.Name .. " (" .. obj.ClassName .. ")")
                break
            end
        end
    end
end

-- // 7. Проверяем Vehicles папку глубже
print("\n[7] Vehicles папка (глубокий поиск):")
local vehicles = Workspace:FindFirstChild("Vehicles")
if vehicles then
    print("  Всего объектов: " .. #vehicles:GetChildren())
    -- Ищем шаблоны машин
    for _, obj in ipairs(vehicles:GetChildren()) do
        if obj:IsA("Model") then
            local seat = obj:FindFirstChildOfClass("VehicleSeat")
            if not seat then
                seat = obj:FindFirstChildOfClass("Seat")
            end
            if seat then
                print("  - " .. obj.Name .. " [с сиденьем: " .. seat.Name .. "]")
            end
        end
    end
end

-- // 8. Ищем шаблоны машин в ReplicatedStorage
print("\n[8] Шаблоны машин в ReplicatedStorage:")
for _, folder in ipairs({"Vehicles", "Cars", "CarTemplates", "VehicleTemplates"}) do
    local f = ReplicatedStorage:FindFirstChild(folder)
    if f then
        print("  Найдена папка: " .. folder)
        local count = 0
        for _, obj in ipairs(f:GetChildren()) do
            count = count + 1
            if count <= 5 then
                print("    - " .. obj.Name)
            end
        end
        if count > 5 then
            print("    ... и ещё " .. (count - 5))
        end
    end
end

-- // 9. Проверяем Leaderstats / деньги
print("\n[9] Деньги игрока:")
local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
if leaderstats then
    for _, stat in ipairs(leaderstats:GetChildren()) do
        print("  " .. stat.Name .. ": " .. tostring(stat.Value))
    end
else
    print("  leaderstats не найден")
    -- Проверяем через GetPlayerData
    local gpd = ReplicatedStorage:FindFirstChild("GetPlayerData")
    if gpd and gpd:IsA("RemoteFunction") then
        print("  GetPlayerData RemoteFunction найден, пробуем вызвать...")
        local success, data = pcall(function()
            return gpd:InvokeServer()
        end)
        if success then
            print("  Данные: " .. tostring(data))
            if type(data) == "table" then
                for k, v in pairs(data) do
                    print("    " .. tostring(k) .. ": " .. tostring(v))
                end
            end
        else
            print("  Ошибка вызова: " .. tostring(data))
        end
    end
end

-- // 10. Ищем CurrencyFeedback
print("\n[10] CurrencyFeedback:")
local cf = LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("CurrencyFeedback")
if cf then
    for _, obj in ipairs(cf:GetDescendants()) do
        if obj:IsA("TextLabel") and obj.Text ~= "" then
            print("  TextLabel: '" .. obj.Text .. "'")
        end
    end
end

print("\n[DE DIAG v2] Диагностика завершена")
