Bridge.SendPoliceAlert = function(data)
    if GetResourceState('ps-dispatch') == 'started' then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        exports['ps-dispatch']:CustomAlert({
            coords = coords,
            dispatchCode = data.code,
            description = data.title,
            message = data.message,
            priority = 2,
            alert = {
                sprite = data.sprite,
                color = data.color,
                scale = data.scale or 0.8,
                length = data.length or 3,
                radius = data.radius or 0,
            }
        })
    end
end