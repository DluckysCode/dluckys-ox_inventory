if not lib then return end

-- Registro de actividad para el panel /admininventory (últimas 300 entradas, en memoria).
-- Se borra al reiniciar ox_inventory.
local MAX = 300
local entries, head = {}, 0
local M = {}

--- kind: craft | recycle | repair | loot | blueprint | box | admin
function M.add(kind, source, text)
    head = head % MAX + 1
    entries[head] = {
        t = os.time(),
        kind = kind,
        player = source and source > 0 and ('%s (%s)'):format(GetPlayerName(source) or '?', source) or 'Servidor',
        text = text,
    }
end

--- Más recientes primero
function M.list()
    local out = {}
    for i = 0, MAX - 1 do
        local e = entries[(head - 1 - i) % MAX + 1]
        if not e then break end
        out[#out + 1] = e
    end
    return out
end

return M
