if not lib then return end

local util = require 'modules.rustutil.client'

-- La interfaz necesita saber cuál es el slot Mochila (el último slot normal)
util.onInventory(function(open)
    if open then SendNUIMessage({ action = 'rustBackpack', data = { base = shared.playerslots } }) end
end)

-- Cómo se ve la mochila puesta (componente 5). false = quitarla.
RegisterNetEvent('ox_inventory:rustBackpackLook', function(clothing)
    local model = GetEntityModel(cache.ped)
    local gender = model == `mp_m_freemode_01` and 'male' or model == `mp_f_freemode_01` and 'female'
    if not gender then return end

    local look = clothing and clothing[gender]
    if look then
        SetPedComponentVariation(cache.ped, 5, look[1], look[2] or 0, 0)
    else
        SetPedComponentVariation(cache.ped, 5, 0, 0, 0)
    end
end)

-- Mochila llena (todos sus slots ocupados): no puedes correr (el servidor marca rustBagFull)
AddStateBagChangeHandler('rustBagFull', ('player:%s'):format(cache.serverId), function(_, _, full)
    if not full then return end
    lib.notify({ type = 'inform', description = 'Mochila llena: no puedes correr' })

    CreateThread(function()
        while LocalPlayer.state.rustBagFull do
            DisableControlAction(0, 21, true) -- correr (Shift)
            Wait(0)
        end
    end)
end)

-- Usar una mochila que no llevas puesta: se abre su contenido
RegisterNetEvent('ox_inventory:rustBackpackOpen', function(bagId)
    exports.ox_inventory:openInventory('stash', bagId)
end)
