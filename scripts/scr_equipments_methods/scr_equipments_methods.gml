var _itemType = itemType.equipment;

global.itemMethods[_itemType][equipmentItems.simpleBag] = [
	new ItemMethod("Equipar", "wear")
];
global.itemMethods[_itemType][equipmentItems.simpleOutfit] = [
	new ItemMethod("Equipar", "wear"),
	new ItemMethod("Rasgar", "dismantle")
];
global.itemMethods[_itemType][equipmentItems.simpleCap] = [
	new ItemMethod("Equipar", "wear")
];
global.itemMethods[_itemType][equipmentItems.leatherJacket] = [
	new ItemMethod("Equipar", "wear")
];
global.itemMethods[_itemType][equipmentItems.boonieHat] = [
	new ItemMethod("Equipar", "wear")
];
global.itemMethods[_itemType][equipmentItems.tornLabCoat] = [
	new ItemMethod("Equipar", "wear")
];