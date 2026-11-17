if not lib then return end

local util = require 'modules.rustutil.client'
local benchState = require 'modules.rustutil.shared'.benchState

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

--- Llama al servidor y responde a la interfaz con { ok, error, item } + sonido.
--- Si el servidor devuelve una tabla (lo que hay en la mesa de reparación) va en "item".
local function action(event, ...)
    local res, err = lib.callback.await(event, false, ...)
    playSound(res and 'craft' or 'error')
    return { ok = res and true or false, error = err, item = type(res) == 'table' and res or nil }
end

RegisterNUICallback('rustcraftGetRecipes', function(_, cb)
    cb(lib.callback.await('ox_inventory:rustcraftRecipes', false) or { error = 'El servidor no respondió' })
end)
RegisterNUICallback('rustcraftCraft', function(d, cb) cb(action('ox_inventory:rustcraftCraft', d.id, d.amount)) end)
-- Mesa de reparación: meter / sacar / ver el objeto, repararlo y cambiarle el color
RegisterNUICallback('rustRepairGet', function(_, cb) cb({ item = lib.callback.await('ox_inventory:rustRepairGet', false) or nil }) end)
RegisterNUICallback('rustRepairPut', function(d, cb) cb(action('ox_inventory:rustRepairPut', d.slot)) end)
RegisterNUICallback('rustRepairTake', function(_, cb) cb(action('ox_inventory:rustRepairTake')) end)
RegisterNUICallback('rustcraftRepair', function(_, cb) cb(action('ox_inventory:rustcraftRepair')) end)
RegisterNUICallback('rustcraftSkin', function(d, cb) cb(action('ox_inventory:rustcraftSkin', d.tint)) end)
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
    if not open then
        util.benchOpen = false -- al cerrar, el próximo inventario vuelve a ser el normal
        return
    end
    local last
    while util.isInventoryOpen() do
        local state = benchState(GlobalState.rustBenches, GetEntityCoords(cache.ped))
        if not sameState(last, state) then
            last = state
            SendNUIMessage({ action = 'rustcraftBench', data = state })
        end
        Wait(1000)
    end
end)

---------------------------------------------------------------------
-- Mesas de trabajo: blip + objeto local cuando estás cerca.
-- La lista viene del servidor (GlobalState.rustBenches) y cambia en vivo con /admininventory.
---------------------------------------------------------------------
local placed = {} -- [id] = { point, blip }

--- Abre tu inventario desde una mesa y cambia la interfaz a su vista ("rustRepairOpen" o "rustCraftOpen")
local function openBenchView(action)
    util.benchOpen = true -- antes de abrir: así la cámara de la ropa no se activa
    client.openInventory()
    -- espera a que la interfaz tenga el inventario y luego cambia a la vista de la mesa
    for _ = 1, 20 do
        if util.isInventoryOpen() then
            return SendNUIMessage({ action = action })
        end
        Wait(50)
    end
end

--- Árbol de desbloqueos: UI propia (sin inventario)
local function openTree()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'rustTreeOpen' })
end

RegisterNUICallback('rustTreeGet', function(_, cb)
    local data, err = lib.callback.await('ox_inventory:rustTreeGet', false)
    cb(data or { error = err or 'El servidor no respondió' })
end)
RegisterNUICallback('rustTreeUnlock', function(d, cb) cb(action('ox_inventory:rustTreeUnlock', d.name)) end)
RegisterNUICallback('rustTreeClose', function(_, cb)
    SetNuiFocus(false, false)
    cb(1)
end)

local hasTarget = GetResourceState('ox_target') ~= 'missing'

--- Opciones de ox_target según el tipo de mesa (nil = esta mesa se usa con TAB)
local function targetOptions(bench)
    if not hasTarget then return end
    local dist = bench.distance or 3.0
    if bench.repair then
        return {
            { name = 'rust_repair_bench', icon = 'fa-solid fa-screwdriver-wrench', label = bench.label, distance = dist,
              onSelect = function() openBenchView('rustRepairOpen') end },
        }
    end
    if (bench.level or 0) >= 1 then
        return {
            { name = 'rust_bench_craft', icon = 'fa-solid fa-hammer', label = 'Craftear', distance = dist,
              onSelect = function() openBenchView('rustCraftOpen') end },
            { name = 'rust_bench_tree', icon = 'fa-solid fa-sitemap', label = 'Desbloquear', distance = dist,
              onSelect = openTree },
        }
    end
end

local function removeBench(id)
    local b = placed[id]
    if not b then return end
    if b.point then
        if hasTarget and b.point.object then exports.ox_target:removeLocalEntity(b.point.object) end
        util.deleteProp(b.point.object)
        util.setText(b.point, false)
        b.point:remove()
    end
    if b.blip then RemoveBlip(b.blip) end
    placed[id] = nil
end

local function addBench(bench)
    local entry = {}

    if bench.blip then
        local blip = AddBlipForCoord(bench.x, bench.y, bench.z)
        SetBlipSprite(blip, bench.blip.sprite or 566)
        SetBlipColour(blip, bench.blip.colour or 31)
        SetBlipScale(blip, bench.blip.scale or 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(bench.label)
        EndTextCommandSetBlipName(blip)
        entry.blip = blip
    end

    if bench.model then
        -- Mesas de trabajo y de reparación se usan con ox_target; el resto (reciclador) con TAB
        local options = targetOptions(bench)
        local useTarget = options ~= nil
        local text = ('[TAB] %s'):format(bench.label)
        entry.point = lib.points.new({
            coords = vec3(bench.x, bench.y, bench.z),
            distance = 60,
            onEnter = function(self)
                self.object = util.spawnProp(bench.model, bench.x, bench.y, bench.z, bench.h)
                if useTarget then exports.ox_target:addLocalEntity(self.object, options) end
            end,
            onExit = function(self)
                if useTarget and self.object then exports.ox_target:removeLocalEntity(self.object) end
                util.deleteProp(self.object)
                self.object = nil
                util.setText(self, false)
            end,
            nearby = not useTarget and function(self)
                util.setText(self, self.currentDistance <= (bench.distance or 3.0), text, 'hammer')
            end or nil,
        })
    end

    placed[bench.id] = entry
end

local function syncBenches(list)
    for id in pairs(placed) do removeBench(id) end
    for _, bench in ipairs(list or {}) do addBench(bench) end
end

AddStateBagChangeHandler('rustBenches', 'global', function(_, _, value) syncBenches(value) end)
CreateThread(function() syncBenches(GlobalState.rustBenches) end)

AddEventHandler('onResourceStop', function(res)
    if res == cache.resource then syncBenches({}) end
end)
