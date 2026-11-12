if not lib then return end

local Inventory = require 'modules.inventory.server'
local config = lib.load('data.rust_storage')

-- Lista de cajas colocadas, guardada en KVP: { [id] = { id, item, owner, x, y, z, h } }
local KVP = 'rustbox:list'
local boxes = json.decode(GetResourceKvpString(KVP) or '{}') or {}

local function save()
    SetResourceKvp(KVP, json.encode(boxes))
    GlobalState.rustBoxes = boxes
end

local function register(box)
    local t = config.types[box.item]
    if not t then return end
    exports.ox_inventory:RegisterStash(box.id, t.label, t.slots, t.maxWeight,
        config.ownerOnly and box.owner or nil, nil, vec3(box.x, box.y, box.z))
end

---------------------------------------------------------------------
-- Limpieza: si el dueño no se conecta en X días, su caja desaparece
---------------------------------------------------------------------
local SEEN_KVP = 'rustbox:seen'
local seen = json.decode(GetResourceKvpString(SEEN_KVP) or '{}') or {}

local function markSeen(owner)
    if not owner then return end
    seen[owner] = os.time()
    SetResourceKvp(SEEN_KVP, json.encode(seen))
end

local function cleanup()
    local days = config.abandonDays or 0
    if days <= 0 then return end

    local limit, removed = os.time() - days * 86400, 0
    for id, box in pairs(boxes) do
        if (seen[box.owner] or 0) < limit then
            exports.ox_inventory:ClearInventory(id)
            boxes[id] = nil
            removed += 1
        end
    end
    if removed > 0 then
        save()
        print(('[rustbox] Se quitaron %d cajas abandonadas (dueño sin conectarse %d días)'):format(removed, days))
    end
end

-- Al entrar con el personaje se marca que el dueño sigue activo
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(5000, function()
        local inv = Inventory(src)
        if inv then markSeen(inv.owner) end
    end)
end)

CreateThread(function()
    while not shared.ready do Wait(100) end

    -- Cajas que no tienen fecha (de antes de esta función) cuentan desde hoy
    for _, box in pairs(boxes) do
        if box.owner and not seen[box.owner] then seen[box.owner] = os.time() end
    end
    SetResourceKvp(SEEN_KVP, json.encode(seen))

    cleanup()
    for _, box in pairs(boxes) do register(box) end
    GlobalState.rustBoxes = boxes

    while true do
        Wait(3600000) -- revisa cada hora
        cleanup()
    end
end)

local function countOwned(owner)
    local n = 0
    for _, b in pairs(boxes) do if b.owner == owner then n += 1 end end
    return n
end

-- Usar el item = colocar la caja delante del jugador (data/items.lua -> server.export)
exports('rustPlaceBox', function(event, item, inventory)
    if event ~= 'usingItem' then return end

    local source, owner = inventory.id, inventory.owner
    local t = config.types[item.name]
    if not t or not owner then return false end

    if countOwned(owner) >= (config.maxPerPlayer or 5) then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Ya tienes demasiadas cajas colocadas' })
        return false
    end

    local ped = GetPlayerPed(source)
    if GetVehiclePedIsIn(ped, false) ~= 0 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'No puedes colocarla dentro de un vehículo' })
        return false
    end

    local pos, h = GetEntityCoords(ped), GetEntityHeading(ped)
    local r = math.rad(h)
    local id = ('rustbox_%s_%d'):format(os.time(), math.random(1000, 9999))

    local box = {
        id = id,
        item = item.name,
        owner = owner,
        x = pos.x - math.sin(r) * 1.2,
        y = pos.y + math.cos(r) * 1.2,
        z = pos.z - 1.0,
        h = h,
    }

    boxes[id] = box
    register(box)
    save()
    markSeen(owner)
    return true -- se consume el item
end)

-- Recoger la caja: solo el dueño y solo si está vacía
lib.callback.register('ox_inventory:rustBoxPickup', function(source, id)
    local box = boxes[id]
    if not box then return false end

    local inv = Inventory(source)
    if not inv or inv.owner ~= box.owner then return false, 'Esta caja no es tuya' end

    local pos = GetEntityCoords(GetPlayerPed(source))
    if #(pos - vec3(box.x, box.y, box.z)) > (config.interactDistance or 2.0) + 1.5 then return false, 'Estás muy lejos' end

    -- se carga desde la base de datos aunque nadie la haya abierto todavía
    local stash = Inventory(id, nil, true)
    if not stash then return false, 'No se pudo revisar la caja' end
    if next(stash.items) then return false, 'Vacía la caja antes de recogerla' end

    if not Inventory.CanCarryItem(source, box.item, 1) then return false, 'Inventario lleno' end

    boxes[id] = nil
    save()
    Inventory.AddItem(source, box.item, 1)
    return true
end)
