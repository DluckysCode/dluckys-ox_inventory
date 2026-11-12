if not lib then return end

local Inventory = require 'modules.inventory.server'
local Bench = require 'modules.rustbench.server'
local config = lib.load('data.rust_loot')
local crafting = lib.load('data.rust_crafting') or {}

-- Nodos: { id, t = tipo, x, y, z, ready = bool, readyAt = os.time(), admin = bool }
local nodes, byId = {}, {}
local starts = {} -- starts[src] = { id, at = GetGameTimer() }

-- Puntos colocados con /inventory, guardados en KVP: { [id] = { t, x, y, z } }
local ADMIN_KVP = 'rustloot:points'
local adminPoints = json.decode(GetResourceKvpString(ADMIN_KVP) or '{}') or {}

-- Recetas con plano, para los planos al azar
local blueprintRecipes = {}
for _, r in ipairs(crafting.recipes or {}) do
    if r.blueprint then blueprintRecipes[#blueprintRecipes + 1] = r.name end
end

local function view(n) return { t = n.t, x = n.x, y = n.y, z = n.z, r = n.ready } end

local function addNode(t, x, y, z, id, admin)
    id = id or ('n%d'):format(#nodes + 1)
    local n = { id = id, t = t, x = x, y = y, z = z, ready = true, admin = admin }
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

-- Primero los puntos fijos (admin y config), después las zonas al azar respetando la distancia
for id, p in pairs(adminPoints) do
    if config.types[p.t] then addNode(p.t, p.x, p.y, p.z, id, true) end
end
for _, spawn in ipairs(config.spawns or {}) do
    if config.types[spawn.type] then
        for _, p in ipairs(spawn.points or {}) do addNode(spawn.type, p.x, p.y, p.z) end
    end
end
for _, spawn in ipairs(config.spawns or {}) do
    if config.types[spawn.type] then
        for _, zone in ipairs(spawn.zones or {}) do
            for _ = 1, zone.count or 1 do
                -- hasta 20 intentos de encontrar un lugar libre; si no hay, se salta ese nodo
                for _ = 1, 20 do
                    local a = math.random() * math.pi * 2
                    local r = math.sqrt(math.random()) * (zone.radius or 20.0)
                    local x, y = zone.center.x + math.cos(a) * r, zone.center.y + math.sin(a) * r
                    if freeSpot(x, y) then
                        addNode(spawn.type, x, y, zone.center.z)
                        break
                    end
                end
            end
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

    local got = 0
    for _, l in ipairs(t.loot or {}) do
        if math.random(100) <= (l.chance or 100) then
            local amount = math.random(l.min or 1, l.max or l.min or 1)
            if Inventory.AddItem(source, l.item, amount) then got += 1 end
        end
    end

    if t.blueprintChance and #blueprintRecipes > 0 and math.random() * 100 < t.blueprintChance then
        exports.ox_inventory:GiveBlueprint(source, blueprintRecipes[math.random(#blueprintRecipes)])
        TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = '¡Encontraste un plano!' })
    end

    if got == 0 then
        TriggerClientEvent('ox_lib:notify', source, { type = 'inform', description = 'No encontraste nada útil' })
    end
    return true
end)

AddEventHandler('playerDropped', function() starts[source] = nil end)

---------------------------------------------------------------------
-- Puntos colocados por admins (/inventory)
---------------------------------------------------------------------
local M = {}

local function saveAdmin() SetResourceKvp(ADMIN_KVP, json.encode(adminPoints)) end

local function removeNode(id)
    for i, n in ipairs(nodes) do
        if n.id == id then
            table.remove(nodes, i)
            break
        end
    end
    byId[id] = nil
    TriggerClientEvent('ox_inventory:rustLootRemove', -1, id)
end

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

function M.add(t, x, y, z)
    if not config.types[t] then return false end
    local id = ('p%d%d'):format(os.time(), math.random(100, 999))
    adminPoints[id] = { t = t, x = x, y = y, z = z }
    saveAdmin()
    TriggerClientEvent('ox_inventory:rustLootAdd', -1, id, view(addNode(t, x, y, z, id, true)))
    return true
end

function M.move(id, x, y, z)
    local p = adminPoints[id]
    if not p then return false end
    p.x, p.y, p.z = x, y, z
    saveAdmin()
    removeNode(id)
    TriggerClientEvent('ox_inventory:rustLootAdd', -1, id, view(addNode(p.t, x, y, z, id, true)))
    return true
end

function M.remove(id)
    if not adminPoints[id] then return false end
    adminPoints[id] = nil
    saveAdmin()
    removeNode(id)
    return true
end

return M
