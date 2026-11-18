-- Crafteo estilo Rust (desde el inventario)
--
-- RECETAS
-- name        = item que se obtiene
-- count       = cuántos da cada crafteo (opcional, por defecto 1)
-- time        = segundos por crafteo
-- category    = id de una de las categories de abajo
-- ingredients = { item = cantidad }
-- groups      = (opcional) { police = 0 } para limitar por trabajo/grado
-- level       = (opcional) nivel mínimo de mesa: 1, 2 o 3. Sin level = se craftea en cualquier lado
-- bench       = (opcional) id de una mesa concreta (en vez de level)
-- blueprint   = (opcional) true = hay que aprender el plano antes de poder craftearla
-- unlock      = (opcional) { cost = chatarra, after = 'otra_receta' } -> nodo del árbol de desbloqueos de la mesa
--               de su "level". Se aprende pagando chatarra en esa mesa (ox_target -> Desbloquear).
--               after = receta que hay que tener desbloqueada antes. unlock implica blueprint = true.
--               El material con el que se paga es unlockItem (abajo).

return {
    categories = {
        { id = 'all',       label = 'Todo' },
        { id = 'medical',   label = 'Médico' },
        { id = 'tools',     label = 'Herramientas' },
        { id = 'weapons',   label = 'Armas' },
        { id = 'ammo',      label = 'Munición' },
        { id = 'attachments', label = 'Accesorios' },
        { id = 'items',     label = 'Objetos' },
    },

    maxQueue = 10, -- máximo de crafteos en cola por jugador
    unlockItem = 'scrapmetal', -- material con el que se pagan los desbloqueos del árbol

    -- TIPOS DE MESA. Para colocarlas, moverlas, añadir más o eliminarlas usa /admininventory en el juego.
    -- coords   = (opcional) vec4(x, y, z, rotación) -> posición inicial (la primera vez que arranca);
    --            sin coords la mesa no aparece sola: la colocas tú con /admininventory
    -- level    = nivel de la mesa (desbloquea recetas con level <= este)
    -- repair   = true: permite reparar armas/herramientas y cambiarles la skin aquí
    -- recycler = true: permite reciclar items aquí
    benches = {
        {
            id = 'workbench',
            label = 'Mesa de trabajo',
            model = `prop_tool_bench02`,
            coords = vec4(1531.58, 1706.9, 108.85, 178.75),
            distance = 3.0,
            level = 1,
            blip = { sprite = 566, colour = 31, scale = 0.7 }, -- false = sin blip
        },
        {
            id = 'workbench2',
            label = 'Mesa de trabajo nivel 2',
            model = `gr_prop_gr_bench_04b`,
            distance = 3.0,
            level = 2,
            blip = { sprite = 566, colour = 5, scale = 0.75 },
        },
        {
            id = 'workbench3',
            label = 'Mesa de trabajo nivel 3',
            model = `gr_prop_gr_bench_02a`,
            distance = 3.0,
            level = 3,
            blip = { sprite = 566, colour = 1, scale = 0.8 },
        },
        {
            id = 'repairbench',
            label = 'Mesa de reparación',
            model = `prop_toolchest_05`,
            distance = 3.0,
            level = 0,
            repair = true,
            blip = { sprite = 402, colour = 47, scale = 0.7 },
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

    -- El id de cada receta es su posición en esta lista (los favoritos se guardan por id):
    -- añade las recetas nuevas AL FINAL para no mover las que ya existen.
    recipes = {
        { name = 'bandage',  time = 3,  category = 'medical', ingredients = { cloth = 5 } },
        { name = 'lockpick', time = 8,  category = 'tools',   ingredients = { scrapmetal = 5 } },
        { name = 'armour',   time = 20, category = 'items',   ingredients = { cloth = 20, scrapmetal = 15 }, level = 1, unlock = { cost = 40 } },

        -- Objetos
        { name = 'mochila_pequena', time = 30, category = 'items', ingredients = { cloth = 30, scrapmetal = 5 } },
        { name = 'mochila_grande',  time = 60, category = 'items', ingredients = { cloth = 60, scrapmetal = 15 }, level = 2, unlock = { cost = 120 } },
        { name = 'parachute',       time = 25, category = 'items', ingredients = { cloth = 40 }, level = 1, unlock = { cost = 30 } },
        { name = 'radio',           time = 20, category = 'items', ingredients = { scrapmetal = 15 }, level = 1, unlock = { cost = 40, after = 'parachute' } },

        -- Armas cuerpo a cuerpo (las básicas sin mesa)
        { name = 'WEAPON_KNUCKLE', time = 8,  category = 'weapons', ingredients = { scrapmetal = 6 } },
        { name = 'WEAPON_KNIFE',   time = 10, category = 'weapons', ingredients = { scrapmetal = 8, cloth = 2 } },
        { name = 'WEAPON_BAT',     time = 10, category = 'weapons', ingredients = { scrapmetal = 6, cloth = 2 } },
        { name = 'WEAPON_HAMMER',  time = 10, category = 'weapons', ingredients = { scrapmetal = 8 } },
        { name = 'WEAPON_CROWBAR', time = 12, category = 'weapons', ingredients = { scrapmetal = 12 } },
        { name = 'WEAPON_HATCHET', time = 15, category = 'weapons', ingredients = { scrapmetal = 15, cloth = 2 }, level = 1, unlock = { cost = 25 } },
        { name = 'WEAPON_MACHETE', time = 20, category = 'weapons', ingredients = { scrapmetal = 20, cloth = 3 }, level = 2, unlock = { cost = 60, after = 'WEAPON_HATCHET' } },

        -- Armas de fuego y munición
        { name = 'WEAPON_SNSPISTOL', time = 60, category = 'weapons', ingredients = { scrapmetal = 60 }, level = 2, unlock = { cost = 150 } },
        { name = 'ammo-9', count = 10, time = 10, category = 'ammo', ingredients = { scrapmetal = 5 }, level = 1 },

        -- Mesa nivel 2-3
        { name = 'ammo-shotgun',      count = 10, time = 15, category = 'ammo',    ingredients = { scrapmetal = 8, cloth = 2 }, level = 2, unlock = { cost = 80, after = 'WEAPON_SAWNOFFSHOTGUN' } },
        { name = 'ammo-45',           count = 10, time = 15, category = 'ammo',    ingredients = { scrapmetal = 7 }, level = 3, unlock = { cost = 120, after = 'WEAPON_MICROSMG' } },
        { name = 'WEAPON_PUMPSHOTGUN', time = 90,  category = 'weapons', ingredients = { scrapmetal = 100, cloth = 10 }, level = 3, unlock = { cost = 300, after = 'WEAPON_SAWNOFFSHOTGUN' } },
        { name = 'WEAPON_MICROSMG',    time = 120, category = 'weapons', ingredients = { scrapmetal = 120, cloth = 10 }, level = 3, unlock = { cost = 400 } },

        ----------------------------------------------------------------
        -- ÁRBOLES DE DESBLOQUEO (añadidos al final para no mover los ids)
        ----------------------------------------------------------------
        -- Mesa nivel 1: accesorios básicos
        { name = 'at_flashlight', time = 15, category = 'attachments', ingredients = { scrapmetal = 10, cloth = 2 }, level = 1, unlock = { cost = 25 } },
        { name = 'at_grip',       time = 20, category = 'attachments', ingredients = { scrapmetal = 15, cloth = 3 }, level = 1, unlock = { cost = 35, after = 'at_flashlight' } },

        -- Mesa nivel 2: pistolas y escopeta recortada
        { name = 'WEAPON_PISTOL',          time = 75,  category = 'weapons',     ingredients = { scrapmetal = 80 },             level = 2, unlock = { cost = 200, after = 'WEAPON_SNSPISTOL' } },
        { name = 'WEAPON_COMBATPISTOL',    time = 90,  category = 'weapons',     ingredients = { scrapmetal = 100 },            level = 2, unlock = { cost = 250, after = 'WEAPON_PISTOL' } },
        { name = 'at_clip_extended_pistol', time = 30, category = 'attachments', ingredients = { scrapmetal = 25 },             level = 2, unlock = { cost = 120, after = 'WEAPON_PISTOL' } },
        { name = 'at_suppressor_light',    time = 40,  category = 'attachments', ingredients = { scrapmetal = 30, cloth = 5 },  level = 2, unlock = { cost = 150, after = 'WEAPON_COMBATPISTOL' } },
        { name = 'WEAPON_SAWNOFFSHOTGUN',  time = 80,  category = 'weapons',     ingredients = { scrapmetal = 90, cloth = 5 },  level = 2, unlock = { cost = 220 } },

        -- Mesa nivel 3: subfusiles, rifles y miras
        { name = 'WEAPON_SMG',             time = 150, category = 'weapons',     ingredients = { scrapmetal = 150, cloth = 15 }, level = 3, unlock = { cost = 500, after = 'WEAPON_MICROSMG' } },
        { name = 'WEAPON_COMPACTRIFLE',    time = 180, category = 'weapons',     ingredients = { scrapmetal = 180, cloth = 15 }, level = 3, unlock = { cost = 600 } },
        { name = 'ammo-rifle2', count = 10, time = 20, category = 'ammo',        ingredients = { scrapmetal = 10 },              level = 3, unlock = { cost = 150, after = 'WEAPON_COMPACTRIFLE' } },
        { name = 'WEAPON_ASSAULTRIFLE',    time = 240, category = 'weapons',     ingredients = { scrapmetal = 250, cloth = 20 }, level = 3, unlock = { cost = 800, after = 'ammo-rifle2' } },
        { name = 'at_clip_extended_rifle', time = 45,  category = 'attachments', ingredients = { scrapmetal = 40 },              level = 3, unlock = { cost = 300, after = 'WEAPON_COMPACTRIFLE' } },
        { name = 'at_scope_holo',          time = 40,  category = 'attachments', ingredients = { scrapmetal = 35, cloth = 5 },   level = 3, unlock = { cost = 250 } },
        { name = 'at_scope_medium',        time = 60,  category = 'attachments', ingredients = { scrapmetal = 50, cloth = 5 },   level = 3, unlock = { cost = 350, after = 'at_scope_holo' } },
    },

    -- REPARAR (en mesas con repair = true). Costo de una reparación completa (0% -> 100%).
    -- Si el item está a medias, cuesta proporcional. Solo items que tengan durabilidad.
    repair = {
        default = { scrapmetal = 10 },
        items = {
            -- WEAPON_PISTOL = { scrapmetal = 15 },
        },
    },

    -- SKINS DE ARMAS (en mesas con repair = true): colores de GTA (tint). ox los guarda en el arma.
    -- cost = lo que cuesta cada cambio de color
    skins = {
        cost = { scrapmetal = 5 },
        tints = {
            { id = 0, label = 'Normal',   color = '#2b2b2b' },
            { id = 1, label = 'Verde',    color = '#3f5a2a' },
            { id = 2, label = 'Dorado',   color = '#c9a53a' },
            { id = 3, label = 'Rosa',     color = '#d97aa6' },
            { id = 4, label = 'Ejército', color = '#8a7a55' },
            { id = 5, label = 'Policía',  color = '#2f4f8a' },
            { id = 6, label = 'Naranja',  color = '#d9822b' },
            { id = 7, label = 'Platino',  color = '#c8ccd0' },
        },
    },

    -- RECICLAR (en mesas con recycler = true). Lo que da CADA unidad reciclada.
    recycleTime = 5, -- segundos que tarda el reciclador en reciclar 1 unidad
    recycle = {
        garbage  = { scrapmetal = 1, cloth = 2 },
        lockpick = { scrapmetal = 2 },
        bandage  = { cloth = 2 },
        -- Armas cuerpo a cuerpo: devuelven más o menos la mitad
        WEAPON_KNUCKLE = { scrapmetal = 3 },
        WEAPON_KNIFE   = { scrapmetal = 4, cloth = 1 },
        WEAPON_BAT     = { scrapmetal = 3, cloth = 1 },
        WEAPON_HAMMER  = { scrapmetal = 4 },
        WEAPON_CROWBAR = { scrapmetal = 6 },
        WEAPON_HATCHET = { scrapmetal = 7, cloth = 1 },
        WEAPON_MACHETE = { scrapmetal = 10, cloth = 1 },
    },

    blueprintItem = 'blueprint', -- item de data/items.lua que enseña una receta
}
