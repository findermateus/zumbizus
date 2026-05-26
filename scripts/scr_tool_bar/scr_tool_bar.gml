global.activeEquipedItemIndex = BLANK_INVENTORY_SPACE ;
global.activeEquipedItem = BLANK_INVENTORY_SPACE ;

function equipItem(_index){
	if (global.activeEquipedItemIndex == _index){
		global.activeEquipedItemIndex = BLANK_INVENTORY_SPACE;
		global.activeEquipedItem = BLANK_INVENTORY_SPACE;
		return;
	}
	var _item = global.equipedItems[| _index];
	if(_item == BLANK_INVENTORY_SPACE) return;
	playClickSound();
	global.activeEquipedItem = _item;
	global.activeEquipedItemIndex = _index;
}

function unequipItem(){
	global.activeEquipedItemIndex = BLANK_INVENTORY_SPACE;
	playSoundWhenItemIsEquiped(global.activeEquipedItem);
	global.activeEquipedItem = BLANK_INVENTORY_SPACE;
}

function unequipItemIfIsEmpty(){
	if (global.activeEquipedItemIndex == BLANK_INVENTORY_SPACE) return;
	var _inventoryIndex = global.equipedItems[| global.activeEquipedItemIndex];
	if (_inventoryIndex == BLANK_INVENTORY_SPACE){
		global.activeEquipedItem = BLANK_INVENTORY_SPACE;
		global.activeEquipedItemIndex = BLANK_INVENTORY_SPACE;
	}
}

function getCleanIndexFromToolBar(){
	for(var _i = 0; _i < global.toolBarSize; _i ++){
		if(global.equipedItems[| _i] == BLANK_INVENTORY_SPACE){
			return _i;
		}
	}
	return BLANK_INVENTORY_SPACE;
}

function playSoundWhenItemIsEquiped(_item){
	audio_play_sound(_item.sound, 0, false);
}