global.currentMenuOptions = [];
/// @param grid_id A ID da ds_grid
/// @param value O valor que deseja procurar
/// @return Retorna [x, y] se encontrar o valor, ou [-1, -1] se não encontrar
function findCleanIndexFromInventory(grid_id, value) {
    var width = ds_grid_width(grid_id);
    var height = ds_grid_height(grid_id);

    for (var _y = 0; _y < height; _y++) {
        for (var _x = 0; _x < width; _x++) {
            if (grid_id[# _x, _y] == value) {
                return [_x, _y];
            }
        }
    }
    return [-1, -1];
}

function findItemInInventoryByIdNoBullshit(_grid_id, _itemId, _itemType){
	var height = ds_grid_width(_grid_id);
    var width = ds_grid_height(_grid_id);
    for (var _y = 0; _y < width; _y++) {
        for (var _x = 0; _x < height; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
			if(_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType){
				return [_x, _y];
			}
        }
    }
	return false;
}

function findItemInInventoryById(_grid_id, _itemId, _itemType){
	var height = ds_grid_width(_grid_id);
    var width = ds_grid_height(_grid_id);
    for (var _y = 0; _y < width; _y++) {
        for (var _x = 0; _x < height; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
			//adicionar conferencia por tipo
			if(_grid_id[# _x, _y].itemId == _itemId && _grid_id[# _x, _y].type == _itemType){
				if(_grid_id[# _x, _y].quantity < _grid_id[# _x, _y].limit) return [_x, _y];
			}
        }
    }
	return false;
}

function findItemInInventory(_grid_id, _item){
	var width = ds_grid_width(_grid_id);
    var height = ds_grid_height(_grid_id);
    for (var _y = 0; _y < height; _y++) {
        for (var _x = 0; _x < width; _x++) {
            if (_grid_id[# _x, _y] == global.blankInventorySpace) continue;
			if(_grid_id[# _x, _y].itemId == _item.itemId && _grid_id[# _x, _y].type == _item.type){
				if(_grid_id[# _x, _y].quantity < _grid_id[# _x, _y].limit){
					return [_x, _y];
				}
			}
        }
    }
	return false;
}

function isItemStackable(_firstItem, _lastItem){
	//são o mesmo item?
	if (_firstItem.itemId != _lastItem.itemId || _firstItem.type != _lastItem.type) return global.blankInventorySpace;
	if(!variable_struct_exists(_firstItem, "limit")) return global.blankInventorySpace;
	if(_lastItem.quantity >= _lastItem.limit) return global.blankInventorySpace;
	
	var _remainingSpace = _lastItem.limit - _lastItem.quantity;

	//se a quantidade do primeiro item for maior que o espaço sobrando ele entra
    if (_firstItem.quantity > _remainingSpace ) {
        _lastItem.quantity += _remainingSpace ;
        _firstItem.quantity -= _remainingSpace ; 
		return {
			firstItem: _firstItem,
			lastItem: _lastItem
		};
    }
    _lastItem.quantity += _firstItem.quantity;
    return {
		lastItem: _lastItem
	};
}

function getConsumedItem(_itemId){
	var _item = constructItem(itemType.trash, global.items[itemType.trash][_itemId]);
	return _item;
}

function dropItem(){
	if(global.currentItemPlayingTheAction == global.blankInventorySpace) return;
	var _itemToDrop = global.activeInventoryAction[# global.currentItemPlayingTheAction.j, global.currentItemPlayingTheAction.i];
	var _droppedItem = instance_create_layer(obj_player.x, obj_player.y, "Items", obj_item);
	_droppedItem.item = _itemToDrop;
	_droppedItem.createdWithBounce();
	createIndicatorForDroppedItems(
		_itemToDrop,
		variable_struct_exists(_itemToDrop, "quantity") ? _itemToDrop.quantity : 1
	);
	global.activeInventoryAction[# global.currentItemPlayingTheAction.j, global.currentItemPlayingTheAction.i] = global.blankInventorySpace;
	global.currentItemPlayingTheAction = global.blankInventorySpace;
	return true;
}

function createItem(_item, _bounce = false){
	var _droppedItem = instance_create_layer(obj_player.x, obj_player.y, "Items", obj_item);
	_droppedItem.item = _item;
	if (!_bounce) return;
	_droppedItem.createdWithBounce();
}

function createItemByObjectId(_id, _item, _bounce = false) {
	if (!instance_exists(_id)) {
		createItem(_item, _bounce);
		return;
	}
	
	var _droppedItem = instance_create_layer(_id.x, _id.y, "Items", obj_item);
	_droppedItem.item = _item;
	if (!_bounce) return;
	_droppedItem.createdWithBounce();
}

function dropItemFromToolBar(_item, _index){
	createIndicatorForDroppedItems(_item);
	var _droppedItem = instance_create_layer(obj_player.x, obj_player.y, "Items", obj_item);
	_droppedItem.item = _item;
	global.equipedItems[| _index] = global.blankInventorySpace;
}

function cleanMenuOptions(){
	array_foreach(global.currentMenuOptions, function (_option){
		instance_destroy(_option);
	});
	global.currentMenuOptions = [];
}

function itemIsDismantable(_item) {
	if (_item == global.blankInventorySpace) return false;
	if (array_length(global.dismantableItems) <= _item.type) return false;
	if (global.dismantableItems[_item.type] == undefined) return false;
	if (array_length(global.dismantableItems[_item.type]) <= _item.itemId) return false;
	var _allocatedItem = global.dismantableItems[_item.type][_item.itemId]
	return _allocatedItem != undefined && _allocatedItem != 0 && !is_struct(_allocatedItem);
}

function getDismantableContent(_id, _type) {
	var _item = global.items[_type][_id];
	if (itemIsDismantable(constructItem(_type, _item))) {
		return global.dismantableItems[_type][_id];
	}
}

function getItemsThatCanBeDismantled(_inventory, _itemType) {
    var _items = [];
    
	if (_itemType == itemType.weapons) {
		for (var i = 0; i < ds_list_size(global.equipedItems); i++) {
	        var _item = global.equipedItems[| i];
	        if(itemIsDismantable(_item)) {
				array_push(_items, {
			        item: _item,
			        toolBar: i
				});
			}
		}
	}
    
    var height = ds_grid_height(_inventory);
    var width = ds_grid_width(_inventory);
    
    for (var i = 0; i < height; i++) {
        for (var j = 0; j < width; j++) {
            var _item = _inventory[# j, i];
			if (itemIsDismantable(_item) && _item.type == _itemType) {
				array_push(_items, {
                        item: _item,
                        j: j,
                        i: i
                    });
			}
        }
    }
    
    return _items;
}


function itemHasDurability(_item) {
	if (_item == global.blankInventorySpace) return false;
	if (variable_struct_exists(_item, "durability")) {
		return _item.durability != undefined;
	}
	return false;
}

function itemWorksWithAmmo(_item) {
	if (_item == global.blankInventorySpace) return false;
	if (variable_struct_exists(_item, "maxAmmo")) {
		return _item.maxAmmo != undefined;
	}
	return false;
}