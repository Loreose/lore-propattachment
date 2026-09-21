Bridge.FaceCoords = function(targetCoords, duration)
    if not targetCoords then return end

    local ped = PlayerPedId()
    local duration = duration or 1000

    TaskTurnPedToFaceCoord(ped, targetCoords.x, targetCoords.y, targetCoords.z, duration)
    return true
end
