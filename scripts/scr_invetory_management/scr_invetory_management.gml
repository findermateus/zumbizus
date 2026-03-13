function getItemQuantityInInventory(_grid_id, _itemId, _itemType){
	var height = ds_grid_width(_grid_id);
    var width = ds_grid_height(_grid_id);
	var _quantity = 0;
    for (var _y = 0; _y < width; _y++) {
        for (var _x = 0; _x < height; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
			if(_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType){
				var _item = _grid_id[# _x, _y];
				var _valueToIncrease = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;
				_quantity += _valueToIncrease;
			}
        }
    }
	return _quantity;
}

function decreaseItemQuantityInInventory(_grid_id, _itemId, _itemType, _quantity) {
    var height = ds_grid_width(_grid_id);
    var width = ds_grid_height(_grid_id);
    
    for (var _y = 0; _y < width; _y++) {
        for (var _x = 0; _x < height; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
            
            if (_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType) {
                var _item = _grid_id[# _x, _y];
                
                if (variable_struct_exists(_item, "quantity")) {
                    var _valueToDecrease = min(_quantity, _item.quantity);
                    _item.quantity -= _valueToDecrease;
                    _quantity -= _valueToDecrease;
                    
                    if (_item.quantity <= 0) {
                        _grid_id[# _x, _y] = global.blankInventorySpace;
                    }
                } else {
                    _grid_id[# _x, _y] = global.blankInventorySpace;
                    _quantity--;
                }
                
                if (_quantity <= 0) return true;
            }
        }
    }
    
    return false;
}
