Bridge.HasItem = function(itemName, amount)
    local amount = amount or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:Search('count', itemName) >= amount
    elseif Bridge.Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.HasItem(itemName, amount)
    end

    return false
end

Bridge.OnItemUse = function(itemName, callback)
    if Bridge.Framework == 'qb' then
        RegisterNetEvent('QBCore:Client:UseItem', function(item)
            if item.name == itemName then
                callback(item)
            end
        end)
    elseif Bridge.Framework == 'esx' then
        RegisterNetEvent('esx:useItem', function(item)
            if item == itemName then
                callback(item)
            end
        end)
    end
end
