if not lib then return end

-- Mochilas: el último slot normal del jugador es el slot "Mochila".
-- Mochila puesta  -> el inventario crece (slots y peso) y su contenido aparece en los slots extra.
-- Mochila quitada -> lo de los slots extra se guarda en el stash de la mochila y el inventario vuelve a su tamaño.
-- Si te desconectas con la mochila puesta, los items quedan en tu inventario (ox los guarda aunque pasen del límite).

local Inventory = require 'modules.inventory.server'
local types = lib.load('data.rust_backpack').types

local BASE = shared.playerslots -- slots normales del jugador
local BP_SLOT = BASE            -- el último slot normal es el de la mochila
local equipped = {}             -- [src] = { bagId, name, baseWeight }

local function slotNum(s) return type(s) == 'table' and s.slot or s end
local function isBackpack(item) return type(item) == 'table' and types[item.name] ~= nil end

--- El contenido de cada mochila vive en un stash propio ("bag_...")
local function ensureStash(bagId, t)
    exports.ox_inventory:RegisterStash(bagId, t.label, t.slots, t.weight)
end

--- Le da un id de stash a la mochila si todavía no tiene
local function bagIdOf(inv, slot, item)
    if item.metadata and item.metadata.bagId then return item.metadata.bagId end
    local bagId = ('bag_%d%d'):format(os.time(), math.random(1000, 9999))
    local metadata = item.metadata or {}
    metadata.bagId = bagId
    Inventory.SetMetadata(inv, slot, metadata)
    return bagId
end

local function setLook(source, name)
    local t = name and types[name]
    TriggerClientEvent('ox_inventory:rustBackpackLook', source, t and t.clothing or false)
end

local function unequip(source)
    local e = equipped[source]
    if not e then return end
    equipped[source] = nil

    local inv = Inventory(source)
    if inv then
        ensureStash(e.bagId, types[e.name])
        -- lo de los slots extra se guarda dentro de la mochila, en la misma posición
        for slot = BASE + 1, inv.slots do
            local item = inv.items[slot]
            if item then
                if Inventory.AddItem(e.bagId, item.name, item.count, item.metadata, slot - BASE) then
                    Inventory.RemoveItem(inv, item.name, item.count, item.metadata, slot)
                end
            end
        end
        Inventory.SetSlotCount(inv, BASE)
        Inventory.SetMaxWeight(inv, e.baseWeight)
    end
    setLook(source, nil)
end

local function equip(source, inv, item)
    local t = types[item.name]
    local bagId = bagIdOf(inv, BP_SLOT, item)
    ensureStash(bagId, t)

    equipped[source] = { bagId = bagId, name = item.name, baseWeight = inv.maxWeight }
    Inventory.SetSlotCount(inv, BASE + t.slots)
    Inventory.SetMaxWeight(inv, inv.maxWeight + t.weight)

    -- lo que tenía guardado la mochila pasa a los slots extra
    local stash = Inventory(bagId, nil, true)
    if stash then
        for slot, stored in pairs(stash.items) do
            if Inventory.AddItem(inv, stored.name, stored.count, stored.metadata, BASE + slot) then
                Inventory.RemoveItem(stash, stored.name, stored.count, stored.metadata, slot)
            end
        end
    end
    setLook(source, item.name)
end

--- Revisa si el slot Mochila cambió y pone/quita la mochila según corresponda
local function sync(source)
    local inv = Inventory(source)
    if not inv or not inv.player then return end

    local item = inv.items[BP_SLOT]
    local e = equipped[source]
    local bagId = isBackpack(item) and item.metadata and item.metadata.bagId

    if e and (not isBackpack(item) or bagId ~= e.bagId) then unequip(source) end
    if isBackpack(item) and not equipped[source] then equip(source, inv, item) end
end

---------------------------------------------------------------------
-- Reglas al mover items
---------------------------------------------------------------------
CreateThread(function()
    while not shared.ready do Wait(100) end

    -- Las reglas valen para cualquier inventario de jugador (el tuyo o el de alguien que registras)
    local function playerId(id)
        id = tonumber(id)
        local inv = id and Inventory(id)
        return inv and inv.player and id or nil
    end

    exports.ox_inventory:registerHook('swapItems', function(p)
        local toId, fromId = playerId(p.toInventory), playerId(p.fromInventory)
        local toSlot = slotNum(p.toSlot)
        local moving = p.fromSlot

        -- en el slot Mochila solo entran mochilas
        if toId and toSlot == BP_SLOT and not isBackpack(moving) then return false end
        -- y al intercambiar, lo que vuelve al slot Mochila también tiene que ser mochila
        if fromId and moving and moving.slot == BP_SLOT and p.action == 'swap' and not isBackpack(p.toSlot) then
            return false
        end
        -- una mochila no puede ir dentro de los slots extra ni dentro de otra mochila
        if isBackpack(moving) and ((toId and toSlot > BASE) or tostring(p.toInventory):find('^bag_')) then
            return false
        end

        SetTimeout(150, function()
            if toId then sync(toId) end
            if fromId and fromId ~= toId then sync(fromId) end
        end)
        return true
    end, {})
end)

-- Respaldo: cada 5 s revisa a quien lleva mochila (por si se la dieron o la quitó otro script)
CreateThread(function()
    while true do
        Wait(5000)
        for src in pairs(equipped) do sync(src) end
    end
end)

-- Al entrar con el personaje
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    SetTimeout(3000, function() sync(src) end)
end)

AddEventHandler('playerDropped', function() equipped[source] = nil end)

---------------------------------------------------------------------
-- Usar una mochila que NO llevas puesta = ver lo que tiene dentro
---------------------------------------------------------------------
exports('rustOpenBackpack', function(event, item, inventory, slot)
    if event ~= 'usingItem' then return end
    if slot == BP_SLOT then return false end -- la puesta ya muestra su contenido en los slots extra

    local data = inventory.items[slot]
    local t = data and types[data.name]
    if not t then return false end

    local bagId = bagIdOf(inventory, slot, data)
    ensureStash(bagId, t)
    TriggerClientEvent('ox_inventory:rustBackpackOpen', inventory.id, bagId)
    return false -- no se consume
end)

---------------------------------------------------------------------
-- Para registrar a otro jugador (modules/rustsearch)
---------------------------------------------------------------------
local M = {}

--- La mochila que lleva puesta: { name, label } o nil
function M.backpack(target)
    local inv = Inventory(target)
    local item = inv and inv.items[BP_SLOT]
    return isBackpack(item) and { name = item.name, label = types[item.name].label } or nil
end

--- Le quita la mochila (con todo lo de adentro) a target y se la da a receiver
function M.takeBackpack(target, receiver)
    local inv = Inventory(target)
    local item = inv and inv.items[BP_SLOT]
    if not isBackpack(item) then return false, 'No lleva mochila' end
    if not Inventory.CanCarryItem(receiver, item.name, 1, item.metadata) then return false, 'Inventario lleno' end

    -- primero se guarda lo de los slots extra dentro de la mochila
    local metadata = item.metadata
    unequip(target)
    if not Inventory.RemoveItem(inv, item.name, 1, nil, BP_SLOT) then return false, 'No se pudo quitar' end
    Inventory.AddItem(receiver, item.name, 1, metadata)
    return true
end

return M
