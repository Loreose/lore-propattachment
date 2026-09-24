Bridge.AddItem = function(source, item, count, metadata)
    local count = count or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:AddItem(source, item, count, metadata)
    elseif Bridge.Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.AddItem(item, count, nil, metadata)
    end
    return false
end

Bridge.RemoveItem = function(source, item, count, metadata)
    local count = count or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:RemoveItem(source, item, count, nil, metadata)
    elseif Bridge.Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.RemoveItem(item, count, nil, metadata)
    end
    return false
end

Bridge.GetItemCount = function(source, item)
    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:Search(source, 'count', item) or 0
    elseif Bridge.Inventory == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local itemData = QBCore.Functions.GetItemByName(item)
        return itemData and itemData.amount or 0
    end
    return 0
end

Bridge.AddMoney = function(source, moneyType, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end

    local moneyType = moneyType == 'cash' and (Bridge.Framework == 'esx' and 'money' or 'cash') or moneyType
    local amount = tonumber(amount) or 0

    if Bridge.Framework == 'qb' then
        return Player.Functions.AddMoney(moneyType, amount, reason or "bridge-add-money")
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'money' then
            Player.addMoney(amount)
        else
            Player.addAccountMoney(moneyType, amount)
        end
        return true
    end
    return false
end

Bridge.RemoveMoney = function(source, moneyType, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return false end

    local moneyType = moneyType == 'cash' and (Bridge.Framework == 'esx' and 'money' or 'cash') or moneyType
    local amount = tonumber(amount) or 0

    if Bridge.Framework == 'qb' then
        return Player.Functions.RemoveMoney(moneyType, amount, reason or "bridge-remove-money")
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'money' then
            if Player.getMoney() >= amount then
                Player.removeMoney(amount)
                return true
            end
        else
            if Player.getAccount(moneyType).money >= amount then
                Player.removeAccountMoney(moneyType, amount)
                return true
            end
        end
    end
    return false
end

Bridge.GetMoney = function(source, moneyType)
    local Player = Bridge.GetPlayer(source)
    if not Player then return 0 end

    local moneyType = moneyType == 'cash' and (Bridge.Framework == 'esx' and 'money' or 'cash') or moneyType

    if Bridge.Framework == 'qb' then
        return Player.PlayerData.money[moneyType] or 0
    elseif Bridge.Framework == 'esx' then
        if moneyType == 'money' then
            return Player.getMoney()
        else
            local account = Player.getAccount(moneyType)
            return account and account.money or 0
        end
    end
    return 0
end

Bridge.HasItem = function(source, itemName, amount)
    local amount = amount or 1

    if Bridge.Inventory == 'ox' then
        return exports.ox_inventory:Search(source, 'count', itemName) >= amount
    else
        local Player = Bridge.GetPlayer(source)
        if not Player then return false end

        if Bridge.Framework == 'qb' then
            local itemData = Player.Functions.GetItemByName(itemName)
            return itemData and itemData.amount >= amount
        elseif Bridge.Framework == 'esx' then
            local itemData = Player.getInventoryItem(itemName)
            return itemData and itemData.count >= amount
        end
    end

    return false
end

Bridge.RegisterUsableItem = function(itemName, callback)
    if Bridge.Inventory == 'ox' then
        exports.ox_inventory:registerHook('useItem', function(payload)
            if payload.item.name == itemName then
                callback(payload.source, payload.item)
            end
        end)
    elseif Bridge.Framework == 'qb' then
        local QBCore = exports['qb-core']:GetCoreObject()
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            callback(source, item)
        end)
    elseif Bridge.Framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        ESX.RegisterUsableItem(itemName, function(source, item)
            callback(source, item)
        end)
    end
end

Bridge.UseItem = function(source, itemName, amount, removeOnUse)
    local amount = amount or 1
    local removeOnUse = removeOnUse == nil and true or removeOnUse

    if Bridge.HasItem(source, itemName, amount) then
        if removeOnUse then
            Bridge.RemoveItem(source, itemName, amount)
        end
        return true
    end

    return false
end
