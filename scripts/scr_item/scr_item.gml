global.currentOptionMenu = noone;
global.currentItemPlayingTheAction = {
	j: BLANK_INVENTORY_SPACE,
	i: BLANK_INVENTORY_SPACE
};
global.toolBarSize = 3;
global.quickUseBarSize = 3;
global.equipedItems = ds_list_create();
global.quickUse = ds_list_create();
global.activeQuickUseIndex = 0;
global.equipments = {
	head: BLANK_INVENTORY_SPACE,
	armor: BLANK_INVENTORY_SPACE,
	bag: BLANK_INVENTORY_SPACE
};

ds_list_clear(global.equipedItems);
for (var _i = 0; _i < global.toolBarSize; _i++) {
    global.equipedItems[| _i] = BLANK_INVENTORY_SPACE;
}

for (var _i = 0; _i < global.quickUseBarSize; _i++) {
    global.quickUse[| _i] = BLANK_INVENTORY_SPACE;
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

function Item(_name, _description, _sprite, _itemId, _sound = snd_can, _stackable = false) constructor
{
	itemId = _itemId;
	name = _name;
	description = _description;
	sprite = _sprite;
	interactOptions = [];
	sound = _sound;
	fitInGrid = fitInGridType.verticaly;
	stackable = _stackable
	quantity = 1;
	value = 1;
}

enum actionTypes {
	handleInventory,
	ignore
}

function ItemMethod(_label, _actionKey) constructor{
	label = _label;
	actionKey = _actionKey;
}

function constructItem(_type, _item = {}){
	var _buildedItem = undefined;

	switch(_type){
		case itemType.consumables:
			_buildedItem = new ConsumableItem(_item.name, _item.description, _item.sprite, _item.itemId, _item.sound, _item);
			
			break;
		case itemType.trash:
		
			_buildedItem = new MaterialItem(_item.limit, _item.name, _item.description, _item.sprite, _item.itemId, _item.quantity, _item.sound);
			break;
		case itemType.weapons:
			_buildedItem = new WeaponItem(_item.name, _item.sprite, _item.description, _item.itemId, _item.sound, _item);
			break;
		case itemType.ammo: 
			_buildedItem = new AmmoItem(_item.limit, _item.name, _item.description, _item.sprite, _item.itemId, _item.quantity, _item.sound);
		
			break;
		case itemType.equipment:
		
			_buildedItem = new EquipmentItem(_item.name, _item.description, _item.sprite, _item.itemId, _item.sound, _item);
	}
	
	if (variable_instance_exists(_item, "fitInGrid")) {
		_buildedItem.fitInGrid = _item.fitInGrid
	}
	
	if (variable_instance_exists(_item, "value")) {
		_buildedItem.value = _item.value;
	}
	
	return _buildedItem;
}