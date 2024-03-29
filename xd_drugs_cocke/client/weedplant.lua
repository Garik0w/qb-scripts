CashoutCore = nil
isLoggedIn = true

local menuOpen = false
local wasOpen = false

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(10)
        if CashoutCore == nil then
            TriggerEvent("CashoutCore:GetObject", function(obj) CashoutCore = obj end)    
            Citizen.Wait(200)
        end
    end
end)

local spawnedWeed = 0
local weedPlants = {}

local isPickingUp, isProcessing, isProcessing2 = false, false, false

RegisterNetEvent("CashoutCore:Client:OnPlayerLoaded")
AddEventHandler("CashoutCore:Client:OnPlayerLoaded", function()
	CheckCoords2()
	Citizen.Wait(1000)
	local coords = GetEntityCoords(PlayerPedId())
	if GetDistanceBetweenCoords(coords, Config.CircleZones.WeedField.coords, true) < 1000 then
		SpawnWeedPlants2()
	end
end)

function CheckCoords2()
	Citizen.CreateThread(function()
		while true do
			local coords = GetEntityCoords(PlayerPedId())
			if GetDistanceBetweenCoords(coords, Config.CircleZones.WeedField.coords, true) < 1000 then
				SpawnWeedPlants2()
			end
			Citizen.Wait(1 * 60000)
		end
	end)
end

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		CheckCoords2()
	end
end)
local CurrentDocks = nil
local currenxpoint
local xpo = 0 --variabile dove memorizzare gli xpoint
local xpcraft1 = 100 --xp minimum craft 1

Citizen.CreateThread(function()--coke pickup---
	while true do
		Citizen.Wait(10)

		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID
		
		
		for i=1, #weedPlants, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(weedPlants[i]), false) < 1 then
				nearbyObject, nearbyID = weedPlants[i], i
			end
		end

		if nearbyObject and IsPedOnFoot(playerPed) then

			if not isPickingUp then
				CashoutCore.Functions.Draw2DText(0.5, 0.88, 'Press ~g~[E]~w~ to pickup Cocke', 0.5)
			end

			if IsControlJustReleased(0, 38) and not isPickingUp then
				
                   

				isPickingUp = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, false)
				--PROP_HUMAN_BUM_BIN animazione
				--prop_cs_cardbox_01 oggetto di spawn  prop_plant_01a
				CashoutCore.Functions.Progressbar("search_register", "Picking up Cocke..", 7500, false, true, {
					disableMovement = true,
					disableCarMovement = true,
					disableMouse = false,
					disableCombat = true,
					disableInventory = true,
				}, {}, {}, {}, function() -- Done
					ClearPedTasks(GetPlayerPed(-1))
					CashoutCore.Functions.DeleteObject(nearbyObject)

					table.remove(weedPlants, nearbyID)
					spawnedWeed = spawnedWeed - 1

					TriggerServerEvent('xd_drugs_weed:pickedUpCannabis2')
				end, function()
					ClearPedTasks(GetPlayerPed(-1))
				end) -- Cancel

				isPickingUp = false

			   
			
		   
	  
           


			end


		else
			Citizen.Wait(500)
		end
	end
end)


AddEventHandler('onResourceStop', function(resource) --weedPlants
	if resource == GetCurrentResourceName() then
		for k, v in pairs(weedPlants) do
			CashoutCore.Functions.DeleteObject(v)
		end
	end
end)
function SpawnWeedPlants2() --This spawns in the Weed plants, 
	while spawnedWeed < 25 do
		Citizen.Wait(1)
		local weedCoords = GenerateWeedCoords2()
--prop_barrel_01a  prop_plant_01a
		CashoutCore.Functions.SpawnLocalObject('prop_plant_01a', weedCoords, function(obj) --- change this prop to whatever plant you are trying to use 
			PlaceObjectOnGroundProperly(obj)
			FreezeEntityPosition(obj, true)
			

			table.insert(weedPlants, obj)
			spawnedWeed = spawnedWeed + 1
		end)
	end
	Citizen.Wait(45 * 60000)
end


function ValidateWeedCoord(plantCoord) --This is a simple validation checker
	if spawnedWeed > 0 then
		local validate = true

		for k, v in pairs(weedPlants) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.CircleZones.WeedField.coords, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function GenerateWeedCoords2() --This spawns the weed plants at the designated location
	while true do
		Citizen.Wait(1)

		local weedCoordX, weedCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-10, 10)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-10, 10)

		weedCoordX = Config.CircleZones.WeedField.coords.x + modX
		weedCoordY = Config.CircleZones.WeedField.coords.y + modY

		local coordZ = GetCoordZWeed(weedCoordX, weedCoordY)
		local coord = vector3(weedCoordX, weedCoordY, coordZ)

		if ValidateWeedCoord(coord) then
			return coord
		end
	end
end

function GetCoordZWeed(x, y) ---- Set the coordinates relative to the heights near where you want the circle spawning
	local groundCheckHeights = { 31.0, 32.0, 33.0, 34.0, 35.0, 36.0, 37.0, 38.0, 39.0, 40.0, 50.0 }

	for i, height in ipairs(groundCheckHeights) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 31.85
end

