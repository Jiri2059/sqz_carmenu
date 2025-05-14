Config = {}
Config.Locale = 'en' -- Locale used in config
Config.Framework = 'esx' -- esx/qb

Config.Menu = 'ox_context' -- ox_context: ox_lib menu with mouse control, ox_menu: ox_lib menu with arrows (keyboard) control, ox_radial: ox_lib radial menu

-- Car Menu
Config.OpenCarMenu = 'F5' -- Key to open Menu
Config.MenuItems = { -- Menu options display (set to false to hide from menu)
    EngineToggle = true, -- Toggle vehicle engine (on/off)
    Doors = true, -- Open/Close doors
    Windows = true, -- Open/Close windows
    NeonLightsToggle = true, -- Toggle vehicle neons (on/off)
    LightsToggle = true, -- Toggle vehicle lights (on/off)
    Extras = true -- Add/Remove vehicle extras
}

-- Cruiser
Config.FrontCruiseSpeedControl = 'PAGEDOWN' -- Key to set front speed crusier on
Config.CruiserControl = 'PAGEUP' -- Key to set Crusier On
Config.MinimalCrusierSpeed = 10 -- Minimal speed (in kmh) to turn Cruiser On
