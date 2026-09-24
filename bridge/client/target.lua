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

Bridge.AddCircleZone = function(name, center, radius, options, targetOptions, distance)
    local radius = radius or 1.0
    local options = options or {}
    local distance = distance or 2.0

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

    local ped = CreatePed(4, modelHash, coords.x, coords.y, coords.z - 1.0, coords.w or 0.0, isNetworked, false)

    SetEntityHeading(ped, coords.w or 0.0)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(modelHash)

    if targetOptions and #targetOptions > 0 then
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