Citizen.CreateThread(function() --- check that makes sure you have the materials needed to process
	while CashoutCore == nil do
		Citizen.Wait(200)
	end
	while true do
		Citizen.Wait(10)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.WeedProcessing.coords, true) < 1 then
			DrawMarker(20, Config.CircleZones.WeedProcessing.coords.x, Config.CircleZones.WeedProcessing.coords.y, Config.CircleZones.WeedProcessing.coords.z - 0.66 , 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 0, 0, 0, true, 0, 0, 0)

			
			if not isProcessing then
				CashoutCore.Functions.DrawText3D(Config.CircleZones.WeedProcessing.coords.x, Config.CircleZones.WeedProcessing.coords.y, Config.CircleZones.WeedProcessing.coords.z, 'Press ~g~[ E ]~w~ to Process')
			end

			if IsControlJustReleased(0, 38) and not isProcessing then
				local hasBag = false
				local s1 = false
				local hasWeed = false
				local s2 = false

				CashoutCore.Functions.TriggerCallback('CashoutCore:HasItem', function(result)
					hasWeed = result
					s1 = true
				end, 'cocke')
				
				while(not s1) do
					Citizen.Wait(100)
				end
				Citizen.Wait(100)
				CashoutCore.Functions.TriggerCallback('CashoutCore:HasItem', function(result)
					hasBag = result
					s2 = true
				end, 'empty_weed_bag')
				
				while(not s2) do
					Citizen.Wait(100)
				end

				if (hasWeed and hasBag) then
					Processweed3()
				elseif (hasWeed) then
					CashoutCore.Functions.Notify('You dont have enough plastic bags.', 'error')
				elseif (hasBag) then
					CashoutCore.Functions.Notify('You dont have enough cocke.', 'error')
				else
					CashoutCore.Functions.Notify('You dont have enough cocke or plastic bags.', 'error')
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)



function Processweed3()  -- simple animations to loop while process is taking place
	isProcessing = true
	local playerPed = PlayerPedId()

	--
	TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_PARKING_METER", 0, true)
	SetEntityHeading(PlayerPedId(), 108.06254)

	CashoutCore.Functions.Progressbar("search_register", "Trying to Process..", 15000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
		disableInventory = true,
	}, {}, {}, {}, function()
	 TriggerServerEvent('xd_drugs_weed:processweed2') -- Done

		local timeLeft = Config.Delays.WeedProcessing / 1000

		while timeLeft > 0 do
			Citizen.Wait(1000)
			timeLeft = timeLeft - 1

			if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.WeedProcessing.coords, false) > 4 then
				TriggerServerEvent('xd_drugs_weed:cancelProcessing2')
				break
			end
		end
		ClearPedTasks(GetPlayerPed(-1))
	end, function()
		ClearPedTasks(GetPlayerPed(-1))
	end) -- Cancel
		
	
	isProcessing = false
end


Citizen.CreateThread(function() --- check that makes sure you have the materials needed to process
	while CashoutCore == nil do
		Citizen.Wait(200)
	end
	while true do
		Citizen.Wait(10)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, Config.CircleZones.DrugDealer.coords, true) < 1 then
			DrawMarker(20, Config.CircleZones.DrugDealer.coords.x, Config.CircleZones.DrugDealer.coords.y, Config.CircleZones.DrugDealer.coords.z - 0.66 , 0, 0, 0, 0, 0, 0, 0.5, 0.5, 0.5, 255, 255, 255, 100, 0, 0, 0, true, 0, 0, 0)

			
			if not isProcessing2 then
				CashoutCore.Functions.DrawText3D(Config.CircleZones.DrugDealer.coords.x, Config.CircleZones.DrugDealer.coords.y, Config.CircleZones.DrugDealer.coords.z, 'Press ~g~[ E ]~w~ to Sell')
			end

			if IsControlJustReleased(0, 38) and not isProcessing2 then
				--local hasBag = false
				--local s1 = false
				local hasWeed2 = false
				local hasBag2 = false
				local s3 = false
				
				CashoutCore.Functions.TriggerCallback('CashoutCore:HasItem', function(result)
					hasWeed2 = result
					hasBag2 = result
					s3 = true
					
				end, 'bag_cocke')
				
				while(not s3) do
					Citizen.Wait(100)
				end
				

				if (hasWeed2) then
					SellDrug3()
				elseif (hasWeed2) then
					CashoutCore.Functions.Notify('You dont have enough plastic bags.', 'error')
				elseif (hasBag2) then
					CashoutCore.Functions.Notify('You dont have enough cocke.', 'error')
				else
					CashoutCore.Functions.Notify('You dont have enough cocke or plastic bags.', 'error')
				end
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function SellDrug3()  -- simple animations to loop while process is taking place
	isProcessing2 = true
	local playerPed = PlayerPedId()

	--
	TaskStartScenarioInPlace(playerPed, "CODE_HUMAN_MEDIC_TEND_TO_DEAD", 0, true)
	SetEntityHeading(PlayerPedId(), 108.06254)

	CashoutCore.Functions.Progressbar("search_register", "Trying to Process..", 15000, false, true, {
		disableMovement = true,
		disableCarMovement = true,
		disableMouse = false,
		disableCombat = true,
		disableInventory = true,
	}, {}, {}, {}, function()
	 TriggerServerEvent('xd_drugs_weed:selld2') -- Done

		local timeLeft = Config.Delays.WeedProcessing / 1000

		while timeLeft > 0 do
			Citizen.Wait(500)
			timeLeft = timeLeft - 1

			if GetDistanceBetweenCoords(GetEntityCoords(playerPed), Config.CircleZones.WeedProcessing.coords, false) > 4 then
				--TriggerServerEvent('xd_drugs_weed:cancelProcessing2')
				break
			end
		end
		ClearPedTasks(GetPlayerPed(-1))
	end, function()
		ClearPedTasks(GetPlayerPed(-1))
	end) -- Cancel
		
	
	isProcessing2 = false
end