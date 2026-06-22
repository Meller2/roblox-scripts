# Roblox Scripts Project

## Project Overview
Разработка Lua скриптов для Roblox с собственной UI библиотекой KiloUI.

## Working Directory
`C:\Users\Ilzat\Downloads\scripts\roblox-scripts`

## GitHub Repository
- **URL**: https://github.com/Meller2/roblox-scripts
- **Remote**: origin -> https://github.com/Meller2/roblox-scripts.git
- **Branch**: master

## Auto-deploy
После любых изменений файлов автоматически выполнять:
```bash
git add .
git commit -m "Описание изменений"
git push origin master
```

## Project Structure
```
roblox-scripts/
  lib/
    KiloUI.lua          -- Собственная UI библиотека (1214 строк)
  my_first_script.lua   -- Автофарм золота для BABFT
  test_debug.lua        -- Диагностика загрузки
  test_minimal.lua      -- Минимальный тест
  deploy.bat            -- Скрипт для ручного деплоя
  .gitignore            -- Игнор .kilo/ и логов
```

## KiloUI Library
Кастомная UI библиотека для Roblox с:
- **Темы**: Default (золото), Ocean (синий), Emerald (зелёный), Serenity (фиолетовый)
- **Элементы**: Window, Tab, Toggle, Slider, Button, Section, Label, Notify
- **Фичи**: Анимации, drag-перетаскивание, ripple-эффекты, loading screen

### API KiloUI
```lua
local KiloUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/KiloUI.lua"))()

local Window = KiloUI:CreateWindow({
    Name = "Название",
    Theme = "Default",  -- Default, Ocean, Emerald, Serenity
})

local Tab = Window:CreateTab("Вкладка", iconId)
Tab:CreateToggle({Name = "Тумблер", Callback = function(v) end})
Tab:CreateSlider({Name = "Слайдер", Min = 0, Max = 100, Callback = function(v) end})
Tab:CreateButton({Name = "Кнопка", Callback = function() end})
Tab:CreateSection("Секция")
Tab:CreateLabel("Текст")
Window:Notify({Title = "Уведомление", Content = "Текст", Duration = 4})
```

## Current Status
- KiloUI создана и запушена на GitHub
- my_first_script.lua обновлён для работы с KiloUI через loadstring
- Solara executor не выполняет скрипты (проблема диагностируется)

## Next Steps
- Исправить проблему с выполнением скриптов в Solara
- Проверить работу test_minimal.lua и test_debug.lua
- Добавить больше элементов в KiloUI (KeyBind, Dropdown, ColorPicker)

## Executor
- **Используется**: Solara
- **Метод загрузки**: loadstring + game:HttpGet
- **Raw URL**: https://raw.githubusercontent.com/Meller2/roblox-scripts/master/
