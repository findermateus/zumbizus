event_inherited();
actionDescription = "Abrir";
containerData = undefined;
//for (var i = 0; i < _containerWidth; ++i)
//{
//    for (var j = 0; j < _containerHeight; ++j)
//    {
//		var _itemType = choose(itemType.consumables, itemType.trash, itemType.weapons);
//		var _itemIndexMax = array_length(global.items[_itemType]) -1;
//		var _itemIndex = irandom(_itemIndexMax);
//		var _item = constructItem(_itemType, global.items[_itemType][_itemIndex]);
//        containerData[# i, j] = _item;
//    }
//}

function loadFurnitureByDefaultId() {
	var _chestId = global.containerMapping[? containerId];
	var _object = global.furnitureObjectConversor[_chestId];
	setFurniture(_object, _object.info);
}

function setFurnitureById() {
	
}

function setFurniture(_furniture, _furnitureInfo = {}){
	if (!is_undefined(containerData)) {
		ds_grid_destroy(containerData);
	}
	if (variable_struct_exists(_furnitureInfo, "id")) {
		var _mapKeys = ds_map_keys_to_array(global.containerMapping);
		var _index = "";
		for (var i = 0; i < array_length(_mapKeys); i ++) {
			if (global.containerMapping[? _mapKeys[i]] == _furnitureInfo.id) {
				_index = _mapKeys[i];
			}
		}
		containerId = _index;
	}
	containerData = ds_grid_create(_furnitureInfo.gridWidth, _furnitureInfo.gridHeight);
	ds_grid_clear(containerData, global.blankInventorySpace);
	sprite_index = _furnitureInfo.sprite;
	furnitureHealth = _furnitureInfo.furnitureHealth;
	xPosition = x;
	yPosition = y;
}

containerOpen = false;
sound = snd_open_container;
furnitureCategory = furnitureCategories.storage;
furnitureId = furnitureIds.chest;

loadFurnitureByDefaultId();

function setSpriteOpen(){
	image_index = image_number - 1;
}

function setSpriteClosed() {
	image_index = 0;
}

function active(){
	if(!verifyConditions()) currentState = innactive;
	if(mouse_check_button_pressed(mb_left)){
		containerOpen = true;
		setSpriteOpen();
		openInventoryWithContainer(id, sound, containerData);
		return;
	}
}

function closeIfShouldClose(){
	if (!containerOpen) return;
	if (!global.activeInventory || obj_inventory.currentState == obj_inventory.hide) {
		closeContainer();	
	}
	var _player = checkPlayerExistence();
	if (!_player) return;
	if(checkObstacules(_player) && checkDistance(_player)) return;
	closeContainer();
}

function closeContainer(){
	containerOpen = false;
	setSpriteClosed();
	audio_play_sound(snd_close_crafting_station, 0, false);
	closeInventory();
}