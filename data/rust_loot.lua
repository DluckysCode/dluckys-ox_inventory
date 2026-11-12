-- Barriles y plantas que dan materiales (estilo Rust)
-- Cada punto aparece en el mundo; al romperlo/recogerlo da botín y vuelve a salir tras "respawn" segundos.
--
-- TIPOS
-- loot = { { item, min, max, chance } }  chance = probabilidad 0-100 (por defecto 100)
-- blueprintChance = % de que además salga un plano al azar (de las recetas con blueprint = true)
--
-- DÓNDE APARECEN
-- points = lista de vec3 exactas
-- zones  = { center = vec3, radius = metros, count = cuántos } -> se reparten al azar en el círculo

return {
    types = {
        barrel = {
            label = 'Barril',
            action = 'Romper',
            model = `prop_barrel_01a`,
            duration = 3000,     -- ms que tarda
            respawn = 600,       -- segundos para volver a aparecer
            anim = { dict = 'melee@large_wpn@streamed_core', clip = 'ground_attack_on_spot' },
            loot = {
                { item = 'scrapmetal', min = 2, max = 5 },
                { item = 'cloth',      min = 1, max = 3, chance = 50 },
                { item = 'garbage',    min = 1, max = 2, chance = 40 },
            },
            blueprintChance = 3,
        },
        hemp = {
            label = 'Cáñamo',
            action = 'Recoger',
            model = `prop_weed_01`,
            duration = 2000,
            respawn = 300,
            anim = { dict = 'amb@world_human_gardener_plant@male@base', clip = 'base' },
            loot = {
                { item = 'cloth', min = 3, max = 6 },
            },
        },
    },

    spawns = {
        {
            type = 'barrel',
            zones = {
                { center = vec3(1531.58, 1706.9, 108.85), radius = 40.0, count = 6 },
            },
        },
        {
            type = 'hemp',
            points = {
                vec3(1520.0, 1690.0, 108.5),
                vec3(1524.0, 1688.0, 108.5),
                vec3(1528.0, 1692.0, 108.5),
            },
        },
    },

    interactDistance = 2.0,
    minSpacing = 4.0, -- metros mínimos (zonas al azar) entre barriles/plantas y de las mesas
}
