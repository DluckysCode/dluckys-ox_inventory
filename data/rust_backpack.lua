-- Mochilas (estilo Rust): se ponen en el slot "Mochila" de la barra rápida.
-- Con la mochila puesta el inventario gana slots y peso; al quitarla, lo de esos slots se guarda dentro de ella.
--
-- slots    = slots extra que da
-- weight   = peso extra que da (gramos)
-- clothing = cómo se ve puesta (componente 5 de GTA = mochilas). false = no se ve.
--            { drawable, texture } por género. Si no se ve bien, cambia el número del drawable.

return {
    types = {
        mochila_pequena = {
            label = 'Mochila pequeña',
            slots = 5,
            weight = 15000,
            clothing = { male = { 45, 0 }, female = { 45, 0 } },
        },
        mochila_grande = {
            label = 'Mochila grande',
            slots = 10,
            weight = 30000,
            clothing = { male = { 82, 0 }, female = { 82, 0 } },
        },
    },
}
