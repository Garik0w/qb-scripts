CashoutCore = nil

Citizen.CreateThread(function()
    while CashoutCore == nil do
        TriggerEvent('CashoutCore:GetObject', function(obj) CashoutCore = obj end)
        Citizen.Wait(200)
    end
end)

-- Code

local InsideMethlab = true
local ClosestMethlab = 0
local CurrentTask = 0
local UsingLaptop = false
local CarryPackage = nil

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function SetClosestMethlab()
    local pos = GetEntityCoords(GetPlayerPed(-1), true)
    local current = nil
    local dist = nil
    for id, methlab in pairs(Config.Locations["laboratories"]) do
        if current ~= nil then
            if(GetDistanceBetweenCoords(pos, Config.Locations["laboratories"][id].coords.x, Config.Locations["laboratories"][id].coords.y, Config.Locations["laboratories"][id].coords.z, true) < dist)then
                current = id
                dist = GetDistanceBetweenCoords(pos, Config.Locations["laboratories"][id].coords.x, Config.Locations["laboratories"][id].coords.y, Config.Locations["laboratories"][id].coords.z, true)
            end
        else
            dist = GetDistanceBetweenCoords(pos, Config.Locations["laboratories"][id].coords.x, Config.Locations["laboratories"][id].coords.y, Config.Locations["laboratories"][id].coords.z, true)
            current = id
        end
    end
    ClosestMethlab = current
end

Citizen.CreateThread(function()
    Wait(500)
    CashoutCore.Functions.TriggerCallback('cash-methdrug:server:GetData', function(data)
        Config.CurrentLab = data.CurrentLab
    end)

    CurrentTask = GetCurrentTask()


    while true do
        SetClosestMethlab()
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])

    while true do
        local inRange = false
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        -- Exit distance check
        if InsideMethlab then
            if(GetDistanceBetweenCoords(pos, Config.Locations["exit"].coords.x, Config.Locations["exit"].coords.y, Config.Locations["exit"].coords.z, true) < 20)then
                inRange = true
                if(GetDistanceBetweenCoords(pos, Config.Locations["exit"].coords.x, Config.Locations["exit"].coords.y, Config.Locations["exit"].coords.z, true) < 1)then
                    DrawText3Ds(Config.Locations["exit"].coords.x, Config.Locations["exit"].coords.y, Config.Locations["exit"].coords.z, '~g~E~w~ - Leave methlab')
                    if IsControlJustPressed(0, Keys["E"]) then
                        ExitMethlab()
                    end
                end
            end
        end

        -- Laptop distance check
        if InsideMethlab then
            if(GetDistanceBetweenCoords(pos, Config.Locations["laptop"].coords.x, Config.Locations["laptop"].coords.y, Config.Locations["laptop"].coords.z, true) < 20)then
                inRange = true
                DrawMarker(2, Config.Locations["laptop"].coords.x, Config.Locations["laptop"].coords.y, Config.Locations["laptop"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.3, 0.1, 222, 11, 11, 155, false, false, false, true, false, false, false)
                if(GetDistanceBetweenCoords(pos, Config.Locations["laptop"].coords.x, Config.Locations["laptop"].coords.y, Config.Locations["laptop"].coords.z, true) < 1)then
                    DrawText3Ds(Config.Locations["laptop"].coords.x - 0.04, Config.Locations["laptop"].coords.y + 0.45, Config.Locations["laptop"].coords.z, '~g~E~w~ - Use a laptop')
                    if IsControlJustPressed(0, Keys["E"]) then
                        RequestLocation()
                    end
                end
            end
        end

        if not Config.CooldownActive then
            if InsideMethlab then
                if CurrentTask == 1 then
                    if Config.Tasks[CurrentTask].ingredients.current == 0 then
                        if not Config.Ingredients["lab"].taken or CarryPackage ~= nil then
                            if(GetDistanceBetweenCoords(pos, Config.Ingredients["lab"].coords.x, Config.Ingredients["lab"].coords.y, Config.Ingredients["lab"].coords.z, true) < 20)then
                                inRange = true
                                DrawMarker(2, Config.Ingredients["lab"].coords.x, Config.Ingredients["lab"].coords.y, Config.Ingredients["lab"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.3, 0.1, 222, 11, 11, 155, false, false, false, true, false, false, false)
                                if(GetDistanceBetweenCoords(pos, Config.Ingredients["lab"].coords.x, Config.Ingredients["lab"].coords.y, Config.Ingredients["lab"].coords.z, true) < 1)then
                                    if CarryPackage == nil then
                                        DrawText3Ds(Config.Ingredients["lab"].coords.x, Config.Ingredients["lab"].coords.y, Config.Ingredients["lab"].coords.z, '~g~E~w~ - Grab ingredients')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            TaskStartScenarioInPlace(GetPlayerPed(-1), "PROP_HUMAN_BUM_BIN", 0, true)
                                            CashoutCore.Functions.Progressbar("pickup_reycle_package", "Grabbing..", 5000, false, true, {}, {}, {}, {}, function() -- Done
                                                ClearPedTasks(GetPlayerPed(-1))
                                                TakeIngredients()
                                            end)
                                        end
                                    else
                                        DrawText3Ds(Config.Ingredients["lab"].coords.x, Config.Ingredients["lab"].coords.y, Config.Ingredients["lab"].coords.z, '~g~E~w~ - Put ingredients away')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            DropIngredients()
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            if InsideMethlab then
                if CurrentTask ~= 0 then
                    if(GetDistanceBetweenCoords(pos, Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z, true) < 20)then
                        inRange = true
                        DrawMarker(2, Config.Tasks[CurrentTask].coords.x,  Config.Tasks[CurrentTask].coords.y,  Config.Tasks[CurrentTask].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.3, 0.1, 222, 11, 11, 155, false, false, false, true, false, false, false)
                        if(GetDistanceBetweenCoords(pos, Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z, true) < 1)then
                            DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z, Config.Tasks[CurrentTask].label)
                            DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z - 0.2, Config.Tasks[CurrentTask].ingredients.current..'/'..Config.Tasks[CurrentTask].ingredients.needed..' Ingrediënten')
                            if Config.Tasks[CurrentTask].ingredients.current == Config.Tasks[CurrentTask].ingredients.needed then
                                if not Config.Tasks[CurrentTask].started then
                                    if not Config.Tasks[CurrentTask].done then
                                        DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z - 0.4, '[E] Start machine')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            StartMachine(CurrentTask)
                                        end
                                    else
                                        DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z - 0.4, '[E] Take ingredients')
                                        if IsControlJustPressed(0, Keys["E"]) then
                                            FinishMachine(CurrentTask)
                                        end
                                    end
                                else
                                    DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z - 0.4, ' Ready over '..Config.Tasks[CurrentTask].timeremaining..'s')
                                end
                            else
                                if CurrentTask == 1 then
                                    if CarryPackage ~= nil then
                                        if Config.Tasks[CurrentTask].ingredients.current == 0 then
                                            DrawText3Ds(Config.Tasks[CurrentTask].coords.x, Config.Tasks[CurrentTask].coords.y, Config.Tasks[CurrentTask].coords.z + 0.2, '[E] Load ingredients')
                                            if IsControlJustPressed(0, Keys["E"]) then
                                                DropIngredients()
                                                Config.Tasks[CurrentTask].ingredients.current = 1
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        if not inRange then
            Citizen.Wait(1000)
        end

        Citizen.Wait(3)
    end
