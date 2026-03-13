enum craftingCategories {
	weapons,
	cooking,
	materials
}

enum craftingOptions {
	create,
	repair,
	dismantle
}

function setUpCraftingGlobals() {
	global.craftingItems = [];

	global.craftingOptions = [];

	global.craftingOptions[craftingOptions.create] = {
		id: craftingOptions.create,
		title: "Criação",
		icon: spr_create_icon
	};

	global.craftingOptions[craftingOptions.repair] = {
		id: craftingOptions.repair,
		title: "Reparar",
		icon: spr_repair_icon
	};

	global.craftingOptions[craftingOptions.dismantle] = {
		id: craftingOptions.dismantle,
		title: "Desmontar",
		icon: spr_trash_icon
	};
}

setUpCraftingGlobals();
setUpCookingGlobals();
setUpMaterialCraftingGlobals();
setUpWeaponCraftingGlobals();
setUpWeaponRepairGlobals();

function CraftingItem(_itemId, _type, _requiredLevel = 1, _requirements = [], _bluePrint = noone) constructor {
	id = _itemId;
	type = _type;
	requirements = _requirements;
	requiredLevel = _requiredLevel;
	bluePrintId = _bluePrint
}

function getAvailableCraftingItemsByCategoryAndLevel(_category, _level) {
	var _list = [];

	var _items = global.craftingItems[_category];

	if (is_undefined(_items)) return _list;

	for (var i = 0; i < array_length(_items); i++) {
		var _item = _items[i];

		if (_level < _item.requiredLevel) continue;

		if (_item.bluePrintId != noone) {
			if (!array_contains(global.player.blueprints, _item.bluePrintId)) continue;
		}

		array_push(_list, _item);
	}

	return _list;
}


function getItemRequirements(_type, _id) {
	var _category = craftingCategories.cooking;
	
	if (_type == itemType.weapons) {
		_category = craftingCategories.weapons;
	}
	
	if (_type == itemType.trash) {
		_category = craftingCategories.materials;
	}
	
	if (!arrayKeyExists(global.craftingItems, _category)) return [];
	
	for (var i = 0; i < array_length(global.craftingItems[_category]); i++) {
		if (global.craftingItems[_category][i].id == _id) {
			return global.craftingItems[_category][i];
		}
	}
	
	return [];
}
