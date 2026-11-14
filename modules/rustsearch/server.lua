if not lib then return end

-- Registrar a otro jugador: además de su inventario, quitarle el equipo puesto (chaleco y mochila).
-- Solo vale si tienes su inventario abierto (ox ya comprobó que está caído/amarrado o que eres policía)
-- y estás a su lado.
local Inventory = require 'modules.inventory.server'
local Clothes = require 'modules.rustclothes.server'
local Backpack = require 'modules.rustbackpack.server'
local Log = require 'modules.rustlog.server'

local function canSearch(source, target)
    target = tonumber(target)
    if not target or target == source or not GetPlayerName(target) then return end
    local inv = Inventory(source)
    if not inv or inv.open ~= target then return end
    local dist = #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(GetPlayerPed(target)))
    return dist <= 4.0 and target or nil
end

lib.callback.register('ox_inventory:rustSearchGear', function(source, target)
    target = canSearch(source, target)
    if not target then return end
    return { vest = Clothes.vest(target), backpack = Backpack.backpack(target) }
end)

local take = {
    vest = function(target, source) return Clothes.takeVest(target, source) end,
    backpack = function(target, source) return Backpack.takeBackpack(target, source) end,
}
local names = { vest = 'el chaleco', backpack = 'la mochila' }

lib.callback.register('ox_inventory:rustSearchTake', function(source, target, what)
    target = canSearch(source, target)
    if not target or not take[what] then return false, 'No puedes hacer eso' end

    local ok, err = take[what](target, source)
    if ok then
        Log.add('steal', source, ('Le quitó %s a %s (%s)'):format(names[what], GetPlayerName(target), target))
        TriggerClientEvent('ox_lib:notify', target, { type = 'error', description = ('Te quitaron %s'):format(names[what]) })
    end
    return ok, err
end)
