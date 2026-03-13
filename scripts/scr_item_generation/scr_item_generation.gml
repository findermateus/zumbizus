function buildPossibleItemDrop(_id, _type, _weight = 10) {
    return {
        id: _id,
        type: _type,
        weight: _weight
    };
}

function getWeightItemRandom(_items_array) {
    var _totalWeight = 0;
    var _count = array_length(_items_array);
    
    for (var i = 0; i < _count; i++) {
        _totalWeight += _items_array[i].weight;
    }
    
    var _roll = irandom_range(1, _totalWeight);
    var _cursor = 0;
    
    for (var i = 0; i < _count; i++) {
        _cursor += _items_array[i].weight;
        if (_roll <= _cursor) {
            return _items_array[i];
        }
    }
    return _items_array[0];
}

function convertRandomItemToBuildedItem(_selectedItem, _limitFactor) {
	var _selectedItemConfig = global.items[_selectedItem.type][_selectedItem.id];
    var _buildedItem = constructItem(_selectedItem.type, _selectedItemConfig);
  
    if (variable_struct_exists(_selectedItemConfig, "limit")) {
        var _limit = ceil(_selectedItemConfig.limit / _limitFactor);
        _buildedItem.quantity = irandom_range(1, _limit);
    }
	
	return _buildedItem;
}