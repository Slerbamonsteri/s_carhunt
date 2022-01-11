local ESX
local foundCars = 'enter webhook here'
local printCoords = 'enter webhook here'
local usingDate = false -- [Boolean] set to true if you want to have the carhunt only available during 18:00 - 23:59
local secret = 'asdasd' .. math.random(1111, 9999) .. 'asdasd'
local triggerSafe = secret
local sync = false
local empty = false
local spawned = false

function Init()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    repeat Wait(10) until ESX ~= nil
    TriggerEvent('s_carhunt:getcar')
end

Init()

RegisterServerEvent('s_carhunt:sSync', function(sync)
    local times = 4
    while not sync do
        Wait(1000)
        times = times - 1
        if times == 1 then
            TriggerClientEvent('s_carhunt:cSync', -1, sync)
        elseif times == 0 then
            break
        end
    end
end)

--[[ 
    Table structure: { 
        pos = vector4 [Position where the car will be spawned], 
        name = string [Display name, unique field],
        model = string [Car model]
    };
    All fields are required.
]]--
local carCoords = { 
    [1] = { pos = vector4(-420.2901, 1064.149, 323.1575, 70.86614), name = "harborbridge", model = 'rmode63s' },
    [2] = { pos = vector4(-1112.941, 584.6901, 103.6718, 116.2205), name = "somewhere1", model = 'mgt' },
    [3] = { pos = vector4(137.7473, -2071.7979, 16.8872, 53.9099), name = "harborbridge", model = 'italia458' },
    [4] = { pos = vector4(955.5502, -2533.0940, 27.5368, 81.9143), name = "somewhere1", model = 'evo9mr' },
    [5] = { pos = vector4(-1213.688, -1781.156, 3.22998, 334.4882), name = "somewhere3", model = 'bmci' },
    [6] = { pos = vector4(1370.2863, 4308.9180, 37.3115, 252.6260), name = "somewhere8", model = 'rt70' }, 
    [7] = { pos = vector4(-676.6814, 5795.8232, 16.5660, 247.8438), name = "somewhere9", model = 'skyline' }, 
    [8] = { pos = vector4(110.4879, 6627.2603, 31.0233, 223.5994), name = "somewhere10", model = 'bnr32' }, 
}

RegisterServerEvent('s_carhunt:getcar', function()
    if #carCoords > 0 then
        local randomCar = math.random(1, #carCoords)
        if not spawned then
            spawned = true
            info = {
                coords = carCoords[randomCar].pos,
                model = carCoords[randomCar].model,
                triggerSafe = triggerSafe
            }
            table.remove(carCoords, randomCar)
            ESX.RegisterServerCallback("s_carhunt:coords", function(source, cb)
                if not empty then
                    if usingDate then
                        if os.date("%X") >= '18:00' and os.date("%X") <= '23:59' then
                            cb(info)
                        else
                            print('Carhunt starts at 18.00')
                        end
                    else
                        cb(info)
                    end
                else
                    TriggerClientEvent('s_carhunt:cantspawn', -1)
                    print('table is empty -- Waiting for server restart / script restart')
                    carLog(1494412, 'Table empty', 'Seems as if all vehicles are claimed for now', 'CarHunt')
                end
            end)
        end
    else
        empty = true
        return
    end
end)

RegisterServerEvent(triggersafe .. 's_carhunt:setVehicle')
AddEventHandler(triggersafe .. 's_carhunt:setVehicle', function(vehicleProps, coordsOld, car)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
    spawned = false
    sync = true
    TriggerEvent('s_carhunt:getcar')

    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
    {
        ['@owner'] = xPlayer.identifier,
        ['@plate'] = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps)
    }, function()
        TriggerClientEvent('esx:showNotification', src, 'Vehicle with license plate: [' .. string.upper(vehicleProps.plate) .. '] is now yours!')
        Wait(1000)
        sync = false
        TriggerEvent('s_carhunt:sSync', sync)
    end)
    local carPlate = vehicleProps.plate
    carLog(1494412, 'Found Car', ''..GetPlayerName(source).. ' | Found vehicle: ' ..carPlate.. ' | in coordinates: **' ..coordsOld.. '** | Vehicle name: **' ..car..'**', 'CarHunt')
end)

RegisterCommand("pc", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerPed = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(playerPed)
    local pedHeading = GetEntityHeading(playerPed)

    if xPlayer.getGroup() == 'mod' or xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        logCoordinates(
            1494412, 
            'Coordinates: ', 
            'Player: **' .. GetPlayerName(source) .. '** \n**'.. vector3(pedCoords.x, pedCoords.y, pedCoords.z) .. '** \n **' .. vector4(pedCoords.x, pedCoords.y, pedCoords.z, pedHeading) .. '**', 
            'pedCoords'
        )
    else
       xPlayer.showNotification('Insufficient permissions to use this command!')
    end
end, false)

function logCoordinates(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
              	["text"] = footer,
              },
          }
      }
    PerformHttpRequest(printCoords, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function carLog(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
            	["text"] = footer,
              },
          }
      }
    PerformHttpRequest(foundCars, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
