-- // ДИАГНОСТИКА: проверяем на каком этапе падает
print("[KiloUI] Скрипт запущен")

local success, result = pcall(function()
    print("[KiloUI] Шаг 1: Загрузка библиотеки...")
    
    local httpResult = game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/KiloUI.lua")
    print("[KiloUI] Шаг 2: HTTP запрос выполнен, длина: " .. #httpResult)
    
    local loadedFunc = loadstring(httpResult)
    print("[KiloUI] Шаг 3: loadstring выполнен")
    
    local KiloUI = loadedFunc()
    print("[KiloUI] Шаг 4: Библиотека загружена")
    
    print("[KiloUI] Шаг 5: Создание окна...")
    local Window = KiloUI:CreateWindow({
        Name = "BABFT Gold Farm Hub",
        LoadingTitle = "Запуск интерфейса...",
        LoadingSubtitle = "by KiloUI",
        Theme = "Default",
    })
    print("[KiloUI] Шаг 6: Окно создано")
    
    return Window
end)

if not success then
    warn("[KiloUI] ОШИБКА: " .. tostring(result))
else
    print("[KiloUI] УСПЕХ! Окно создано.")
end