end)

function StartMachine(k)
    Citizen.CreateThread(function()
        Config.Tasks[k].started = true
        while Config.Tasks[k].timeremaining > 0 do
            Config.Tasks[k].timeremaining = Config.Tasks[k].timeremaining - 1
            Citizen.Wait(1000)
        end
        Config.Tasks[k].started = false
        Config.Tasks[k].done = true
    end)
end

function FinishMachine(k)
    Config.Tasks[k].done = false
    Config.Tasks[k].timeremaining = Config.Tasks[k].duration
    Config.Tasks[k].ingredients.current = 0

    if CurrentTask + 1 > #Config.Tasks then
        Config.CooldownActive = true
    else
        print('next task')
    end
end

RegisterNetEvent('cash-methdrug:client:UseLabKey')
AddEventHandler('cash-methdrug:client:UseLabKey', function(labkey)
    if ClosestMethlab == Config.CurrentLab then
        local ped = GetPlayerPed(-1)
        local pos = GetEntityCoords(ped)

        local dist = GetDistanceBetweenCoords(pos, Config.Locations["laboratories"][ClosestMethlab].coords.x, Config.Locations["laboratories"][ClosestMethlab].coords.y, Config.Locations["laboratories"][ClosestMethlab].coords.z, true)
        if dist < 1 then
            if labkey == ClosestMethlab then
                EnterMethlab()
            else
                CashoutCore.Functions.Notify('This is not the correct key..', 'error')
            end
        end
    end
end)

