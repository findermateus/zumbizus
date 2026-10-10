global.genderList[global.genders.others] = {
	title: "Outro",
	id: global.genders.others
};

function NpcAttribute(_id) constructor {
	id = _id;
	xp = 0;
	level = 1;

	static setXp = function (_xp) {
		xp = _xp;
	}

	static increaseXp = function (_quantity) {
		xp += _quantity;
		if (xp >= 100) {
			level ++;
			xp = 0;
		}
	}
}

/// @param {Real} _residentId
/// @param {Struct} _data { name, genderId, skinColor, hairOption, hairColor, eyeId, outfitId?, helmetId?, bagId? }
function BaseResident(_residentId, _data) constructor {
	residentId = _residentId;

	name = _data.name;
	genderId = _data.genderId;
	skinColor = _data.skinColor;
	hairOption = _data.hairOption;
	hairColor = _data.hairColor;
	eyeId = _data.eyeId;
	outfitId = _data[$ "outfitId"] ?? -1;
	helmetId = _data[$ "helmetId"] ?? -1;
	bagId = _data[$ "bagId"] ?? -1;

	// Indexado por baseAttribute
	attributes = [];
	attributes[baseAttribute.crafting] = new NpcAttribute(baseAttribute.crafting);
	attributes[baseAttribute.production] = new NpcAttribute(baseAttribute.production);
	attributes[baseAttribute.supplies] = new NpcAttribute(baseAttribute.supplies);
	attributes[baseAttribute.battle] = new NpcAttribute(baseAttribute.battle);
	attributes[baseAttribute.economy] = new NpcAttribute(baseAttribute.economy);

	// { furnitureId, objectId, slot } | undefined
	workplace = undefined;

	static getHair = function () {
		return new PersonHair(hairOption, hairColor);
	}
}

// residentId (string) -> BaseResident
global.baseResidents = {};
global.nextResidentId = 0;

function getBaseResident(_residentId) {
	return global.baseResidents[$ string(_residentId)];
}

/// @returns {Array<Struct.BaseResident>}
function getBaseResidentList() {
	var _keys = variable_struct_get_names(global.baseResidents);
	var _list = [];

	for (var i = 0; i < array_length(_keys); i++) {
		array_push(_list, global.baseResidents[$ _keys[i]]);
	}

	array_sort(_list, function (_a, _b) {
		return _a.residentId - _b.residentId;
	});

	return _list;
}

/// @returns {Struct.BaseResident}
function createBaseResident(_data) {
	var _resident = new BaseResident(global.nextResidentId, _data);

	global.nextResidentId++;
	global.baseResidents[$ string(_resident.residentId)] = _resident;

	with (obj_base_residents_controller) {
		loadResidentList();
	}

	return _resident;
}

function addBaseResident(_npc) {
	var _resident = createBaseResident({
		name: _npc.name,
		genderId: _npc.genderId,
		skinColor: _npc.skinColor,
		hairOption: _npc.hairOption,
		hairColor: _npc.hairColor,
		eyeId: _npc.eyeId,
		outfitId: _npc.outfitId,
		helmetId: _npc.helmetId,
		bagId: _npc.bagId
	});

	return _resident.residentId;
}