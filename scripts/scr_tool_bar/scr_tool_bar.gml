global.blankInventorySpace = "";

global.activeEquipedItemIndex = global.blankInventorySpace ;
global.activeEquipedItem = global.blankInventorySpace ;

function equipItem(_index){
	if (global.activeEquipedItemIndex == _index){
		global.activeEquipedItemIndex = global.blankInventorySpace;
		global.activeEquipedItem = global.blankInventorySpace;
		return;
	}
	var _item = global.equipedItems[| _index];
	if(_item == global.blankInventorySpace) return;
	playClickSound();
	global.activeEquipedItem = _item;
	global.activeEquipedItemIndex = _index;
}

function unequipItem(){
	global.activeEquipedItemIndex = global.blankInventorySpace;
	playSoundWhenItemIsEquiped(global.activeEquipedItem);
	global.activeEquipedItem = global.blankInventorySpace;
}

function unequipItemIfIsEmpty(){
	if (global.activeEquipedItemIndex == global.blankInventorySpace) return;
	var _inventoryIndex = global.equipedItems[| global.activeEquipedItemIndex];
	if (_inventoryIndex == global.blankInventorySpace){
		global.activeEquipedItem = global.blankInventorySpace;
		global.activeEquipedItemIndex = global.blankInventorySpace;
	}
}

function getCleanIndexFromToolBar(){
	for(var _i = 0; _i < global.toolBarSize; _i ++){
		if(global.equipedItems[| _i] == global.blankInventorySpace){
			return _i;
		}
	}
	return global.blankInventorySpace;
}

function playSoundWhenItemIsEquiped(_item){
	audio_play_sound(_item.sound, 0, false);
}