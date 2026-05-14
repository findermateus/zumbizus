enum equipmentItems {
	simpleBag,
	simpleOutfit,
	simpleCap,
	leatherJacket,
	boonieHat
}

enum equipmentType {
	bag,
	head,
	armor
}

function EquipmentItem(_name, _description, _sprite, _id, _sound, _data): Item(_name, _description, _sprite, _id, _sound) constructor{
	type = itemType.equipment;
	equipType = _data.equipType;
	equipmentData = _data.equipmentData;
}