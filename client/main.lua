local Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["F"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

ESX = nil
local currentActionTime = nil
local currentItem = nil
local isActionStarted = false
local isActionFailed = false
local isInLocation = false
local currentStep = 0
local currentAction = nil
local x, y, z = nil
local weedPlants = {}
local spawnedWeeds = 0
local plants = {}
local currentowo = nil


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID, current

    	for k,v in pairs(plants) do
    		if GetDistanceBetweenCoords(coords, GetEntityCoords(v.obj), false) < 1 then
    			nearbyObject, nearbyID, current = v.obj, v.id, options[v.name]
    		end
    	end

    	if nearbyObject and IsPedOnFoot(playerPed) then
    		if not isPickingUp then
    			ESX.ShowHelpNotification(_U('weed_pickupprompt'))
    		end

    		if IsControlJustReleased(0, 38) and not isPickingUp then
    			isPickingUp = true

    			ESX.TriggerServerCallback('esx_planting_sync:canPickUp', function(canPickUp)
    				if canPickUp then
    					TaskStartScenarioInPlace(playerPed, 'world_human_gardener_plant', 0, false)

    					Citizen.Wait(2000)
    					ClearPedTasks(playerPed)
    					Citizen.Wait(1500)
    		
    					ESX.Game.DeleteObject(nearbyObject)
    		
    					TriggerServerEvent("esx_planting_sync:removeplants", nearbyID)
    		
    					TriggerServerEvent('esx_planting_sync:statusSuccess', current.success_msg, 100, 300, current.success_item)
    				else
    					ESX.ShowNotification(_U('weed_inventoryfull'))
    				end

    				isPickingUp = false
    			end, current.success_item)
    		end
    	else
    		Citizen.Wait(500)
        end
	end
end)

RegisterNetEvent("esx_planting_sync:RequestStart")
AddEventHandler("esx_planting_sync:RequestStart", function(item_name, time)
    currentItem = options[item_name]
    currentActionTime = time
    isInLocation = false
    local playerPed = GetPlayerPed(-1)

    for k, Cords in pairs(currentItem.cords) do
        if IsPedInAnyVehicle(playerPed) then
            exports.pNotify:SendNotification({text = "不要在車子裡面!!", type = "error", layout = "centerLeft", timeout = 2000})
            do return end
        end
        if isActionStarted then
            exports.pNotify:SendNotification({text = "請等待上一次結束", type = "error", layout = "centerLeft", timeout = 2000})
            do return end
        end
        if GetDistanceBetweenCoords (Cords.x, Cords.y, Cords.z, GetEntityCoords(playerPed)) <= Cords.distance then
            isInLocation = true
            isActionStarted = true
            ESX.UI.Menu.CloseAll()
            TriggerServerEvent('esx_planting_sync:RemoveItem', item_name)
            exports.pNotify:SendNotification({text = currentItem.start_msg, type = "success", layout = "centerLeft", timeout = 2000})

            local coords    = GetEntityCoords(playerPed)
            local forward   = GetEntityForwardVector(playerPed)
            x, y, z = table.unpack(coords)

            for k, StartAnims in pairs(currentItem.animations_end) do
                if currentActionTime == 0 then
                    FreezeEntityPosition(playerPed, false)
                    do return end
                end
                startAnim(StartAnims.lib, StartAnims.anim)
                Citizen.Wait(StartAnims.timeout)
            end
			
            RequestModel(currentItem.object)
            while not HasModelLoaded(currentItem.object) do
                Citizen.Wait(1)
            end
            ESX.Game.SpawnObject(currentItem.object, {
                x = x,
                y = y,
                z = z - currentItem.first_step
            })
	 
            currentStep = 1
            TriggerEvent('esx_planting_sync:StartGrowing', currentStep, coords)
        end
    end
    if not isInLocation then
        exports.pNotify:SendNotification({text = _U('wrong_place'), type = "error", layout = "centerLeft", timeout = 2000})
    end
end)

