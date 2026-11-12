-- Cajas de almacenamiento que los jugadores colocan en el mundo (estilo Rust)
-- Usa el item para colocarla delante de ti. [E] abrir · [G] recoger (solo el dueño y vacía)

return {
    types = {
        caja_madera = {               -- nombre del item en data/items.lua
            label = 'Caja de madera',
            model = `prop_box_wood05a`, -- cámbialo si prefieres otro objeto
            slots = 20,
            maxWeight = 100000,       -- gramos
        },
    },

    maxPerPlayer = 5,      -- cajas máximas por personaje
    ownerOnly = false,     -- true = solo el dueño puede abrirla; false = cualquiera (como en Rust)
    interactDistance = 2.0,
}
