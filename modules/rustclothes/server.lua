if not lib then return end

local Inventory = require 'modules.inventory.server'
local config = lib.load('data.rust_clothing')
local ITEM = config.item

local slotById = {}
for _, s in ipairs(config.slots) do slotById[s.id] = s end

local cooldown = {}

local function busy(source)
    local now = GetGameTimer()
    if cooldown[source] and now - cooldown[source] < 1000 then return true end
    cooldown[source] = now
end

local function isInt(n) return type(n) == 'number' and n == math.floor(n) and n >= -1 and n < 1000 end

--- Valida lo que manda el cliente: solo los componentes/props de esa ranura y números enteros
local function sanitize(slot, data)
    if type(data) ~= 'table' then return end
    if slot.prop then
        local p = data.props and data.props[1]
        if type(p) ~= 'table' or p[1] ~= slot.prop or not isInt(p[2]) or p[2] < 0 or not isInt(p[3]) then return end
        return { props = { { slot.prop, p[2], p[3] } } }
    end

    local allowed = { [slot.comp] = true }
    for _, e in ipairs(slot.extra or {}) do allowed[e] = true end

    local comps = {}
    for _, c in ipairs(data.comps or {}) do
        if type(c) ~= 'table' or not allowed[c[1]] or not isInt(c[2]) or not isInt(c[3]) then return end
        comps[#comps + 1] = { c[1], c[2], c[3] }
    end
    if not comps[1] or comps[1][1] ~= slot.comp then return end
    return { comps = comps }
end

---------------------------------------------------------------------
-- Validación: lo que dice el cliente tiene que coincidir con
-- 1) lo que el servidor ve en el PJ (si puede leerlo), o
-- 2) lo último que hizo este sistema, o
-- 3) la apariencia guardada en illenium-appearance (tabla playerskins)
---------------------------------------------------------------------
local known = {}     -- known[src][kind] = { d = drawable, t = texture } tras quitar/poner
local skinCache = {} -- skinCache[src] = apariencia guardada (o false si no hay)

local function nakedValue(slot, gender)
    if slot.prop then return -1 end
    return config.naked[gender][slot.comp] or 0
end

local function fromServerPed(source, slot)
    local ped = GetPlayerPed(source)
    local ok, d, t = pcall(function()
        if slot.prop then return GetPedPropIndex(ped, slot.prop), GetPedPropTextureIndex(ped, slot.prop) end
        return GetPedDrawableVariation(ped, slot.comp), GetPedTextureVariation(ped, slot.comp)
    end)
    if ok and type(d) == 'number' then return { d = d, t = t } end
end

local function fromSavedSkin(source, slot)
    if skinCache[source] == nil then
        skinCache[source] = false
        local inv = Inventory(source)
        local citizenid = inv and inv.owner
        if citizenid and MySQL then
            local ok, row = pcall(MySQL.single.await,
                'SELECT skin FROM playerskins WHERE citizenid = ? AND active = 1 LIMIT 1', { citizenid })
            if ok and row and row.skin then skinCache[source] = json.decode(row.skin) or false end
        end
    end

    local skin = skinCache[source]
    if not skin then return end
    if slot.prop then
        for _, p in ipairs(skin.props or {}) do
            if p.prop_id == slot.prop then return { d = p.drawable, t = p.texture } end
        end
    else
        for _, c in ipairs(skin.components or {}) do
            if c.component_id == slot.comp then return { d = c.drawable, t = c.texture } end
        end
    end
end

--- ¿Lo que dice el cliente (data = nil si dice que no lleva nada) es creíble?
local function verify(source, slot, gender, data)
    local claimD = data and (slot.prop and data.props[1][2] or data.comps[1][2]) or nakedValue(slot, gender)

    local expected = fromServerPed(source, slot)
        or (known[source] and known[source][slot.id])
        or fromSavedSkin(source, slot)

    if not expected then return true end -- no hay forma de comprobarlo
    return expected.d == claimD
end

local function remember(source, slot, gender, data)
    known[source] = known[source] or {}
    if data then
        local main = slot.prop and data.props[1] or data.comps[1]
        known[source][slot.id] = { d = main[2], t = main[3] }
    else
        known[source][slot.id] = { d = nakedValue(slot, gender), t = 0 }
    end
end

local function makeMetadata(slot, gender, data)
    return {
        label = slot.label,
        kind = slot.id,
        gender = gender,
        comps = data.comps,
        props = data.props,
        image = slot.image, -- web/images/<image>.png; sin image se usa prenda.png
        description = ('%s · %s'):format(slot.label, gender == 'male' and 'Hombre' or 'Mujer'),
    }
end

-- Quitarse una prenda: te da el item con esa ropa
lib.callback.register('ox_inventory:rustClothesTakeOff', function(source, kind, gender, data)
    local slot = slotById[kind]
    if not slot or slot.armour then return false, 'Ranura inválida' end
    if busy(source) then return false, 'Espera un momento' end
    if gender ~= 'male' and gender ~= 'female' then return false, 'Solo funciona con personajes freemode' end

    data = sanitize(slot, data)
    if not data then return false, 'No llevas nada ahí' end
    if not verify(source, slot, gender, data) then
        print(('^3[rustclothes] %s (%s) intentó quitarse una prenda que no coincide (%s)^0'):format(GetPlayerName(source), source, kind))
        return false, 'La ropa no coincide con tu apariencia guardada'
    end

    local metadata = makeMetadata(slot, gender, data)
    if not Inventory.CanCarryItem(source, ITEM, 1, metadata) then return false, 'Inventario lleno' end

    Inventory.AddItem(source, ITEM, 1, metadata)
    remember(source, slot, gender, nil)
    return true
end)

