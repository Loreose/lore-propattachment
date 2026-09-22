Bridge.AddTargetEntity = function(entity, options, distance)
    local distance = distance or 2.0

    if Bridge.Target == 'ox' then
        local oxOptions = {}
        for _, opt in ipairs(options) do
            table.insert(oxOptions, {
                name = opt.name or opt.label,
                icon = opt.icon,
                label = opt.label,
                distance = distance,
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

Bridge.AddTargetBone = function(bones, options, distance)
    local distance = distance or 2.0
    if type(bones) ~= "table" then bones = { bones } end

    if Bridge.Target == 'ox' then
        local oxOptions = {}
        for _, opt in ipairs(options) do
            table.insert(oxOptions, {
                name = opt.name or opt.label,
                icon = opt.icon,
                label = opt.label,
                distance = distance,
                bones = bones,
                onSelect = function(data)
                    if opt.action then opt.action(data.entity) end
                end,
                canInteract = opt.canInteract
            })
        end
        exports.ox_target:addGlobalVehicle(oxOptions)
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
        exports['qb-target']:AddTargetBone(bones, {
            options = qbOptions,
            distance = distance
        })
    end
end

--- Bridge.AddTargetBone('boot', {
---     {
---         name = 'open_trunk',
---         label = 'Bagajı Aç',
---         icon = 'fas fa-box-open',
---         action = function(entity)
---             SetVehicleDoorOpen(entity, 5, false, false)
---         end,
---         canInteract = function(entity)
---             return DoesEntityExist(entity) and GetVehicleDoorAngleRatio(entity, 5) == 0.0
---         end
---     }
--- }, 2.5)
---
--- Bridge.AddTargetBone({ 'bonnet', 'engine' }, {
---     {
---         name = 'inspect_engine',
---         label = 'Motoru İncele',
---         icon = 'fas fa-wrench',
---         action = function(entity)
---             print("Motor inceleniyor. Araç ID:", entity)
---         end,
---         canInteract = function(entity)
---             return DoesEntityExist(entity) and not IsEntityDead(entity)
---         end
---     }
--- }, 2.0)

Bridge.AddCircleZone = function(name, center, radius, options, targetOptions, distance)
    local radius = radius or 1.0
    local options = options or {}
    local distance = distance or 2.0

    -- --- OX TARGET ---
    if Bridge.Target == 'ox' then
        local oxOptions = {}
        for _, opt in ipairs(targetOptions) do
            table.insert(oxOptions, {
                name = opt.name or opt.label,
                icon = opt.icon,
                label = opt.label,
                distance = distance,
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
            drawSprite = options.drawSprite or false,
            options = oxOptions
        })
        
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
                drawSprite = options.drawSprite or false
            },
            {
                options = qbOptions,
                distance = distance
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
--     },
--   2.0
-- )

Bridge.RemoveZone = function(zoneId)
    if not zoneId then return end

    if Bridge.Target == 'ox' then
        exports.ox_target:removeZone(zoneId)
    elseif Bridge.Target == 'qb' then
        exports['qb-target']:RemoveZone(zoneId)
    end
end

Bridge.SpawnPedWithTarget = function(model, coords, targetOptions, distance, isNetworked)
    local modelHash = type(model) == 'string' and GetHashKey(model) or model
    local isNetworked = isNetworked or false
    local distance = distance or 2.0
    if not HasModelLoaded(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Wait(10)
        end
    end

    -- 2. Ped Oluşturma
    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w or 0.0, isNetworked, false)

    SetEntityHeading(ped, coords.w or 0.0)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(modelHash)

    -- 3. Target Ekleme
    if targetOptions and #targetOptions > 0 then
        -- OX TARGET
        if Bridge.Target == 'ox' then
            local oxOptions = {}
            for _, opt in ipairs(targetOptions) do
                table.insert(oxOptions, {
                    name = opt.name or opt.label,
                    icon = opt.icon,
                    label = opt.label,
                    distance = distance,
                    onSelect = function(data)
                        if opt.action then opt.action(data.entity, data.distance, data.coords) end
                    end,
                    canInteract = opt.canInteract
                })
            end

            exports.ox_target:addLocalEntity(ped, oxOptions)

        -- QB TARGET
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

            exports['qb-target']:AddTargetEntity(ped, {
                options = qbOptions,
                distance = distance
            })
        end
    end

    return ped
end


--- local ped = Bridge.SpawnPedWithTarget(
---     'a_m_y_business_01',
---     vec4(145.2, -1035.4, 29.3, 160.0),
---     {
---         {
---             label = 'Konuş',
---             icon = 'fas fa-comments',
---             action = function(entity)
---                 print("NPC ile konuşuldu:", entity)
---             end,
---             canInteract = function(entity)
---                 return not IsPedDeadOrDying(entity, true)
---             end
---         }
---     },
---     2.0
--- )