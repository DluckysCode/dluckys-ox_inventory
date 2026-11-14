-- Loot que sale al abrir por primera vez un dumpster o la guantera/maletero de un carro sin dueño
-- { item, mínimo, máximo, probabilidad % (opcional, sin ella = siempre) }
-- Usa solo items que existan en data/items.lua o data/weapons.lua. Se aplica con: ensure ox_inventory

return {
    dumpster = {
        { 'garbage',    1, 3 },
        { 'scrapmetal', 1, 3, 70 },
        { 'cloth',      1, 3, 60 },
        { 'lockpick',   1, 1, 10 },
    },

    vehicle = {
        { 'sprunk',  1, 1 },
        { 'water',   1, 1 },
        { 'garbage', 1, 2, 50 },
        { 'panties', 1, 1, 5 },
    },
}
