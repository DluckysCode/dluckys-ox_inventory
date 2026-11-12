if not lib then return end

local util = require 'modules.rustutil.client'
local config = lib.load('data.rust_storage')
local dist = config.interactDistance or 2.0
local points = {} -- [id] = lib.point

local function removePoint(id)
    local p = points[id]
    if not p then return end
    util.deleteProp(p.object)
    util.setText(p, false)
    p:remove()
    points[id] = nil
end

local function addPoint(box)
    local t = config.types[box.item]
    if not t then return end
    local text = ('[E] Abrir %s  ·  [G] Recoger'):format(t.label)

    points[box.id] = lib.points.new({
        coords = vec3(box.x, box.y, box.z),
        distance = 50,
        onEnter = function(self)
            self.object = util.spawnProp(t.model, box.x, box.y, box.z, box.h)
        end,
        onExit = function(self)
            util.deleteProp(self.object)
            self.object = nil
            util.setText(self, false)
        end,
        nearby = function(self)
            local close = self.currentDistance <= dist
            util.setText(self, close, text, 'box')
            if not close or util.isInventoryOpen() then return end

            if IsControlJustReleased(0, 38) then -- E
                exports.ox_inventory:openInventory('stash', box.id)
            elseif IsControlJustReleased(0, 47) then -- G
                local ok, err = lib.callback.await('ox_inventory:rustBoxPickup', false, box.id)
                if not ok and err then lib.notify({ type = 'error', description = err }) end
            end
        end,
    })
end

-- Sincroniza con la lista de cajas del servidor (GlobalState.rustBoxes)
local function sync(list)
    list = list or {}
    for id in pairs(points) do
        if not list[id] then removePoint(id) end
    end
    for id, box in pairs(list) do
        if not points[id] then addPoint(box) end
    end
end

AddStateBagChangeHandler('rustBoxes', 'global', function(_, _, value) sync(value) end)
CreateThread(function() sync(GlobalState.rustBoxes) end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    for id in pairs(points) do removePoint(id) end
end)