-- Ponerse una prenda: el item sale del inventario y se devuelve lo que tenías puesto
lib.callback.register('ox_inventory:rustClothesEquip', function(source, invSlot, kind, gender, current)
    local slot = slotById[kind]
    if not slot or slot.armour then return false, 'Ranura inválida' end
    if busy(source) then return false, 'Espera un momento' end

    local item = Inventory.GetSlot(source, tonumber(invSlot))
    if not item or item.name ~= ITEM or not item.metadata then return false, 'Eso no es ropa' end
    if item.metadata.kind ~= kind then
        local target = slotById[item.metadata.kind]
        return false, ('Esa prenda va en: %s'):format(target and target.label or '?')
    end
    if item.metadata.gender ~= gender then return false, 'Esa prenda es de otro género' end

    local metadata = item.metadata
    if not Inventory.RemoveItem(source, ITEM, 1, nil, item.slot) then return false, 'No se pudo quitar el item' end

    -- lo que llevabas puesto se devuelve solo si coincide con lo verificable
    current = sanitize(slot, current)
    if current and verify(source, slot, gender, current) then
        Inventory.AddItem(source, ITEM, 1, makeMetadata(slot, gender, current))
    end

    local new = sanitize(slot, { comps = metadata.comps, props = metadata.props })
    if new then remember(source, slot, gender, new) end

    return true, { comps = metadata.comps, props = metadata.props }
end)

---------------------------------------------------------------------
-- Chaleco antibalas (ranura con armour = true)
-- La protección la pone y la lee el servidor. El item guarda la que le queda (metadata.armour).
---------------------------------------------------------------------
local ARMOUR = config.armour or { item = 'armour' }

local function vestKey(owner) return ('rustclothes:vest:%s'):format(owner) end

--- Marca si lleva el chaleco (statebag para el cliente + KVP para cuando reconecte) y cambia cómo se ve
local function setVest(source, on)
    Player(source).state:set('rustVest', on, true)
    local inv = Inventory(source)
    if inv and inv.owner then
        if on then SetResourceKvpInt(vestKey(inv.owner), 1) else DeleteResourceKvp(vestKey(inv.owner)) end
    end
    TriggerClientEvent('ox_inventory:rustArmourLook', source, on)
end

local function takeOffArmour(source)
    if not Player(source).state.rustVest then return false, 'No llevas chaleco' end
    local ped = GetPlayerPed(source)
    local value = GetPedArmour(ped)

    if value > 0 then
        local metadata = { armour = value, description = ('Protección: %d%%'):format(value) }
        if not Inventory.CanCarryItem(source, ARMOUR.item, 1, metadata) then return false, 'Inventario lleno' end
        Inventory.AddItem(source, ARMOUR.item, 1, metadata)
    end
    SetPedArmour(ped, 0)
    setVest(source, false)
    return true
end

local function equipArmour(source, invSlot)
    local item = Inventory.GetSlot(source, tonumber(invSlot))
    if not item or item.name ~= ARMOUR.item then return false, 'En el chaleco solo va un chaleco antibalas' end
    local value = math.max(1, math.min(100, tonumber(item.metadata and item.metadata.armour) or 100))

    -- si ya llevaba uno, se le devuelve primero
    if Player(source).state.rustVest then
        local ok, err = takeOffArmour(source)
        if not ok then return false, err end
    end
    if not Inventory.RemoveItem(source, ARMOUR.item, 1, nil, item.slot) then return false, 'No se pudo usar el chaleco' end

    SetPedArmour(GetPlayerPed(source), value)
    setVest(source, true)
    return true
end

lib.callback.register('ox_inventory:rustArmourEquip', function(source, invSlot)
    if busy(source) then return false, 'Espera un momento' end
    return equipArmour(source, invSlot)
end)

lib.callback.register('ox_inventory:rustArmourTakeOff', function(source)
    if busy(source) then return false, 'Espera un momento' end
    return takeOffArmour(source)
end)

-- Usar el item = ponértelo en la ranura (data/items.lua -> server.export)
exports('rustUseArmour', function(event, _, inventory, slot)
    if event ~= 'usingItem' then return end
    local ok, err = equipArmour(inventory.id, slot)
    if not ok then TriggerClientEvent('ox_lib:notify', inventory.id, { type = 'error', description = err }) end
    return false -- el item ya se quitó (o no se usa); ox no tiene que consumir nada
end)

-- El cliente avisa cuando la protección llega a 0: el chaleco se rompió
RegisterNetEvent('ox_inventory:rustArmourBroken', function()
    local src = source
    if Player(src).state.rustVest and GetPedArmour(GetPlayerPed(src)) <= 0 then setVest(src, false) end
end)

-- Al entrar con el personaje: sigue puesto solo si lo llevaba y todavía tiene protección
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(4000, function()
        local inv = Inventory(src)
        if not inv or not inv.owner then return end
        local had = GetResourceKvpInt(vestKey(inv.owner)) == 1
        setVest(src, had and GetPedArmour(GetPlayerPed(src)) > 0)
    end)
end)

AddEventHandler('playerDropped', function()
    cooldown[source] = nil
    known[source] = nil
    skinCache[source] = nil
end)

-- Cada vez que illenium guarda la apariencia (tiendas de ropa o este inventario),
-- se vuelve a leer de la base de datos para la próxima comprobación
RegisterNetEvent('illenium-appearance:server:saveAppearance', function()
    local src = source
    SetTimeout(1500, function()
        skinCache[src] = nil
        known[src] = nil
    end)
end)
