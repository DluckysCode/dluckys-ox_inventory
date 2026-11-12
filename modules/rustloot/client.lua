if not lib then return end

local util = require 'modules.rustutil.client'
local config = lib.load('data.rust_loot')
local dist = config.interactDistance or 2.0
local points = {} -- [id] = lib.point
local busy = false

local function spawn(p)
    if p.object or not p.node.r then return end
    local t = config.types[p.node.t]
    p.object = util.spawnProp(t.model, p.node.x, p.node.y, p.node.z, 0.0, true)
end

local function despawn(p)
    util.deleteProp(p.object)
    p.object = nil
    util.setText(p, false)
end

local function harvest(id, t)
    busy = true
    if lib.callback.await('ox_inventory:rustLootStart', false, id) then
        local done = lib.progressBar({
            duration = t.duration or 2000,
            label = ('%s %s...'):format(t.action, t.label:lower()),
            canCancel = true,
            disable = { move = true, car = true, combat = true },
            anim = t.anim and { dict = t.anim.dict, clip = t.anim.clip, flag = 1 } or nil,
        })
        if done then
            local ok, err = lib.callback.await('ox_inventory:rustLootFinish', false, id)
            if not ok and err then lib.notify({ type = 'error', description = err }) end
        end
    end
    busy = false
end

local function addPoint(id, node)
    local t = config.types[node.t]
    if not t then return end
    local text = ('[E] %s %s'):format(t.action, t.label:lower())
    local pos2 = vec2(node.x, node.y)

    points[id] = lib.points.new({
        coords = vec3(node.x, node.y, node.z),
        distance = 60,
        node = node,
        onEnter = spawn,
        onExit = despawn,
        nearby = function(self)
            if not self.object then return end
            local close = not busy and #(GetEntityCoords(cache.ped).xy - pos2) <= dist
            util.setText(self, close, text, 'hand')

            if close and not util.isInventoryOpen() and IsControlJustReleased(0, 38) then
                util.setText(self, false)
                CreateThread(function() harvest(id, t) end)
            end
        end,
    })
end

-- Lista completa al entrar (reintenta si el servidor aún no está listo);
-- después solo llegan los cambios de cada nodo
local loaded = false
local function requestList()
    lib.callback('ox_inventory:rustLootList', false, function(list)
        if loaded or not list then return end
        loaded = true
        for id, node in pairs(list) do addPoint(id, node) end
    end)
    SetTimeout(5000, function()
        if not loaded then requestList() end
    end)
end
requestList()

RegisterNetEvent('ox_inventory:rustLootState', function(id, ready)
    local p = points[id]
    if not p then return end
    p.node.r = ready
    if ready then
        if p.currentDistance then spawn(p) end
    else
        despawn(p)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    for _, p in pairs(points) do despawn(p) end
end)
