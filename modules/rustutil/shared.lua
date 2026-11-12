-- Funciones compartidas (cliente y servidor) del inventario estilo Rust
local M = {}

--- Qué mesas hay cerca de "pos": { ids = {id=true}, level = n, repair = bool, recycler = bool }
function M.benchState(benches, pos)
    local state = { ids = {}, level = 0, repair = false, recycler = false }
    for _, b in ipairs(benches or {}) do
        if #(pos - b.coords.xyz) <= (b.distance or 3.0) then
            state.ids[b.id] = true
            state.level = math.max(state.level, b.level or 0)
            state.repair = state.repair or b.repair == true
            state.recycler = state.recycler or b.recycler == true
        end
    end
    return state
end

return M
