-- Ayudas del cliente compartidas por los módulos rust* (objetos locales, texto en pantalla, inventario abierto)
local M = {}

--- Crea un objeto solo para este jugador, congelado y apoyado en el suelo
function M.spawnProp(model, x, y, z, heading, findGround)
    lib.requestModel(model)
    if findGround then
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 5.0, false)
        if found then z = groundZ end
    end
    local obj = CreateObject(model, x, y, z, false, false, false)
    SetEntityHeading(obj, heading or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetModelAsNoLongerNeeded(model)
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
