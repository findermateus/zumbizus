function dismantleItem(_j, _i, _toolBar) {
	var _itemInInventory = {};
	if (_toolBar != -1) {
		_itemInInventory = global.equipedItems[| _toolBar];
	} else {
		_itemInInventory = getInventoryItemByPosition(_j, _i, global.inventory);
	}
	
	var _dismantableReturn = getDismantableContent(_itemInInventory.itemId, _itemInInventory.type)
	
	array_foreach(_dismantableReturn, function (_return) {
		var _item = global.items[_return.type][_return.id];
		var _buildedItem = constructItem(_return.type, _item);
		_buildedItem.quantity = _return.quantity;
		var _result = addItemToGrid(global.inventory, _buildedItem);
		if (_result == false) {
			createItem(_buildedItem, true);
			createIndicatorForDroppedItems(_buildedItem, _buildedItem.quantity);
			return;
		}
		if (_result == true) {
			createIndicatorModal(_buildedItem, _buildedItem.quantity);
			return;
		}
		createIndicatorModal(_buildedItem, _result);
		var _droppedItems = variable_clone(_buildedItem);
		_droppedItems.quantity = _buildedItem.quantity - _result;
		createItem(_droppedItems, true);
	});
	
	if (_toolBar != -1) {
		global.equipedItems[| _toolBar] = global.blankInventorySpace;
	} else {
		cleanInventoryGrid(global.inventory, _j, _i);
	}
	
	audio_play_sound(snd_builded_item, 0, false);
}