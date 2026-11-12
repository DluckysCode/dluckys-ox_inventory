-- Ayudas del cliente compartidas por los módulos rust* (objetos locales, texto en pantalla, inventario abierto)
local M = {}

--- Crea un objeto solo para este jugador, congelado y apoyado en el suelo.
--- El suelo puede tardar en cargar (sobre todo dentro de edificios), así que reintenta hasta 3 s.
function M.spawnProp(model, x, y, z, heading, findGround)
    lib.requestModel(model)
    local obj = CreateObject(model, x, y, z, false, false, false)
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)

    CreateThread(function()
        for _ = 1, 30 do
            if not DoesEntityExist(obj) then return end
            RequestCollisionAtCoord(x, y, z)
            if findGround then
                -- se busca desde poco por encima para no agarrar techos
                local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 1.5, false)
                if found then SetEntityCoords(obj, x, y, groundZ, false, false, false, false) end
            end
            if PlaceObjectOnGroundProperly(obj) then return end
            Wait(100)
        end
    end)

    return obj
end

function M.deleteProp(obj)
    if obj and DoesEntityExist(obj) then DeleteEntity(obj) end
end

--- Muestra/oculta el texto de ayuda de un punto sin repetir llamadas cada frame
function M.setText(point, show, text, icon)
    show = show and true or false
    if show == (point.showing or false) then return end
    point.showing = show
    if show then lib.showTextUI(text, { icon = icon }) else lib.hideTextUI() end
end

--- Avisa a los módulos cuando el inventario se abre o se cierra (fn(abierto))
local listeners, open = {}, false

AddStateBagChangeHandler('invOpen', ('player:%s'):format(cache.serverId), function(_, _, value)
    local now = value and true or false
    if now == open then return end
    open = now
    for i = 1, #listeners do CreateThread(function() listeners[i](open) end) end
end)

function M.onInventory(fn) listeners[#listeners + 1] = fn end
function M.isInventoryOpen() return open end

return M
