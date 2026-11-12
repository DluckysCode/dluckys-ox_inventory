-- Ranuras de ropa del inventario estilo Rust
-- comp  = componente de GTA (SetPedComponentVariation)
-- prop  = prop de GTA (SetPedPropIndex)
-- extra = componentes que se guardan junto con la prenda (ej. brazos con la chaqueta)
-- side  = columna donde se muestra (left / right)

return {
    item = 'prenda', -- item de data/items.lua que representa una prenda

    -- Cámara que muestra al personaje a la izquierda mientras el inventario está abierto
    -- offset = posición de la cámara respecto al PJ (x = lado, y = delante, z = altura)
    -- target = punto al que mira
    -- Para mover al PJ: cambia la X de offset y target por igual (más negativo = más a la izquierda)
    -- Para hacerlo más grande/pequeño: cambia la Y de offset (menos = más grande)
    -- Para subir/bajar al PJ en pantalla: cambia la Z de target (más negativo = PJ más arriba)
    camera = {
        enabled = true,
        auto = true, -- ajusta solo el lado según la resolución (2K, 4K, ultra ancho)
        offset = vec3(-2.05, 4.3, -0.5),
        target = vec3(-2.05, 0.0, -0.58),
        fov = 45.0,
    },

    slots = {
        { id = 'hat',       label = 'Cabeza',    prop = 0,  side = 'left' },
        { id = 'mask',      label = 'Máscara',   comp = 1,  side = 'right' },
        { id = 'jacket',    label = 'Torso',     comp = 11, extra = { 3 }, side = 'left' },
        { id = 'shirt',     label = 'Interior',  comp = 8,  side = 'right' },
        { id = 'vest',      label = 'Chaleco',   comp = 9,  side = 'left' },
        { id = 'accessory', label = 'Accesorio', comp = 7,  side = 'right' },
        { id = 'legs',      label = 'Pantalón',  comp = 4,  side = 'left' },
        { id = 'shoes',     label = 'Zapatos',   comp = 6,  side = 'left' },
        { id = 'glasses',   label = 'Lentes',    prop = 1,  side = 'right' },
    },

    -- Valores "sin ropa" por componente. Si alguno se ve raro en tu servidor, cámbialo aquí.
    naked = {
        male   = { [1] = 0, [3] = 15, [4] = 61, [6] = 34, [7] = 0, [8] = 15, [9] = 0, [11] = 15 },
        female = { [1] = 0, [3] = 15, [4] = 14, [6] = 35, [7] = 0, [8] = 14, [9] = 0, [11] = 15 },
    },
}
