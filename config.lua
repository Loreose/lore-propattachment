Config = {}

Config.Debug = true


function debug(...)
    if Config.Debug then print("^3[DEBUG]^7", ...) end
end