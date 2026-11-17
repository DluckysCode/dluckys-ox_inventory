if not lib then return end

-- Mesas colocadas en el mundo. Los "tipos" vienen de data/rust_crafting.lua (benches);
-- las posiciones se guardan en KVP para poder moverlas/añadirlas con /admininventory sin reiniciar.

local config = lib.load('data.rust_crafting') or {}
local KVP = 'rustbench:data'

local templates = {}
for _, b in ipairs(config.benches or {}) do templates[b.id] = b end

-- data = { placed = { {id, template, x, y, z, h}, ... }, deleted = { [templateId] = true } }
local data = json.decode(GetResourceKvpString(KVP) or '{}') or {}
data.placed = data.placed or {}
data.deleted = data.deleted or {}

-- Mesas nuevas del archivo de config que todavía no están colocadas: se ponen en sus coordenadas.
-- Un tipo sin coords no se coloca solo: lo pone un admin con /admininventory.
do
    local placed = {}
    for _, p in ipairs(data.placed) do placed[p.id] = true end
    for id, b in pairs(templates) do
        local c = b.coords
        if c and not placed[id] and not data.deleted[id] then
            data.placed[#data.placed + 1] = { id = id, template = id, x = c.x, y = c.y, z = c.z, h = c.w or 0.0 }
        end
    end
end

local M = {}
local list, byId = {}, {}

local function rebuild()
    list, byId = {}, {}
    for _, p in ipairs(data.placed) do
        local t = templates[p.template]
        if t then
            local b = {
                id = p.id, template = p.template, label = t.label, model = t.model,
                distance = t.distance, level = t.level, repair = t.repair, recycler = t.recycler, blip = t.blip,
                x = p.x, y = p.y, z = p.z, h = p.h,
            }
            list[#list + 1] = b
            byId[b.id] = b
        end
    end
    GlobalState.rustBenches = list
end

local function save()
    SetResourceKvp(KVP, json.encode(data))
    rebuild()
end
save()

local function find(id)
    for i, p in ipairs(data.placed) do
        if p.id == id then return i, p end
    end
end

function M.list() return list end
function M.template(id) return templates[id] end
function M.templates() return templates end

function M.add(template, x, y, z, h)
    if not templates[template] then return false end
    local id = ('%s_%d%d'):format(template, os.time(), math.random(100, 999))
    data.placed[#data.placed + 1] = { id = id, template = template, x = x, y = y, z = z, h = h }
    save()
    return true
end

function M.move(id, x, y, z, h)
    local _, p = find(id)
    if not p then return false end
    p.x, p.y, p.z, p.h = x, y, z, h
    save()
    return true
end

function M.remove(id)
    local i = find(id)
    if not i then return false end
    table.remove(data.placed, i)
    if templates[id] then data.deleted[id] = true end -- que no vuelva a salir desde la config
    save()
    return true
end

return M
