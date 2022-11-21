ESX = nil
local InventoriesIndex = {}
local Inventories = {}
local SharedInventories = {}
local Database = {
	Account = {}
}
MySQL.ready(function()

	Wait(10000)

	TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

	MySQL.Async.fetchAll('SELECT * FROM addon_account', { }, function(result_accounts)
		Database.Account = result_accounts
		for i=1, #Database.Account do
			local name = Database.Account[i].name
			local label = Database.Account[i].label
			local shared = Database.Account[i].shared

			MySQL.Async.fetchAll("SELECT * FROM addon_inventory_items WHERE inventory_name LIKE '%"..name.."%'", { }, function(result_inventories)
				if #result_inventories > 0 then
					for resultI = 1, #result_inventories do
						inventory_name = result_inventories[resultI].inventory_name
						local tempItems = json.decode(result_inventories[resultI].data)

						if shared == 0 then

							table.insert(InventoriesIndex, inventory_name)

							Inventories[inventory_name] = {}
							local items = {}
						
							label = nil
							for k, v in pairs(tempItems) do
								table.insert(items, {
									name  = k,
									count = v,
									label = getItemLabel(k)
								})
							end

							local addonInventory = CreateAddonInventory(inventory_name, items)
							table.insert(Inventories[inventory_name], addonInventory)

						else
							local items = {}

							for k, v in pairs(tempItems) do
								table.insert(items, {
									name = k,
									count = v,
									label = getItemLabel(k)
								})
							end

							local addonInventory = CreateAddonInventory(inventory_name, items)
							table.insert(SharedInventories, {name = inventory_name, inventory = addonInventory})
						end
					end
				end
			end)
		end
	end)
end)

function getItemLabel(name)
	if ESX.Items[name] ~= nil then
		return ESX.Items[name].label
	end
	
	return nil
end

function GetInventory(name, owner)
	for i=1, #Inventories[name], 1 do
		if Inventories[name][i].owner == owner then
			return Inventories[name][i]
		end
	end
end

function GetSharedInventory(name)
	for i=1, #SharedInventories do
		if SharedInventories[i].name == name then
			return SharedInventories[i].inventory
		end
	end
end

AddEventHandler('esx_addoninventory:getInventory', function(name, owner, cb)
	cb(GetInventory(name, owner))
end)

AddEventHandler('esx_addoninventory:getSharedInventory', function(name, cb)
	cb(GetSharedInventory(name))
end)

AddEventHandler('esx:playerLoaded', function(source)
	local player = source
	local xPlayer = ESX.GetPlayerFromId(player)
	local addonInventories = {}

	for i=1, #InventoriesIndex, 1 do
		local name      = InventoriesIndex[i]
		local inventory = GetInventory(name, xPlayer.identifier)

		if inventory == nil then
			inventory = CreateAddonInventory(name, xPlayer.identifier, {})
			table.insert(Inventories[name], inventory)
		end

		table.insert(addonInventories, inventory)
	end

	xPlayer.set('addonInventories', addonInventories)
end)


function CreateAddonInventory(name, items)
	local self = {}

	self.name = name
	self.items = items

	self.addItem = function(name, count)
		local item = self.getItem(name)
		if item ~= nil then
			item.count = item.count + count
			self.saveItem(name, item.count)
		else
			table.insert(items, {name = name, count = count, label = ESX.Items[name].label})
			updateData(self.name, self.items)
		end
	end

	self.removeItem = function(name, count)
		local item = self.getItem(name)
		item.count = item.count - count
	
		self.saveItem(name, item.count)
	end

	self.setItem = function(name, count)
		local item = self.getItem(name)
		item.count = count

		self.saveItem(name, item.count)
	end

	self.getItem = function(name)
		item = nil
	
		for i=1, #self.items, 1 do
			if self.items[i].name == name then
				item = self.items[i]
				break
			end
		end
    	
		return item
	end

	self.saveItem = function(name, count)

		if count > 0 then
			for i=1, #self.items do
				if self.items[i].name == name then
					self.items[i].count = count
					break
				end
			end
			
			updateData(self.name, self.items)
		else
			for i=1, #self.items do
				if self.items[i].name == name then
					table.remove(self.items, i)
					break
				end
			end
			
			updateData(self.name, self.items)
		end
	end

	return self
end

function updateData(inventory_name, items)
	local itemsToStore = {}
	for i=1, #items do
		if items[i].count > 0 then
			itemsToStore[items[i].name] = items[i].count
		end
	end
		
	MySQL.Async.execute('UPDATE addon_inventory_items SET data = @data WHERE inventory_name = @inventory_name', {
		['@inventory_name'] = inventory_name,
		['@data'] = json.encode(itemsToStore) or {}
	})
end
