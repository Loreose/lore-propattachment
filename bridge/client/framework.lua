Bridge.GetPlayerData = function()
    if Bridge.Framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif Bridge.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerData()
    end
    return nil
end

Bridge.Notify = function(msg, type, time)
    local type = type or 'inform'
    local time = time or 5000

    if GetResourceState('ox_lib') == 'started' then
        lib.notify({ title = msg, type = type, duration = time })
    end
end

RegisterNetEvent('lore-bridge:client:notify', function(msg, type, time)
    Bridge.Notify(msg, type, time)
end)
