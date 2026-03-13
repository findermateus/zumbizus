global.currentOptionMenu = noone;
global.blankInventorySpace = "";
global.currentItemPlayingTheAction = {
	j: global.blankInventorySpace,
	i: global.blankInventorySpace
};
global.toolBarSize = 3;
global.quickUseBarSize = 3;
global.equipedItems = ds_list_create();
global.quickUse = ds_list_create();
global.activeQuickUseIndex = 0;
global.equipments = {
	head: global.blankInventorySpace,
	armor: global.blankInventorySpace,
	bag: global.blankInventorySpace
};

ds_list_clear(global.equipedItems);
for (var _i = 0; _i < global.toolBarSize; _i++) {
    global.equipedItems[| _i] = global.blankInventorySpace;
}

for (var _i = 0; _i < global.quickUseBarSize; _i++) {
    global.quickUse[| _i] = global.blankInventorySpace;
}

enum itemType {
	consumables,
	weapons,
	trash,
	ammo,
	equipment
};
enum fitInGridType {
	horizontaly,
	verticaly
}

function Item(_name, _description, _sprite, _itemId, _sound = snd_can, _fitInGrid = fitInGridType.verticaly, _stackable = false) constructor
{
	itemId = _itemId;
	name = _name;
	description = _description;
	sprite = _sprite;
	interactOptions = [];
	sound = _sound;
	fitInGrid = _fitInGrid;
	stackable = _stackable
	quantity = 1;
}

enum actionTypes {
	handleInventory,
	ignore
}

function ItemMethod(_label, _actionKey) constructor{
	label = _label;
	actionKey = _actionKey;
}

function constructItem(_type, _item){
	var _buildedItem = undefined;
	switch(_type){
		case itemType.consumables:
			_buildedItem = consumableConstructor(_item); 
			break;
		case itemType.trash:
			_buildedItem = trashConstructor(_item);
			break;
		case itemType.weapons:
			_buildedItem = weaponContructor(_item);
			break;
		case itemType.ammo: 
			_buildedItem = ammoContructor(_item);
			break;
		case itemType.equipment:
			_buildedItem = equipmentConstructor(_item);
	}
	
	return _buildedItem;
}