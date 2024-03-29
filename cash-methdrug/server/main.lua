CashoutCore = nil
TriggerEvent('CashoutCore:GetObject', function(obj) CashoutCore = obj end)

-- Code

Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    print('Lab entry has been set to location: '..Config.CurrentLab)
end)

CashoutCore.Functions.CreateCallback('cash-methdrug:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

CashoutCore.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = CashoutCore.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('cash-methdrug:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end