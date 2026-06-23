-- // ДИАГНОСТИКА: проверяем структуру Workspace BABFT
print("[DIAG] Запуск диагностики BABFT...")

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // Проверяем BoatStages
local boatStages = Workspace:FindFirstChild("BoatStages")
if boatStages then
    print("[DIAG] BoatStages найден!")
    local normalStages = boatStages:FindFirstChild("NormalStages")
    if normalStages then
        print("[DIAG] NormalStages найден!")
        print("[DIAG] Дочерние объекты NormalStages:")
        for _, child in ipairs(normalStages:GetChildren()) do
            print("  - " .. child.Name)
        end
        
        -- // Проверяем первый этап
        local stage1 = normalStages:FindFirstChild("CaveStage1")
        if stage1 then
            print("[DIAG] CaveStage1 найден!")
            local darkness = stage1:FindFirstChild("DarknessPart")
            if darkness then
                print("[DIAG] DarknessPart найден! Position: " .. tostring(darkness.Position))
            else
                print("[DIAG] ОШИБКА: DarknessPart не найден в CaveStage1")
            end
        else
            print("[DIAG] ОШИБКА: CaveStage1 не найден")
        end
        
        -- // Проверяем TheEnd
        local theEnd = normalStages:FindFirstChild("TheEnd")
        if theEnd then
            print("[DIAG] TheEnd найден!")
            local chest = theEnd:FindFirstChild("GoldenChest")
            if chest then
                print("[DIAG] GoldenChest найден!")
                local trigger = chest:FindFirstChild("Trigger")
                if trigger then
                    print("[DIAG] Trigger найден! Position: " .. tostring(trigger.Position))
                else
                    print("[DIAG] ОШИБКА: Trigger не найден")
                end
            else
                print("[DIAG] ОШИБКА: GoldenChest не найден")
            end
        else
            print("[DIAG] ОШИБКА: TheEnd не найден")
        end
    else
        print("[DIAG] ОШИБКА: NormalStages не найден в BoatStages")
        print("[DIAG] Доступные папки в BoatStages:")
        for _, child in ipairs(boatStages:GetChildren()) do
            print("  - " .. child.Name)
        end
    end
else
    print("[DIAG] ОШИБКА: BoatStages не найден в Workspace!")
    print("[DIAG] Доступные объекты в Workspace:")
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") or child:IsA("Model") then
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end
    end
end

-- // Проверяем персонажа
local character = LocalPlayer.Character
if character then
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        print("[DIAG] HumanoidRootPart найден! Position: " .. tostring(hrp.Position))
    else
        print("[DIAG] ОШИБКА: HumanoidRootPart не найден")
    end
else
    print("[DIAG] ОШИБКА: Character не найден")
end

-- // Проверяем firetouchinterest
if firetouchinterest then
    print("[DIAG] firetouchinterest доступен")
else
    print("[DIAG] ОШИБКА: firetouchinterest НЕ доступен в этом executor!")
end

print("[DIAG] Диагностика завершена")
