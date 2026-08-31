enum mapType {
	hostile,
	civilized
}

enum MapAccessType {
	Permanent,
	Quest
}

function map(_id, _name, _level, _costFood, _costWater, _room, _description, _type, _image, _rainChance, _accessType = MapAccessType.Permanent, _questId = undefined) {
	return {
		id: _id,
		name: _name,
		level: _level,
		costFood: _costFood,
		costWater: _costWater,
		room: _room,
		description: _description,
		type: _type,
		image: _image,
		rainChance: _rainChance,
		accessType: _accessType,
		questId: _questId
	}
}

global.maps = {
	playerBase: map(
		"player_base",
		"Base",
		0,
		0,
		0,
		rm_player_base,
		"Base do Player",
		mapType.civilized,
		spr_small_city_map,
		20
	),

	forest: map(
		"forest",
		"Bosque das Folhas Altas",
		1,
		0,
		0,
		rm_forest,
		"Área arborizada. Muitos recursos naturais",
		mapType.hostile,
		spr_forest_map,
		20
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
		spr_dump_map,
		20,
		MapAccessType.Quest,
		Quests.ExploreDump
	)
};

global.unlockedMaps = [];

function unlockMap(_mapKey) {
    if (!variable_struct_exists(global.maps, _mapKey)) {
		return;
	}
        
    var _alreadyUnlocked = false;
    
	for (var i = 0; i < array_length(global.unlockedMaps); i++) {
        if (global.unlockedMaps[i] == _mapKey) {
            _alreadyUnlocked = true;
            break;
        }
    }
        
    if (!_alreadyUnlocked) {
        array_push(global.unlockedMaps, _mapKey);
    }
}

function lockMap(_mapKey) {
	var _index = array_get_index(global.unlockedMaps, _mapKey);

	if (_index == -1) {
		return;
	}

	array_delete(global.unlockedMaps, _index, 1);
}

unlockMap("forest");