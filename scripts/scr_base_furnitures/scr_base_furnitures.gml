global.currentBaseMenuOption = -1;
global.baseFurnitures = [];
global.baseProductiveFurnitures = [];
global.workingNpcs = [];

function Worker(_id) constructor {
	id = _id;
}

function loadBaseFurnituresData() {
	if (room != rm_player_base) return;
	global.baseProductiveFurnitures = [];
	global.baseFurnitures = [];
	for (var i = 0; i < instance_number(obj_furniture); i ++) {
		iterateBaseFurniture(i);	
	}
}

function iterateBaseFurniture(i) {
	var _furniture = instance_find(obj_furniture, i);
	array_push(global.baseFurnitures, _furniture.furniture);
	
	if (is_undefined(_furniture.objectId)) {
		global.baseFurnitureIdCount ++;
		_furniture.objectId = global.baseFurnitureIdCount;
	}
	
	if (!ds_map_exists(global.productiveFurnitures, _furniture.furnitureId)) return;
	var _productiveFurniture = global.productiveFurnitures[? _furniture.furnitureId];
	
	if (!is_struct(_productiveFurniture)) return;
	array_push(global.baseProductiveFurnitures, _furniture);
}
