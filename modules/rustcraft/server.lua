if not lib then return end

local Inventory = require 'modules.inventory.server'
local Items = require 'modules.items.server'
local Log = require 'modules.rustlog.server'
local config = lib.load('data.rust_crafting') or { recipes = {}, categories = {} }

-- Recetas = las de data/rust_crafting.lua + cambios hechos con /admininventory (guardados en KVP).
-- Una receta "eliminada" queda desactivada (disabled) para que los ids no cambien.
local RECIPES_KVP = 'rustcraft:recipes'
local overrides = json.decode(GetResourceKvpString(RECIPES_KVP) or '{}') or {}
local EDITABLE = { 'time', 'count', 'category', 'ingredients', 'level', 'bench', 'blueprint', 'disabled' }

local recipes, recipeByName = {}, {}

local function addRecipe(r)
    r.id, r.count = #recipes + 1, r.count or 1
    recipes[r.id] = r
    recipeByName[r.name] = r
end

for _, r in ipairs(config.recipes) do addRecipe(r) end
for name, o in pairs(overrides) do
    local r = recipeByName[name]
    if not r then
        r = { name = name }
        addRecipe(r)
    end
    for _, k in ipairs(EDITABLE) do
        if o[k] ~= nil then r[k] = o[k] ~= false and o[k] or nil end
    end
    r.count = r.count or 1
end

local queues = {} ---@type table<number, { list: table[], busy: boolean, token: number, owner: string? }>
local nextJobId = 0

local function itemLabel(name)
    local item = Items(name)
    return item and item.label or name
end

local function ownerOf(source)
    local inv = Inventory(source)
    return inv and inv.owner
end

local function hasGroup(source, groups)
    if not groups then return true end
    local inv = Inventory(source)
    local playerGroups = inv and inv.player and inv.player.groups or {}
    for name, grade in pairs(groups) do
        if (playerGroups[name] or -1) >= grade then return true end
    end
    return false
end

