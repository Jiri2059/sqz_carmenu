Config = {}
Config.Locale = 'en' -- Locale (cs/de/en/es/fr/it/pl)
Config.Framework = 'esx' -- esx/qb

Config.Menu = 'ox_context' -- ox_context: ox_lib menu with mouse control, ox_menu: ox_lib menu with arrows (keyboard) control, ox_radial: ox_lib radial menu
Config.Notifications = 'ox' -- ox: ox_lib notifications, esx: esx notifications, qb: qb notifications, pnotify: pNotify, cd: cd notifications, mythic: mythic notifications
Config.ox_menuPosition = 'top-right' -- ox_menu position (top-left, top-right, bottom-left, bottom-right)

-- Car Menu
Config.OpenCarMenu = 'F5' -- Key to open Menu
Config.MenuItems = { -- Menu options display (set to false to hide from menu)
    EngineToggle = true, -- Toggle vehicle engine (on/off)
    NeonLightsToggle = true, -- Toggle vehicle neons (on/off)
    Extras = true, -- Add/Remove vehicle extras
    Liveries = true, -- Change vehicle livery
    Doors = true, -- Open/Close doors
    Windows = true, -- Open/Close windows
    Lights = true, -- Toggle vehicle lights (on/off)
}

-- Cruiser
Config.FrontCruiseSpeedControl = 'PAGEDOWN' -- Key to set front speed crusier on
Config.CruiserControl = 'PAGEUP' -- Key to set Crusier On
Config.MinimalCrusierSpeed = 10 -- Minimal speed (in kmh) to turn Cruiser On