function OpenLaptop()
    if not UsingLaptop then
        local ped = GetPlayerPed(-1)
        local dict = "mp_prison_break"
        local anim = "hack_loop"
        local flag = 0

        SetEntityCoords(ped, Config.Locations["laptop"].coords.x, Config.Locations["laptop"].coords.y, Config.Locations["laptop"].coords.z - 0.98, 0.0, 0.0, 0.0, false)
        SetEntityHeading(ped, Config.Locations["laptop"].coords.h)

        LoadAnimationDict(dict)
        TaskPlayAnim(ped, dict, anim, 2.0, 2.0, -1, flag, 0, false, false, false)

        Citizen.Wait(400)
        SendNUIMessage({
            action = "open",
            tasks = Config.Tasks,
        })
        SetNuiFocus(true, true)
        UsingLaptop = true
    end
end

function CloseLaptop()
    local ped = GetPlayerPed(-1)
    local dict = "mp_prison_break"
    local flag = 0

    TaskPlayAnim(ped, dict, "exit", 8.0, 8.0, -1, flag, 0, false, false, false)

    SetNuiFocus(false, false)
    UsingLaptop = false
end

RegisterNUICallback('Close', CloseLaptop)

function EnterMethlab()
    local ped = GetPlayerPed(-1)

    OpenDoorAnimation()
    InsideMethlab = true
    Citizen.Wait(500)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    SetEntityCoords(ped, Config.Locations["exit"].coords.x, Config.Locations["exit"].coords.y, Config.Locations["exit"].coords.z - 0.98)
    SetEntityHeading(ped, Config.Locations["exit"].coords.h)
    Citizen.Wait(1000)
    DoScreenFadeIn(250)
end

function ExitMethlab()
    local ped = GetPlayerPed(-1)
    local dict = "mp_heists@keypad@"
    local anim = "idle_a"
    local flag = 0
    local keypad = {
        coords = {x = 996.92, y = -3199.85, z = -36.4, h = 94.5, r = 1.0}, 
    }

    CurrentTask = GetCurrentTask()

    SetEntityCoords(ped, keypad.coords.x, keypad.coords.y, keypad.coords.z - 0.98)
    SetEntityHeading(ped, keypad.coords.h)

    LoadAnimationDict(dict) 

    TaskPlayAnim(ped, dict, anim, 8.0, 8.0, -1, flag, 0, false, false, false)
    Citizen.Wait(2500)
    TaskPlayAnim(ped, dict, "exit", 2.0, 2.0, -1, flag, 0, false, false, false)
    Citizen.Wait(1000)
    DoScreenFadeOut(250)
    Citizen.Wait(250)
    SetEntityCoords(ped, Config.Locations["laboratories"][Config.CurrentLab].coords.x, Config.Locations["laboratories"][Config.CurrentLab].coords.y, Config.Locations["laboratories"][Config.CurrentLab].coords.z - 0.98)
    SetEntityHeading(ped, Config.Locations["laboratories"][Config.CurrentLab].coords.h)
    InsideMethlab = false
    Citizen.Wait(1000)
    DoScreenFadeIn(250)
end

function LoadAnimationDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(1)
    end
end

function OpenDoorAnimation()
    local ped = GetPlayerPed(-1)

    LoadAnimationDict("anim@heists@keycard@") 
    TaskPlayAnim(ped, "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0)
    Citizen.Wait(400)
    ClearPedTasks(ped)
end

function GetCurrentTask()
    local currenttask = nil
    for k, v in pairs(Config.Tasks) do
        if not v.completed then
            currenttask = k
            break
        end
    end
    return currenttask
end

function TakeIngredients()
    local pos = GetEntityCoords(GetPlayerPed(-1), true)
    RequestAnimDict("anim@heists@box_carry@")
    while (not HasAnimDictLoaded("anim@heists@box_carry@")) do
        Citizen.Wait(7)
    end
    TaskPlayAnim(GetPlayerPed(-1), "anim@heists@box_carry@" ,"idle", 5.0, -1, -1, 50, 0, false, false, false)
    local model = GetHashKey("prop_cs_cardbox_01")
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(0) end
    local object = CreateObject(model, pos.x, pos.y, pos.z, true, true, true)
    AttachEntityToEntity(object, GetPlayerPed(-1), GetPedBoneIndex(GetPlayerPed(-1), 57005), 0.05, 0.1, -0.3, 300.0, 250.0, 20.0, true, true, false, true, 1, true)
    CarryPackage = object
end

function DropIngredients()
    ClearPedTasks(GetPlayerPed(-1))
    DetachEntity(CarryPackage, true, true)
    DeleteObject(CarryPackage)
    CarryPackage = nil
end
