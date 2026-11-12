if not lib then return end

local config = lib.load('data.rust_storage')
local points = {} -- [id] = lib.point

local function removePoint(id)
    local p = points[id]
    if not p then return end
    if p.object and DoesEntityExist(p.object) then DeleteEntity(p.object) end
    if p.showing then lib.hideTextUI() end
    p:remove()
    points[id] = nil
end

local function addPoint(box)
    local t = config.types[box.item]
    if not t then return end
    local coords = vec3(box.x, box.y, box.z)

    points[box.id] = lib.points.new({
        coords = coords,
        distance = 50,
        onEnter = function(self)
            lib.requestModel(t.model)
            self.object = CreateObject(t.model, coords.x, coords.y, coords.z, false, false, false)
            SetEntityHeading(self.object, box.h or 0.0)
            PlaceObjectOnGroundProperly(self.object)
            FreezeEntityPosition(self.object, true)
            SetModelAsNoLongerNeeded(t.model)
        end,
        onExit = function(self)
            if self.object and DoesEntityExist(self.object) then DeleteEntity(self.object) end
            self.object = nil
            if self.showing then
                lib.hideTextUI()
                self.showing = false
            end
        end,
        nearby = function(self)
            local close = self.currentDistance <= (config.interactDistance or 2.0)
            if close ~= (self.showing or false) then
                self.showing = close
                if close then
                    lib.showTextUI(('[E] Abrir %s  ·  [G] Recoger'):format(t.label), { icon = 'box' })
                else
                    lib.hideTextUI()
                end
            end
            if not close or LocalPlayer.state.invOpen then return end

            if IsControlJustReleased(0, 38) then -- E
                exports.ox_inventory:openInventory('stash', box.id)
            elseif IsControlJustReleased(0, 47) then -- G
                local ok, err = lib.callback.await('ox_inventory:rustBoxPickup', false, box.id)
                if not ok and err then lib.notify({ type = 'error', description = err }) end
            end
        end,
    })
end

-- Sincroniza con la lista de cajas del servidor
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
