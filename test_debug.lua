-- // Fluent UI Test
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/Meller2/roblox-scripts/master/lib/Fluent.lua"))()

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
    Main = Window:AddTab({ Title = "Главная", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Настройки", Icon = "settings" })
}

local Options = Fluent.Options

-- // Notification
Fluent:Notify({
    Title = "Загрузка завершена",
    Content = "Fluent UI успешно загружен",
    SubContent = "by KiloUI",
    Duration = 5
})

-- // Paragraph
Tabs.Main:AddParagraph({
    Title = "Статус",
    Content = "Скрипт готов к работе\nВерсия: 1.0"
})

-- // Button
Tabs.Main:AddButton({
    Title = "Тест кнопка",
    Description = "Нажми меня",
    Callback = function()
        Fluent:Notify({
            Title = "Успех",
            Content = "Кнопка нажата!",
            Duration = 3
        })
    end
})

-- // Toggle
local Toggle = Tabs.Main:AddToggle("AutoFarm", {Title = "Автофарм", Default = false})

Toggle:OnChanged(function()
    print("Автофарм:", Options.AutoFarm.Value)
end)

-- // Slider
local Slider = Tabs.Main:AddSlider("Speed", {
    Title = "Скорость",
    Description = "Скорость фарма",
    Default = 50,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        print("Скорость:", Value)
    end
})

-- // Dropdown
local Dropdown = Tabs.Main:AddDropdown("Weapon", {
    Title = "Оружие",
    Values = {"Меч", "Лук", "Посох", "Кинжал"},
    Multi = false,
    Default = 1,
})

Dropdown:SetValue("Меч")

Dropdown:OnChanged(function(Value)
    print("Оружие:", Value)
end)

-- // Keybind
local Keybind = Tabs.Main:AddKeybind("ToggleKey", {
    Title = "Клавиша",
    Mode = "Toggle",
    Default = "RightShift",
    Callback = function(Value)
        print("Клавиша:", Value)
    end
})

-- // Colorpicker
local Colorpicker = Tabs.Main:AddColorpicker("AccentColor", {
    Title = "Цвет акцента",
    Default = Color3.fromRGB(240, 165, 0)
})

Colorpicker:OnChanged(function()
    print("Цвет:", Colorpicker.Value)
end)

-- // Settings tab
Tabs.Settings:AddParagraph({
    Title = "Настройки",
    Content = "Здесь будут настройки скрипта"
})

Window:SelectTab(1)

print("[Fluent] UI загружен успешно!")
