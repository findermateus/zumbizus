enum mapType {
	hostile,
	civilized
}

function map(_id, _name, _level, _costFood, _costWater, _room, _description, _type, _image) {
	return {
        id: _id,
        name: _name,
        level: _level,
        costFood: _costFood,
        costWater: _costWater,
        room: _room,
        description: _description,
        type: _type,
		image: _image
    }
}

global.maps = {
    forest: map(
        "forest",
        "Bosque das Folhas Altas",
        1,
        0,
        0,
        rm_forest,
        "Área arborizada. Muitos recursos naturais",
        mapType.hostile,
		spr_forest_map
    ),

    small_city: map(
        "small_city",
        "Bairro das Memórias",
        1,
        0,
        0,
        rm_small_city,
        "Uma cidade deserta. Bons saques.",
        mapType.hostile,
		spr_small_city_map
    ),

    junkyard: map(
        "junkyard",
        "Pátio dos Achados",
        1,
        0,
        0, 
        rm_dump,
        "Depósito de sucata. Atenção aos infectados.",
        mapType.hostile,
		spr_dump_map
    )
};