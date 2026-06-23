# Roblox Scripts Project

## Project Overview
Разработка Lua скриптов для Roblox. Универсальный скрипт-хаб с автоопределением плейса.

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
    Fluent.lua              -- UI библиотека Fluent (dawid-scripts/Fluent)
    KiloUI.lua              -- Старая кастомная UI библиотека (не используется)
  scripts/
    babft.lua               -- Build a Boat for Treasure (Gold Farm)
    driving_empire.lua      -- Driving Empire (Auto Farm v3)
  my_first_script.lua       -- Универсальный хаб (автоопределение плейса)
  log_viewer.lua            -- Просмотрщик логов с копированием
  test_debug.lua            -- Диагностика структуры игры
  test_minimal.lua          -- Минимальный тест
  logs.md                   -- Результаты сканирования RemoteEvents DE
  deploy.bat                -- Скрипт для ручного деплоя
  .gitignore                -- Игнор .kilo/ и логов
```

## Script Hub (my_first_script.lua)
Универсальный хаб с автоопределением `game.PlaceId`:
- **189707** → Build a Boat for Treasure → `scripts/babft.lua`
- **3351674303** → Driving Empire → `scripts/driving_empire.lua`
- Неизвестный плейс → уведомление со списком поддерживаемых игр

### Команда запуска
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/my_first_script.lua?v="..os.time()))()
```
- `?v=` + `os.time()` обязателен для обхода кэша Solara/GitHub raw
- Версии скриптов обновляются в заголовках (DE — v4.1, BABFT — v4.1, Hub — v2)

## UI Library: Fluent
Используется **Fluent** от dawid-scripts (GitHub: dawid-scripts/Fluent).
- Загружается из нашего репозитория: `lib/Fluent.lua`
- GitHub releases URL НЕ работает через `game:HttpGet` (редиректы)
- Acrylic blur отключён (`Acrylic = false`) — вызывает краши в Solara

### API Fluent
```lua
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/Fluent.lua?v="..os.time()))()

local Window = Fluent:CreateWindow({
    Title = "Название",
    SubTitle = "by KiloUI",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tab = Window:AddTab({ Title = "Вкладка", Icon = "home" })
Tab:AddToggle("Flag", {Title = "Тумблер", Default = false})
Tab:AddSlider("Flag", {Title = "Слайдер", Min = 0, Max = 100, Default = 50, Rounding = 0})
Tab:AddButton({Title = "Кнопка", Callback = function() end})
Tab:AddDropdown("Flag", {Title = "Дропдаун", Values = {"a","b"}, Multi = false, Default = 1})
Tab:AddColorpicker("Flag", {Title = "Цвет", Default = Color3.fromRGB(255,0,0)})
Tab:AddKeybind("Flag", {Title = "Клавиша", Mode = "Toggle", Default = "RightShift"})
Tab:AddInput("Flag", {Title = "Поле", Default = "", Placeholder = "..."})
Tab:AddParagraph({Title = "Заголовок", Content = "Текст"})
Tab:AddSection("Секция")

Fluent:Notify({Title = "Заголовок", Content = "Текст", SubContent = "Подтекст", Duration = 5})

-- Получение значения: Options.Flag.Value
-- OnChanged: Toggle:OnChanged(function(v) ... end)
```

### Важные ограничения Fluent
- НЕТ метода `AddLabel` — использовать `AddParagraph`
- НЕТ метода `CreateToggle/CreateSlider` (это старый KiloUI API)
- Все элементы через `Add*` методы

## Log Viewer (log_viewer.lua)
Просмотрщик логов с копированием текста:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/log_viewer.lua?v="..os.time()))()
```
- Перехватывает `print()` и `warn()`
- Кнопка "В файл (UTF-8)" — сохраняет с UTF-8 BOM для кириллицы
- Кнопка "Копировать" — открывает TextBox, клик → Ctrl+A → Ctrl+C
- Горячая клавиша: Ctrl+L (показать/скрыть)
- **Важно**: добавлять `?v=` + os.time() для обхода CDN кэша

## Supported Games

### Build a Boat for Treasure (PlaceId: 189707)
- **Файл**: `scripts/babft.lua`
- **Функции**: Автофарм золота через телепорт к CaveStage1-10 → GoldenChest → firetouchinterest
- **Структура**: Workspace.BoatStages.NormalStages.{CaveStage1..10, TheEnd}

### Driving Empire (PlaceId: 3351674303)
- **Файл**: `scripts/driving_empire.lua`
- **Функции**: Авто-гонки, авто-доставки, телепорты, квесты, статы
- **RemoteEvents**: Все в `ReplicatedStorage.Remotes`
  - Гонки: `JoinRacingQueue`, `LeaveRacingQueue`, `RaceQueue`, `RaceStateUpdate`, `RaceFinished`, `RaceDNF`, `RaceQuickRestart`, `RaceLeaderboardClaimRewards`
  - Доставки: `AttemptDeliveryPickup`, `AttemptDeliveryComplete`
  - Телепорт: `Teleport` (RemoteEvent)
  - Машина: `StarterCar` (RemoteFunction), `GetVehicleStats` (RemoteFunction)
  - Квесты: `ClaimQuestReward`, `QuestsUpdate`
  - Данные: `VoldexAdmin.RemoteFunctions.GetPlayerData`, `GetStats`
  - Деньги: `CollectCashDrop`
- **Структура**: Workspace.{Vehicles, HousePlots, Map/Buildings, PersistentRaceSpawns}
- **Cmdr**: Система команд через `CmdrClient.CmdrFunction`/`CmdrEvent`

## Known Issues
1. **Fluent не грузится с GitHub releases** — использовать URL из нашего репозитория
2. **GitHub raw CDN кэширует** — добавлять `?v=` + os.time() для обхода
3. **Acrylic blur крашит Solara** — всегда `Acrylic = false`
4. **Driving Empire скрипт не работает** — RemoteEvents найдены, но логика требует тестирования в игре
5. **setclipboard() артефакты кириллицы** — использовать запись в файл с UTF-8 BOM

## Executor
- **Используется**: Solara (Xeno не работает)
- **Метод загрузки**: loadstring + game:HttpGet
- **Raw URL**: https://raw.githubusercontent.com/Meller2/roblox-scripts/master/
- **Важно**: Solara кэширует скрипты, нужен cache-busting параметр

## Diagnostics
Для изучения структуры нового плейса использовать `test_debug.lua`:
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/test_debug.lua"))()
```
Вывод сохраняется в консоль и показывает: папки Workspace, RemoteEvents, GUI, RemoteFunctions.
