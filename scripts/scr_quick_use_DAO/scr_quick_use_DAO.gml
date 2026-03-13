function addItemToQuickUse(_item, _quantity, _index = undefined) {
	if (!is_undefined(_index)) {
		addToQuickUseWithIndex(_index, _item, _quantity);	
	}
	for (var i = 0; i < global.quickUseBarSize; i ++) {
		addToQuickUseWithIndex(i, _item, _quantity);
	}
}

function getItemFromQuickUse(_index) {
	if (_index >= ds_list_size(global.quickUse)) return false; 
	 
	return global.quickUse[| _index] == global.blankInventorySpace ? false : global.quickUse[| _index];
}

function addToQuickUseWithIndex(_index, _item, _quantity) {
	var _equipedItem = getItemFromQuickUse(_index);
	if (_equipedItem == false) {
		global.quickUse[| _index] = _item;
		audio_play_sound(_item.sound, 0, false);
		cleanInventoryGrid(global.activeInventoryAction, global.currentItemPlayingTheAction.j, global.currentItemPlayingTheAction.i);
		return true;
	}
	if (_equipedItem.itemId == _item.itemId && _equipedItem.type == _item.type) {
		var _allowedSpace = _equipedItem.limit - _equipedItem.quantity;
		var _spaceToAllocate = _item.quantity <= _allowedSpace ? _item.quantity : _allowedSpace;
		_equipedItem.quantity += _spaceToAllocate;
		cleanItemInInventoryById(global.activeInventoryAction, _item.itemId, _item.type, _spaceToAllocate);
		audio_play_sound(_item.sound, 0, false);
		return true;
	}
	
	global.quickUse[| _index] = _item;
	global.activeInventoryAction[# global.currentItemPlayingTheAction.j, global.currentItemPlayingTheAction.i] = _equipedItem;
	audio_play_sound(_item.sound, 0, false);
}

function increaseQuickUseBarSize() {
	global.quickUse[| global.quickUseBarSize] = global.blankInventorySpace;
	global.quickUseBarSize ++;
}

function itemCanBeAddedToQuickBarUse(_item) {
	if (_item == global.blankInventorySpace) return false;
	return _item.type == itemType.consumables;
}

function useItemFromQuickUseBar(_index) {
	var _item = getItemFromQuickUse(_index);
	if (_item == false) return false;
	var _consumingAction = function () {};
	var _options = global.itemMethods[_item.type][_item.itemId]
	var _actionType = "use";
	if (_item.consumableType == consumableTypes.drink) {
		_actionType = "drink";
	} 
	if (_item.consumableType == consumableTypes.food) {
		_actionType = "eat";
	}
	executeItemMethod(_item, _actionType, false);
	var _data = global.consumableUsageData[_item.itemId];
	var _consumedItemId = _data.itemToDrop;
	if (_consumedItemId != undefined) {
		var _consumedItem = getConsumedItem(_consumedItemId);
		var _result = addItemToGrid(global.inventory, _consumedItem);
		if (!_result) {
			createIndicatorForDroppedItems(_consumedItem, 1);
			createItem(_consumedItem, true);
		} else {
			createIndicatorModal(_consumedItem, 1);
		}
	}
	
	global.quickUse[| _index].quantity --;
	
	if (global.quickUse[| _index].quantity <= 0) {
		global.quickUse[| _index] = global.blankInventorySpace;
	}
}

function addQuickUseItemToInventory(_index){
	var _item = getItemFromQuickUse(_index);
	if (_item == false) return;
	var _removeItem = function (_i, _item) {
		audio_play_sound(_item.sound, 0, false);
		global.quickUse[| _i] = global.blankInventorySpace;
	}
	var _result = addItemToGrid(global.inventory, _item);
	if (_result) {
		_removeItem(_index, _item);
		return true;
	}
	if (obj_inventory.secundaryInventory == false) return false;
	var _secundaryInventoryResult = addItemToGrid(obj_inventory.secundaryInventory, _item);
	if (_secundaryInventoryResult) {
		_removeItem(_index, _item);
		return true;
	}
	return false;
}