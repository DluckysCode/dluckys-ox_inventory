if not lib then return end

-- Registrar a otro jugador: la interfaz pide su equipo puesto y lo quita (todo lo valida el servidor)
RegisterNUICallback('rustSearchGear', function(d, cb)
    cb(lib.callback.await('ox_inventory:rustSearchGear', false, d.target) or false)
end)

RegisterNUICallback('rustSearchTake', function(d, cb)
    local ok, err = lib.callback.await('ox_inventory:rustSearchTake', false, d.target, d.what)
    PlaySoundFrontend(-1, ok and 'PICK_UP' or 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    cb({ ok = ok == true, error = err })
end)
