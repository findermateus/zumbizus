function saveGame(_playerData = false, _playerBase = false){
	if(_playerData) savePlayerData();
	if(_playerBase) savePlayerBase();
	
	var _toolBarData = {
		equipedItems: _toolBarEquipedItems,
		toolBarSize: global.toolBarSize
	};
	var _equipedItemData = {
		activeEquipedItem: global.activeEquipedItem,
		activeEquipedItemIndex: global.activeEquipedItemIndex
	};
	var _inventoryData = [];
	for(var i = 0; i < ds_grid_height(global.inventory); i ++){
		for(var j = 0; j < ds_grid_width(global.inventory); j ++){
			_inventoryData[i][j] = global.inventory[# i, j];
		}
	}
	var _stats = {
		hunger: global.player.currentHunger,
		thirst: global.player.currentThirst
	};
	var _saveData = json_stringify({
		inventory:  _inventoryData,
		toolBar: _toolBarData,
		equipedItem: _equipedItemData,
		stats: _stats
	});
	var _saveFile = file_text_open_write("player_save.json");
	file_text_write_string(_saveFile, _saveData);
	file_text_close(_saveFile);
}
	
function loadGame(){
	loadPlayerData();
	loadPlayerBase();
}

function loadPlayerData(){
	if (!file_exists("player_save.json")) {
		return;
	}
	var _playerSaveFile = file_text_open_read("player_save.json");
	var _playerSaveJson = file_text_read_string(_playerSaveFile);
	if(_playerSaveJson != ""){
		var _playerData = json_parse(_playerSaveJson);
		loadArrayToDsGrid(_playerData.inventory, global.inventory);
		loadPlayerToolBar(_playerData.toolBar);
		loadPlayerEquipedItem(_playerData.equipedItem);
		if (variable_struct_exists(_playerData, "stats")){
			loadPlayerStats(_playerData.stats);
		}
	}
	file_text_close(_playerSaveFile);
}

function loadArrayToDsGrid(_data, _destiny){
	var _inventoryHeight = ds_grid_height(_destiny);
	var _inventoryWidth = ds_grid_width(_destiny);
	for(var i = 0; i < _inventoryHeight; i++){
		for(var j = 0; j < ds_grid_width(_destiny); j ++){
			var _item = _data[i][j];
			_destiny[# j, i] = _data[i][j];
			if (_data[i][j] == global.blankInventorySpace) continue;
		}
	}
}

function loadPlayerToolBar(_toolBar){
	global.toolBarSize = _toolBar.toolBarSize;
	for(var i = 0; i < array_length(_toolBar.equipedItems); i ++){
		var _item = _toolBar.equipedItems[i];
		global.equipedItems[| i] = _item;
	}
}

function loadPlayerStats(_stats){
	global.player.currentThirst = _stats.thirst;
	global.player.currentHunger = _stats.hunger;
}

function loadPlayerEquipedItem(_equipedItem){
	global.activeEquipedItemIndex = _equipedItem.activeEquipedItemIndex;
	global.activeEquipedItem = _equipedItem.activeEquipedItem;
}
	
function createBlankBaseSaveFile() {
	var _saveFile = file_text_open_write("player_base_save.json");
	file_text_write_string(_saveFile, "");
	file_text_close(_saveFile);
}
	
function loadPlayerBase(){
	if (!file_exists("player_base_save.json")) {
		createBlankBaseSaveFile();
	}
	var _playerBaseSaveFile = file_text_open_read("player_base_save.json");
	var _baseSaveJson = file_text_read_string(_playerBaseSaveFile);
	if (_baseSaveJson == global.blankInventorySpace){
		loadDefaultBaseData();
		file_text_close(_playerBaseSaveFile);
		return;
	}
	var _baseData = json_parse(_baseSaveJson);
	if (is_struct(_baseData)){
		loadBaseFurnitures(_baseData.furnitures);
		loadBaseItems(_baseData.items);
	} else {
		//caso ainda não exista save, carregar as mobilias base.
		loadDefaultBaseData();
	}
	
	//caso tenha um save legado
	if (!instance_exists(obj_furniture_map_selector)) {
		loadDefaultBaseData();
	}
	
	file_text_close(_playerBaseSaveFile);
}

function loadDefaultBaseData() {
	instance_create_layer(400, 700, "Items", obj_furniture_map_selector);
}

function loadBaseFurnitures(_furnitures){
	instance_destroy(obj_furniture);
	var _furnitureLength = array_length(_furnitures);
	var _lastInsertId = 0;
	for(var i = 0; i < _furnitureLength; i ++){
		var _furnitureInfo = _furnitures[i];
		var _furniture = instance_create_layer(0, 0, "Items", _furnitureInfo.objectIndex, _furnitureInfo.objectInfo);
		
		_furniture.furniture = _furnitureInfo.objectInfo.furniture;
		_furniture.furnitureHealth = _furnitureInfo.objectInfo.furnitureHealth;
		_furniture.furnitureInfo = _furnitureInfo.objectInfo.furnitureInfo;
		_furniture.objectId = _furnitureInfo.objectId;
		
		if(_furniture.object_index == obj_chest){
			_furniture.containerData = ds_grid_create(_furnitureInfo.container.width, _furnitureInfo.container.height);
			loadArrayToDsGrid(_furnitureInfo.container.containerData, _furniture.containerData);
		}
		
		_furniture.loadSavedData(_furnitureInfo);
		_lastInsertId = _furnitureInfo.objectId > _lastInsertId ? _furnitureInfo.objectId : _lastInsertId;
	}
	global.baseFurnitureIdCount = _lastInsertId;
}

function setFurnitureBaseId(_obj) {
	global.baseFurnitureIdCount ++;
	_obj.objectId = global.baseFurnitureIdCount;
}

function loadBaseItems(_items){
	instance_destroy(obj_item);
	array_foreach(_items, function (_item) {
		var _itemInstance = instance_create_layer(0, 0, "Items", obj_item, _item);
		_itemInstance.angle = _item.angle;
		_itemInstance.item = _item.item;
	});
}
	
function savePlayerBase(){
	if(room != rm_player_base) return;
	var _furnitureList = getPlayerBaseFurnitures();
	var _itemList = getPlayerBaseItems();
	var _playerBaseData = {
		furnitures: _furnitureList,
		items: _itemList
	};
	var _saveFile = file_text_open_write("player_base_save.json");
	file_text_write_string(_saveFile, json_stringify(_playerBaseData));
	file_text_close(_saveFile);
}

function getPlayerBaseItems(){
	var _itemList = [];
	with(obj_item){
		var _item = {
			x: x,
			y: y,
			item: item,
			angle: angle,
			image_angle: image_angle
		}
		array_push(_itemList, _item);
	}
	return _itemList;
}

function getPlayerBaseFurnitures(){
	var _furnitureList = [];
	with(obj_furniture){
		var _furnitureData = {
			objectIndex: object_index,
			objectId: objectId,
			objectInfo: {
				x: x,
				y: y,
				image_angle: image_angle,
				sprite_index: sprite_index,
				furnitureInfo: furnitureInfo,
				furniture: furniture,
				furnitureHealth: furnitureHealth,
			}
		}
		if (object_index == obj_chest){
			_furnitureData.container = {};
			var _containerValues = addContainerValues(containerData);
			_furnitureData.objectInfo.containerId = containerId;
			_furnitureData.container.containerData = _containerValues;
			_furnitureData.container.height = ds_grid_height(containerData);
			_furnitureData.container.width = ds_grid_width(containerData);
		}
		var _productiveData = getFurnitureData(furnitureId, objectId);
		if (_productiveData != undefined) {
			_furnitureData.productiveData = _productiveData;
		}
		array_push(_furnitureList, _furnitureData)
	}
	return _furnitureList;
}

function addContainerValues(containerData){
	//aqui tem que inverter
	var _containerValues = [];
	var _width = ds_grid_width(containerData);
	var _height = ds_grid_height(containerData);
	for(var i = 0; i < _height; i ++){
		for(var j = 0; j < _width; j++){
			_containerValues[i][j] = containerData[# j, i];
		}
	}
	return _containerValues;
}