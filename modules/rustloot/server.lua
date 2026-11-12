if not lib then return end

local Inventory = require 'modules.inventory.server'
local config = lib.load('data.rust_loot')
local crafting = lib.load('data.rust_crafting') or {}

-- Nodos: [id] = { id, t = tipo, x, y, z, ready = bool, readyAt = os.time() }
local nodes = {}
local starts = {} -- starts[src] = { id, at = GetGameTimer() }

-- Recetas con plano, para los planos al azar
local blueprintRecipes = {}
for _, r in ipairs(crafting.recipes or {}) do
    if r.blueprint then blueprintRecipes[#blueprintRecipes + 1] = r.name end
end

local function addNode(t, x, y, z)
    local id = ('n%d'):format(#nodes + 1)
    nodes[#nodes + 1] = { id = id, t = t, x = x, y = y, z = z, ready = true }
end

for _, spawn in ipairs(config.spawns or {}) do
    if config.types[spawn.type] then
        for _, p in ipairs(spawn.points or {}) do addNode(spawn.type, p.x, p.y, p.z) end
        for _, zone in ipairs(spawn.zones or {}) do
            for _ = 1, zone.count or 1 do
                local a = math.random() * math.pi * 2
                local r = math.sqrt(math.random()) * (zone.radius or 20.0)
                addNode(spawn.type, zone.center.x + math.cos(a) * r, zone.center.y + math.sin(a) * r, zone.center.z)
            end
        end
    end
end

local byId = {}
for _, n in ipairs(nodes) do byId[n.id] = n end

--- Lista completa (solo al entrar): { [id] = { t, x, y, z, r = disponible } }
lib.callback.register('ox_inventory:rustLootList', function()
    local list = {}
    for _, n in ipairs(nodes) do list[n.id] = { t = n.t, x = n.x, y = n.y, z = n.z, r = n.ready } end
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
