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

function EquipmentItem(_name, _description, _sprite, _id, _sound, _fitInGrid, _data): Item(_name, _description, _sprite, _id, _sound, _fitInGrid) constructor{
	type = itemType.equipment;
	equipType = _data.equipType;
	equipmentData = _data.equipmentData;
}

function equipmentConstructor(_item = {
	itemId: undefined,
	name: undefined,
	description: undefined,
	sprite: undefined,
	internalValue: undefined,
	sound: undefined,
	fitInGrid: fitInGridType.verticaly,
	equipmentData: {}
}){
	return new EquipmentItem(_item.name, _item.description, _item.sprite, _item.itemId, _item.sound, _item.fitInGrid, _item);
}