if not lib then return end

local util = require 'modules.rustutil.client'
local benchState = require 'modules.rustutil.shared'.benchState
local config = lib.load('data.rust_crafting') or {}

--- Sonidos del juego (no necesitan archivos)
local sounds = {
    craft = { 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    done  = { 'PICK_UP', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
    error = { 'ERROR', 'HUD_FRONTEND_DEFAULT_SOUNDSET' },
}
local function playSound(name)
    local s = sounds[name]
    PlaySoundFrontend(-1, s[1], s[2], true)
end

--- Llama al servidor y responde a la interfaz con { ok, error } + sonido
local function action(event, ...)
    local ok, err = lib.callback.await(event, false, ...)
    playSound(ok and 'craft' or 'error')
    return { ok = ok == true, error = err }
end

RegisterNUICallback('rustcraftGetRecipes', function(_, cb)
    cb(lib.callback.await('ox_inventory:rustcraftRecipes', false) or { error = 'El servidor no respondió' })
end)
RegisterNUICallback('rustcraftCraft', function(d, cb) cb(action('ox_inventory:rustcraftCraft', d.id, d.amount)) end)
RegisterNUICallback('rustcraftRepair', function(d, cb) cb(action('ox_inventory:rustcraftRepair', d.slot)) end)
RegisterNUICallback('rustcraftRecycle', function(d, cb) cb(action('ox_inventory:rustcraftRecycle', d.name, d.amount)) end)
RegisterNUICallback('rustcraftCancel', function(d, cb)
    cb({ ok = lib.callback.await('ox_inventory:rustcraftCancel', false, d.id) == true })
end)

RegisterNetEvent('ox_inventory:rustcraftQueue', function(queue, serverTime)
    SendNUIMessage({ action = 'rustcraftQueue', data = { queue = queue, serverTime = serverTime } })
end)
RegisterNetEvent('ox_inventory:rustcraftDone', function() playSound('done') end)

---------------------------------------------------------------------
-- Mesas cercanas en vivo mientras el inventario está abierto
-- (el servidor igual lo vuelve a comprobar al craftear)
---------------------------------------------------------------------
local function sameState(a, b)
    if not a or a.level ~= b.level or a.repair ~= b.repair or a.recycler ~= b.recycler then return false end
    for id in pairs(a.ids) do if not b.ids[id] then return false end end
    for id in pairs(b.ids) do if not a.ids[id] then return false end end
    return true
end

util.onInventory(function(open)
    if not open then return end
    local last
    while util.isInventoryOpen() do
        local state = benchState(config.benches, GetEntityCoords(cache.ped))
        if not sameState(last, state) then
            last = state
            SendNUIMessage({ action = 'rustcraftBench', data = state })
        end
        Wait(1000)
    end
end)

---------------------------------------------------------------------
-- Mesas de trabajo: blip + objeto local cuando estás cerca
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
        local text = ('[TAB] %s'):format(bench.label)
        lib.points.new({
            coords = c.xyz,
            distance = 60,
            onEnter = function(self)
                self.object = util.spawnProp(bench.model, c.x, c.y, c.z, c.w)
            end,
            onExit = function(self)
                util.deleteProp(self.object)
                self.object = nil
                util.setText(self, false)
            end,
            nearby = function(self)
                util.setText(self, self.currentDistance <= (bench.distance or 3.0), text, 'hammer')
            end,
        })
    end
end
