Bridge = {
    Framework = nil, -- 'qb' | 'esx'
    Inventory = nil, -- 'ox' | 'qb'
    Target = nil,    -- 'ox' | 'qb'
    HasOxLib = GetResourceState('ox_lib') == 'started'
}

local function InitBridge()
    if GetResourceState('qb-core') == 'started' then
        Bridge.Framework = 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        Bridge.Framework = 'esx'
    end

    if GetResourceState('ox_inventory') == 'started' then
        Bridge.Inventory = 'ox'
    elseif GetResourceState('qb-inventory') == 'started' or GetResourceState('ps-inventory') == 'started' then
        Bridge.Inventory = 'qb'
    end

    if GetResourceState('ox_target') == 'started' then
        Bridge.Target = 'ox'
    elseif GetResourceState('qb-target') == 'started' then
        Bridge.Target = 'qb'
    end

    print(string.format('^2[Bridge Init]^7 Framework: %s | Inventory: %s | Target: %s',
        Bridge.Framework or 'None',
        Bridge.Inventory or 'None',
        Bridge.Target or 'None'
    ))
end

InitBridge()
