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

function NPC(_name, _id, _gender, _skinColor, _hair) constructor {
	name = _name;
	id = _id;
	gender = _gender;
	skinColor = _skinColor;
	hair = _hair;
	attributes = [];
	attributes[sectorList.crafting] = new NpcAttribute(sectorList.crafting);
	attributes[sectorList.defense] = new NpcAttribute(sectorList.defense);
	attributes[sectorList.production] = new NpcAttribute(sectorList.production);
	attributes[sectorList.supply] = new NpcAttribute(sectorList.supply);
	attributes[sectorList.trade] = new NpcAttribute(sectorList.trade);
}


global.npcList = [];