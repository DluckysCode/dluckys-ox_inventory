-- Crafteo estilo Rust (desde el inventario)
--
-- RECETAS
-- name        = item que se obtiene
-- count       = cuántos da cada crafteo (opcional, por defecto 1)
-- time        = segundos por crafteo
-- category    = medical | tools | weapons | items
-- ingredients = { item = cantidad }
-- groups      = (opcional) { police = 0 } para limitar por trabajo/grado
-- level       = (opcional) nivel mínimo de mesa: 1, 2 o 3. Sin level = se craftea en cualquier lado
-- bench       = (opcional) id de una mesa concreta (en vez de level)
-- blueprint   = (opcional) true = hay que aprender el plano antes de poder craftearla

return {
    categories = {
        { id = 'all',       label = 'Todo' },
        { id = 'medical',   label = 'Médico' },
        { id = 'tools',     label = 'Herramientas' },
        { id = 'weapons',   label = 'Armas' },
        { id = 'items',     label = 'Objetos' },
        { id = 'textil',    label = 'Textil' },
    },

    maxQueue = 10, -- máximo de crafteos en cola por jugador

    -- TIPOS DE MESA. Para colocarlas, moverlas, añadir más o eliminarlas usa /admininventory en el juego.
    -- coords   = vec4(x, y, z, rotación) -> solo la posición inicial (la primera vez que arranca);
    --            después manda lo que hagas con /admininventory (se guarda en el servidor)
    -- level    = nivel de la mesa (desbloquea recetas con level <= este)
    -- repair   = true: permite reparar armas/herramientas aquí
    -- recycler = true: permite reciclar items aquí
    benches = {
        {
            id = 'workbench',
            label = 'Mesa de trabajo',
            model = `prop_tool_bench02`,
            coords = vec4(1531.58, 1706.9, 108.85, 178.75),
            distance = 3.0,
            level = 1,
            repair = true,
            blip = { sprite = 566, colour = 31, scale = 0.7 }, -- false = sin blip
        },
        {
            id = 'recycler',
            label = 'Reciclador',
            model = `prop_dumpster_01a`, -- cambia el modelo si quieres otro
            coords = vec4(1535.58, 1706.9, 108.85, 178.75), -- ejemplo: al lado de la mesa, cámbialo
            distance = 3.0,
            level = 0,
            recycler = true,
            blip = { sprite = 365, colour = 2, scale = 0.7 },
        },
    },

    recipes = {
        { name = 'bandage',  time = 3,  category = 'medical', ingredients = { cloth = 5 } },
        { name = 'lockpick', time = 8,  category = 'tools',   ingredients = { scrapmetal = 5 } },
        { name = 'armour',   time = 20, category = 'items',   ingredients = { cloth = 20, scrapmetal = 15 }, level = 1, blueprint = true },

        -- Textil (dl_sastreria): materiales para la mesa de costura
        { name = 'hilo',     count = 2, time = 3, category = 'textil', ingredients = { algodon = 2 } },
        { name = 'cloth',    count = 1, time = 4, category = 'textil', ingredients = { algodon = 2, hilo = 1 }, level = 1 },
        { name = 'cuero',    count = 1, time = 6, category = 'textil', ingredients = { cuero_crudo = 1 }, level = 1 },
        { name = 'plastico', count = 1, time = 3, category = 'textil', ingredients = { botella_plastico = 3 }, level = 1 },
    },

    -- REPARAR (en mesas con repair = true). Costo de una reparación completa (0% -> 100%).
    -- Si el item está a medias, cuesta proporcional. Solo items que tengan durabilidad.
    repair = {
        default = { scrapmetal = 10 },
        items = {
            -- WEAPON_PISTOL = { scrapmetal = 15 },
        },
    },

    -- RECICLAR (en mesas con recycler = true). Lo que da CADA unidad reciclada.
    recycle = {
        garbage  = { scrapmetal = 1, cloth = 2 },
        lockpick = { scrapmetal = 2 },
        bandage  = { cloth = 2 },
        prenda   = { cloth = 1, hilo = 1 }, -- cualquier prenda de ropa (dl_sastreria)
    },

    blueprintItem = 'blueprint', -- item de data/items.lua que enseña una receta
}
