if not lib then return end

local config = lib.load('data.rust_crafting') or {}

--- Sonidos del juego (no necesitan archivos)
local sounds = {
    craft = { 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    done  = { 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    error = { 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
}
local function playSound(name)
    local s = sounds[name]
    if s then PlaySoundFrontend(-1, s[1], s[2], true) end
end
exports('rustSound', playSound)

RegisterNUICallback('rustcraftGetRecipes', function(_, cb)
    cb(lib.callback.await('ox_inventory:rustcraftRecipes', false) or { error = 'El servidor no respondió' })
end)

RegisterNUICallback('rustcraftCraft', function(data, cb)
    local ok, err = lib.callback.await('ox_inventory:rustcraftCraft', false, data.id, data.amount)
    playSound(ok and 'craft' or 'error')
    cb({ ok = ok, error = err })
end)

RegisterNUICallback('rustcraftCancel', function(data, cb)
    cb({ ok = lib.callback.await('ox_inventory:rustcraftCancel', false, data.id) == true })
end)

RegisterNetEvent('ox_inventory:rustcraftQueue', function(queue, serverTime)
    SendNUIMessage({ action = 'rustcraftQueue', data = { queue = queue, serverTime = serverTime } })
end)

RegisterNetEvent('ox_inventory:rustcraftDone', function()
    playSound('done')
end)

RegisterNUICallback('rustcraftRepair', function(data, cb)
    local ok, err = lib.callback.await('ox_inventory:rustcraftRepair', false, data.slot)
    playSound(ok and 'craft' or 'error')
    cb({ ok = ok, error = err })
end)

RegisterNUICallback('rustcraftRecycle', function(data, cb)
    local ok, err = lib.callback.await('ox_inventory:rustcraftRecycle', false, data.name, data.amount)
    playSound(ok and 'craft' or 'error')
    cb({ ok = ok, error = err })
end)

---------------------------------------------------------------------
-- Mesas cercanas en vivo mientras el inventario está abierto
-- (el servidor igual lo vuelve a comprobar al craftear)
---------------------------------------------------------------------
local function benchState()
    local state = { ids = {}, level = 0, repair = false, recycler = false }
    local pos = GetEntityCoords(cache.ped)
    for _, b in ipairs(config.benches or {}) do
        if #(pos - b.coords.xyz) <= (b.distance or 3.0) then
            state.ids[b.id] = true
            state.level = math.max(state.level, b.level or 0)
            state.repair = state.repair or b.repair == true
            state.recycler = state.recycler or b.recycler == true
        end
    end
    return state
end

local invOpen = false
AddStateBagChangeHandler('invOpen', ('player:%s'):format(cache.serverId), function(_, _, value)
    local was = invOpen
    invOpen = value and true or false
    if not invOpen or was then return end

    CreateThread(function()
        local last
        while invOpen do
            local state = benchState()
            local key = json.encode(state)
            if key ~= last then
                last = key
                SendNUIMessage({ action = 'rustcraftBench', data = state })
            end
            Wait(1000)
        end
    end)
end)

---------------------------------------------------------------------
-- Mesas de trabajo: el objeto se crea solo cuando estás cerca
---------------------------------------------------------------------
for _, bench in ipairs(config.benches or {}) do
    local c = bench.coords

    if bench.blip then
        local blip = AddBlipForCoord(c.x, c.y, c.z)
        SetBlipSprite(blip, bench.blip.sprite or 566)
        SetBlipColour(blip, bench.blip.colour or 31)
        SetBlipScale(blip, bench.blip.scale or 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(bench.label)
        EndTextCommandSetBlipName(blip)
    end

    if bench.model then
        lib.points.new({
            coords = c.xyz,
            distance = 60,
            onEnter = function(self)
                lib.requestModel(bench.model)
                self.object = CreateObject(bench.model, c.x, c.y, c.z, false, false, false)
                SetEntityHeading(self.object, c.w or 0.0)
                PlaceObjectOnGroundProperly(self.object)
                FreezeEntityPosition(self.object, true)
                SetModelAsNoLongerNeeded(bench.model)
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
                local close = self.currentDistance <= (bench.distance or 3.0)
                if close and not self.showing then
                    lib.showTextUI(('[TAB] %s'):format(bench.label), { icon = 'hammer' })
                    self.showing = true
                elseif not close and self.showing then
                    lib.hideTextUI()
                    self.showing = false
                end
            end,
        })
    end
end
