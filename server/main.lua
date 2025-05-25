AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    local configErrors = 0
    print('^2[SQZ CARMENU] ^7Resource started successfully!')
    Wait(1000)
    if Config.Locale ~= "en" and not Locales[Config.Locale] then
        print('^1[SQZ CARMENU] ^7Locale "' .. Config.Locale .. '" does not exist, using "en" instead.')
        Config.Locale = "en"
        configErrors = configErrors + 1
    end
    if Config.Framework ~= "esx" and Config.Framework ~= "qb" then
        print('^1[SQZ CARMENU] ^7Framework "' .. Config.Framework .. '" is not supported, using "esx" instead.')
        Config.Framework = "esx"
        configErrors = configErrors + 1
    end
    if Config.Menu ~= "ox_radial" and Config.Menu ~= "ox_menu" and Config.Menu ~= "ox_context" then
        print('^1[SQZ CARMENU] ^7Menu "' .. Config.Menu .. '" is not supported, using "ox_context" instead.')
        Config.Menu = "ox_context"
        configErrors = configErrors + 1
    end
    if Config.Notifications ~= "ox" and Config.Notifications ~= "esx" and Config.Notifications ~= "qb" and Config.Notifications ~= "pnotify" and Config.Notifications ~= "cd" and Config.Notifications ~= "mythic" then
        print('^1[SQZ CARMENU] ^7Notifications "' .. Config.Notifications .. '" are not supported, using "ox" instead.')
        Config.Notifications = "ox"
        configErrors = configErrors + 1
    end
    if Config.ox_menuPosition ~= "top-left" and Config.ox_menuPosition ~= "top-right" and Config.ox_menuPosition ~= "bottom-left" and Config.ox_menuPosition ~= "bottom-right" then
        print('^1[SQZ CARMENU] ^7Menu position "' .. Config.ox_menuPosition .. '" is not supported, using "top-right" instead.')
        Config.ox_menuPosition = "top-right"
        configErrors = configErrors + 1
    end
    if Config.OpenCarMenu == nil or Config.OpenCarMenu == '' then
        print('^1[SQZ CARMENU] ^7OpenCarMenu is not set, using "F5" instead.')
        Config.OpenCarMenu = 'F5'
        configErrors = configErrors + 1
    end
    if Config.MinimalCrusierSpeed == nil or Config.MinimalCrusierSpeed < 0 then
        print('^1[SQZ CARMENU] ^7MinimalCrusierSpeed is not set or is less than 0, using 10 instead.')
        Config.MinimalCrusierSpeed = 10
        configErrors = configErrors + 1
    end
    if Config.FrontCruiseSpeedControl == nil or Config.FrontCruiseSpeedControl == '' then
        print('^1[SQZ CARMENU] ^7FrontCruiseSpeedControl is not set, using "PAGEDOWN" instead.')
        Config.FrontCruiseSpeedControl = 'PAGEDOWN'
        configErrors = configErrors + 1
    end
    if Config.CruiserControl == nil or Config.CruiserControl == '' then
        print('^1[SQZ CARMENU] ^7CruiserControl is not set, using "PAGEUP" instead.')
        Config.CruiserControl = 'PAGEUP'
        configErrors = configErrors + 1
    end
    if Config.MenuItems == nil or type(Config.MenuItems) ~= 'table' then
        print('^1[SQZ CARMENU] ^7MenuItems is not set or is not a table, using default values.')
        Config.MenuItems = {
            EngineToggle = true,
            NeonLightsToggle = true,
            Extras = true,
            Liveries = true,
            Doors = true,
            Windows = true,
            Lights = true,
        }
        configErrors = configErrors + 1
    end
    if Config.Framework == 'esx' and Config.Notifications == 'qb' then
        print('^1[SQZ CARMENU] ^7Notifications (' .. Config.Notifications .. ') for ESX framework are not supported, using "esx" notifications instead.')
        Config.Notifications = 'esx'
        configErrors = configErrors + 1
    elseif Config.Framework == 'qb' and Config.Notifications == 'esx' then
        print('^1[SQZ CARMENU] ^7Notifications (' .. Config.Notifications .. ') for QB framework are not supported, using "qb" notifications instead.')
        Config.Notifications = 'qb'
        configErrors = configErrors + 1
    end

    if configErrors > 0 then
        print('^1[SQZ CARMENU] ^7' .. configErrors .. ' configuration error(s) found. Please check the details above.')
    else
        print('^2[SQZ CARMENU] ^7Configuration is valid, successfully loaded.')
    end
end)

RegisterServerEvent('sqz_carmenu:server:configIssue', function(message)
    print('^1[SQZ CARMENU] ^7' .. message)
end)
