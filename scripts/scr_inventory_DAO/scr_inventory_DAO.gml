function getItemById(_inventory, _type, _id, _ignoreFull = false) {
	for (var i = 0; i < ds_grid_height(_inventory); i ++) {
		for (var j = 0; j < ds_grid_width(_inventory); j ++) {
			var _item = _inventory[# j, i];
			if (_item == global.blankInventorySpace) continue;
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

function getBlankSpaceInInventory(_inventory) {
	for (var i = 0; i < ds_grid_height(_inventory); i ++) {
		for (var j = 0; j < ds_grid_width(_inventory); j ++) {
			var _item = _inventory[# j, i];
			if (_item == global.blankInventorySpace) return [j, i];
		}
	}	
	return false;
}

function cleanItemInInventoryById(_grid_id, _itemId, _itemType, _quantity){
	var width = ds_grid_width(_grid_id);
    var height = ds_grid_height(_grid_id);
	for (var _y = 0; _y < height; _y++) {
        for (var _x = 0; _x < width; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
			if(_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType){
				var _auxInGrid = _grid_id[# _x, _y].quantity;
				_grid_id[# _x, _y].quantity -= _quantity;
				if (_grid_id[# _x, _y].quantity <= 0){
					_grid_id[# _x, _y] = global.blankInventorySpace;
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
			if (_item == global.blankInventorySpace) continue;
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
		_inventory[# _j, _i] = global.blankInventorySpace;
		return _difference;
	}
	_inventory[# _j, _i].quantity -= _quantity;
	if (_inventory[# _j, _i] <= 0) _inventory[# _j, _i] = global.blankInventorySpace;
}

function cleanInventoryGrid(_inventory, _j, _i) {
	_inventory[# _j, _i] = global.blankInventorySpace;
}

function getInventoryItemByPosition(_j, _i, _inventory) {
	return _inventory[# _j, _i];
}