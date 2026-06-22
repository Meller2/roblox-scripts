-- // ДИАГНОСТИКА: проверяем на каком этапе падает
print("[KiloUI] Скрипт запущен")

local success, result = pcall(function()
    print("[KiloUI] Шаг 1: Загрузка библиотеки...")
    
    local httpResult = game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/KiloUI.lua?v=" .. os.time())
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

    local Tab1 = Window:CreateTab("Главная", nil)
    Tab1:CreateSection("Тест элементов")
    Tab1:CreateLabel("Это тестовая метка")
    Tab1:CreateToggle({Name = "Автофарм", Callback = function(v) print("Toggle:", v) end})
    Tab1:CreateSlider({Name = "Скорость", Min = 1, Max = 100, Default = 50, Callback = function(v) print("Slider:", v) end})
    Tab1:CreateButton({Name = "Тест кнопка", Callback = function() Window:Notify({Title = "Успех!", Content = "Кнопка нажата", Duration = 3}) end})

    local Tab2 = Window:CreateTab("Настройки", nil)
    Tab2:CreateSection("Настройки")
    Tab2:CreateToggle({Name = "Тёмная тема", CurrentValue = true, Callback = function(v) print("Theme:", v) end})

    print("[KiloUI] Шаг 7: Табы и элементы созданы")

    Window:Notify({Title = "KiloUI загружен", Content = "Все элементы работают", Duration = 4})

    return Window
end)

if not success then
    warn("[KiloUI] ОШИБКА: " .. tostring(result))
else
    print("[KiloUI] УСПЕХ! Окно создано.")
end
