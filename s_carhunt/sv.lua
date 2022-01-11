ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local foundcars = 'enter webhook here'
local printcoords = 'enter webhook here'

local secret = 'asdasd'..math.random(1111,9999)..'asdasd'

triggersafe = secret

local sync = false


CreateThread(function()
    TriggerEvent('s_carhunt:getcar')
end)


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


local carcoords = { --add more if u want, remember to follow logic here (name doesnt really matter as long as it is unique)
[1] = { pos = vector4(-420.2901, 1064.149, 323.1575, 70.86614), name = "harborbridge", model = 'rmode63s' }, --
[2] = { pos = vector4(-1112.941, 584.6901, 103.6718, 116.2205), name = "somewhere1", model = 'mgt' }, --
[3] = { pos = vector4(137.7473, -2071.7979, 16.8872, 53.9099), name = "harborbridge", model = 'italia458' },
[4] = { pos = vector4(955.5502, -2533.0940, 27.5368, 81.9143), name = "somewhere1", model = 'evo9mr' },
[5] = { pos = vector4(-1213.688, -1781.156, 3.22998, 334.4882), name = "somewhere3", model = 'bmci' }, --
[6] = { pos = vector4(1370.2863, 4308.9180, 37.3115, 252.6260), name = "somewhere8", model = 'rt70' }, 
[7] = { pos = vector4(-676.6814, 5795.8232, 16.5660, 247.8438), name = "somewhere9", model = 'skyline' }, 
[8] = { pos = vector4(110.4879, 6627.2603, 31.0233, 223.5994), name = "somewhere10", model = 'bnr32' }, 
}

local empty = false
RegisterServerEvent('s_carhunt:getcar',function()
    if #carcoords > 0 then
        rc = math.random(1, #carcoords)
        for i,v in ipairs(carcoords) do
            Wait(50)
            if v.name == carcoords[rc].name then
                if not spawned then
                    spawned = true
                    info = {
                        coords = v.pos,
                        model = v.model,
                        triggersafe = triggersafe
                    }
                    table.remove(carcoords, i)
                    ESX.RegisterServerCallback("s_carhunt:coords", function(source, cb)
                        if not empty then
                            --if os.date("%X") >= '18:00' and os.date("%X") <= '23:59' then -- remove this line if you dont want to use specific times when script should start (I used this between automatic restarts so it properly started for players
                                cb(info)
                                cantspawn = false
                            --else --Remove this line if you removed os.date
                            --    print('Autojahti alkaa klo 18:00') --Remove this line if you removed os.date
                           --end -- Remove this line if you removed os.date
                        else
                            cantspawn = true
                            TriggerClientEvent('s_carhunt:cantspawn', -1, cantspawn)
                            print('table is empty -- Waiting for server restart / script restart')
                            carLog(1494412, 'Table empty', 'Seems as if all vehicles are claimed for now', 'CarHunt')
                        end
                    end)
                break
                end
            end
        end
    else
        empty = true
        return
    end
end)


RegisterServerEvent(triggersafe..'s_carhunt:setVehicle')
AddEventHandler(triggersafe..'s_carhunt:setVehicle', function(vehicleProps, coordsOLD, auto)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
    auto22 = auto
    spawned = false
    sync = true
    TriggerEvent('s_carhunt:getcar')
    MySQL.Async.execute('INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (@owner, @plate, @vehicle)',
    {
        ['@owner']   = xPlayer.identifier,
        ['@plate']   = vehicleProps.plate,
        ['@vehicle'] = json.encode(vehicleProps)
    }, function ()
        TriggerClientEvent('esx:showNotification', _source, 'Vehicle with license plate: ['.. string.upper(vehicleProps.plate).. '] is now yours!')
        Wait(1000)
        sync = false
        TriggerEvent('s_carhunt:sSync', sync)
    end)
    local autokilpi = vehicleProps.plate
    carLog(1494412, 'Found Car', ''..GetPlayerName(source).. ' | Found vehicle: ' ..autokilpi.. ' | in coordinates: **' ..coordsOLD.. '** | Vehicle name: **' ..auto22..'**', 'CarHunt')
end)


--################################ Threw in easy way to print vector3 / vector4 coordinates ###############################################--

RegisterCommand("pc", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    local pelaaja = GetPlayerPed(source)
    local pedcoords = GetEntityCoords(pelaaja)
    local pedheading = GetEntityHeading(pelaaja)
    x,y,z = pedcoords.x, pedcoords.y, pedcoords.z
    h = pedheading
    if xPlayer.getGroup() == 'mod' or xPlayer.getGroup() == 'admin' or xPlayer.getGroup() == 'superadmin' then
        koordlog(1494412, 'Coordinates: ', 'Player: **' ..GetPlayerName(source).. '** \n**'..vector3(x,y,z).. '** \n **' ..vector4(x,y,z,h).. '**', 'PedCoords')
    else
       xPlayer.showNotification('Ei oikeuksia komentoon')
    end
end, false)

function koordlog(color, name, message, footer)
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
    PerformHttpRequest(printcoords, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

--#######################################################################################################


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
    PerformHttpRequest(foundcars, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
