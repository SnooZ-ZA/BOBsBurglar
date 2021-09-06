ESX             = nil
local PlayerData = {}
picking  = false
MenuOpened = false
OnDuty = false
CurrentJob = nil
LastVehicle = 0

MainBlip = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	ESX.PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand("coords", function()
	print(GetEntityCoords(PlayerPedId()))
end)

function OpenLocker()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "locker_menu", {
		title = Config.TranslationList[Config.Translation]["LOCKER_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["WORK_CLOTHES"], value = "work_clothes"},
			{label = Config.TranslationList[Config.Translation]["NORMAL_CLOTHES"], value = "normal_clothes"}
		}
	}, 
	function(Data, LockerMenu) -- Selection
		if Data.current.value == "normal_clothes" then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin, jobSkin)
				local isMale = CurrentSkin.sex == 0

				TriggerEvent('skinchanger:loadDefaultModel', isMale, function()
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(CurrentSkin)
						TriggerEvent('skinchanger:loadSkin', CurrentSkin)
						OnDuty = false
					end)
				end)
			end)
		elseif Data.current.value == "work_clothes" then
			WorkClothesData = {}

			TriggerEvent('skinchanger:getSkin', function(CurrentSkin)
				if CurrentSkin.sex == 0 then
					WorkClothesData = Config.Uniforms.Male
				else
					WorkClothesData = Config.Uniforms.FeMale
				end

				if WorkClothesData ~= {} then
					TriggerEvent('skinchanger:loadClothes', CurrentSkin, WorkClothesData)
				end

				OnDuty = true
			end)
		end

		LockerMenu.close()
		MenuOpened = false
	end, 
	function(Data, LockerMenu) -- Close
		LockerMenu.close()
		MenuOpened = false
	end)
end

function OpenGarage()
	MenuOpened = true

	MenuList = {}

	for Index, CurrentVehicle in pairs(Config.Vehicles) do
		table.insert(MenuList, {label = CurrentVehicle.Name, value = CurrentVehicle.SpawnName})
	end

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_menu", {
		title = Config.TranslationList[Config.Translation]["GARAGE_MENU"],
		align = "bottom-right",
		elements = MenuList
	}, 
	function(Data, GarageMenu) -- Selection
		for Index, CurrentVehicle in pairs(Config.Vehicles) do
			if Data.current.value == CurrentVehicle.SpawnName then
				VehicleHash = GetHashKey(CurrentVehicle.SpawnName)

				RequestModel(VehicleHash)

				Citizen.CreateThread(function()
					TimeWaited = 0

					while not HasModelLoaded(VehicleHash) do
						Citizen.Wait(100)
						TimeWaited = TimeWaited + 100

						if TimeWaited >= 5000 then
							ESX.ShowNotification(Config.TranslationList[Config.Translation]["GARAGE_PROBLEM"], false, true, 90)
							break
						end
					end

					NewVehicle = CreateVehicle(
						VehicleHash, 
						Config.VehicleSpawn.X, Config.VehicleSpawn.Y, Config.VehicleSpawn.Z,
						Config.VehicleSpawn.Heading,
						true, false
					)

					if (Config.LicensePlate ~= "") then
						SetVehicleNumberPlateText(NewVehicle, Config.LicensePlate)
					end

					SetVehicleOnGroundProperly(NewVehicle)
					SetModelAsNoLongerNeeded(VehicleHash)

					TaskWarpPedIntoVehicle(PlayerPedId(), NewVehicle, -1)
				end)
			end
		end

		GarageMenu.close()
		MenuOpened = false
	end, 
	function(Data, GarageMenu) -- Close
		GarageMenu.close()
		MenuOpened = false
	end)
end

