function getItemById(_inventory, _type, _id, _ignoreFull = false) {
	for (var i = 0; i < ds_grid_height(_inventory); i ++) {
		for (var j = 0; j < ds_grid_width(_inventory); j ++) {
			var _item = _inventory[# j, i];
			if (_item == BLANK_INVENTORY_SPACE) continue;
			if (_item.itemId = _id && _item.type == _type) {
				if (_ignoreFull && _item.quantity == _item.limit) {
					continue;
				}
				return _item;
			}
		}
	}	
	return false;
}

function addItemToGrid(_inventory, _item) {
	var _stackable = _item.stackable;
	
	if (_stackable) {
		var _alreadyPlacedItem = getItemById(_inventory, _item.type, _item.itemId, true);
		
		if (_alreadyPlacedItem != false) {
			var _remainingSpace = _alreadyPlacedItem.limit - _alreadyPlacedItem.quantity;
			var _totalSpace = _item.quantity;
			
			if (_remainingSpace >= _item.quantity) {
				_alreadyPlacedItem.quantity += _item.quantity;
				return true;
			}
			
			if (_remainingSpace > 0) {
				_alreadyPlacedItem.quantity = _alreadyPlacedItem.limit;
				_item.quantity -= _remainingSpace;
				var _result = addItemToGrid(_inventory, _item);
				if (_result == true){
					_item.quantity += _remainingSpace;
		
					return true;
				}
				
				if (_result == false) {
					
					return _remainingSpace;
				}
			}
		}
	}
	
	var _blankSpace = getBlankSpaceInInventory(_inventory);
	
	if (_blankSpace == false) return false;
	
	_inventory[# _blankSpace[0], _blankSpace[1]] = _item;
	
	return true;
}

function canAddAbsoluteItemToGrid(_inventory, _item) {
	var _quantityLeft = _item.quantity;

	if (_item.stackable) {
		var _cols = ds_grid_width(_inventory);
		var _rows = ds_grid_height(_inventory);

		for (var _y = 0; _y < _rows; _y++) {
			for (var _x = 0; _x < _cols; _x++) {
				var _slotItem = _inventory[# _x, _y];

				if (_slotItem == BLANK_INVENTORY_SPACE) continue;

				if (_slotItem.type != _item.type || _slotItem.itemId != _item.itemId) continue;
				if (!variable_struct_exists(_slotItem, "limit")) continue;

				var _remainingSpace = _slotItem.limit - _slotItem.quantity;

				if (_remainingSpace > 0) {
					_quantityLeft -= _remainingSpace;

					if (_quantityLeft <= 0) {
						return true;
					}
				}
			}
		}

		var _blankSpaces = 0;

		for (var _y = 0; _y < _rows; _y++) {
			for (var _x = 0; _x < _cols; _x++) {
				if (_inventory[# _x, _y] == BLANK_INVENTORY_SPACE) {
					_blankSpaces++;
				}
			}
		}

		var _limit = variable_struct_exists(_item, "limit") ? _item.limit : _item.quantity;

		return (_blankSpaces * _limit) >= _quantityLeft;
	}

	return getBlankSpaceInInventory(_inventory) != false;
}

function addAbsoluteItemToGrid(_inventory, _item) {
	if (!canAddAbsoluteItemToGrid(_inventory, _item)) {
		return false;
	}

	return addItemToGrid(_inventory, _item) == true;
}

function getBlankSpaceInInventory(_inventory) {
	for (var i = 0; i < ds_grid_height(_inventory); i ++) {
		for (var j = 0; j < ds_grid_width(_inventory); j ++) {
			var _item = _inventory[# j, i];
			if (_item == BLANK_INVENTORY_SPACE) return [j, i];
		}
	}	
	return false;
}

function cleanItemInInventoryById(_grid_id, _itemId, _itemType, _quantity){
	var width = ds_grid_width(_grid_id);
    var height = ds_grid_height(_grid_id);
	for (var _y = 0; _y < height; _y++) {
        for (var _x = 0; _x < width; _x++) {
            if (_grid_id[# _x, _y] == BLANK_INVENTORY_SPACE) continue;
			if(_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType){
				var _auxInGrid = _grid_id[# _x, _y].quantity;
				_grid_id[# _x, _y].quantity -= _quantity;
				if (_grid_id[# _x, _y].quantity <= 0){
					_grid_id[# _x, _y] = BLANK_INVENTORY_SPACE;
				}
				_quantity -= _auxInGrid;
			}
			if (_quantity <= 0) return true;
        }
    }
}

function countTotalItemsInInventoryById(_grid_id, _itemId, _itemType){
	var width = ds_grid_width(_grid_id);
    var height = ds_grid_height(_grid_id);
	var _quantity = 0;
    for (var _y = 0; _y < height; _y++) {
        for (var _x = 0; _x < width; _x++) {
            var _item = _grid_id[# _x, _y]
			if (_item == BLANK_INVENTORY_SPACE) continue;
			if(_item.itemId == _itemId && _item.type == _itemType){
				if (!_item.stackable) {
					_quantity ++;
					continue;
				}
				_quantity += _item.quantity;
			}
        }
    }
	return _quantity;
}

function removeItemQuantityByGrid(_inventory, _j, _i, _quantity) {
	if (_inventory[# _j, _i].quantity < _quantity) {
		var _difference = _quantity - _inventory[# _j, _i].quantity 
		_inventory[# _j, _i] = BLANK_INVENTORY_SPACE;
		return _difference;
	}
	_inventory[# _j, _i].quantity -= _quantity;
	if (_inventory[# _j, _i] <= 0) _inventory[# _j, _i] = BLANK_INVENTORY_SPACE;
}

function cleanInventoryGrid(_inventory, _j, _i) {
	_inventory[# _j, _i] = BLANK_INVENTORY_SPACE;
}

function getInventoryItemByPosition(_j, _i, _inventory) {
	return _inventory[# _j, _i];
}