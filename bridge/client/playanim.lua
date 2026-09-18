Bridge.PlayAnim = function(dict, anim, duration, flag, propModel, bone, pos, rot)
    local ped = PlayerPedId()
    local propEntity = nil

    if dict and not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end

    if propModel then
        local modelHash = type(propModel) == 'string' and GetHashKey(propModel) or propModel

        if not HasModelLoaded(modelHash) then
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do
                Wait(10)
            end
        end

        local coords = GetEntityCoords(ped)
        propEntity = CreateObject(modelHash, coords.x, coords.y, coords.z, true, true, false)

        local boneIndex = bone or 28422
        local offsetPos = pos or vec3(0.0, 0.0, 0.0)
        local offsetRot = rot or vec3(0.0, 0.0, 0.0)

        AttachEntityToEntity(
            propEntity, ped, GetPedBoneIndex(ped, boneIndex),
            offsetPos.x, offsetPos.y, offsetPos.z,
            offsetRot.x, offsetRot.y, offsetRot.z,
            true, true, false, true, 1, true
        )

        SetModelAsNoLongerNeeded(modelHash)
    end

    if dict and anim then
        TaskPlayAnim(
            ped,
            dict,
            anim,
            8.0, -8.0,
            duration or -1,
            flag or 49,
            0,
            false, false, false
        )
        RemoveAnimDict(dict)
    end

    return propEntity
end

--- local prop = Bridge.PlayAnim(
---     'amb@world_human_drinking@coffee@male@idle_a',
---     'idle_c',
---     -1,
---     49,
---     'p_amb_coffeecup_01',
---     28422,
---     vec3(0.12, 0.008, 0.03),
---     vec3(-80.0, 0.0, 0.0)
--- )

Bridge.StopAnim = function(propEntity)
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if propEntity and DoesEntityExist(propEntity) then
        DetachEntity(propEntity, true, true)
        DeleteEntity(propEntity)
    end
end
