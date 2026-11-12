if not lib then return end

local config = lib.load('data.rust_loot')
local points = {} -- [id] = lib.point
local busy = false

local function hideText(p)
    if p.showing then
        lib.hideTextUI()
        p.showing = false
    end
end

local function despawn(p)
    if p.object and DoesEntityExist(p.object) then DeleteEntity(p.object) end
    p.object = nil
end

local function spawn(p)
    if p.object or not p.node.r then return end
    local t = config.types[p.node.t]
    lib.requestModel(t.model)
    local x, y, z = p.node.x, p.node.y, p.node.z
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 5.0, false)
    p.object = CreateObject(t.model, x, y, found and groundZ or z, false, false, false)
    PlaceObjectOnGroundProperly(p.object)
    FreezeEntityPosition(p.object, true)
    SetModelAsNoLongerNeeded(t.model)
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

    points[id] = lib.points.new({
        coords = vec3(node.x, node.y, node.z),
        distance = 60,
        node = node,
        onEnter = function(self) spawn(self) end,
        onExit = function(self)
            despawn(self)
            hideText(self)
        end,
        nearby = function(self)
            if not self.object then return hideText(self) end
            local pos = GetEntityCoords(cache.ped)
            local close = #(pos.xy - vec2(self.node.x, self.node.y)) <= (config.interactDistance or 2.0)

            if close and not self.showing and not busy then
                lib.showTextUI(('[E] %s %s'):format(t.action, t.label:lower()), { icon = 'hand' })
                self.showing = true
            elseif (not close or busy) and self.showing then
                hideText(self)
            end

            if close and not busy and not LocalPlayer.state.invOpen and IsControlJustReleased(0, 38) then
                hideText(self)
                CreateThread(function() harvest(id, t) end)
            end
        end,
    })
end

-- Sincroniza con el servidor (aparecer / desaparecer)
local function sync(list)
    list = list or {}
    for id, node in pairs(list) do
        local p = points[id]
        if not p then
            addPoint(id, node)
        else
            p.node = node
            if node.r then
                if p.currentDistance and p.currentDistance < 60 then spawn(p) end
            else
                despawn(p)
                hideText(p)
            end
        end
    end
end

AddStateBagChangeHandler('rustLoot', 'global', function(_, _, value) sync(value) end)
CreateThread(function() sync(GlobalState.rustLoot) end)

AddEventHandler('onResourceStop', function(res)
    if res ~= cache.resource then return end
    for _, p in pairs(points) do
        despawn(p)
        hideText(p)
    end
end)
