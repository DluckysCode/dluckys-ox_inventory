if not lib then return end

-- /admininventory: panel de admin + modo para colocar objetos en 3D + blips en el mapa
local benchTemplates = {}
for _, b in ipairs(lib.load('data.rust_crafting').benches or {}) do benchTemplates[b.id] = b end

local currentTab = 'world'

local function server(action, d)
    local ok, err = lib.callback.await('ox_inventory:rustAdminAction', false, action, d)
    return { ok = ok == true, error = err }
end

local function showPanel()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'rustAdmin', data = { open = true, tab = currentTab } })
end

local function hidePanel()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'rustAdmin', data = { open = false } })
end

RegisterNetEvent('ox_inventory:rustAdminOpen', showPanel)
RegisterNUICallback('rustAdminClose', function(_, cb)
    cb(1)
    hidePanel()
end)

RegisterNUICallback('rustAdminTab', function(d, cb)
    currentTab = d.tab
    cb(lib.callback.await('ox_inventory:rustAdminData', false, d.tab) or {})
end)

---------------------------------------------------------------------
-- Modo colocar con ajuste fino
---------------------------------------------------------------------
local CONTROLS = { 24, 25, 14, 15, 37, 44, 140, 141, 142, 172, 173, 174, 175, 10, 11 }
local HELP = '[Click] Colocar · [Rueda] Girar · [Q] Fijar posición · [Flechas] Mover · [RePág/AvPág] Altura · [Shift] Fino · [Click der.] Cancelar'

--- Vista previa transparente del modelo donde miras; devuelve { x, y, z, h } o nil si se cancela
local function place(model, heading)
    lib.requestModel(model)
    local p = GetEntityCoords(cache.ped)
    local obj = CreateObject(model, p.x, p.y, p.z, false, false, false)
    SetEntityAlpha(obj, 170, false)
    SetEntityCollision(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)

    heading = heading or GetEntityHeading(cache.ped)
    local locked, pos, lift = false, nil, 0.0
    local result

    lib.showTextUI(HELP, { icon = 'arrows-up-down-left-right' })

    while true do
        for i = 1, #CONTROLS do DisableControlAction(0, CONTROLS[i], true) end
        local fine = IsControlPressed(0, 21) -- Shift

        if not locked then
            local hit, _, coords = lib.raycast.cam(1 | 16, 4, 20.0)
            if hit then pos = coords end
        else
            -- con la posición fija, las flechas la mueven respecto a la cámara
            local step = fine and 0.003 or 0.015
            local rot = math.rad(GetGameplayCamRot(2).z)
            local fwd, right = vec3(-math.sin(rot), math.cos(rot), 0), vec3(math.cos(rot), math.sin(rot), 0)
            if IsDisabledControlPressed(0, 172) then pos += fwd * step end
            if IsDisabledControlPressed(0, 173) then pos -= fwd * step end
            if IsDisabledControlPressed(0, 175) then pos += right * step end
            if IsDisabledControlPressed(0, 174) then pos -= right * step end
        end

        local up = fine and 0.002 or 0.01
        if IsDisabledControlPressed(0, 10) then lift += up end
        if IsDisabledControlPressed(0, 11) then lift -= up end
        if IsDisabledControlJustPressed(0, 44) and pos then locked = not locked end

        local turn = fine and 1.0 or 15.0
        if IsDisabledControlJustPressed(0, 15) then heading += turn end
        if IsDisabledControlJustPressed(0, 14) then heading -= turn end

        if pos then
            SetEntityCoordsNoOffset(obj, pos.x, pos.y, pos.z + lift, false, false, false)
            SetEntityHeading(obj, heading % 360.0)
        end

        if pos and IsDisabledControlJustPressed(0, 24) then
            result = { x = pos.x, y = pos.y, z = pos.z + lift, h = heading % 360.0 }
            break
        end
        if IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 177) then break end

        Wait(0)
    end

    lib.hideTextUI()
    DeleteEntity(obj)
    return result
end

--- Oculta el panel, coloca, manda al servidor y vuelve a abrir el panel
local function placeAndSend(action, model, extra, heading)
    hidePanel()
    local res = { ok = false }
    local p = place(model, heading)
    if p then
        for k, v in pairs(extra) do p[k] = v end
        res = server(action, p)
        lib.notify({ type = res.ok and 'success' or 'error', description = res.ok and 'Guardado' or (res.error or 'No se pudo guardar') })
    end
    showPanel()
    return res
end

---------------------------------------------------------------------
-- Blips temporales en el mapa (se quitan solos a los 5 minutos)
---------------------------------------------------------------------
local mapBlips = {}

local function clearMap()
    for i = 1, #mapBlips do RemoveBlip(mapBlips[i]) end
    mapBlips = {}
end

local function blip(x, y, z, sprite, colour, label)
    local b = AddBlipForCoord(x, y, z)
    SetBlipSprite(b, sprite)
    SetBlipColour(b, colour)
    SetBlipScale(b, 0.7)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(b)
    mapBlips[#mapBlips + 1] = b
end

local function showMap()
    local data = lib.callback.await('ox_inventory:rustAdminMap', false)
    if not data then return false end
    clearMap()
    for _, b in ipairs(data.benches) do blip(b.x, b.y, b.z, 566, 31, ('[Admin] %s'):format(b.label)) end
    local mine = mapBlips
    SetTimeout(300000, function() if mapBlips == mine then clearMap() end end)
    return true
end

---------------------------------------------------------------------
-- Acciones del panel
---------------------------------------------------------------------
RegisterNUICallback('rustAdminAction', function(d, cb)
    local a = d.action

    if a == 'addBench' then
        local t = benchTemplates[d.template]
        return cb(t and placeAndSend('addBench', t.model, { template = d.template }) or {})
    elseif a == 'moveBench' then
        local t = benchTemplates[d.template]
        return cb(t and placeAndSend('moveBench', t.model, { id = d.id }, d.h) or {})
    elseif a == 'goto' then
        hidePanel()
        SetEntityCoords(cache.ped, d.x, d.y, d.z + 0.5, false, false, false, false)
        return cb({ ok = true })
    elseif a == 'map' then
        if d.on then return cb({ ok = showMap() }) end
        clearMap()
        return cb({ ok = true })
    elseif a == 'viewPlayer' then
        hidePanel() -- se abre el inventario de ox en su lugar
        return cb(server(a, d))
    end

    cb(server(a, d)) -- el resto va directo al servidor (eliminar, dar items, planos, recetas…)
end)

AddEventHandler('onResourceStop', function(res)
    if res == cache.resource then clearMap() end
end)
