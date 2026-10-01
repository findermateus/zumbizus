function saveExists() {
	if (!file_exists("player_save.json")) {
		return false;
	}

	var _saveFile = file_text_open_read("player_save.json");
	var _saveJson = file_text_read_string(_saveFile);
	file_text_close(_saveFile);

	if (_saveJson == "") {
		return false;
	}

	try {
		var _saveData = json_parse(_saveJson);

		if (!is_struct(_saveData)) return false;
		if (!variable_struct_exists(_saveData, "version")) return false;
		if (!variable_struct_exists(_saveData, "inventory")) return false;
		if (!variable_struct_exists(_saveData, "toolBar")) return false;
		if (!variable_struct_exists(_saveData, "equipedItem")) return false;
		if (!variable_struct_exists(_saveData, "player")) return false;
		if (!variable_struct_exists(_saveData, "quickUse")) return false;
		if (!variable_struct_exists(_saveData, "equipments")) return false;

		return true;
	} catch (_error) {
		return false;
	}
}

function saveGame(_playerData = true, _playerBase = false) {
	if (_playerData) {
		savePlayerData();
	}

	if (_playerBase) {
		savePlayerBase();
	}
}
	
function savePlayerData() {
	var _saveData = {
		version: 2,
		inventory: getInventorySaveData(global.inventory),
		toolBar: getToolBarSaveData(),
		equipedItem: getEquipedItemSaveData(),
		quickUse: getQuickUseSaveData(),
		equipments: getEquipmentsSaveData(),
		player: getPlayerSaveData()
	};

	var _saveFile = file_text_open_write("player_save.json");
	file_text_write_string(_saveFile, json_stringify(_saveData));
	file_text_close(_saveFile);
}

function getQuickUseSaveData() {
	var _quickUseItems = [];

	for (var i = 0; i < ds_list_size(global.quickUse); i++) {
		_quickUseItems[i] = global.quickUse[| i];
	}

	return {
		items: _quickUseItems
	};
}