function OpenMenu()
	MenuOpened = true

	ESX.UI.Menu.Open("default", GetCurrentResourceName(), "menu_menu", {
		title = Config.TranslationList[Config.Translation]["MENU_MENU"],
		align = "bottom-right",
		elements = {
			{label = Config.TranslationList[Config.Translation]["MENU_NEW"], value = "new_job"},
			{label = Config.TranslationList[Config.Translation]["MENU_CANCEL"], value = "cancel_job"}
		}
	}, 
	function(Data, MenuMenu) -- Selection
		if Data.current.value == "new_job" and isNight() then
			if CurrentJob == nil then
				ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~b~Stand by for Location!')
				local wait = math.random(20000, 40000)
				Citizen.Wait(wait)
				RandomJob = Config.Jobs[math.random(1, #Config.Jobs)]
				
				CurrentJob = {}

				CurrentJob["X"] = RandomJob.X
				CurrentJob["Y"] = RandomJob.Y
				CurrentJob["Z"] = RandomJob.Z
				CurrentJob["H"] = RandomJob.H

				CurrentJob["Blip"] = AddBlipForCoord(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)
				SetBlipSprite(CurrentJob.Blip, 458)
				SetBlipDisplay(CurrentJob.Blip, 4)
				SetBlipScale(CurrentJob.Blip, 1.0)
				SetBlipColour(CurrentJob.Blip, 64)
				SetBlipAsShortRange(CurrentJob.Blip, true)
				BeginTextCommandSetBlipName("STRING")
				AddTextComponentString(Config.JobBlipName)
				EndTextCommandSetBlipName(CurrentJob.Blip)

				SetNewWaypoint(CurrentJob.X, CurrentJob.Y)
				local ModelHash = GetHashKey('p_v_43_safe_s')
				local Prop = CreateObject(ModelHash, 0, 0, 0, true, true, true)
				
                SetEntityCoords(Prop, CurrentJob.X, CurrentJob.Y, CurrentJob.Z, 0, 0, 0, false)
                SetEntityHeading(Prop, CurrentJob.H)
				PlaceObjectOnGroundProperly(Prop)
				Citizen.Wait(100)
                FreezeEntityPosition(Prop, true)

				CurrentJob["Enabled"] = false

				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CREATED"], false, true, 210)
				ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~g~Location Confirmed! Empty the Vault.')
			else
				--ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_ALREADY"], false, true, 90)
				ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~r~Already have a new Location!')
			end
		elseif Data.current.value == "cancel_job" then
			if CurrentJob ~= {} then
				RemoveBlip(CurrentJob.Blip)
				DeleteWaypoint()
				CurrentJob = nil

				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_CANCELED"], false, true, 210)
			else
				ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
			end
		else
		--ESX.ShowNotification(Config.TranslationList[Config.Translation]["NOT_NIGHT"], false, true, 90)
			ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~r~We only work at night ~y~8PM to 5AM! ~r~Call me later!')
		end

		MenuMenu.close()
		MenuOpened = false
	end, 
	function(Data, MenuMenu) -- Close
		MenuMenu.close()
		MenuOpened = false
	end)
end

RegisterNUICallback("main", function(RequestData)
	if RequestData.ReturnType == "EXIT" then
		if CurrentJob ~= {} then
			CurrentJob.Enabled = false

			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	elseif RequestData.ReturnType == "DONE" then
		if CurrentJob ~= {} then
			SetNuiFocus(false, false)
			SendNUIMessage({RequestType = "Visibility", RequestData = false})

			RemoveBlip(CurrentJob.Blip)
			DeleteWaypoint()
			CurrentJob = nil

			TriggerServerEvent('esx_technician_pc:PayMoney', CurrentJob)
			
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["JOB_DONE"], false, true, 210)
		else
			ESX.ShowNotification(Config.TranslationList[Config.Translation]["MENU_NONE"], false, true, 90)
		end
	end
end)

LockerCoords = vector3(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
GarageCoords = vector3(Config.Garage.X, Config.Garage.Y, Config.Garage.Z)
DeleteCoords = vector3(Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z)

Citizen.CreateThread(function() -- Locker
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			PlayerJobInfo = ESX.PlayerData.job

			if PlayerJobInfo ~= nil then
				if PlayerJobInfo.name == "burglar" then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

					if Vdist2(PlayerCoords, LockerCoords) <= 1.5 and PlayerVehicle == 0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["LOCKER_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							if MenuOpened == false then
								OpenLocker()
							end
						end
					end

					-- Blip
					if MainBlip == nil then
						MainBlip = AddBlipForCoord(Config.Locker.X, Config.Locker.Y, Config.Locker.Z)
						SetBlipSprite(MainBlip, 458)
						SetBlipDisplay(MainBlip, 4)
						SetBlipScale(MainBlip, 1.0)
						SetBlipColour(MainBlip, 57)
						SetBlipAsShortRange(MainBlip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(Config.BlipName)
						EndTextCommandSetBlipName(MainBlip)
					end

					-- Circle
					DrawMarker(
						25, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Stripes
					DrawMarker(
						30, -- Type
						Config.Locker.X, Config.Locker.Y, Config.Locker.Z, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						0.75, 0.75, 0.75, -- Scale
						255, 120, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

				else
					if MainBlip ~= nil then
						RemoveBlip(MainBlip)
						MainBlip = nil
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Garage
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				-- Circle
				DrawMarker(
					25, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z - 0.98, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					1.5, 1.5, 1.5, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				-- Car
				DrawMarker(
					36, -- Type
					Config.Garage.X, Config.Garage.Y, Config.Garage.Z, -- Position
					0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
					0.75, 0.75, 0.75, -- Scale
					255, 120, 0, 155, -- Color
					false, true, 2, nil, nil, false -- Extra
				)

				if Vdist2(PlayerCoords, GarageCoords) <= 1.5 and PlayerVehicle == 0 then
					ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["GARAGE_HELP"], true, false, 1)
				
					if IsControlJustPressed(1, 51) then
						if MenuOpened == false then
							OpenGarage()
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Deleter
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true then
				PlayerCoords = GetEntityCoords(PlayerPedId())
				PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())

				IsVehicle = false

				for Index, CurrentVehicle in pairs(Config.Vehicles) do
					if IsVehicleModel(PlayerVehicle, GetHashKey(CurrentVehicle.SpawnName)) then
						IsVehicle = true
					end
				end

				if IsVehicle == true then
					-- Circle
					DrawMarker(
						25, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.5, 3.5, 3.5, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Car
					DrawMarker(
						36, -- Type
						Config.VehicleDelete.X, Config.VehicleDelete.Y, Config.VehicleDelete.Z + 0.5, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						3.0, 3.0, 3.0, -- Scale
						255, 0, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					if Vdist2(PlayerCoords, DeleteCoords) <= 3.0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["DELETE_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
							SetEntityAsMissionEntity(PlayerVehicle, true, true)
							DeleteVehicle(PlayerVehicle)
						end
					else
						if LastVehicle ~= PlayerVehicle then
							LastVehicle = PlayerVehicle
							ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["MENU_HELP"], false, false, 5000)
						end
					end

					if IsControlJustPressed(1, 10) then
						if MenuOpened == false then
							OpenMenu()
						end
					end
				else
					LastVehicle = 0
				end
			end
		end
	end
end)

Citizen.CreateThread(function() -- Jobs
	while true do
		Citizen.Wait(1)

		if ESX ~= nil then
			if OnDuty == true and CurrentJob ~= nil then
				if CurrentJob.Enabled == false then
					PlayerCoords = GetEntityCoords(PlayerPedId())
					PlayerVehicle = GetVehiclePedIsIn(PlayerPedId())
					JobCoords = vector3(CurrentJob.X, CurrentJob.Y, CurrentJob.Z)

					-- Circle
					DrawMarker(
						25, -- Type
						CurrentJob.X, CurrentJob.Y, CurrentJob.Z - 0.98, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						1.5, 1.5, 1.5, -- Scale
						0, 255, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)

					-- Question Mark
					DrawMarker(
						32, -- Type
						CurrentJob.X, CurrentJob.Y, CurrentJob.Z, -- Position
						0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -- Orientation
						0.75, 0.75, 0.75, -- Scale
						0, 255, 0, 155, -- Color
						false, true, 2, nil, nil, false -- Extra
					)
					
					
					if Vdist2(PlayerCoords, JobCoords) <= 1.5 and PlayerVehicle == 0 then
						ESX.ShowHelpNotification(Config.TranslationList[Config.Translation]["JOB_HELP"], true, false, 1)
					
						if IsControlJustPressed(1, 51) then
								picking  = true
								local res = exports["BOBsBurglar"]:createSafe({math.random(0,99), math.random(0,99), math.random(0,99)})
								
								if res == true then
									
									local x = GetClosestObjectOfType(PlayerCoords, 1.5, GetHashKey('p_v_43_safe_s'), false, false, false)
									local entity = nil
									if DoesEntityExist(x) then
									entity = x
									DeleteObject(entity)
									end
									Citizen.Wait(100)
									local ModelHash2 = GetHashKey('v_ilev_gangsafe')
									local Prop2 = CreateObject(ModelHash2, 0, 0, 0, true, true, true)
				
									SetEntityCoords(Prop2, CurrentJob.X, CurrentJob.Y, CurrentJob.Z -1, 0, 0, 0, false)
									SetEntityHeading(Prop2, CurrentJob.H)
									PlaceObjectOnGroundProperly(Prop2)
									Citizen.Wait(100)
									FreezeEntityPosition(Prop2, true)
									TriggerServerEvent('esx_burglar:PayMoney', CurrentJob)
									RemoveBlip(CurrentJob.Blip)
									DeleteWaypoint()
									CurrentJob = nil
									picking  = false
									Citizen.Wait(10000)
									DeleteObject(Prop2)
									
								else
									picking  = false
									ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~r~Failed! You triggerd an alarm!')
									Citizen.Wait(1000)											
									
										if not DoesEntityExist(goon) then
										RequestModel("s_m_y_dealer_01")
											while not HasModelLoaded("s_m_y_dealer_01") do
											Wait(10)
											end
											local ped = PlayerPedId()
											local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.2, 0.0)
											local heading = GetEntityHeading(ped)
											local pedcoords = GetEntityCoords(ped)
											
													local gooninfo = {
															x= coords.x,
															y= coords.y,
															z= coords.z,
															h= heading,
															}
															
											goon = CreatePed(4, "s_m_y_dealer_01", gooninfo.x, gooninfo.y - 1, gooninfo.z, gooninfo.h, false, true)
											SetPedFleeAttributes(goon, 0, 0)
											SetPedCombatAttributes(goon, 46, 1)
											SetPedCombatAbility(goon, 100)
											SetPedCombatMovement(goon, 2)
											SetPedCombatRange(goon, 2)
											SetPedKeepTask(goon, true)
											GiveWeaponToPed(goon, GetHashKey('WEAPON_GOLFCLUB'),1,false,true)
										end
										local playerped = PlayerPedId()					
										AddRelationshipGroup('HomeOwner')
										AddRelationshipGroup('PlayerPed')
										SetPedRelationshipGroupHash(goon, 'HomeOwner')
										SetRelationshipBetweenGroups(5,GetPedRelationshipGroupDefaultHash(playerped),'HomeOwner')
										SetRelationshipBetweenGroups(5,'HomeOwner',GetPedRelationshipGroupDefaultHash(playerped))
										SetPedCombatRange(goon,2)
											Citizen.Wait(20000)
											if DoesEntityExist(goon) then
											DeleteEntity(goon)
											end
								end
								
								
						end
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        while picking do
            Citizen.Wait(0)

			text = "LEFT [~b~A~s~] RIGHT [~g~D~s~] ACCEPT [~y~W~s~] CANCEL [~r~S~s~]"

			DrawGenericTextThisFrame()

			SetTextEntry("STRING")
			AddTextComponentString(text)
			DrawText(0.5, 0.8)
        end
    end
end)

function DrawGenericTextThisFrame()
	SetTextFont(4)
	SetTextScale(0.0, 0.5)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(true)
end

function ShowAdvancedNotification(icon, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, 4, sender, title, text)
    DrawNotification(false, true)
end

function isNight()
 local hour = GetClockHours()
 if hour > 19 or hour < 5 then
  return true
 end
end

AddEventHandler('esx:onPlayerDeath', function(data)
	if CurrentJob ~= {} then
	RemoveBlip(CurrentJob.Blip)
	DeleteWaypoint()
	CurrentJob = nil
	ShowAdvancedNotification('CHAR_JIMMY', 'BOSS', 'JIMMY', '~r~Mission Failed!')
	end
	if DoesEntityExist(goon) then
	DeleteEntity(goon)
	end
end)
