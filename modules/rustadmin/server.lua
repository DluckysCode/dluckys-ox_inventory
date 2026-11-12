if not lib then return end

-- /admininventory: panel de admin para colocar / mover / eliminar mesas y puntos de botín en 3D
local Bench = require 'modules.rustbench.server'
local Loot = require 'modules.rustloot.server'

-- lib.addCommand con restricted da el permiso "command.admininventory" al grupo admin
local function isAdmin(src) return IsPlayerAceAllowed(src, 'command.admininventory') end

local function isNum(n) return type(n) == 'number' and n == n and math.abs(n) < 100000 end

lib.addCommand('admininventory', {
    help = 'Colocar, mover o eliminar mesas y botín (admin)',
    restricted = 'group.admin',
}, function(source)
    TriggerClientEvent('ox_inventory:rustAdminOpen', source)
end)

lib.callback.register('ox_inventory:rustAdminData', function(source)
    if not isAdmin(source) then return end

    local templates = {}
    for id, t in pairs(Bench.templates()) do templates[#templates + 1] = { id = id, label = t.label, model = t.model } end

    local benches = {}
    for _, b in ipairs(Bench.list()) do
        benches[#benches + 1] = { id = b.id, template = b.template, label = b.label, x = b.x, y = b.y, z = b.z, h = b.h }
    end

    return { benches = benches, templates = templates, lootTypes = Loot.types(), loot = Loot.points() }
end)

local actions = {
    addBench    = function(d) return Bench.add(d.template, d.x, d.y, d.z, d.h) end,
    moveBench   = function(d) return Bench.move(d.id, d.x, d.y, d.z, d.h) end,
    removeBench = function(d) return Bench.remove(d.id) end,
    addLoot     = function(d) return Loot.add(d.type, d.x, d.y, d.z) end,
    moveLoot    = function(d) return Loot.move(d.id, d.x, d.y, d.z) end,
    removeLoot  = function(d) return Loot.remove(d.id) end,
}

lib.callback.register('ox_inventory:rustAdminAction', function(source, action, d)
    if not isAdmin(source) or type(d) ~= 'table' or not actions[action] then return false end
    if d.x ~= nil and not (isNum(d.x) and isNum(d.y) and isNum(d.z) and isNum(d.h or 0)) then return false end

    local ok = actions[action](d)
    if ok then
        print(('[rustadmin] %s (%s) -> %s %s'):format(GetPlayerName(source), source, action, d.id or d.template or d.type or ''))
    end
    return ok
end)