RegisterNetEvent("esx_planting_sync:StartGrowing")
AddEventHandler("esx_planting_sync:StartGrowing", function(currentStep, coords)
            while currentStep < currentItem.steps do
                --exports['progressBars']:startUI(2800, currentItem.progess_msg)
                Citizen.Wait(3000)
                spawnNextObject(currentItem.object, currentItem.grow[currentStep], x, y, z)
                currentStep = currentStep + 1
                Citizen.Wait(2000)
            end
                Citizen.Wait(1000)
                --exports['progressBars']:startUI(2800, currentItem.progess_msg)
                Citizen.Wait(3000)
                deleteLastObject(currentItem.object, x, y, z)
                TriggerServerEvent("esx_planting_sync:addplants", coords, currentItem.name)
                isActionStarted = false
                currentStep = 0
end)

RegisterCommand("fuckyou", function(source, args, rawCommand)
    -- If the source is > 0, then that means it must be a player.
    PlaceObjectOnGroundProperly(args[1])
end, false)

RegisterNetEvent("esx_planting_sync:RemovePlants")
AddEventHandler("esx_planting_sync:RemovePlants", function(id)
    ESX.Game.DeleteObject(plants[id].obj)
    plants[id] = nil
end)

RegisterNetEvent("esx_planting_sync:CreatePlants")
AddEventHandler("esx_planting_sync:CreatePlants", function(plantId, plantcoord, item_name)
    currentowo = options[item_name]
    plantObject = false
    ESX.Game.SpawnLocalObject(currentowo.end_object, plantcoord, function(obj)
        plantObject = obj
    end)
    while not plantObject do
        Citizen.Wait(10)
    end
    PlaceObjectOnGroundProperly(plantObject)
    FreezeEntityPosition(plantObject, true)

    plants[plantId] = {
        id = plantId,
        obj = plantObject,
        coords = plantcoord,
        name = item_name
    }

end)

-- function

function startAnim(lib, anim)
    if isActionStarted then
        Citizen.CreateThread(function()
            RequestAnimDict(lib)
            while not HasAnimDictLoaded( lib) do
                Citizen.Wait(1)
            end
            TaskPlayAnim(GetPlayerPed(-1), lib ,anim ,8.0, -8.0, -1, 0, 0, false, false, false )
        end)
    end
end

function spawnEndObject(object_start, object_end, x, y, z)
    if isActionStarted then
        deleteLastObject(object_start, x, y, z)
    end
end

function deleteLastObject(object_end, x, y, z)
    ESX.Game.DeleteObject(ESX.Game.GetClosestObject(object_end, {
        x = x,
        y = y,
        z = z
    }))
end

function spawnNextObject(object_start, grow, x, y, z)
    if isActionStarted then
        ESX.Game.DeleteObject(ESX.Game.GetClosestObject(object_start, {
            x = x,
            y = y,
            z = z - grow
        }))
        ESX.Game.SpawnObject(object_start, {
            x = x,
            y = y,
            z = z - grow
        })
    end
end

function cancelAnim()
    ClearPedTasksImmediately(GetPlayerPed(-1))
    ClearPedTasks(GetPlayerPed(-1))
    ClearPedSecondaryTask(GetPlayerPed(-1))
end

function stopEvent()
    currentStep = 0
    isActionFailed = true
    currentActionTime = 0
    cancelAnim()
    FreezeEntityPosition(GetPlayerPed(-1), false)
    spawnEndObject(currentItem.object, currentItem.end_object, x, y, z)
    x = nil
    isActionStarted = false
    exports.pNotify:SendNotification({text = _U('cancel'), type = "info", layout = "centerLeft", timeout = 2000})
    exports.pNotify:SendNotification({text = currentItem.fail_msg, type = "error", layout = "centerLeft", timeout = 2500})
end