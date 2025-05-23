-- if Config.Framework == 'esx' then
	exports["es_extended"]:getSharedObject()

	local motor = true
	local neons = true
	local cruiserOn = false
	local forwardspeed = false
	local forwardvehiclespeed = 0
	local currentVehicle = 0
	local isRadialOpen = false
	local menuCooldown = false

	RegisterCommand('carmenu', function()
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player, false)	
		if (IsPedSittingInAnyVehicle(player)) then
			   OpenVehicleControlsMenu()
		else
			showNotification('error', _U('not_inveh'))
		end
    end, false)

	RegisterCommand("cruisercontrol", function()
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player,false)
		if (IsPedSittingInAnyVehicle(player)) and GetPedInVehicleSeat(vehicle, -1) then
			local vehicleSpeed = GetEntitySpeed(vehicle)
			local kmh = (vehicleSpeed * 3.6)
			if cruiserOn then
				cruiserOn = false
				SetEntityMaxSpeed(vehicle, GetVehicleHandlingFloat(vehicle,"CHandlingData","fInitialDriveMaxFlatVel"))
				showNotification('success', _U('cruiser_off'))
			elseif not cruiserOn then
				if kmh >= Config.MinimalCrusierSpeed then
					cruiserOn = true
					SetEntityMaxSpeed(vehicle, vehicleSpeed)
					showNotification('success', _U('crusier_on', ESX.Math.Round(kmh)))
				else
					showNotification('error', _U('not_required_speed', Config.MinimalCrusierSpeed))
				end
			end
		else
			showNotification('error', _U('not_driver'))
		end
	end, false)
	
	RegisterCommand("frontcruisercontrol", function()
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player,false)
		if (IsPedSittingInAnyVehicle(player)) and GetPedInVehicleSeat(vehicle, -1) then
			local vehicleSpeed = GetEntitySpeed(vehicle)
			local kmh = (vehicleSpeed * 3.6)
			if forwardspeed then
				forwardspeed = false
				showNotification('success', _U('forw_crusier_odd'))
			elseif not forwardspeed then
				forwardspeed = true
				forwardvehiclespeed = vehicleSpeed
				showNotification('success', _U('crusier_on', kmh))
			end
		else
			showNotification('error', _U('not_driver'))
		end
	end, false)

	
	CreateThread(function()
		while true do
			Wait(0)
			if IsControlPressed(1, 32) or IsControlPressed(1, 33) or IsControlPressed(1, 55) then
				if forwardspeed then
					forwardspeed = false
					showNotification('success', _U('forw_crusier_odd'))
				end
			end
		end
	end)
	
	CreateThread(function()
		while true do
			Wait(500)
			if forwardspeed then
				local player = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(player,false)
				if not IsEntityInAir(vehicle) then
					SetVehicleForwardSpeed(vehicle, forwardvehiclespeed)
				elseif IsEntityInAir(vehicle) then
					forwardspeed = false
					showNotification('success', _U('forw_crusier_odd'))
				end
			end
		end
	end)

	local inVehicle = false
	local radialRegistered = false

	CreateThread(function()
		while true do
			if Config.Menu == 'ox_radial' then
				local ped = PlayerPedId()
				local vehicle = GetVehiclePedIsIn(ped, false)
				local wasInVehicle = inVehicle
				inVehicle = IsPedInAnyVehicle(ped, false)
	
				if inVehicle ~= wasInVehicle then
					if inVehicle then
						if not radialRegistered then
							radialRegistered = true
							local itemsExtras = {}
							local itemsLiveries = {}
							for extraId = 0, 20 do
								if DoesExtraExist(vehicle, extraId) then
									local isOn = IsVehicleExtraTurnedOn(vehicle, extraId)
									itemsExtras[#itemsExtras + 1] = {
										label = _U('item_extra', extraId),
										icon = 'toggle-on',
										onSelect = function()
											SetVehicleExtra(vehicle, extraId, isOn and 1 or 0)
										end
									}
								end
							end

							local liveryCount = GetVehicleLiveryCount(vehicle)
							if liveryCount > 0 then
								local currentLivery = GetVehicleLivery(vehicle)
								for liveryId = 0, liveryCount - 1 do
									itemsLiveries[#itemsLiveries + 1] = {
										label = _U('item_livery', liveryId),
										icon = 'hashtag',
										onSelect = function()
											SetVehicleLivery(vehicle, liveryId)
										end
									}
								end
							end
							lib.registerRadial({
						  		id = 'car_menu',
						  		items = {
									if Config.MenuItems.EngineToggle then
										{
											label = _U('engine'),
							  				icon = 'power-off',
							  				onSelect = function()
												if motor then
													motor = false
													SetVehicleEngineOn(vehicle, false, false, false)
												elseif not motor then
													motor = true
													SetVehicleEngineOn(vehicle, true, false, false)
												end
												while (motor == false) do
													SetVehicleUndriveable(vehicle,true)
													Wait(0)
												end
							  				end
										},
									end,
									if Config.MenuItems.NeonLightsToggle then
										{
											label = _U('neons'),
											icon = 'bolt',
											onSelect = function()
												if neons then
													neons = false
													DisableVehicleNeonLights(vehicle, false, false, false)
												elseif not neons then
													neons = true
													DisableVehicleNeonLights(vehicle, true, false, false)
												end	
											end
										},
									end,
									if Config.MenuItems.Extras then
										{
											label = _U('extras'),
											icon = 'plus',
											menu = 'menu_extras',
										},
									end,
									if Config.MenuItems.Liveries then
										{
											label = _U('liveries'),
											icon = 'palette',
											menu = 'menu_liveries',
										},
									end,
									if Config.MenuItems.Doors then
										{
											label = _U('open_close'),
											icon = 'door-open',
											menu = 'menu_open_close'
										},
									end,
									if Config.MenuItems.Windows then
										{
											label = _U('windows'),
											icon = 'window-maximize',
											menu = 'menu_windows'
										},
									end,
									if Config.MenuItems.Lights then
										{
											label = _U('lights'),
											icon = 'lightbulb',
											menu = 'menu_lights'
										},
									end,
						  		}
							})

							if Config.MenuItems.Extras then
						  		lib.registerRadial({
									id = 'menu_extras',
									items = itemsExtras
						  		})
							end

							if Config.MenuItems.Liveries then
						  		lib.registerRadial({
									id = 'menu_liveries',
									items = itemsLiveries
						  		})
							end
							
							if Config.MenuItems.Doors then
								lib.registerRadial({
								  id = 'menu_open_close',
								  items = {
									{
									  label = _U('fronleftdoors'),
									  icon = 'door-open',
									  onSelect = function()
										if not fronleftdoors then
											fronleftdoors = true
											SetVehicleDoorOpen(vehicle, 0, false)
										elseif fronleftdoors then
											fronleftdoors = false
											SetVehicleDoorShut(vehicle, 0, false)
										end
									  end
									},
									{
									  label = _U('frontrightdoors'),
									  icon = 'door-open',
									  onSelect = function()
										if not frontrightdoors then
											frontrightdoors = true
											SetVehicleDoorOpen(vehicle, 1, false)
										elseif frontrightdoors then
											frontrightdoors = false
											SetVehicleDoorShut(vehicle, 1, false)
										end
									  end
									},
									{
									  label = _U('backleftdoors'),
									  icon = 'door-open',
									  onSelect = function()
										if not backleftdoors then
											backleftdoors = true
											SetVehicleDoorOpen(vehicle, 2, false)
										elseif backleftdoors then
											backleftdoors = false
											SetVehicleDoorShut(vehicle, 2, false)
										end
									  end
									},
									{
									  label = _U('backrightdoors'),
									  icon = 'door-open',
									  onSelect = function()
										if not backrightdoors then
											backrightdoors = true
											SetVehicleDoorOpen(vehicle, 3, false)
										elseif backrightdoors then
											backrightdoors = false
											SetVehicleDoorShut(vehicle, 3, false)
										end
									  end
									},
									{
									  label = _U('alldoorsopen'),
									  icon = 'door-open',
									  onSelect = function()
										fronleftdoors = true
										frontrightdoors = true
										backleftdoors = true
										backrightdoors = true
										trunk = true
										hood = true
										SetVehicleDoorOpen(vehicle, 0, false)
										SetVehicleDoorOpen(vehicle, 1, false)
										SetVehicleDoorOpen(vehicle, 2, false)
										SetVehicleDoorOpen(vehicle, 3, false)
										SetVehicleDoorOpen(vehicle, 4, false)
										SetVehicleDoorOpen(vehicle, 5, false)
									  end
									},
									{
									  label = _U('alldoorsclose'),
									  icon = 'door-close',
									  onSelect = function()
										fronleftdoors = false
										frontrightdoors = false
										backleftdoors = false
										backrightdoors = false
										trunk = false
										hood = false
										SetVehicleDoorsShut(vehicle)
									  end
									},
									{
									  label = _U('trunk'),
									  icon = 'luggage-cart',
									  onSelect = function()
										if not trunk then
											trunk = true
											SetVehicleDoorOpen(vehicle, 5, false)
										elseif trunk then
											trunk = false
											SetVehicleDoorShut(vehicle, 5, false)
										end
									  end
									},
									{
									  label = _U('hood'),
									  icon = 'car-side',
									  onSelect = function()
										if not hood then
											hood = true
											SetVehicleDoorOpen(vehicle, 4, false)
										elseif hood then
											hood = false
											SetVehicleDoorShut(vehicle, 4, false)
										end
									  end
									}
								  }
								})
							end
	
							if Config.MenuItems.Windows then
								lib.registerRadial({
								  id = 'menu_windows',
								  items = {
									{
									  label = _U('leftfrontwindows'),
									  icon = 'window-restore',
									  onSelect = function()
										if not leftfrontwindows then
											leftfrontwindows = true
											RollUpWindow(vehicle, 0, false)
										elseif leftfrontwindows then
											leftfrontwindows = false
											RollDownWindow(vehicle, 0, false)
										end
									  end
									},
									{
									  label = _U('rightfrontwindows'),
									  icon = 'window-restore',
									  onSelect = function()
										if not rightfrontwindows then
											rightfrontwindows = true
											RollUpWindow(vehicle, 1, false)
										elseif rightfrontwindows then
											rightfrontwindows = false
											RollDownWindow(vehicle, 1, false)
										end
									  end
									},
									{
									  label = _U('leftbackwindow'),
									  icon = 'window-restore',
									  onSelect = function()
										if not leftbackwindow then
											leftbackwindow = true
											RollUpWindow(vehicle, 2, false)
										elseif leftbackwindow then
											leftbackwindow = false
											RollDownWindow(vehicle, 2, false)
										end
									  end
									},
									{
									  label = _U('rightbackwindow'),
									  icon = 'window-restore',
									  onSelect = function()
										if not rightbackwindow then
											rightbackwindow = true
											RollUpWindow(vehicle, 3, false)
										elseif rightbackwindow then
											rightbackwindow = false
											RollDownWindow(vehicle, 3, false)
										end
									  end
									},
									{
									  label = _U('windowsdown'),
									  icon = 'window-restore',
									  onSelect = function()
										leftfrontwindows = true
										rightfrontwindows = true
										leftbackwindow = true
										rightbackwindow = true
										RollDownWindows(vehicle)
									  end
									},
									{
									  label = _U('windowsup'),
									  icon = 'window-restore',
									  onSelect = function()
										leftfrontwindows = false
										rightfrontwindows = false
										leftbackwindow = false
										rightbackwindow = false
										RollUpWindow(vehicle, 0, false)
										RollUpWindow(vehicle, 1, false)
										RollUpWindow(vehicle, 2, false)
										RollUpWindow(vehicle, 3, false)
									  end
									}
								  }
								})
							end
	
							if Config.MenuItems.Lights then
								lib.registerRadial({
								  id = 'menu_lights',
								  items = {
									{
									  label = _U('interiorlights'),
									  icon = 'lightbulb',
									  onSelect = function()
										if not interiorlights then
											interiorlights = true
											SetVehicleInteriorlight(vehicle, true)
										elseif interiorlights then
											interiorlights = false
											SetVehicleInteriorlight(vehicle, false)
										end
									  end
									},
									{
									  label = _U('frontlights'),
									  icon = 'car-side',
									  onSelect = function()
										if not frontlights then
											frontlights = true
											SetVehicleLights(vehicle, true)
										elseif frontlights then
											frontlights = false
											SetVehicleLights(vehicle, false)
										end
									  end
									}
								  }
								})
							end

							lib.addRadialItem({
								{
									id = 'vehicle_menu',
									label = _U('car_menu'),
									icon = 'car',
									menu = 'car_menu'
								}
							})
						end
					else
						lib.removeRadialItem('vehicle_menu')
						radialRegistered = false
					end
				end
			end
			Wait(1000)
		end
	end)

	AddEventHandler('onResourceStop', function(resource)
		if GetCurrentResourceName() == 'sqz_carmenu' then
			lib.removeRadialItem('car_menu')
		end
	end)

	function OpenVehicleControlsMenu()
		local player = PlayerPedId()
		local vehicle = GetVehiclePedIsIn(player,false)

		local interiorlights = false
		local frontlights = true

		local leftfrontwindows = true
		local rightfrontwindows = true
		local leftbackwindow = true
		local rightbackwindow = true

		local fronleftdoors = false
		local frontrightdoors = false
		local backleftdoors = false
		local backrightdoors = false
		local trunk = false
		local hood = false

		if Config.Menu == 'ox_context' then
			lib.registerContext({
				id = 'car_menu',
				title = _U('car_menu'),
				options = {
					if Config.MenuItems.EngineToggle then
						{
							title = _U('engine'),
							icon = 'power-off',
							onSelect = function()
								if motor then
									motor = false
									SetVehicleEngineOn(vehicle, false, false, false)
								elseif not motor then
									motor = true
									SetVehicleEngineOn(vehicle, true, false, false)
								end
								while (motor == false) do
									SetVehicleUndriveable(vehicle,true)
									Wait(0)
								end
							end,
						},
					end,
					if Config.MenuItems.NeonLightsToggle then
						{
							title = _U('neons'),
							icon = 'bolt',
							onSelect = function()
								if neons then
									neons = false
									DisableVehicleNeonLights(vehicle, false, false, false)
								elseif not neons then
									neons = true
									DisableVehicleNeonLights(vehicle, true, false, false)
								end	
							end,
						},
					end,
					if Config.MenuItems.Extras then
						{
							title = _U('extras'),
							menu = 'menu_extras',
							icon = 'plus'
						},
					end,
					if Config.MenuItems.Liveries then
						{
							title = _U('liveries'),
							menu = 'menu_liveries',
							icon = 'palette'
						},
					end,
					if Config.MenuItems.Doors then
						{
							title = _U('open_close'),
							menu = 'menu_open_close',
							icon = 'door-open'
						},
					end,
					if Config.MenuItems.Windows then
						{
							title = _U('windows'),
							menu = 'menu_windows',
							icon = 'window-maximize'
						},
					end,
					if Config.MenuItems.Lights then
						{
							title = _U('lights'),
							menu = 'menu_lights',
							icon = 'lightbulb'
						},
					end,
				}
			})
	
			local extrasOptions = {}
			for extraId = 0, 20 do
				if DoesExtraExist(vehicle, extraId) then
					local isOn = IsVehicleExtraTurnedOn(vehicle, extraId)
					local title = _U('item_extra', extraId)
	
					table.insert(extrasOptions, {
						title = title,
						icon = "toggle-on",
						onSelect = function()
							SetVehicleExtra(vehicle, extraId, isOn and 1 or 0)
						end
					})
				end
			end
			
			if Config.MenuItems.Extras then
				lib.registerContext({
					id = 'menu_extras',
					title = _U('extras'),
					menu = 'car_menu',
					options = extrasOptions
				})
			end
	
			local liveryCount = GetVehicleLiveryCount(vehicle)
			local liveriesOptions = {}

			for liveryId = 0, (liveryCount > 0 and liveryCount - 1 or 0) do
				table.insert(liveriesOptions, {
					title = _U('item_livery', liveryId),
					icon = "hashtag",
					onSelect = function()
						SetVehicleLivery(vehicle, liveryId)
					end
				})
			end
	
			if Config.MenuItems.Liveries then
				lib.registerContext({
					id = 'menu_liveries',
					title = _U('liveries'),
					menu = 'car_menu',
					options = liveriesOptions
				})
			end
	
			if Config.MenuItems.Doors then
				lib.registerContext({
					id = 'menu_open_close',
					title = _U('open_close'),
					menu = 'car_menu',
					options = {
						{
							title = _U('fronleftdoors'),
							icon = 'door-open',
							onSelect = function()
								if not fronleftdoors then
									fronleftdoors = true
									SetVehicleDoorOpen(vehicle, 0, false)
								elseif fronleftdoors then
									fronleftdoors = false
									SetVehicleDoorShut(vehicle, 0, false)
								end
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('frontrightdoors'),
							icon = 'door-open',
							onSelect = function()
								if not frontrightdoors then
									frontrightdoors = true
									SetVehicleDoorOpen(vehicle, 1, false)
								elseif frontrightdoors then
									frontrightdoors = false
									SetVehicleDoorShut(vehicle, 1, false)
								end
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('backleftdoors'),
							icon = 'door-open',
							onSelect = function()
								if not backleftdoors then
									backleftdoors = true
									SetVehicleDoorOpen(vehicle, 2, false)
								elseif backleftdoors then
									backleftdoors = false
									SetVehicleDoorShut(vehicle, 2, false)
								end
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('backrightdoors'),
							icon = 'door-open',
							onSelect = function()
								if not backrightdoors then
									backrightdoors = true
									SetVehicleDoorOpen(vehicle, 3, false)
								elseif backrightdoors then
									backrightdoors = false
									SetVehicleDoorShut(vehicle, 3, false)
								end
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('alldoorsopen'),
							icon = 'door-open',
							onSelect = function()
								fronleftdoors = true
								frontrightdoors = true
								backleftdoors = true
								backrightdoors = true
								trunk = true
								hood = true
								SetVehicleDoorOpen(vehicle, 0, false)
								SetVehicleDoorOpen(vehicle, 1, false)
								SetVehicleDoorOpen(vehicle, 2, false)
								SetVehicleDoorOpen(vehicle, 3, false)
								SetVehicleDoorOpen(vehicle, 4, false)
								SetVehicleDoorOpen(vehicle, 5, false)
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('alldoorsclose'),
							icon = 'door-open',
							onSelect = function()
								fronleftdoors = false
								frontrightdoors = false
								backleftdoors = false
								backrightdoors = false
								trunk = false
								hood = false
								SetVehicleDoorsShut(vehicle)	
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('trunk'),
							icon = 'luggage-cart',
							onSelect = function()
								if not trunk then
									trunk = true
									SetVehicleDoorOpen(vehicle, 5, false)
								elseif trunk then
									trunk = false
									SetVehicleDoorShut(vehicle, 5, false)
								end
								lib.showContext('menu_open_close')
							end,
						},
						{
							title = _U('hood'),
							icon = 'car-side',
							onSelect = function()
								if not hood then
									hood = true
									SetVehicleDoorOpen(vehicle, 4, false)
								elseif hood then
									hood = false
									SetVehicleDoorShut(vehicle, 4, false)
								end
								lib.showContext('menu_open_close')
							end,
						}
					}
				})
			end
	
			if Config.MenuItems.Windows then
				lib.registerContext({
					id = 'menu_windows',
					title = _U('windows'),
					menu = 'car_menu',
					options = {
						{
							title = _U('leftfrontwindows'),
							icon = 'window-restore',
							onSelect = function()
								if not leftfrontwindows then
									leftfrontwindows = true
									RollUpWindow(vehicle, 0, false)
								elseif leftfrontwindows then
									leftfrontwindows = false
									RollDownWindow(vehicle, 0, false)
								end
								lib.showContext('menu_windows')
							end,
						},
						{
							title = _U('rightfrontwindows'),
							icon = 'window-restore',
							onSelect = function()
								if not rightfrontwindows then
									rightfrontwindows = true
									RollUpWindow(vehicle, 1, false)
								elseif rightfrontwindows then
									rightfrontwindows = false
									RollDownWindow(vehicle, 1, false)
								end
								lib.showContext('menu_windows')
							end,
						},
						{
							title = _U('leftbackwindow'),
							icon = 'window-restore',
							onSelect = function()
								if not leftbackwindow then
									leftbackwindow = true
									RollUpWindow(vehicle, 2, false)
								elseif leftbackwindow then
									leftbackwindow = false
									RollDownWindow(vehicle, 2, false)
								end
								lib.showContext('menu_windows')
							end,
						},
						{
							title = _U('rightbackwindow'),
							icon = 'window-restore',
							onSelect = function()
								if not rightbackwindow then
									rightbackwindow = true
									RollUpWindow(vehicle, 3, false)
								elseif rightbackwindow then
									rightbackwindow = false
									RollDownWindow(vehicle, 3, false)
								end
								lib.showContext('menu_windows')
							end,
						},
						{
							title = _U('windowsdown'),
							icon = 'window-restore',
							onSelect = function()
								leftfrontwindows = true
								rightfrontwindows = true
								leftbackwindow = true
								rightbackwindow = true
								RollDownWindows(vehicle)
								lib.showContext('menu_windows')
							end,
						},
						{
							title = _U('windowsup'),
							icon = 'window-restore',
							onSelect = function()
								leftfrontwindows = false
								rightfrontwindows = false
								leftbackwindow = false
								rightbackwindow = false
								RollUpWindow(vehicle, 0, false)
								RollUpWindow(vehicle, 1, false)
								RollUpWindow(vehicle, 2, false)
								RollUpWindow(vehicle, 3, false)
								lib.showContext('menu_windows')
							end,
						}
					}
				})
			end
	
			if Config.MenuItems.Lights then
				lib.registerContext({
					id = 'menu_lights',
					title = _U('lights'),
					menu = 'car_menu',
					options = {
						{
							title = _U('interiorlights'),
							icon = 'lightbulb',
							onSelect = function()
								if not interiorlights then
									interiorlights = true
									SetVehicleInteriorlight(vehicle, true)
								elseif interiorlights then
									interiorlights = false
									SetVehicleInteriorlight(vehicle, false)
								end
								lib.showContext('menu_lights')
							end,
						},
						{
							title = _U('frontlights'),
							icon = 'car-side',
							onSelect = function()
								if not frontlights then
									frontlights = true
									SetVehicleLights(vehicle, true)
								elseif frontlights then
									frontlights = false
									SetVehicleLights(vehicle, false)
								end
								lib.showContext('menu_lights')
							end,
						}
					}
				})
			end
	
			lib.showContext('car_menu')
		elseif Config.Menu == 'ox_menu' then
			local extrasOptions = {}
    		for extraId = 0, 20 do
        		if DoesExtraExist(vehicle, extraId) then
            		local isOn = IsVehicleExtraTurnedOn(vehicle, extraId)
            		table.insert(extrasOptions, {
						label = _U('item_extra', extraId),
						icon = 'toggle-on',
                		value = extraId
            		})
        		end
    		end

    		local liveryOptions = {}
		    local liveryCount = GetVehicleLiveryCount(vehicle)
		    for liveryId = 0, (liveryCount > 0 and liveryCount - 1 or 0) do
		        table.insert(liveryOptions, {
		            label = _U('item_livery', liveryId),
					icon = 'hashtag',
		            value = liveryId
        		})
		    end

			lib.registerMenu({
				id = 'car_menu',
				title = _U('car_menu'),
				position = Config.ox_menuPosition,
				options = {
					if Config.MenuItems.EngineToggle then
						{label = _U('engine'), icon = 'power-off'},
					end,
					if Config.MenuItems.NeonLightsToggle then
						{label = _U('neons'), icon = 'bolt'},
					end,
					if Config.MenuItems.Extras then
						{label = _U('extras'), icon = 'plus', values = extrasOptions},
					end,
					if Config.MenuItems.Liveries then
						{label = _U('liveries'), icon = 'palette', values = liveryOptions},
					end,
					if Config.MenuItems.Doors then
						{label = _U('open_close'), icon = 'door-open', values = {_U('fronleftdoors'), _U('frontrightdoors'), _U('backleftdoors'), _U('backrightdoors'), _U('alldoorsopen'), _U('alldoorsclose'), _U('trunk'), _U('hood')}},
					end,
					if Config.MenuItems.Windows then
						{label = _U('windows'), icon = 'window-maximize', values = {_U('leftfrontwindows'), _U('rightfrontwindows'), _U('leftbackwindow'), _U('rightbackwindow'), _U('windowsdown'), _U('windowsup')}},
					end,
					if Config.MenuItems.Lights then
						{label = _U('lights'), icon = 'lightbulb', values = {_U('interiorlights'), _U('frontlights')}},
					end,
				}
			}, function(selected, scrollIndex, args)
				print(selected, scrollIndex, args)
				if selected == 1 then
					if motor then
						motor = false
						SetVehicleEngineOn(vehicle, false, false, false)
					elseif not motor then
						motor = true
						SetVehicleEngineOn(vehicle, true, false, false)
					end
					while (motor == false) do
						SetVehicleUndriveable(vehicle,true)
						Wait(0)
					end
				elseif selected == 2 then
					if neons then
						neons = false
						DisableVehicleNeonLights(vehicle, false, false, false)
					elseif not neons then
						neons = true
						DisableVehicleNeonLights(vehicle, true, false, false)
					end	
				elseif selected == 3 then
					local extraId = extrasOptions[scrollIndex]?.value
		            if extraId then
        		        local currentState = IsVehicleExtraTurnedOn(vehicle, extraId)
		                SetVehicleExtra(vehicle, extraId, currentState and 1 or 0)
        		        lib.showMenu('car_menu')
		            end
				elseif selected == 4 then
					local liveryId = liveryOptions[scrollIndex]?.value
		            if liveryId then
        		        SetVehicleLivery(vehicle, liveryId)
                		lib.showMenu('car_menu')
		            end
				elseif selected == 5 then
					if scrollIndex == 1 then
						if not fronleftdoors then
							fronleftdoors = true
							SetVehicleDoorOpen(vehicle, 0, false)
						elseif fronleftdoors then
							fronleftdoors = false
							SetVehicleDoorShut(vehicle, 0, false)
						end
					elseif scrollIndex == 2 then
						if not frontrightdoors then
							frontrightdoors = true
							SetVehicleDoorOpen(vehicle, 1, false)
						elseif frontrightdoors then
							frontrightdoors = false
							SetVehicleDoorShut(vehicle, 1, false)
						end
					elseif scrollIndex == 3 then
						if not backleftdoors then
							backleftdoors = true
							SetVehicleDoorOpen(vehicle, 2, false)
						elseif backleftdoors then
							backleftdoors = false
							SetVehicleDoorShut(vehicle, 2, false)
						end
					elseif scrollIndex == 4 then
						if not backrightdoors then
							backrightdoors = true
							SetVehicleDoorOpen(vehicle, 3, false)
						elseif backrightdoors then
							backrightdoors = false
							SetVehicleDoorShut(vehicle, 3, false)
						end
					elseif scrollIndex == 5 then
						fronleftdoors = true
						frontrightdoors = true
						backleftdoors = true
						backrightdoors = true
						trunk = true
						hood = true
						SetVehicleDoorOpen(vehicle, 0, false)
						SetVehicleDoorOpen(vehicle, 1, false)
						SetVehicleDoorOpen(vehicle, 2, false)
						SetVehicleDoorOpen(vehicle, 3, false)
						SetVehicleDoorOpen(vehicle, 4, false)
						SetVehicleDoorOpen(vehicle, 5, false)
					elseif scrollIndex == 6 then
						fronleftdoors = false
						frontrightdoors = false
						backleftdoors = false
						backrightdoors = false
						trunk = false
						hood = false
						SetVehicleDoorsShut(vehicle)
					elseif scrollIndex == 7 then
						if not trunk then
							trunk = true
							SetVehicleDoorOpen(vehicle, 5, false)
						elseif trunk then
							trunk = false
							SetVehicleDoorShut(vehicle, 5, false)
						end
					elseif scrollIndex == 8 then
						if not hood then
							hood = true
							SetVehicleDoorOpen(vehicle, 4, false)
						elseif hood then
							hood = false
							SetVehicleDoorShut(vehicle, 4, false)
						end
					end
				elseif selected == 6 then
					if scrollIndex == 1 then
						if not leftfrontwindows then
							leftfrontwindows = true
							RollUpWindow(vehicle, 0, false)
						elseif leftfrontwindows then
							leftfrontwindows = false
							RollDownWindow(vehicle, 0, false)
						end
					elseif scrollIndex == 2 then
						if not rightfrontwindows then
							rightfrontwindows = true
							RollUpWindow(vehicle, 1, false)
						elseif rightfrontwindows then
							rightfrontwindows = false
							RollDownWindow(vehicle, 1, false)
						end
					elseif scrollIndex == 3 then
						if not leftbackwindow then
							leftbackwindow = true
							RollUpWindow(vehicle, 2, false)
						elseif leftbackwindow then
							leftbackwindow = false
							RollDownWindow(vehicle, 2, false)
						end
					elseif scrollIndex == 4 then
						if not rightbackwindow then
							rightbackwindow = true
							RollUpWindow(vehicle, 3, false)
						elseif rightbackwindow then
							rightbackwindow = false
							RollDownWindow(vehicle, 3, false)
						end
					elseif scrollIndex == 5 then
						leftfrontwindows = true
						rightfrontwindows = true
						leftbackwindow = true
						rightbackwindow = true
						RollDownWindows(vehicle)
					elseif scrollIndex == 6 then
						leftfrontwindows = false
						rightfrontwindows = false
						leftbackwindow = false
						rightbackwindow = false	
						RollUpWindow(vehicle, 0, false)
						RollUpWindow(vehicle, 1, false)
						RollUpWindow(vehicle, 2, false)
						RollUpWindow(vehicle, 3, false)	
					end
				elseif selected == 7 then
					if scrollIndex == 1 then
						if not interiorlights then
							interiorlights = true
							SetVehicleInteriorlight(vehicle, true)
						elseif interiorlights then
							interiorlights = false
							SetVehicleInteriorlight(vehicle, false)
						end
					elseif scrollIndex == 2 then
						if not frontlights then
							frontlights = true
							SetVehicleLights(vehicle, true)
						elseif frontlights then
							frontlights = false
							SetVehicleLights(vehicle, false)
						end
					end
				end
			end)
			lib.showMenu('car_menu')
		end
	end

	function showNotification(nType, msg)
		if Config.Notifications == 'ox' then
			lib.notify({
    			title = 'CARMENU',
			    description = msg,
			    type = nType
			})
		elseif Config.Notifications == 'esx' then
			ESX.ShowNotification(msg, nType, 4000, 'CARMENU')
		elseif Config.Notifications == 'pnotify' then
			exports.pNotify:SendNotification({
            	text = 'CARMENU - ' .. msg,
	            type = nType,
    	        timeout = 4000,
        	    layout = "centerLeft",
            	queue = "left"
        	})
		elseif Config.Notifications == 'cd' then
			TriggerEvent('cd_notifications:Add', {
    			title = 'CARMENU', 
    			message = msg,
    			type = nType, --'success | warning | error | info | dark'.
    			options = {
        			duration = 4, --(in seconds) How long should the notification last?
    			}
			})
		elseif Config.Notifications == 'mythic' then
			exports['mythic_notify']:DoHudText(nType, "CARMENU - " .. msg)
		end
	end
-- end


	Wait(500)
	RegisterKeyMapping('carmenu', Locale('open_carmenu'), 'keyboard', Config.OpenCarMenu)
	RegisterKeyMapping('cruisercontrol', Locale('cruise_control'), 'keyboard', Config.CruiserControl)
	RegisterKeyMapping('frontcruisercontrol', Locale('front_cruise_control'), 'keyboard', Config.FrontCruiseSpeedControl)