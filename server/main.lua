ESX = nil
local lastTime = nil
local spawnedWeeds = 0
local Plants = {}
local plantid = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    xPlayer.triggerEvent('esx_planting_sync:createMissingPlants', Plants)
end)

for item_name in pairs(options) do
    ESX.RegisterUsableItem(item_name, function(source)
        local _source = source
		TriggerClientEvent('esx_planting_sync:RequestStart', _source, item_name, lastTime)
    end)
end

RegisterServerEvent("esx_planting_sync:addplants")
AddEventHandler("esx_planting_sync:addplants", function(coords, name)
    local plantid = (spawnedWeeds == 65635 and 0 or spawnedWeeds + 1)
    local currentitem = options[name]
    math.randomseed(os.time())
    local amount = math.random(currentitem.range[1], currentitem.range[2])
    local label = ('~y~%s~s~ [~b~%s~s~]'):format(currentitem.label[1], amount)
    
    Plants[plantid] = {
        id = plantid,
        name = name,
        coords = coords,
        label  = label,
        amount = amount
    }

    TriggerClientEvent('esx_planting_sync:CreatePlants', -1, plantid, coords, name, label)
    spawnedWeeds = plantid
end)

RegisterServerEvent("esx_planting_sync:RemoveItem")
AddEventHandler("esx_planting_sync:RemoveItem", function(item_name)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    xPlayer.removeInventoryItem(item_name, 1)
end)

RegisterCommand('optionsread',function(source, args, rawCommand)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local name = args[1]
    local currentitem =  options[name]
    xPlayer.showNotification(currentitem.label[1])
end ,false)


RegisterNetEvent('esx_planting_sync:onPickup')
AddEventHandler('esx_planting_sync:onPickup', function(id)
local plant, xPlayer, success = Plants[id], ESX.GetPlayerFromId(source)

if plant then
    local currentitem = options[plant.name]
    local item = currentitem.success_item
    local amount = plant.amount
    if xPlayer.canCarryItem(item, amount) then
        xPlayer.addInventoryItem(item, amount)
        success = true
    else
        xPlayer.showNotification(_U('weed_inventoryfull'))
        success = false
    end

        if success then
            Plants[id] = nil
            TriggerClientEvent('esx_planting_sync:RemovePlants', -1, id)
        end
    end
end)