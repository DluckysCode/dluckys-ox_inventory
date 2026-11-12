if not lib then return end

local Inventory = require 'modules.inventory.server'
local Bench = require 'modules.rustbench.server'
local Craft = require 'modules.rustcraft.server'
local Log = require 'modules.rustlog.server'
local config = lib.load('data.rust_loot')

-- Nodos: { id, t = tipo, x, y, z, ready, readyAt, admin = punto fijo de admin, zone = id de zona de admin }
local nodes, byId = {}, {}
local starts = {} -- starts[src] = { id, at = GetGameTimer() }

-- Hechos con /admininventory, guardados en KVP
local POINTS_KVP, ZONES_KVP = 'rustloot:points', 'rustloot:zones'
local adminPoints = json.decode(GetResourceKvpString(POINTS_KVP) or '{}') or {} -- [id] = { t, x, y, z }
local adminZones = json.decode(GetResourceKvpString(ZONES_KVP) or '{}') or {}   -- [id] = { t, x, y, z, radius, count }

local function view(n) return { t = n.t, x = n.x, y = n.y, z = n.z, r = n.ready } end

local function addNode(t, x, y, z, id, extra)
    id = id or ('n%d'):format(#nodes + 1)
    local n = { id = id, t = t, x = x, y = y, z = z, ready = true }
    if extra then for k, v in pairs(extra) do n[k] = v end end
    nodes[#nodes + 1] = n
    byId[id] = n
    return n
end

--- ¿Está (x, y) a la distancia mínima de las mesas y de los otros nodos?
local spacing = config.minSpacing or 4.0
local function freeSpot(x, y)
    for _, b in ipairs(Bench.list()) do
        if #(vec2(x, y) - vec2(b.x, b.y)) < spacing then return false end
    end
    for _, n in ipairs(nodes) do
        if #(vec2(x, y) - vec2(n.x, n.y)) < spacing then return false end
    end
    return true
end

--- Reparte "count" nodos al azar en un círculo (hasta 20 intentos cada uno). Devuelve los creados.
local function fillZone(t, cx, cy, cz, radius, count, zoneId)
    local created = {}
    for k = 1, count do
        for _ = 1, 20 do
            local a = math.random() * math.pi * 2
            local r = math.sqrt(math.random()) * radius
            local x, y = cx + math.cos(a) * r, cy + math.sin(a) * r
            if freeSpot(x, y) then
                local id = zoneId and ('%s_%d'):format(zoneId, k) or nil
                created[#created + 1] = addNode(t, x, y, cz, id, zoneId and { zone = zoneId })
                break
            end
        end
    end
    return created
end

-- Primero los puntos fijos (admin y config), después las zonas al azar respetando la distancia
for id, p in pairs(adminPoints) do
    if config.types[p.t] then addNode(p.t, p.x, p.y, p.z, id, { admin = true }) end
end
for _, spawn in ipairs(config.spawns or {}) do
    if config.types[spawn.type] then
        for _, p in ipairs(spawn.points or {}) do addNode(spawn.type, p.x, p.y, p.z) end
    end
end
for id, z in pairs(adminZones) do
    if config.types[z.t] then fillZone(z.t, z.x, z.y, z.z, z.radius, z.count, id) end
end
for _, spawn in ipairs(config.spawns or {}) do
    if config.types[spawn.type] then
        for _, zone in ipairs(spawn.zones or {}) do
            local c = zone.center
            fillZone(spawn.type, c.x, c.y, c.z, zone.radius or 20.0, zone.count or 1)
        end
    end
end

--- Lista completa (solo al entrar)
lib.callback.register('ox_inventory:rustLootList', function()
    local list = {}
    for _, n in ipairs(nodes) do list[n.id] = view(n) end
    return list
end)

--- Avisa a todos solo del nodo que cambió
local function setReady(n, ready)
    n.ready = ready
    TriggerClientEvent('ox_inventory:rustLootState', -1, n.id, ready)
end

-- Reaparición
CreateThread(function()
    while true do
        Wait(10000)
        local now = os.time()
        for _, n in ipairs(nodes) do
            if not n.ready and now >= n.readyAt then setReady(n, true) end
        end
    end
end)

--- Distancia en el plano (sin altura: el cliente ajusta la Z al suelo)
local function near(source, n)
    local p = GetEntityCoords(GetPlayerPed(source))
    return #(vec2(p.x, p.y) - vec2(n.x, n.y)) <= (config.interactDistance or 2.0) + 1.5
end

lib.callback.register('ox_inventory:rustLootStart', function(source, id)
    local n = byId[id]
    if not n or not n.ready or not near(source, n) then return false end
    starts[source] = { id = id, at = GetGameTimer() }
    return true
end)

lib.callback.register('ox_inventory:rustLootFinish', function(source, id)
    local n, s = byId[id], starts[source]
    starts[source] = nil
    if not n or not n.ready or not s or s.id ~= id then return false end

    local t = config.types[n.t]
    -- tiene que haber pasado (casi) todo el tiempo de la acción
    if GetGameTimer() - s.at < (t.duration or 2000) * 0.8 then return false end
    if not near(source, n) then return false, 'Estás muy lejos' end

    n.readyAt = os.time() + (t.respawn or 300)
    setReady(n, false)

    local got = {}
    for _, l in ipairs(t.loot or {}) do
        if math.random(100) <= (l.chance or 100) then
            local amount = math.random(l.min or 1, l.max or l.min or 1)
            if Inventory.AddItem(source, l.item, amount) then got[#got + 1] = ('%dx %s'):format(amount, l.item) end
        end
    end

    local bps = Craft.blueprintRecipes()
    if t.blueprintChance and #bps > 0 and math.random() * 100 < t.blueprintChance then
        local recipe = bps[math.random(#bps)]
        exports.ox_inventory:GiveBlueprint(source, recipe)
        got[#got + 1] = ('plano de %s'):format(recipe)
        TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = '¡Encontraste un plano!' })
    end

    if #got == 0 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'inform', description = 'No encontraste nada útil' })
    end
    Log.add('loot', source, ('%s: %s'):format(t.label, #got > 0 and table.concat(got, ', ') or 'nada'))
    return true
end)

AddEventHandler('playerDropped', function() starts[source] = nil end)

---------------------------------------------------------------------
-- Puntos y zonas de admin (/admininventory)
---------------------------------------------------------------------
local M = {}

local function savePoints() SetResourceKvp(POINTS_KVP, json.encode(adminPoints)) end
local function saveZones() SetResourceKvp(ZONES_KVP, json.encode(adminZones)) end

--- Quita nodos que cumplan "match" y avisa a los clientes
local function removeNodes(match)
    for i = #nodes, 1, -1 do
        local n = nodes[i]
        if match(n) then
            table.remove(nodes, i)
            byId[n.id] = nil
            TriggerClientEvent('ox_inventory:rustLootRemove', -1, n.id)
        end
    end
end

local function broadcast(n) TriggerClientEvent('ox_inventory:rustLootAdd', -1, n.id, view(n)) end

function M.types()
    local list = {}
    for id, t in pairs(config.types) do list[#list + 1] = { id = id, label = t.label } end
    return list
end

function M.points()
    local list = {}
    for _, n in ipairs(nodes) do
        if n.admin then
            list[#list + 1] = { id = n.id, t = n.t, label = config.types[n.t].label, x = n.x, y = n.y, z = n.z }
        end
    end
    return list
end

function M.zones()
    local list = {}
    for id, z in pairs(adminZones) do
        list[#list + 1] = {
            id = id, t = z.t, label = config.types[z.t] and config.types[z.t].label or z.t,
            x = z.x, y = z.y, z = z.z, radius = z.radius, count = z.count,
        }
    end
    return list
end

--- Todos los nodos y zonas, para los blips del mapa
function M.map()
    local list = {}
    for _, n in ipairs(nodes) do list[#list + 1] = { t = n.t, x = n.x, y = n.y, z = n.z } end
    return list, M.zones()
end

function M.add(t, x, y, z)
    if not config.types[t] then return false end
    local id = ('p%d%d'):format(os.time(), math.random(100, 999))
    adminPoints[id] = { t = t, x = x, y = y, z = z }
    savePoints()
    broadcast(addNode(t, x, y, z, id, { admin = true }))
    return true
end

function M.move(id, x, y, z)
    local p = adminPoints[id]
    if not p then return false end
    p.x, p.y, p.z = x, y, z
    savePoints()
    removeNodes(function(n) return n.id == id end)
    broadcast(addNode(p.t, x, y, z, id, { admin = true }))
    return true
end

function M.remove(id)
    if not adminPoints[id] then return false end
    adminPoints[id] = nil
    savePoints()
    removeNodes(function(n) return n.id == id end)
    return true
end

function M.addZone(t, x, y, z, radius, count)
    if not config.types[t] then return false end
    radius = math.max(2.0, math.min(200.0, radius))
    count = math.max(1, math.min(50, math.floor(count)))
    local id = ('z%d%d'):format(os.time(), math.random(100, 999))
    adminZones[id] = { t = t, x = x, y = y, z = z, radius = radius, count = count }
    saveZones()
    for _, n in ipairs(fillZone(t, x, y, z, radius, count, id)) do broadcast(n) end
    return true
end

function M.removeZone(id)
    if not adminZones[id] then return false end
    adminZones[id] = nil
    saveZones()
    removeNodes(function(n) return n.zone == id end)
    return true
end

return M
