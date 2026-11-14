if not lib then return end

local config = lib.load('data.rust_clothing')
local slotById = {}
for _, s in ipairs(config.slots) do slotById[s.id] = s end

local function notify(msg)
    if not msg then return end
    PlaySoundFrontend(-1, 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    lib.notify({ type = 'error', description = msg })
end

local function saveAppearance()
    PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    if GetResourceState('illenium-appearance') ~= 'started' then return end
    local appearance = exports['illenium-appearance']:getPedAppearance(cache.ped)
    TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
end

local function gender()
    local model = GetEntityModel(cache.ped)
    if model == `mp_m_freemode_01` then return 'male' end
    if model == `mp_f_freemode_01` then return 'female' end
end

local function isWorn(g, slot)
    if slot.armour then return LocalPlayer.state.rustVest == true end
    if not g then return false end
    if slot.prop then return GetPedPropIndex(cache.ped, slot.prop) ~= -1 end
    return GetPedDrawableVariation(cache.ped, slot.comp) ~= (config.naked[g][slot.comp] or 0)
end

local function sendClothing()
    local g = gender()
    local slots = {}
    for i, s in ipairs(config.slots) do
        slots[i] = {
            id = s.id, label = s.label, side = s.side, image = s.image, worn = isWorn(g, s),
            accepts = s.armour and config.armour.item or config.item, -- qué item se puede soltar en la ranura
        }
    end
    SendNUIMessage({ action = 'rustClothing', data = { slots = slots } })
end

local function stripSlot(g, slot)
    if slot.prop then return ClearPedProp(cache.ped, slot.prop) end
    SetPedComponentVariation(cache.ped, slot.comp, config.naked[g][slot.comp] or 0, 0, 0)
    for _, extra in ipairs(slot.extra or {}) do
        SetPedComponentVariation(cache.ped, extra, config.naked[g][extra] or 0, 0, 0)
    end
end

local function applyData(data)
    for _, c in ipairs(data.comps or {}) do
        SetPedComponentVariation(cache.ped, c[1], c[2], c[3] or 0, 0)
    end
    for _, p in ipairs(data.props or {}) do
        SetPedPropIndex(cache.ped, p[1], p[2], p[3] or 0, true)
    end
end

local function readComp(ped, id) return { id, GetPedDrawableVariation(ped, id), GetPedTextureVariation(ped, id) } end

--- Lee lo que llevas puesto en una ranura (nil si no llevas nada)
local function readSlot(g, slot)
    if not isWorn(g, slot) then return end
    local ped = cache.ped
    if slot.prop then
        return { props = { { slot.prop, GetPedPropIndex(ped, slot.prop), GetPedPropTextureIndex(ped, slot.prop) } } }
    end
    local comps = { readComp(ped, slot.comp) }
    for _, extra in ipairs(slot.extra or {}) do comps[#comps + 1] = readComp(ped, extra) end
    return { comps = comps }
end

--- Chaleco antibalas: lo maneja el servidor (protección incluida)
local function armourAction(event, ...)
    local ok, err = lib.callback.await(event, false, ...)
    if ok then PlaySoundFrontend(-1, 'NAV_LEFT_RIGHT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true) else notify(err) end
end

RegisterNUICallback('rustClothesTakeOff', function(data, cb)
    cb(1)
    local slot = slotById[data.kind]
    if not slot then return end
    if slot.armour then return armourAction('ox_inventory:rustArmourTakeOff', data.slot) end
    local g = gender()
    local current = readSlot(g, slot)
    if not current then return notify('No llevas nada ahí') end

    local ok, err = lib.callback.await('ox_inventory:rustClothesTakeOff', false, data.kind, g, current, data.slot)
    if ok then
        stripSlot(g, slot)
        saveAppearance()
    else
        notify(err or 'No se pudo quitar la prenda')
    end
    sendClothing()
end)

RegisterNUICallback('rustClothesEquip', function(data, cb)
    cb(1)
    local slot = slotById[data.kind]
    if not slot then return end
    if slot.armour then return armourAction('ox_inventory:rustArmourEquip', data.slot) end
    local g = gender()
    local ok, res = lib.callback.await('ox_inventory:rustClothesEquip', false, data.slot, data.kind, g, readSlot(g, slot))
    if ok and res then
        applyData(res)
        saveAppearance()
    else
        notify(res or 'No se pudo poner la prenda')
    end
    sendClothing()
end)

-- El servidor pone o quita el chaleco: cómo se ve y vigilar si se rompe (protección en 0)
RegisterNetEvent('ox_inventory:rustArmourLook', function(on)
    local g = gender()
    if g then
        local look = on and config.armour.look[g]
        SetPedComponentVariation(cache.ped, 9, look and look[1] or config.naked[g][9] or 0, look and look[2] or 0, 0)
    end
    sendClothing()

    if not on then return end
    CreateThread(function()
        while LocalPlayer.state.rustVest do
            Wait(1000)
            if GetPedArmour(cache.ped) <= 0 then
                TriggerServerEvent('ox_inventory:rustArmourBroken')
                break
            end
        end
    end)
end)

---------------------------------------------------------------------
-- Cámara que muestra al personaje a la izquierda de la pantalla
---------------------------------------------------------------------
local cam = config.camera or {}
local camHandle

local function startCam()
    if cam.enabled == false or camHandle then return end
    local ped = cache.ped
    if IsPedInAnyVehicle(ped, false) or IsEntityDead(ped) then return end

    camHandle = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    local o, t = cam.offset or vec3(-2.05, 4.3, -0.5), cam.target or vec3(-2.05, 0.0, -0.58)
    local fov = cam.fov or 45.0
    local side = o.x

    if cam.auto ~= false then
        -- Calcula dónde cae el hueco entre las ranuras de ropa según la pantalla.
        -- La interfaz mide en "alto de pantalla": margen 3% del ancho + ranuras + mitad del hueco.
        local w, h = GetActiveScreenResolution()
        local aspect = w / h
        local pedX = 0.03 * aspect + 0.26            -- centro del hueco, en altos de pantalla
        local metersPerScreen = 2 * o.y * math.tan(math.rad(fov / 2))
        side = -(aspect / 2 - pedX) * metersPerScreen
    end

    AttachCamToEntity(camHandle, ped, side, o.y, o.z, true)
    PointCamAtEntity(camHandle, ped, side + (t.x - o.x), t.y, t.z, true)
    SetCamFov(camHandle, fov)
    RenderScriptCams(true, true, 400, true, false)
end

local function stopCam()
    if not camHandle then return end
    RenderScriptCams(false, true, 400, true, false)
    DestroyCam(camHandle, false)
    camHandle = nil
end

require 'modules.rustutil.client'.onInventory(function(open)
    if not open then return stopCam() end
    startCam()
    sendClothing()
end)

AddEventHandler('onResourceStop', function(res)
    if res == cache.resource then stopCam() end
end)