--- { {name, label, amount}, ... } para mostrar materiales en la interfaz
local function toList(tbl)
    local list = {}
    for name, amount in pairs(tbl or {}) do
        list[#list + 1] = { name = name, label = itemLabel(name), amount = amount }
    end
    return list
end

---------------------------------------------------------------------
-- Mesas
---------------------------------------------------------------------
local Bench = require 'modules.rustbench.server'

--- Qué mesas tiene cerca el jugador: { ids = {tipo=true}, level = n, repair = bool, recycler = bool }
local sharedBenchState = require 'modules.rustutil.shared'.benchState
local function benchState(source)
    return sharedBenchState(Bench.list(), GetEntityCoords(GetPlayerPed(source)))
end

local function benchLabel(id)
    local t = id and Bench.template(id)
    return t and t.label or id
end

---------------------------------------------------------------------
-- Planos (blueprints): recetas aprendidas por personaje, guardadas en KVP
---------------------------------------------------------------------
local learnedCache = {}

local function getLearned(owner)
    if not owner then return {} end
    if not learnedCache[owner] then
        learnedCache[owner] = json.decode(GetResourceKvpString(('rustcraft:bp:%s'):format(owner)) or '{}') or {}
    end
    return learnedCache[owner]
end

local function learn(owner, recipeName)
    local learned = getLearned(owner)
    learned[recipeName] = true
    SetResourceKvp(('rustcraft:bp:%s'):format(owner), json.encode(learned))
end

--- ¿Puede este jugador craftear esta receta ahora? (ok, motivo)
local function canUse(source, recipe, state, learned)
    if recipe.disabled then return false, 'Esta receta está desactivada' end
    if not hasGroup(source, recipe.groups) then return false, 'No puedes craftear esto' end
    if recipe.blueprint and not learned[recipe.name] then return false, 'Necesitas aprender el plano' end
    if recipe.bench and not state.ids[recipe.bench] then
        return false, ('Necesitas estar cerca de: %s'):format(benchLabel(recipe.bench))
    end
    if recipe.level and state.level < recipe.level then
        return false, ('Necesitas una mesa de nivel %d'):format(recipe.level)
    end
    return true
end

---------------------------------------------------------------------
-- Datos fijos para la interfaz (se arman una sola vez)
---------------------------------------------------------------------
local uiData
local function buildUiData()
    local list = {}
    for i, r in ipairs(recipes) do
        local def = not r.disabled and Items(r.name)
        if def then
            list[i] = {
                id = i,
                name = r.name,
                label = def.label or r.name,
                description = def.description,
                count = r.count,
                time = r.time,
                category = r.category or 'items',
                ingredients = toList(r.ingredients),
                bench = r.bench,
                benchLabel = benchLabel(r.bench),
                level = r.level,
                blueprint = r.blueprint == true,
            }
        end
    end

    local repairItems = {}
    for name, cost in pairs(config.repair and config.repair.items or {}) do repairItems[name] = toList(cost) end

    local recycle = {}
    for name, out in pairs(config.recycle or {}) do recycle[name] = toList(out) end

    uiData = {
        recipes = list,
        repair = { default = toList(config.repair and config.repair.default), items = repairItems },
        recycle = recycle,
    }
end

---------------------------------------------------------------------
-- Cola de crafteo
---------------------------------------------------------------------
local function sendQueue(source)
    local q = queues[source]
    local list = {}
    for i, job in ipairs(q and q.list or {}) do
        list[i] = {
            id = job.id,
            name = job.recipe.name,
            label = itemLabel(job.recipe.name),
            amount = job.remaining,
            time = job.recipe.time,
            startedAt = job.startedAt,
        }
    end
    TriggerClientEvent('ox_inventory:rustcraftQueue', source, list, os.time())
end

local function processQueue(source)
    local q = queues[source]
    if not q or q.busy or #q.list == 0 then return end

    q.busy = true
    q.token += 1
    local token, job = q.token, q.list[1]
    job.startedAt = os.time()
    sendQueue(source)

    SetTimeout(job.recipe.time * 1000, function()
        -- cancelado, desconectado o reiniciado: este temporizador ya no vale
        if queues[source] ~= q or q.token ~= token then return end
        q.busy = false

        local recipe = job.recipe
        if Inventory.CanCarryItem(source, recipe.name, recipe.count) then
            Inventory.AddItem(source, recipe.name, recipe.count)
            TriggerClientEvent('ox_inventory:rustcraftDone', source)
        else
            for item, amount in pairs(recipe.ingredients) do
                Inventory.AddItem(source, item, amount)
            end
            TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Inventario lleno' })
        end

        job.remaining -= 1
        job.startedAt = nil
        if job.remaining <= 0 then table.remove(q.list, 1) end

        if #q.list > 0 then processQueue(source) else sendQueue(source) end
    end)
end

---------------------------------------------------------------------
-- Devoluciones pendientes (desconexión o reinicio), guardadas en KVP
---------------------------------------------------------------------
local function refundKey(owner) return ('rustcraft:refund:%s'):format(owner) end

local function givePendingRefund(source)
    local owner = ownerOf(source)
    local raw = owner and GetResourceKvpString(refundKey(owner))
    if not raw then return end

    local leftover = {}
    for name, count in pairs(json.decode(raw) or {}) do
        if not Inventory.AddItem(source, name, count) then leftover[name] = count end
    end

    if next(leftover) then
        SetResourceKvp(refundKey(owner), json.encode(leftover))
    else
        DeleteResourceKvp(refundKey(owner))
    end

    TriggerClientEvent('ox_lib:notify', source, {
        type = 'inform',
        description = 'Se te devolvieron los materiales de tu cola de crafteo.',
    })
end

local function saveRefund(q)
    if not q or not q.owner or #q.list == 0 then return end

    local key = refundKey(q.owner)
    local items = json.decode(GetResourceKvpString(key) or '{}') or {}
    for _, job in ipairs(q.list) do
        for name, need in pairs(job.recipe.ingredients) do
            items[name] = (items[name] or 0) + need * job.remaining
        end
    end
    SetResourceKvp(key, json.encode(items))
end

local function saveAll()
    for src, q in pairs(queues) do
        saveRefund(q)
        queues[src] = nil
    end
end

---------------------------------------------------------------------
-- Callbacks de crafteo
---------------------------------------------------------------------
lib.callback.register('ox_inventory:rustcraftRecipes', function(source)
    if not uiData then buildUiData() end
    givePendingRefund(source)

    local learned = getLearned(ownerOf(source))
    local list = {}
    for i, r in ipairs(recipes) do
        if uiData.recipes[i] and hasGroup(source, r.groups) then
            local entry = table.clone(uiData.recipes[i])
            entry.learned = not r.blueprint or learned[r.name] == true
            list[#list + 1] = entry
        end
    end

    sendQueue(source)
    return {
        categories = config.categories,
        recipes = list,
        bench = benchState(source),
        repair = uiData.repair,
        recycle = uiData.recycle,
    }
end)

lib.callback.register('ox_inventory:rustcraftCraft', function(source, recipeId, amount)
    local recipe = recipes[tonumber(recipeId)]
    amount = math.floor(tonumber(amount) or 1)
    if not recipe or amount < 1 or amount > 100 then return false, 'Receta inválida' end

    local ok, reason = canUse(source, recipe, benchState(source), getLearned(ownerOf(source)))
    if not ok then return false, reason end

    local q = queues[source]
    if not q then
        q = { list = {}, busy = false, token = 0, owner = ownerOf(source) }
        queues[source] = q
    end
    if #q.list >= (config.maxQueue or 10) then return false, 'Cola llena' end

    for item, need in pairs(recipe.ingredients) do
        if (Inventory.GetItemCount(source, item) or 0) < need * amount then
            return false, ('Te falta %s'):format(itemLabel(item))
        end
    end
    for item, need in pairs(recipe.ingredients) do
        Inventory.RemoveItem(source, item, need * amount)
    end

    nextJobId += 1
    q.list[#q.list + 1] = { id = nextJobId, recipe = recipe, remaining = amount }
    if q.busy then sendQueue(source) else processQueue(source) end
    Log.add('craft', source, ('%dx %s'):format(amount * recipe.count, itemLabel(recipe.name)))
    return true
end)

lib.callback.register('ox_inventory:rustcraftCancel', function(source, jobId)
    local q = queues[source]
    if not q then return false end

    for i, job in ipairs(q.list) do
        if job.id == jobId then
            for item, need in pairs(job.recipe.ingredients) do
                Inventory.AddItem(source, item, need * job.remaining)
            end
            table.remove(q.list, i)
            if i == 1 then
                q.busy = false
                q.token += 1 -- invalida el temporizador del crafteo cancelado
            end
            if #q.list > 0 and not q.busy then processQueue(source) else sendQueue(source) end
            return true
        end
    end
    return false
end)

---------------------------------------------------------------------
-- Reparar (en mesa con repair = true)
---------------------------------------------------------------------
lib.callback.register('ox_inventory:rustcraftRepair', function(source, slotId)
    if not benchState(source).repair then return false, 'Necesitas estar en una mesa para reparar' end

    local item = Inventory.GetSlot(source, tonumber(slotId))
    local durability = item and item.metadata and item.metadata.durability
    if type(durability) ~= 'number' or durability > 100 then return false, 'Ese item no se puede reparar' end
    if durability >= 100 then return false, 'Ya está al 100%' end

    local base = config.repair and (config.repair.items or {})[item.name] or (config.repair and config.repair.default)
    if not base then return false, 'Ese item no se puede reparar' end

    local missing = (100 - durability) / 100
    local cost = {}
    for name, amount in pairs(base) do
        cost[name] = math.max(1, math.ceil(amount * missing))
        if (Inventory.GetItemCount(source, name) or 0) < cost[name] then
            return false, ('Te falta %s'):format(itemLabel(name))
        end
    end

    for name, amount in pairs(cost) do Inventory.RemoveItem(source, name, amount) end
    Inventory.SetDurability(source, item.slot, 100)
    TriggerClientEvent('ox_inventory:rustcraftDone', source)
    Log.add('repair', source, ('%s (%d%% -> 100%%)'):format(itemLabel(item.name), math.floor(durability)))
    return true
end)

---------------------------------------------------------------------
-- Reciclar (en mesa con recycler = true)
---------------------------------------------------------------------
lib.callback.register('ox_inventory:rustcraftRecycle', function(source, itemName, amount)
    if not benchState(source).recycler then return false, 'Necesitas estar en un reciclador' end

    local output = config.recycle and config.recycle[itemName]
    amount = math.floor(tonumber(amount) or 1)
    if not output or amount < 1 or amount > 1000 then return false, 'Ese item no se puede reciclar' end
    if (Inventory.GetItemCount(source, itemName) or 0) < amount then return false, 'No tienes suficientes' end

    for name, per in pairs(output) do
        if not Inventory.CanCarryItem(source, name, per * amount) then return false, 'Inventario lleno' end
    end

    if not Inventory.RemoveItem(source, itemName, amount) then return false, 'No se pudo reciclar' end
    for name, per in pairs(output) do Inventory.AddItem(source, name, per * amount) end
    TriggerClientEvent('ox_inventory:rustcraftDone', source)
    Log.add('recycle', source, ('%dx %s'):format(amount, itemLabel(itemName)))
    return true
end)

---------------------------------------------------------------------
-- Item "plano": al usarlo aprendes la receta (data/items.lua -> server.export)
---------------------------------------------------------------------
exports('rustLearnBlueprint', function(event, item, inventory, slot)
    if event ~= 'usingItem' then return end

    local source = inventory.id
    local data = inventory.items[slot]
    local recipeName = data and data.metadata and data.metadata.recipe
    local recipe = recipeName and recipeByName[recipeName]

    if not recipe or not recipe.blueprint then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Este plano está en blanco' })
        return false
    end

    local owner = inventory.owner
    if getLearned(owner)[recipeName] then
        TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Ya conoces este plano' })
        return false
    end

    learn(owner, recipeName)
    Log.add('blueprint', source, ('Aprendió %s'):format(itemLabel(recipeName)))
    TriggerClientEvent('ox_lib:notify', source, {
        type = 'success',
        description = ('Aprendiste a craftear: %s'):format(itemLabel(recipeName)),
    })
    return true
end)

--- Da un plano con su receta. Úsalo desde otros scripts: exports.ox_inventory:GiveBlueprint(src, 'armour')
local function giveBlueprint(target, recipeName)
    local recipe = recipeByName[recipeName]
    if not recipe or not recipe.blueprint then return false end
    return Inventory.AddItem(target, config.blueprintItem or 'blueprint', 1, {
        recipe = recipeName,
        label = ('Plano: %s'):format(itemLabel(recipeName)),
        description = ('Úsalo para aprender a craftear %s.'):format(itemLabel(recipeName)),
    })
end
exports('GiveBlueprint', giveBlueprint)

---------------------------------------------------------------------
-- Eventos
---------------------------------------------------------------------
AddEventHandler('playerDropped', function()
    local q = queues[source]
    queues[source] = nil
    saveRefund(q)
end)

AddEventHandler('onResourceStop', function(res)
    if res == cache.resource then saveAll() end
end)
AddEventHandler('txAdmin:events:serverShuttingDown', saveAll)
AddEventHandler('txAdmin:events:scheduledRestart', function(data)
    if data.secondsRemaining <= 60 then saveAll() end
end)

-- Al entrar con el personaje (Qbox) se devuelve lo pendiente
RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    local src = source
    CreateThread(function()
        for _ = 1, 50 do
            if Inventory(src) then return givePendingRefund(src) end
            Wait(200)
        end
    end)
end)

---------------------------------------------------------------------
-- Funciones para /admininventory
---------------------------------------------------------------------
local M = {}

--- Nombres de las recetas activas que usan plano (para los planos al azar del botín)
function M.blueprintRecipes()
    local list = {}
    for _, r in ipairs(recipes) do
        if r.blueprint and not r.disabled then list[#list + 1] = r.name end
    end
    return list
end

function M.categories() return config.categories end

--- Todas las recetas (también las desactivadas) para editarlas
function M.list()
    local list = {}
    for _, r in ipairs(recipes) do
        list[#list + 1] = {
            name = r.name, label = itemLabel(r.name), time = r.time, count = r.count,
            category = r.category or 'items', ingredients = r.ingredients or {},
            level = r.level, bench = r.bench, blueprint = r.blueprint == true, disabled = r.disabled == true,
        }
    end
    return list
end

--- Crea o cambia una receta. d = { name, time, count, category, ingredients = {item = n}, level, bench, blueprint, disabled }
function M.save(d)
    if type(d.name) ~= 'string' or not Items(d.name) then return false, 'Ese item no existe' end

    local ingredients = {}
    for item, n in pairs(type(d.ingredients) == 'table' and d.ingredients or {}) do
        n = tonumber(n)
        if not Items(item) then return false, ('El material "%s" no existe'):format(item) end
        if n and n > 0 then ingredients[item] = n end
    end
    if not next(ingredients) then return false, 'La receta necesita al menos un material' end

    local o = {
        time = math.max(1, math.floor(tonumber(d.time) or 1)),
        count = math.max(1, math.floor(tonumber(d.count) or 1)),
        category = type(d.category) == 'string' and d.category or 'items',
        ingredients = ingredients,
        level = tonumber(d.level) and tonumber(d.level) > 0 and math.floor(tonumber(d.level)) or false,
        bench = type(d.bench) == 'string' and d.bench ~= '' and d.bench or false,
        blueprint = d.blueprint == true,
        disabled = d.disabled == true,
    }
    overrides[d.name] = o
    SetResourceKvp(RECIPES_KVP, json.encode(overrides))

    local r = recipeByName[d.name]
    if not r then
        r = { name = d.name }
        addRecipe(r)
    end
    for _, k in ipairs(EDITABLE) do r[k] = o[k] ~= false and o[k] or nil end
    uiData = nil -- se vuelve a armar para la interfaz
    return true
end

--- Planos de un jugador conectado
local function setLearned(target, learned)
    local owner = ownerOf(target)
    if not owner then return false end
    learnedCache[owner] = learned
    SetResourceKvp(('rustcraft:bp:%s'):format(owner), json.encode(learned))
    return true
end

function M.resetBlueprints(target) return setLearned(target, {}) end

function M.learnAll(target)
    local learned = {}
    for _, name in ipairs(M.blueprintRecipes()) do learned[name] = true end
    return setLearned(target, learned)
end

M.giveBlueprint = giveBlueprint

return M
