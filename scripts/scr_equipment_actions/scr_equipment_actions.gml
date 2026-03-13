

function handleEquipmentSwitch(){
	var _handleMethods = {
		"bag": handleBagSwitch,
		"armor": handleArmorSwitch,
		"head": handleHeadSwitch
	}
	_handleMethods[$ indicatorToWhereItemShouldBePut]();
}

function handleBagSwitch(){
	if (global.equipments.bag == global.blankInventorySpace){
		setInventorySize(global.inventoryWidth, global.inventoryHeight);
		return;
	}
	var _itemData = global.equipments.bag.equipmentData;
	var _inventoryWidth = global.inventoryWidth + _itemData.capacity
	setInventorySize(_inventoryWidth, global.inventoryHeight);
}

function handleHeadSwitch() {
	
}

function setInventorySize(_width, _height){
	var _auxiliarInventory = [];
	var _inventoryWidth = ds_grid_width(global.inventory);
	var _inventoryHeight = ds_grid_height(global.inventory);
	//limpa o inventário
	for (var i = 0; i < _inventoryHeight; i++){
		for (var j = 0; j < _inventoryWidth; j ++){
			var _item = global.inventory[# j, i];
			if (_item == global.blankInventorySpace) continue;
			array_push(_auxiliarInventory, _item);
		}
	}
	ds_grid_destroy(global.inventory);
	global.inventory = ds_grid_create(_width, _height);
	ds_grid_clear(global.inventory, global.blankInventorySpace);
	for (var i = 0; i < _height; i++){
		for (var j = 0; j < _width; j ++){
			if (!array_length(_auxiliarInventory)) continue;
			global.inventory[# j, i] = array_shift(_auxiliarInventory);
		}
	}
	var _inventoryLength = array_length(_auxiliarInventory);
	if (!_inventoryLength) return;
	array_foreach(_auxiliarInventory, function (_item) {
		createIndicatorForDroppedItems(_item);
		createItem(_item, true);
	});
}

function createIndicatorForDroppedItems(_item, _quantity = 1){
	var _indicatorModal = instance_create_layer(0, 0, "Alert", obj_collected_item_indicator);
	_indicatorModal.box.collecting = false;
	_indicatorModal.box.textContent = _item.name;
	_indicatorModal.box.sprite = _item.sprite;
	_indicatorModal.box.itemId = _item.itemId;
	_indicatorModal.box.quantity = _quantity;
}

function createIndicatorModal(_item, _quantity = 1){
	var _indicatorModal = instance_create_layer(x, y, "Alert", obj_collected_item_indicator);
	_indicatorModal.box.textContent = _item.name;
	_indicatorModal.box.sprite = _item.sprite;
	_indicatorModal.box.itemId = _item.itemId;
	_indicatorModal.box.quantity = _quantity;
}

function handleArmorSwitch(){

}