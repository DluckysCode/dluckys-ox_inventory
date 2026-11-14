if not lib then return end

-- /admininventory: panel de admin (Mundo · Jugadores · Recetas · Registro)
local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'
local Bench = require 'modules.rustbench.server'
local Craft = require 'modules.rustcraft.server'
local Log = require 'modules.rustlog.server'

-- lib.addCommand con restricted da el permiso "command.admininventory" al grupo admin
local function isAdmin(src) return IsPlayerAceAllowed(src, 'command.admininventory') end

local function isNum(n) return type(n) == 'number' and n == n and math.abs(n) < 100000 end

local function playerName(id)
    id = tonumber(id)
    return id and GetPlayerName(id) and ('%s (%s)'):format(GetPlayerName(id), id)
end

lib.addCommand('admininventory', {
    help = 'Panel de admin del inventario: mundo, jugadores, recetas y registro',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('ox_inventory:rustAdminOpen', source)
end)

---------------------------------------------------------------------
-- Datos de cada pestaña (se piden solo al abrirla)
---------------------------------------------------------------------
local function onlinePlayers()
    local list = {}
    for _, src in ipairs(GetPlayers()) do
        local id = tonumber(src)
        list[#list + 1] = { id = id, name = GetPlayerName(id) }
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

local itemList -- se arma una sola vez
local function allItems()
    if not itemList then
        itemList = {}
        for name, item in pairs(Items()) do itemList[#itemList + 1] = { name = name, label = item.label or name } end
        table.sort(itemList, function(a, b) return a.label < b.label end)
    end
    return itemList
end

local tabs = {
    world = function()
        local templates = {}
        for id, t in pairs(Bench.templates()) do templates[#templates + 1] = { id = id, label = t.label, model = t.model } end

        local benches = {}
        for _, b in ipairs(Bench.list()) do
            benches[#benches + 1] = { id = b.id, template = b.template, label = b.label, x = b.x, y = b.y, z = b.z, h = b.h }
        end

        return { benches = benches, templates = templates }
    end,
    players = function()
        return { players = onlinePlayers(), items = allItems(), blueprints = Craft.blueprintRecipes() }
    end,
    recipes = function()
        local benches = {}
        for id, t in pairs(Bench.templates()) do benches[#benches + 1] = { id = id, label = t.label } end
        return { recipes = Craft.list(), categories = Craft.categories(), benches = benches, items = allItems() }
    end,
    log = function() return { log = Log.list() } end,
}

lib.callback.register('ox_inventory:rustAdminData', function(source, tab)
    if not isAdmin(source) or not tabs[tab] then return end
    return tabs[tab]()
end)

--- Para los blips del mapa: todo lo que hay colocado
lib.callback.register('ox_inventory:rustAdminMap', function(source)
    if not isAdmin(source) then return end
    return { benches = Bench.list() }
end)

---------------------------------------------------------------------
-- Acciones
---------------------------------------------------------------------
local function pos(d) return d.x, d.y, d.z, d.h or 0.0 end

local actions = {
    -- Mundo
    addBench    = function(_, d) return Bench.add(d.template, pos(d)) end,
    moveBench   = function(_, d) return Bench.move(d.id, pos(d)) end,
    removeBench = function(_, d) return Bench.remove(d.id) end,

    -- Jugadores
    viewPlayer  = function(src, d)
        local target = tonumber(d.target)
        return target and GetPlayerName(target) ~= nil
            and exports.ox_inventory:forceOpenInventory(src, 'player', target) ~= nil
    end,
    giveItem    = function(_, d)
        local target, count = tonumber(d.target), math.floor(tonumber(d.count) or 1)
        if not target or not GetPlayerName(target) or not Items(d.item) or count < 1 or count > 10000 then return false end
        return Inventory.AddItem(target, d.item, count) and true or false
    end,
    giveBlueprint = function(_, d)
        local target = tonumber(d.target)
        return target and GetPlayerName(target) ~= nil and Craft.giveBlueprint(target, d.recipe) and true or false
    end,
    resetBlueprints = function(_, d) return Craft.resetBlueprints(tonumber(d.target)) end,
    learnAll        = function(_, d) return Craft.learnAll(tonumber(d.target)) end,

    -- Recetas
    saveRecipe  = function(_, d) return Craft.save(d) end,
}

--- Texto para el registro
local function describe(action, d)
    local who = d.target and playerName(d.target)
    if action == 'giveItem' then return ('Dio %sx %s a %s'):format(d.count, d.item, who or d.target) end
    if action == 'giveBlueprint' then return ('Dio plano de %s a %s'):format(d.recipe, who or d.target) end
    if action == 'saveRecipe' then return ('Guardó la receta %s%s'):format(d.name, d.disabled and ' (desactivada)' or '') end
    if who then return ('%s: %s'):format(action, who) end
    return ('%s %s'):format(action, d.id or d.template or d.item or '')
end

lib.callback.register('ox_inventory:rustAdminAction', function(source, action, d)
    if not isAdmin(source) or type(d) ~= 'table' or not actions[action] then return false end
    if d.x ~= nil and not (isNum(d.x) and isNum(d.y) and isNum(d.z) and isNum(d.h or 0)) then return false end

    local ok, err = actions[action](source, d)
    if ok and action ~= 'viewPlayer' then
        Log.add('admin', source, describe(action, d))
    end
    return ok == true, err
end)
