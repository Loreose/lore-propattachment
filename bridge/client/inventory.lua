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

--- RegisterCommand('telefondurum', function()
---     local hasPhone = Bridge.HasItem('phone', 1)
---
---     if hasPhone then
---         Bridge.Notify('Telefonunuz yanınızda!', 'info')
---     else
---         Bridge.Notify('Cebinizde telefon bulunamadı!', 'error')
---     end
--- end)

Bridge.OnItemUse = function(itemName, callback)
    if Bridge.Framework == 'qb' then
        RegisterNetEvent('QBCore:Client:UseItem', function(item)
            if item.name == itemName then
                callback(item)
            end
        end)
    elseif Bridge.Framework == 'esx' then
        -- ESX client event dinleyicisi
        RegisterNetEvent('esx:useItem', function(item)
            if item == itemName then
                callback(item)
            end
        end)
    end
end

--- Bridge.OnItemUse('lockpick', function(item)
---     print("Maymuncuk kullanıldı! Eşya verisi:", json.encode(item))
---
---     -- Animasyon veya Maymuncuk minigame'i başlat
---     local success = Bridge.ProgressBar({
---         duration = 4000,
---         label = 'Maymuncuk deneniyor...',
---         anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechanic' }
---     })
---
---     if success then
---         Bridge.Notify('Maymuncuk başarılı!', 'success')
---     end
--- end)
