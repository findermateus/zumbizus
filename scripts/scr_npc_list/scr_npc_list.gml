global.genderList[global.genders.others] = {
	title: "Outro",
	id: global.genders.others
};

function NpcAttribute(_id) constructor {
	id = _id;
	xp = 0;
	level = 0;
	
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

function NPC(_name, _id, _gender, _skinColor, _hair, _eyeId, _outfitId = -1, _helmetId = -1, _bagId = -1) constructor {
	name = _name;
	id = _id;
	gender = _gender;
	skinColor = _skinColor;
	hair = _hair;
	eyeId = _eyeId;
	outfitId = _outfitId;
	helmetId = _helmetId;
	bagId = _bagId;
	attributes = [];
	attributes[sectorList.crafting] = new NpcAttribute(sectorList.crafting);
	attributes[sectorList.defense] = new NpcAttribute(sectorList.defense);
	attributes[sectorList.production] = new NpcAttribute(sectorList.production);
	attributes[sectorList.supply] = new NpcAttribute(sectorList.supply);
	attributes[sectorList.trade] = new NpcAttribute(sectorList.trade);
}

global.baseResidents = [];

function addBaseResident(_npc) {
	var _residentId = array_length(global.baseResidents);

	global.baseResidents[_residentId] = new NPC(
		_npc.name,
		_residentId,
		_npc.genderId,
		getHexStringFromColor(_npc.skinColor),
		new PersonHair(_npc.hairOption, _npc.hairColor),
		_npc.eyeId,
		_npc.outfitId,
		_npc.helmetId,
		_npc.bagId
	);

	with (obj_base_residents_controller) {
		loadResidentList();
	}

	return _residentId;
}