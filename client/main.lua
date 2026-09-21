AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
end)

local isEditing = false
local currentProp = nil
local currentBone = nil

local posX, posY, posZ = 0.0, 0.0, 0.0
local rotX, rotY, rotZ = 0.0, 0.0, 0.0

local function attachAndEdit(modelName, boneId)
    local ped = PlayerPedId()
    local model = GetHashKey(modelName)

    if not IsModelValid(model) then
        print("Invalid model!")
        return
    end

    if not HasModelLoaded(model) then
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(10)
        end
    end

    if currentProp then
        DeleteEntity(currentProp)
    end

    local coords = GetEntityCoords(ped)
    currentProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    currentBone = tonumber(boneId)

    posX, posY, posZ = 0.0, 0.0, 0.0
    rotX, rotY, rotZ = 0.0, 0.0, 0.0

    AttachEntityToEntity(currentProp, ped, GetPedBoneIndex(ped, currentBone), posX, posY, posZ, rotX, rotY, rotZ, true, true, false, true, 1, true)

    isEditing = true

    CreateThread(function()
        while isEditing do
            Wait(0)
            
            -- Instruction text
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0, 0.3)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString("~y~WASD~w~: Move X/Y | ~y~Q/E~w~: Move Z | ~y~Arrows~w~: Rot X/Y | ~y~Z/C~w~: Rot Z | ~g~ENTER~w~: Save & Print | ~r~BACKSPACE~w~: Cancel")
            DrawText(0.01, 0.3)

            -- Show current values
            SetTextFont(0)
            SetTextProportional(1)
            SetTextScale(0.0, 0.3)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(string.format("Offset: X: %.3f, Y: %.3f, Z: %.3f~n~Rot: X: %.3f, Y: %.3f, Z: %.3f", posX, posY, posZ, rotX, rotY, rotZ))
            DrawText(0.01, 0.35)

            local changed = false
            local speed = 0.01
            if IsControlPressed(0, 21) then -- Shift for faster movement
                speed = 0.05
            end

            -- Move X/Y (WASD)
            if IsControlPressed(0, 32) then posY = posY + speed changed = true end -- W
            if IsControlPressed(0, 33) then posY = posY - speed changed = true end -- S
            if IsControlPressed(0, 34) then posX = posX - speed changed = true end -- A
            if IsControlPressed(0, 35) then posX = posX + speed changed = true end -- D

            -- Move Z (Q/E)
            if IsControlPressed(0, 44) then posZ = posZ + speed changed = true end -- Q
            if IsControlPressed(0, 46) then posZ = posZ - speed changed = true end -- E

            -- Rotate X/Y (Arrows)
            if IsControlPressed(0, 172) then rotX = rotX + (speed * 50) changed = true end -- Up
            if IsControlPressed(0, 173) then rotX = rotX - (speed * 50) changed = true end -- Down
            if IsControlPressed(0, 174) then rotY = rotY - (speed * 50) changed = true end -- Left
            if IsControlPressed(0, 175) then rotY = rotY + (speed * 50) changed = true end -- Right

            -- Rotate Z (Z/C)
            if IsControlPressed(0, 20) then rotZ = rotZ + (speed * 50) changed = true end -- Z
            if IsControlPressed(0, 26) then rotZ = rotZ - (speed * 50) changed = true end -- C

            if changed then
                AttachEntityToEntity(currentProp, ped, GetPedBoneIndex(ped, currentBone), posX, posY, posZ, rotX, rotY, rotZ, true, true, false, true, 1, true)
            end

            -- Enter to save
            if IsControlJustPressed(0, 18) then
                isEditing = false
                print("^2[Prop System] ^7Saved to F8 console.")
                print(string.format("^3Model^7: %s | ^3Bone^7: %s", modelName, currentBone))
                print(string.format("^3Offset^7: vec3(%.4f, %.4f, %.4f)", posX, posY, posZ))
                print(string.format("^3Rotation^7: vec3(%.4f, %.4f, %.4f)", rotX, rotY, rotZ))
            end
            
            -- Backspace to cancel
            if IsControlJustPressed(0, 177) then
                isEditing = false
                DeleteEntity(currentProp)
                currentProp = nil
                print("^1[Prop System] ^7Cancelled.")
            end
        end
    end)
end

RegisterCommand('propattach', function(source, args)
    if #args < 2 then
        print("^1[Prop System] ^7Usage: /propattach [model] [boneid]")
        return
    end

    local model = args[1]
    local boneId = args[2]

    attachAndEdit(model, boneId)
end, false)

RegisterCommand('playanim', function(source, args)
    if #args < 2 then
        print("^1[Anim System] ^7Usage: /playanim [dict] [clip] [flag]")
        return
    end

    local dict = args[1]
    local clip = args[2]
    local flag = tonumber(args[3]) or 1 -- Default to 1 (Normal playback)

    local ped = PlayerPedId()

    if not DoesAnimDictExist(dict) then
        print("^1[Anim System] ^7Animation dictionary does not exist: " .. dict)
        return
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(ped, dict, clip, 8.0, -8.0, -1, flag, 0, false, false, false)
    print(string.format("^2[Anim System] ^7Playing: %s / %s", dict, clip))
end, false)

RegisterCommand('stopanim', function()
    ClearPedTasks(PlayerPedId())
    print("^2[Anim System] ^7Animations cleared.")
end, false)
