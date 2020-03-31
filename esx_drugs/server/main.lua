ESX = nil
local playersProcessingCannabis = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_drugs:sellDrug')
AddEventHandler('esx_drugs:sellDrug', function(itemName, amount, DrugDealerlocation)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = Config.DrugDealerItems[itemName]
	local xItem = xPlayer.getInventoryItem(itemName)
	local targetCoords = {}

	if DrugDealerlocation == 1 then
		DrugDealerlocation = _U('DrugDealerOne')
		targetCoords = {
			x = ESX.Math.Round(-1172.02, 1),
			y = ESX.Math.Round(-1571.98, 1),
			z = ESX.Math.Round(4.66, 1)
		}
	elseif DrugDealerlocation == 2 then
		DrugDealerlocation = _U('DrugDealerTwo')
		targetCoords = {
			x = ESX.Math.Round(2403.5, 1),
			y = ESX.Math.Round(3127.6, 1),
			z = ESX.Math.Round(48.2, 1)
		}
	else
		DrugDealerlocation = _U('DrugDealerThree')
		targetCoords = {
			x = ESX.Math.Round(-560, 1),
			y = ESX.Math.Round(5282.8, 1),
			z = ESX.Math.Round(73.1, 1)
		}
	end

	if not price then
		print(('esx_drugs: %s attempted to sell an invalid drug!'):format(xPlayer.identifier))
		return
	end

	if xItem.count < amount then
		xPlayer.showNotification(_U('dealer_notenough'))
		return
	end

	price = ESX.Math.Round(price * amount)

	if Config.GiveBlack then
		xPlayer.addAccountMoney('black_money', price)
	else
		xPlayer.addMoney(price)
	end

	xPlayer.removeInventoryItem(xItem.name, amount)
	xPlayer.showNotification(_U('dealer_sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
	TriggerClientEvent('esx_outlawalert:outlawNotify', -1, _U('selldrug', DrugDealerlocation))
	TriggerClientEvent('esx_outlawalert:SellDrugInProgress', -1, targetCoords)
end)

ESX.RegisterServerCallback('esx_drugs:buyLicense', function(source, cb, licenseName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local license = Config.LicensePrices[licenseName]

	if license then
		if xPlayer.getMoney() >= license.price then
			xPlayer.removeMoney(license.price)
	
			TriggerEvent('esx_license:addLicense', source, licenseName, function()
				cb(true)
			end)
		else
			cb(false)
		end
	else
		print(('esx_drugs: %s attempted to buy an invalid license!'):format(xPlayer.identifier))
		cb(false)
	end
end)

RegisterServerEvent('esx_drugs:pickedUpCannabis')
AddEventHandler('esx_drugs:pickedUpCannabis', function()
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.canCarryItem('cannabis', 1) then
		xPlayer.addInventoryItem('cannabis', 1)
	else
		xPlayer.showNotification(_U('weed_inventoryfull'))
	end
end)

ESX.RegisterServerCallback('esx_drugs:canPickUp', function(source, cb, item)
	local xPlayer = ESX.GetPlayerFromId(source)
	cb(xPlayer.canCarryItem(item, 1))
end)

RegisterServerEvent('esx_drugs:processCannabis')
AddEventHandler('esx_drugs:processCannabis', function()
	if not playersProcessingCannabis[source] then
		local _source = source

		playersProcessingCannabis[_source] = ESX.SetTimeout(Config.Delays.WeedProcessing, function()
			local xPlayer = ESX.GetPlayerFromId(_source)
			local xCannabis = xPlayer.getInventoryItem('cannabis')

			if not xPlayer.canCarryItem('marijuana', 1) then
				xPlayer.showNotification(_U('weed_processingfull'))
			elseif xCannabis.count < 3 then
				xPlayer.showNotification(_U('weed_processingenough'))
			else
				xPlayer.removeInventoryItem('cannabis', 3)
				xPlayer.addInventoryItem('marijuana', 1)

				xPlayer.showNotification(_U('weed_processed'))
			end

			playersProcessingCannabis[_source] = nil
		end)
	else
		print(('esx_drugs: %s attempted to exploit weed processing!'):format(GetPlayerIdentifiers(source)[1]))
	end
end)

function CancelProcessing(playerID)
	if playersProcessingCannabis[playerID] then
		ESX.ClearTimeout(playersProcessingCannabis[playerID])
		playersProcessingCannabis[playerID] = nil
	end
end

RegisterServerEvent('esx_drugs:cancelProcessing')
AddEventHandler('esx_drugs:cancelProcessing', function()
	CancelProcessing(source)
end)

AddEventHandler('esx:playerDropped', function(playerID, reason)
	CancelProcessing(playerID)
end)

RegisterServerEvent('esx:onPlayerDeath')
AddEventHandler('esx:onPlayerDeath', function(data)
	CancelProcessing(source)
end)
