-- // Driving Empire Диагностика
-- // Изучаем структуру игры

print("[DE DIAG] Запуск диагностики Driving Empire...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Проверяем основные папки
local foldersToCheck = {
    "Vehicles",
    "HousePlots",
    "Races",
    "Dealerships",
    "Map",
    "City"
}

print("\n[DE DIAG] Проверка папок в Workspace:")
for _, folderName in ipairs(foldersToCheck) do
    local folder = Workspace:FindFirstChild(folderName)
    if folder then
        print("  ✓ " .. folderName .. " найден")
        -- Показываем первые 5 дочерних объектов
        local children = folder:GetChildren()
        print("    Дочерние объекты (первые 5):")
        for i = 1, math.min(5, #children) do
            print("      - " .. children[i].Name .. " (" .. children[i].ClassName .. ")")
        end
        if #children > 5 then
            print("      ... и ещё " .. (#children - 5))
        end
    else
        print("  ✗ " .. folderName .. " НЕ найден")
    end
end

-- // Проверяем Races
print("\n[DE DIAG] Поиск гонок:")
local races = Workspace:FindFirstChild("Races")
if races then
    for _, race in ipairs(races:GetChildren()) do
        print("  - " .. race.Name)
        -- Проверяем структуру гонки
        local checkpoints = race:FindFirstChild("Checkpoints") or race:FindFirstChild("Parts")
        if checkpoints then
            print("    Checkpoints/Parts: " .. #checkpoints:GetChildren() .. " объектов")
        end
    end
else
    print("  Папка Races не найдена, ищем альтернативы...")
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:lower():find("race") or obj.Name:lower():find("circuit") then
            print("  Найдено: " .. obj.Name)
        end
    end
end

-- // Проверяем Dealerships
print("\n[DE DIAG] Поиск дилершипov:")
local dealerships = Workspace:FindFirstChild("Dealerships")
if dealerships then
    for _, d in ipairs(dealerships:GetChildren()) do
        print("  - " .. d.Name)
    end
else
    print("  Папка Dealerships не найдена")
end

-- // Проверяем персонажа и машину
print("\n[DE DIAG] Персонаж и машина:")
local character = LocalPlayer.Character
if character then
    print("  Character найден")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        print("  HRP Position: " .. tostring(hrp.Position))
    end
    
    -- Ищем VehicleSeat в персонаже
    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
            print("  Найдено сиденье: " .. obj.Parent.Name)
        end
    end
else
    print("  Character НЕ найден")
end

-- // Ищем машины в Workspace
print("\n[DE DIAG] Поиск машин в Workspace:")
local vehicleCount = 0
for _, obj in ipairs(Workspace:GetChildren()) do
    if obj:IsA("Model") then
        local seat = obj:FindFirstChildOfClass("VehicleSeat")
        if seat then
            vehicleCount = vehicleCount + 1
            if vehicleCount <= 5 then
                print("  - " .. obj.Name .. " (Seat: " .. seat.Name .. ")")
            end
        end
    end
end
print("  Всего машин найдено: " .. vehicleCount)

-- // Проверяем RemoteEvents
print("\n[DE DIAG] RemoteEvents в ReplicatedStorage:")
local RS = game:GetService("ReplicatedStorage")
local remoteCount = 0
for _, obj in ipairs(RS:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        remoteCount = remoteCount + 1
        if remoteCount <= 10 then
            print("  - " .. obj.Name .. " (" .. obj.ClassName .. ")")
        end
    end
end
print("  Всего RemoteEvents: " .. remoteCount)

-- // Проверяем PlayerGui
print("\n[DE DIAG] GUI в PlayerGui:")
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if PlayerGui then
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            print("  - " .. gui.Name)
        end
    end
end

print("\n[DE DIAG] Диагностика завершена")
print("[DE DIAG] Скопируй этот вывод и покажи разработчику")
