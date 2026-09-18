Bridge.AddTargetEntity = function(entity, options, distance)
    local distance = distance or 2.0
    if Bridge.Target == 'ox' then
        local oxOptions = {}
        for _, opt in ipairs(options) do
            table.insert(oxOptions, {
                name = opt.name or opt.label,
                icon = opt.icon,
                label = opt.label,
                onSelect = function(data)
                    if opt.action then opt.action(data.entity) end
                end,
                canInteract = opt.canInteract
            })
        end
        exports.ox_target:addLocalEntity(entity, oxOptions)
    elseif Bridge.Target == 'qb' then
        local qbOptions = {}
        for _, opt in ipairs(options) do
            table.insert(qbOptions, {
                icon = opt.icon,
                label = opt.label,
                action = opt.action,
                canInteract = opt.canInteract
            })
        end
        exports['qb-target']:AddTargetEntity(entity, {
            options = qbOptions,
            distance = distance
        })
    end
end

--- local veh = GetVehiclePedIsIn(PlayerPedId(), false)
---
--- Bridge.AddTargetEntity(veh, {
---     {
---         name = 'vehicle_inspect',
---         label = 'Aracı İncele',
---         icon = 'fas fa-magnifying-glass',
---         action = function(entity)
---             print("İncelenen Araç Entity ID:", entity)
---         end,
---         canInteract = function(entity)
---             return DoesEntityExist(entity) and not IsEntityDead(entity)
---         end
---     }
--- }, 2.5)

Bridge.AddCircleZone = function(name, center, radius, options, targetOptions)
    local radius = radius or 1.0
    local options = options or {}

    -- --- OX TARGET ---
    if Bridge.Target == 'ox' then
        local oxOptions = {}
        for _, opt in ipairs(targetOptions) do
            table.insert(oxOptions, {
                name = opt.name or opt.label,
                icon = opt.icon,
                label = opt.label,
                onSelect = function(data)
                    if opt.action then opt.action(data.entity, data.distance, data.coords) end
                end,
                canInteract = opt.canInteract
            })
        end

        return exports.ox_target:addSphereZone({
            name = name,
            coords = center,
            radius = radius,
            debug = options.debug or false,
            drawSprite = options.drawSprite or false, -- ox_target built-in sprite
            options = oxOptions
        })

        -- --- QB TARGET ---
    elseif Bridge.Target == 'qb' then
        local qbOptions = {}
        for _, opt in ipairs(targetOptions) do
            table.insert(qbOptions, {
                icon = opt.icon,
                label = opt.label,
                action = opt.action,
                canInteract = opt.canInteract
            })
        end

        exports['qb-target']:AddCircleZone(
            name,
            center,
            radius,
            {
                name = name,
                debugPoly = options.debug or false,
                useZ = options.useZ == nil and true or options.useZ,
                drawSprite = options.drawSprite or false -- qb-target PolyZone built-in sprite
            },
            {
                options = qbOptions,
                distance = options.distance or 2.0
            }
        )

        return name
    end
end

-- local shopCoords = vec3(25.3, -1347.1, 29.5)

-- local myZone = Bridge.AddCircleZone(
--     'market_interaction_zone',
--     shopCoords,
--     1.5,
--     {
--         debug = false,
--         distance = 2.5,
--         drawSprite = true
--     },
--     {
--         {
--             name = 'open_shop_menu',
--             label = 'Market Aç',
--             icon = 'fas fa-shopping-cart',
--             action = function(entity, distance, coords)
--                 print("Market açıldı.")
--             end
--         }
--     }
-- )

Bridge.RemoveZone = function(zoneId)
    if not zoneId then return end

    if Bridge.Target == 'ox' then
        exports.ox_target:removeZone(zoneId)
    elseif Bridge.Target == 'qb' then
        exports['qb-target']:RemoveZone(zoneId)
    end
end