function getInventorySaveData(_inventory) {
	var _inventoryData = [];

	var _width = ds_grid_width(_inventory);
	var _height = ds_grid_height(_inventory);

	for (var i = 0; i < _height; i++) {
		for (var j = 0; j < _width; j++) {
			_inventoryData[i][j] = _inventory[# j, i];
		}
	}

	return _inventoryData;
}

function getToolBarSaveData() {
	var _toolBarEquipedItems = [];

	for (var i = 0; i < ds_list_size(global.equipedItems); i++) {
		_toolBarEquipedItems[i] = global.equipedItems[| i];
	}

	return {
		equipedItems: _toolBarEquipedItems,
		toolBarSize: global.toolBarSize
	};
}

function getEquipmentsSaveData() {
	return {
		head: global.equipments.head,
		armor: global.equipments.armor,
		bag: global.equipments.bag
	};
}

function getEquipedItemSaveData() {
	return {
		activeEquipedItem: global.activeEquipedItem,
		activeEquipedItemIndex: global.activeEquipedItemIndex
	};
}

function getPlayerSaveData() {
	return {
		identity: {
			name: global.player.name,
			skinColor: global.player.skinColor,
			gender: global.player.gender,
			hair: global.player.hair
		},

		progression: {
			level: global.player.level,
			xp: global.player.xp,
			skills: global.player.skills,
			stats: global.player.stats,
			blueprints: global.player.blueprints
		},

		economy: {
			money: global.player.money
		},

		survival: {
			defaultTotalThirst: global.player.defaultTotalThirst,
			defaultTotalHunger: global.player.defaultTotalHunger,
			currentThirst: global.player.currentThirst,
			currentHunger: global.player.currentHunger
		},

		health: {
			maxHealth: global.player.maxHealth,
			health: global.player.health,
			defaultMaxHealth: global.player.defaultMaxHealth
		},

		stamina: {
			maxStamina: global.player.maxStamina,
			defaultMaxStamina: global.player.defaultMaxStamina,
			stamina: global.player.stamina,
			staminaAcceleration: global.player.staminaAcceleration,
			staminaRecoveryDelay: global.player.staminaRecoveryDelay,
			staminaDecreaseAcceleration: global.player.staminaDecreaseAcceleration,
			sprintSpeed: global.player.sprintSpeed,
			sprintStaminaDecrease: global.player.sprintStaminaDecrease
		},

		movement: {
			walkingAceleration: global.player.walkingAceleration,
			walkingSpeed: global.player.walkingSpeed
		},

		buffs: {
			buffList: getPlayerBuffsSaveData()
		}
	};
}
	
function loadGame(){
	loadPlayerData();
}

function loadPlayerData() {
	if (!saveExists()) {
		return;
	}

	var _playerSaveFile = file_text_open_read("player_save.json");
	var _playerSaveJson = file_text_read_string(_playerSaveFile);
	file_text_close(_playerSaveFile);

	var _playerData = json_parse(_playerSaveJson);

	loadPlayerState(_playerData.player);

	loadPlayerEquipments(_playerData.equipments);
	applyEquipmentsAfterLoad();

	loadArrayToDsGrid(_playerData.inventory, global.inventory);

	loadPlayerToolBar(_playerData.toolBar);
	loadPlayerEquipedItem(_playerData.equipedItem);
	loadPlayerQuickUse(_playerData.quickUse);
}

function loadArrayToDsGrid(_data, _destiny) {
	var _height = ds_grid_height(_destiny);
	var _width = ds_grid_width(_destiny);

	for (var i = 0; i < _height; i++) {
		for (var j = 0; j < _width; j++) {
			_destiny[# j, i] = _data[i][j];
		}
	}
}

function loadPlayerState(_playerData) {
	loadPlayerIdentity(_playerData.identity);
	loadPlayerProgression(_playerData.progression);
	loadPlayerEconomy(_playerData.economy);
	loadPlayerSurvival(_playerData.survival);
	loadPlayerHealth(_playerData.health);
	loadPlayerStamina(_playerData.stamina);
	loadPlayerMovement(_playerData.movement);
	loadPlayerBuffs(_playerData.buffs);
}

function loadPlayerQuickUse(_quickUse) {
	ds_list_clear(global.quickUse);

	for (var i = 0; i < array_length(_quickUse.items); i++) {
		ds_list_add(global.quickUse, _quickUse.items[i]);
	}
}

function loadPlayerIdentity(_identity) {
	global.player.name = _identity.name;
	global.player.skinColor = _identity.skinColor;
	global.player.gender = _identity.gender;
	global.player.hair = _identity.hair;
}

function loadPlayerProgression(_progression) {
	global.player.level = _progression.level;
	global.player.xp = _progression.xp;
	global.player.skills = _progression.skills;
	global.player.stats = _progression.stats;
	global.player.blueprints = _progression.blueprints;
}

function loadPlayerSurvival(_survival) {
	global.player.defaultTotalThirst = _survival.defaultTotalThirst;
	global.player.defaultTotalHunger = _survival.defaultTotalHunger;
	global.player.currentThirst = _survival.currentThirst;
	global.player.currentHunger = _survival.currentHunger;
}

function loadPlayerHealth(_health) {
	global.player.maxHealth = _health.maxHealth;
	global.player.health = _health.health;
	global.player.defaultMaxHealth = _health.defaultMaxHealth;
}

function loadPlayerStamina(_stamina) {
	global.player.maxStamina = _stamina.maxStamina;
	global.player.defaultMaxStamina = _stamina.defaultMaxStamina;
	global.player.stamina = _stamina.stamina;
	global.player.staminaAcceleration = _stamina.staminaAcceleration;
	global.player.staminaRecoveryDelay = _stamina.staminaRecoveryDelay;
	global.player.staminaDecreaseAcceleration = _stamina.staminaDecreaseAcceleration;
	global.player.sprintSpeed = _stamina.sprintSpeed;
	global.player.sprintStaminaDecrease = _stamina.sprintStaminaDecrease;
}

function loadPlayerMovement(_movement) {
	global.player.walkingAceleration = _movement.walkingAceleration;
	global.player.walkingSpeed = _movement.walkingSpeed;
}

function getPlayerBuffsSaveData() {
	var _buffList = [];

	for (var i = 0; i < array_length(global.player.buffList); i++) {
		var _buff = global.player.buffList[i];

		if (!is_struct(_buff)) continue;

		array_push(_buffList, {
			id: _buff.id,
			multiplier: _buff.multiplier,
			type: _buff.type,
			description: _buff.description,
			timeInSeconds: _buff.timeInSeconds,
			currentTime: _buff.currentTime,
			positive: _buff.positive,
			icon: _buff.icon,
			customDescription: _buff.customDescription
		});
	}

	return {
		buffList: _buffList
	};
}

function loadPlayerBuffs(_buffs) {
	global.player.buffList = [];

	if (!is_struct(_buffs)) return;
	if (!variable_struct_exists(_buffs, "buffList")) return;

	for (var i = 0; i < array_length(_buffs.buffList); i++) {
		var _buffData = _buffs.buffList[i];

		if (!is_struct(_buffData)) continue;

		var _icon = variable_struct_exists(_buffData, "icon")
			? _buffData.icon
			: undefined;

		var _customDescription = variable_struct_exists(_buffData, "customDescription")
			? _buffData.customDescription
			: "";

		var _buff = new Buff(
			_buffData.id,
			_buffData.multiplier,
			_buffData.type,
			_buffData.description,
			_buffData.timeInSeconds,
			_buffData.positive,
			_icon,
			_customDescription
		);

		if (variable_struct_exists(_buffData, "currentTime")) {
			_buff.currentTime = _buffData.currentTime;
		}

		array_push(global.player.buffList, _buff);
	}
}

function loadPlayerEconomy(_economy) {
	global.player.money = _economy.money;
}

function loadPlayerToolBar(_toolBar){
	global.toolBarSize = _toolBar.toolBarSize;
	for(var i = 0; i < array_length(_toolBar.equipedItems); i ++){
		var _item = _toolBar.equipedItems[i];
		global.equipedItems[| i] = _item;
	}
}

function loadPlayerEquipedItem(_equipedItem){
	global.activeEquipedItemIndex = _equipedItem.activeEquipedItemIndex;
	global.activeEquipedItem = _equipedItem.activeEquipedItem;
}

function loadPlayerEquipments(_equipments) {
	global.equipments.head = _equipments.head;
	global.equipments.armor = _equipments.armor;
	global.equipments.bag = _equipments.bag;
}
	
function applyEquipmentsAfterLoad() {
	handleBagSwitch();
	handleArmorSwitch();
	handleHeadSwitch();
}
	
function createBlankBaseSaveFile() {
	var _saveFile = file_text_open_write("player_base_save.json");
	file_text_write_string(_saveFile, "");
	file_text_close(_saveFile);
}
	
function loadPlayerBase() {
	if (!file_exists("player_base_save.json")) {
		createBlankBaseSaveFile();
	}

	var _playerBaseSaveFile = file_text_open_read("player_base_save.json");
	var _baseSaveJson = file_text_read_string(_playerBaseSaveFile);
	file_text_close(_playerBaseSaveFile);

	if (_baseSaveJson == "" || _baseSaveJson == BLANK_INVENTORY_SPACE) {
		loadDefaultBaseData();
		return;
	}

	try {
		var _baseData = json_parse(_baseSaveJson);

		if (is_struct(_baseData)) {
			loadBaseFurnitures(_baseData.furnitures);
			loadBaseItems(_baseData.items);
		} else {
			loadDefaultBaseData();
		}
	} catch (_error) {
		loadDefaultBaseData();
		return;
	}

	if (!instance_exists(obj_furniture_map_selector)) {
		loadDefaultBaseData();
	}
}

function loadDefaultBaseData() {
	instance_create_layer(400, 700, "Items", obj_furniture_map_selector);
	instance_create_layer(600, 700, "Items", obj_furniture_simple_crafting_station);
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