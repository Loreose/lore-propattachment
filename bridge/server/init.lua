Bridge.GetPlayer = function(source)
    if Bridge.Framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayer(source)
    elseif Bridge.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerFromId(source)
    end
    return nil
end
