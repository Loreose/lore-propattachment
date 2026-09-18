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

--- RegisterNetEvent('myScript:server:rewardPlayer', function()
---     local src = source
---
---     -- Oyuncuya 2 adet su ve özel metadatalı telsiz ver
---     local addedWater = Bridge.AddItem(src, 'water', 2)
---     local addedRadio = Bridge.AddItem(src, 'radio', 1, { channel = 101 })
---
---     if addedWater and addedRadio then
---         Bridge.Notify(src, 'Ödülleriniz envanterinize eklendi!', 'success')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:useCraftingItem', function()
---     local src = source
---
---     -- Oyuncudan 1 adet hurda demir sil
---     local removed = Bridge.RemoveItem(src, 'scrapmetal', 1)
---
---     if removed then
---         print("Hurda demir başarıyla eksiltildi.")
---     else
---         Bridge.Notify(src, 'Envanterinizde yeterli hurda demir yok!', 'error')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:sellGold', function()
---     local src = source
---
---     -- Oyuncunun üzerindeki toplam altın külçesi sayısını öğren
---     local goldCount = Bridge.GetItemCount(src, 'goldingot')
---
---     if goldCount > 0 then
---         local pricePerGold = 500
---         local totalEarnings = goldCount * pricePerGold
---
---         -- Altınların hepsini sil ve parasını ver
---         if Bridge.RemoveItem(src, 'goldingot', goldCount) then
---             Bridge.AddMoney(src, 'cash', totalEarnings, "gold-sale")
---             Bridge.Notify(src, string.format('%d adet altın satıldı. Kazanç: $%d', goldCount, totalEarnings), 'success')
---         end
---     else
---         Bridge.Notify(src, 'Üzerinizde satılacak altın yok!', 'error')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:payoutJob', function()
---     local src = source
---     local rewardAmount = 1500
---
---     -- Oyuncunun banka hesabına para ekle
---     local success = Bridge.AddMoney(src, 'bank', rewardAmount, 'job-reward')
---
---     if success then
---         Bridge.Notify(src, string.format('Maaşınız bankanıza yatırıldı: $%d', rewardAmount), 'success')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:buyItem', function()
---     local src = source
---     local price = 250
---
---     -- Oyuncudan nakit para düşmeyi dene
---     local paid = Bridge.RemoveMoney(src, 'cash', price, 'store-buy')
---
---     if paid then
---         Bridge.AddItem(src, 'water', 1)
---         Bridge.Notify(src, 'Satın alım başarılı!', 'success')
---     else
---         Bridge.Notify(src, 'Yeterli nakit paranız yok!', 'error')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:checkBalance', function()
---     local src = source
---
---     local bankBalance = Bridge.GetMoney(src, 'bank')
---     local cashBalance = Bridge.GetMoney(src, 'cash')
---
---     print(string.format("Oyuncu ID: %d | Banka: $%d | Nakit: $%d", src, bankBalance, cashBalance))
---
---     if bankBalance >= 10000 then
---         Bridge.Notify(src, 'VIP erişim için paranız yeterli!', 'info')
---     end
--- end)

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

--- RegisterNetEvent('myScript:server:craftWeapon', function()
---     local src = source
---
---     -- Oyuncunun üzerinde en az 5 adet demir var mı kontrol et
---     local hasIron = Bridge.HasItem(src, 'iron', 5)
---
---     if hasIron then
---         Bridge.RemoveItem(src, 'iron', 5)
---         Bridge.AddItem(src, 'weapon_knife', 1)
---         Bridge.Notify(src, 'Bıçak başarıyla üretildi!', 'success')
---     else
---         Bridge.Notify(src, 'Üretim için yeterli demiriniz yok! (Gerekli: 5)', 'error')
---     end
--- end)

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

--- Bridge.RegisterUsableItem('burger', function(source, item)
---     local src = source
---
---     -- Eşyayı envanterden 1 adet düş ve etkisini başlat
---     local used = Bridge.UseItem(src, 'burger', 1, true)
---
---     if used then
---         -- Client tarafına açlık doyurma event'i gönder
---         TriggerClientEvent('myScript:client:eatBurger', src)
---         Bridge.Notify(src, 'Lezzetli bir hamburger yediniz.', 'success')
---     end
--- end)

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

--- Bridge.RegisterUsableItem('medkit', function(source, item)
---     local src = source
---
---     -- İlk yardım kitini kontrol et ama silme (removeOnUse = false)
---     -- İşlemi client animasyonu bittikten sonra silmek isterseniz bu yöntem kullanılır:
---     local hasItem = Bridge.UseItem(src, 'medkit', 1, false)
---
---     if hasItem then
---         TriggerClientEvent('myScript:client:startHealing', src)
---     else
---         Bridge.Notify(src, 'Üzerinizde ilk yardım kiti bulunamadı!', 'error')
---     end
--- end)
