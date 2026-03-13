function getItemsThatCanBeRepaired(_intentory){
	var height = ds_grid_height(_intentory);
	var width = ds_grid_width(_intentory);
	var _items = [];
	for (var i = 0; i < ds_list_size(global.equipedItems); i ++){
		var _item = global.equipedItems[| i];
		if (_item == global.blankInventorySpace) continue;
		if (itemHasDurability(_item)) {
			array_push(_items, {
				item: _item,
				toolBar: i
			});
		}
	}
    for (var i = 0; i < height; i++) {
        for (var j = 0; j < width; j++) {
			var _item = _intentory[# j, i];
			if (_item == global.blankInventorySpace) continue;
            if (itemHasDurability(_item)) {
				array_push(_items, {
					item: _item,
					j: j,
					i: i
				});
            }
        }
    }
	
	var _cleanedItems = array_filter(_items, function (_struct) {
		var _item = _struct.item;
		return _item.durability < _item.maxDurability;
	});
	
	return _cleanedItems;
}

function getItemRepairRequirements(_id) {
	var _type = itemType.weapons;
	var _weaponsReqs = global.repairItems[_type];
	
	var _key = -1;
	for (var i = 0; i < array_length(_weaponsReqs); i++) {
		if (_weaponsReqs[i].id == _id) {
			_key = i;
		}
	}
	
	return _key == -1 ? false : _weaponsReqs[_key];
}

function repairItemFromToolBar(_i) {
	var _item = global.equipedItems[| _i]
	global.equipedItems[| _i].durability = _item.maxDurability;
}

function repairItemFromInventory(_j, _i, _inventory) {
	var _item = _inventory[# _j, _i];
	_inventory[# _j, _i].durability = _item.maxDurability; 
}