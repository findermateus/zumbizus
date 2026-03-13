global.dismantableItems = [];

function dismantableReturnItem(_type, _id, _quantity) {
	return {
		id: _id,
		type: _type,
		quantity: _quantity
	}
}

global.dismantableItems[itemType.weapons][weaponItems.nailBoard] = [
	dismantableReturnItem(itemType.trash, trashItems.wood_board, 1),
	dismantableReturnItem(itemType.trash, trashItems.nail, 2)
];

global.dismantableItems[itemType.weapons][weaponItems.baseballBatWithNails] = [
	dismantableReturnItem(itemType.trash, trashItems.nail, 4)
];

global.dismantableItems[itemType.equipment][equipmentItems.simpleOutfit] = [
	dismantableReturnItem(itemType.consumables, consumableItems.bandage, 2)
];

function getDismantleReturnFromItem(_type, _id) {
	var _item = global.items[_type][_id];
	var _isDismantable = itemIsDismantable(_item);
	if (_isDismantable) return false;
	return global.dismantableItems[_type][_id];
}