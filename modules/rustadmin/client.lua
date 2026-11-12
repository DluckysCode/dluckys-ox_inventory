if not lib then return end

-- /inventory: panel de admin + modo para colocar objetos en 3D
local lootTypes = lib.load('data.rust_loot').types
local data -- última respuesta del servidor (mesas, tipos, puntos)

local function refresh()
    data = lib.callback.await('ox_inventory:rustAdminData', false)
    return data
end

local function openPanel()
    if not refresh() then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'rustAdmin', data = data })
end

local function hidePanel()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'rustAdmin', data = false })
end

RegisterNetEvent('ox_inventory:rustAdminOpen', openPanel)
RegisterNUICallback('rustAdminClose', function(_, cb)
    cb(1)
    hidePanel()
end)

---------------------------------------------------------------------
-- Modo colocar: vista previa transparente donde miras
-- Rueda = girar (Shift = fino) · Click izq = colocar · Click der / Retroceso = cancelar
---------------------------------------------------------------------
local HELP = '[Click] Colocar  ·  [Rueda] Girar (Shift = fino)  ·  [Click der.] Cancelar'

local function place(model, heading)
    lib.requestModel(model)
    local start = GetEntityCoords(cache.ped)
    local obj = CreateObject(model, start.x, start.y, start.z, false, false, false)
    SetEntityAlpha(obj, 170, false)
    SetEntityCollision(obj, false, false)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)

    heading = heading or GetEntityHeading(cache.ped)
    local result
    lib.showTextUI(HELP, { icon = 'arrows-up-down-left-right' })

    while true do
        -- que el mouse no dispare ni cambie de arma mientras colocas
        DisableControlAction(0, 24, true)  -- atacar
        DisableControlAction(0, 25, true)  -- apuntar
        DisableControlAction(0, 14, true)  -- rueda abajo (arma)
        DisableControlAction(0, 15, true)  -- rueda arriba (arma)
        DisableControlAction(0, 37, true)  -- rueda de armas
        DisableControlAction(0, 140, true) -- golpes cuerpo a cuerpo
        DisableControlAction(0, 141, true)
        DisableControlAction(0, 142, true)

        local hit, _, coords = lib.raycast.cam(1 | 16, 4, 15.0)
        if hit then
            SetEntityCoordsNoOffset(obj, coords.x, coords.y, coords.z, false, false, false)
        end

        local step = IsControlPressed(0, 21) and 1.0 or 15.0 -- Shift = fino
        if IsDisabledControlJustPressed(0, 15) then heading = heading + step end
        if IsDisabledControlJustPressed(0, 14) then heading = heading - step end
        SetEntityHeading(obj, heading % 360.0)

        if hit and IsDisabledControlJustPressed(0, 24) then
            result = { x = coords.x, y = coords.y, z = coords.z, h = heading % 360.0 }
            break
        end
        if IsDisabledControlJustPressed(0, 25) or IsControlJustPressed(0, 177) then break end

        Wait(0)
    end

    lib.hideTextUI()
    DeleteEntity(obj)
    return result
end

local function templateModel(id)
    for _, t in ipairs(data.templates) do
        if t.id == id then return t.model end
    end
end

local function benchById(id)
    for _, b in ipairs(data.benches) do
        if b.id == id then return b end
    end
end

local function lootById(id)
    for _, p in ipairs(data.loot) do
        if p.id == id then return p end
    end
end

--- Oculta el panel, deja colocar el objeto y lo manda al servidor; luego vuelve a abrir el panel
local function placeAndSend(action, model, extra, heading)
    hidePanel()
    local pos = place(model, heading)
    if pos then
        for k, v in pairs(extra) do pos[k] = v end
        local ok = lib.callback.await('ox_inventory:rustAdminAction', false, action, pos)
        lib.notify({ type = ok and 'success' or 'error', description = ok and 'Guardado' or 'No se pudo guardar' })
    end
    openPanel()
end

RegisterNUICallback('rustAdminAction', function(d, cb)
    cb(1)
    if not data then return end
    local a = d.action

    if a == 'addBench' then
        local model = templateModel(d.template)
        if model then placeAndSend('addBench', model, { template = d.template }) end
    elseif a == 'moveBench' then
        local b = benchById(d.id)
        local model = b and templateModel(b.template)
        if model then placeAndSend('moveBench', model, { id = b.id }, b.h) end
    elseif a == 'addLoot' then
        local t = lootTypes[d.type]
        if t then placeAndSend('addLoot', t.model, { type = d.type }) end
    elseif a == 'moveLoot' then
        local p = lootById(d.id)
        local t = p and lootTypes[p.t]
        if t then placeAndSend('moveLoot', t.model, { id = p.id }) end
    elseif a == 'removeBench' or a == 'removeLoot' then
        lib.callback.await('ox_inventory:rustAdminAction', false, a, { id = d.id })
        openPanel()
    elseif a == 'goto' then
        local target = benchById(d.id) or lootById(d.id)
        if target then
            hidePanel()
            SetEntityCoords(cache.ped, target.x, target.y, target.z + 0.5, false, false, false, false)
        end
    end
end)
