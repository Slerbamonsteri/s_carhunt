local ESX
local canDraw = false
local cantSpawn = false
local data = {}
local triggerSafe = ""
local vehicle, livery

function Init()
	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	repeat Wait(10) until ESX ~= nil
end

Init()

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	Wait(5000)
	TriggerEvent('s_carhunt:GetServerCoords')
end)

RegisterNetEvent('s_carhunt:cSync', function(sync)
	drawing = false
	ESX.ShowNotification('<span style="color:blue">CarHunt:</span> <br>Vehicle has been claimed! <br>Next vehicle will spawn within 10sec.')
	TriggerEvent('s_carhunt:GetServerCoords')
end)

RegisterNetEvent('s_carhunt:cantSpawn', function()
	cantSpawn = true
end)

-- This function will get coordinates of the vehicle and claim position from server
RegisterNetEvent('s_carhunt:GetServerCoords', function()
	ESX.TriggerServerCallback('s_carhunt:coords', function(info)
		data = info
		triggerSafe = info.triggerSafe
		Wait(1000)
		spawnAmbient(data.coords)
		drawing = true
		Markers()
	end)
end)

function Markers()
	while true do
		local pedCoords = GetEntityCoords(PlayerPedId())
		local coords = vector3(data.coords.x, data.coords.y, data.coords.z)
		local dist = #(pedCoords - coords)
		local w = 2000
		if dist <= 4 then
			w = 5
			if drawing then
				s = 5
				Draw3DText(coords.x, coords.y, coords.z + 1.23, '~s~[~g~E~s~] ~g~Claim~s~ this vehicle')
				if IsControlJustReleased(0, 38) then
					if IsPedInAnyVehicle(PlayerPedId(), true) then
						vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
						local vehPed = GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1)
						if vehPed == PlayerPedId() then
							prepare()
							drawing = false
						else
							ESX.ShowNotification('You have to be in the drivers seat!')
						end
					else
						ESX.ShowNotification('Get in the vehicle first')
					end
				end
			else
				break
			end
		end
		Wait(w)
	end
end

function prepare()
	drawing = false
	DoScreenFadeOut(1000)
	Wait(1000)
	DeleteVehicle(vehicle)
	claimcar()
	Wait(1000)
	DoScreenFadeIn(1000)
	PlaySoundFrontend(-1, "Mission_Pass_Notify", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", 1)
	Scaleforms()
	TriggerServerEvent('s_carhunt:getcar')
end

function spawnAmbient(coords)
	RequestModel(data.model)
	repeat Wait(10) until HasModelLoaded(data.model)
	while true do
		local w = 100
		local pedCoords = GetEntityCoords(PlayerPedId())
		local claimCoords = vector3(data.coords.x, data.coords.y, data.coords.z)
		local dist = #(pedCoords - claimCoords)
		if dist < 30 then
			if not cantSpawn then
				if ESX.Game.IsSpawnPointClear(claimCoords, 3.0) then
					spawnvehicle = CreateVehicle(data.model, data.coords, false, true)
					PlaceObjectOnGroundProperly(spawnvehicle)
					Wait(1000)
					FreezeEntityPosition(spawnvehicle, true)
					SetEntityVisible(spawnvehicle, true, 0)
					SetEntityCollision(spawnvehicle, true)
					livery = SetVehicleLivery(spawnvehicle, 0)
					newPlate = exports.esx_vehicleshop:GeneratePlate()
					local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
					--local vehicleProps = exports.renzu_customs:GetVehicleProperties(spawnvehicle)
					vehicleProps.plate = newPlate
					vehicleProps.livery = livery
					SetVehicleNumberPlateText(spawnvehicle, newPlate)
				end
				break
			end
		end
		Wait(w)
	end
end

function claimcar()
	newVehicle = CreateVehicle(data.model, data.coords, true, true)
	repeat Wait(100) until DoesEntityExist(newVehicle)
	if DoesEntityExist(newVehicle) then
		SetEntityVisible(newVehicle, true, true)
		SetEntityCollision(newVehicle, true)
		livery = SetVehicleLivery(newVehicle, 0)
		--local vehicleProps = exports.renzu_customs:GetVehicleProperties(newVehicle)
		local vehicleProps = ESX.Game.GetVehicleProperties(newVehicle)
		vehicleProps.plate = newPlate
		vehicleProps.livery = livery
		SetVehicleNumberPlateText(newVehicle, newPlate)
		TaskWarpPedIntoVehicle(PlayerPedId(), newVehicle, -1)
		TriggerServerEvent(triggerSafe .. 's_carhunt:setVehicle', vehicleProps, coords, data.model)
	end
end

function Scaleforms()
	local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
	while not HasScaleformMovieLoaded(scaleform) do
		Wait(10)
	end
	canDraw = 2000
	BeginScaleformMovieMethod(scaleform, "SHOW_WEAPON_PURCHASED")
	PushScaleformMovieMethodParameterString("~y~Congratulations!~s~")
	PushScaleformMovieMethodParameterString("~g~Vehicle~s~ is now yours!")
	ScaleformMovieMethodAddParamInt(5)
	EndScaleformMovieMethod()
	while canDraw > 0 do
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		w = 5
		Wait(w)
		if canDraw then
			canDraw = canDraw - 10
		end
	end

end

function Draw3DText(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 159)
end
