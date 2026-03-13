event_inherited();

var _dependencies = [
	obj_player_buff_controller,
	obj_xp_controller,
	obj_damage_controller,
	obj_player_stats
];

array_foreach(_dependencies, function (_dep) {
	if (!instance_exists(_dep)) {
		instance_create_layer(0, 0, "Controllers", _dep);
	}	
});

playerSprite = spr_human_male_iddle;
currentSpriteFrame = 0;
spriteSpeed = sprite_get_speed(playerSprite);
spriteLength = sprite_get_number(playerSprite);
spriteXscale = 1;
faceDirection = 3;
switchSprite = false;
equipedItem = global.blankInventorySpace;
currentState = playerIddleState;
shouldRecoverStamina = true;
staminaDestiny = global.player.maxStamina;
staminaAcceleration = global.player.staminaAcceleration;
currentSpeed = global.player.walkingSpeed;
playerAngleOffset = 0;
playerAngleTimer = 0;
closestObjectToCatch = noone;

inputs = {
	up: keyboard_check(ord("W")),
	down: keyboard_check(ord("S")),
	left: keyboard_check(ord("A")),
	right: keyboard_check(ord("D"))
};

playerSoundController = instance_create_layer(0, 0, "Controllers", obj_player_sound_controller);
particleSystem = part_system_create();
particleDust = part_type_create();

#region dust particle system
{
	part_type_sprite(particleDust, spr_particle, 0, 0, 1);
	part_type_life(particleDust, 20, 40);
	part_type_speed(particleDust, .2, .4, -.004, 0);
	part_type_size(particleDust, 1, 1, .03, 0);
	part_type_alpha2(particleDust, .6, 0);
	part_type_scale(particleDust, .5, .5);
}

#endregion

velh = 0;
velv = 0;
playerAceleration = global.player.walkingAceleration;
if(!instance_exists(obj_weapon)) {
	var _weapon = instance_create_layer(x, y, "Weapons", obj_weapon);
	_weapon.father = id;
}

{
	//define a orientação do audio
	audio_listener_orientation(0, 0, 1000, 0, -1, 0);
}

sprites = {
	iddle: spr_human_male_iddle,
	walking: spr_human_male_walking,
	//running: spr_player_running
}

#region funcionalyties
function loadInputs(){
	inputs = {
		up: keyboard_check(ord("W")),
		down: keyboard_check(ord("S")),
		left: keyboard_check(ord("A")),
		right: keyboard_check(ord("D"))
	};
}

function setDirection(_right, _left) {
	if (_right) {
		faceDirection = 0; spriteXscale = 1;
	}
	if (_left) {
		faceDirection = 2; spriteXscale = -1;
	}
	shadowDirection = spriteXscale;
}

function movimentPlayer(_adjustByMouse = false){
	if (!_adjustByMouse) {
		setDirection(inputs.right, inputs.left)
	} else {
		setDirection(mouse_x > x, mouse_x < x);
	}
	if((inputs.up xor inputs.down) || (inputs.right xor inputs.left)){
		var _dir = point_direction(0, 0, (inputs.right - inputs.left), (inputs.down - inputs.up));
		var _velh = lengthdir_x(currentSpeed, _dir);
		var _velv = lengthdir_y(currentSpeed, _dir);
		velh = lerp(velh, _velh, playerAceleration);
		velv = lerp(velv, _velv, playerAceleration);
		return;
	}
	velh = lerp(velh, 0, playerAceleration);
	velv = lerp(velv, 0, playerAceleration);
}

function updateSpriteWithState(_sprite){
	if(!switchSprite){
		switchSprite = true;
		currentSpriteFrame = 0;
	}
	playerSprite = _sprite;
	spriteToDrawShadow = playerSprite;
	spriteLength = sprite_get_number(playerSprite);
	spriteSpeed = sprite_get_speed(playerSprite) / 60;
	currentSpriteFrame  += spriteSpeed;
	currentSpriteFrame %= spriteLength;
}

function updateEquipedItems(){
	unequipItemIfIsEmpty();
	var _pressedKey = getToolBarPressedKey();
	if(!_pressedKey) return;
	if (obj_weapon.currentState == obj_weapon.weaponAttackingState) return;
	if (obj_weapon.currentState == obj_weapon.reloadingState) {
		obj_weapon.finishReloading();
	}
	var _toolBarIndex = _pressedKey - 1;
	equipItem(_toolBarIndex);
}

function updateQuickUseBar() {
	if (global.stopInteractions) {
		return;
	}
	var _scrollUp = mouse_wheel_up();
	var _scrollDown = mouse_wheel_down();
	global.activeQuickUseIndex += _scrollDown - _scrollUp;
	if (_scrollDown || _scrollUp) {
		playClickSound();
	}
	if (global.activeQuickUseIndex < 0) global.activeQuickUseIndex = ds_list_size(global.quickUse) - 1;
	if (global.activeQuickUseIndex >= global.quickUseBarSize) global.activeQuickUseIndex = 0;
	if (!keyboard_check_released(ord("E"))) return;
	useItemFromQuickUseBar(global.activeQuickUseIndex);
}

function getToolBarPressedKey(){
	var _pressedKey = false;
	if (keyboard_check_pressed(ord("1"))) _pressedKey = 1;
	if (keyboard_check_pressed(ord("2"))) _pressedKey = 2;
	if (keyboard_check_pressed(ord("3"))) _pressedKey = 3;
	return _pressedKey;
}

function drawGUIEquipedItem(){
	var _screenWidth = display_get_gui_width();
	var _screenHeight = display_get_gui_height();
	var _item = global.activeEquipedItem;
	if (_item == global.blankInventorySpace) return;
	if (!itemWorksWithAmmo(_item)) return;
	var _xPosition = _screenWidth;
	draw_text_scribble(_xPosition, _screenHeight/2, "[fa_right]" + string(_item.bullets) + "/" + string(_item.maxAmmo));
}

function decreaseStamina(_quantity){
	obj_player_stats.setStaminaGuiJiggle();
	shouldRecoverStamina = false;
	global.player.stamina -= abs(_quantity);
	staminaDestiny = global.player.stamina;
	staminaAcceleration = global.player.staminaDecreaseAcceleration;
	var _recoveryDelay = global.player.stamina <= 0 ? global.player.staminaRecoveryDelay * 2 : global.player.staminaRecoveryDelay;
	alarm[0] = _recoveryDelay;
}

function increaseStamina(_value) {
	obj_player_stats.setStaminaGuiJiggle();
	global.player.stamina += abs(_value);
	staminaDestiny = global.player.stamina;
	staminaAcceleration = global.player.staminaDecreaseAcceleration;
}

function handleStamina(){
	if (!shouldRecoverStamina) return;
	global.player.stamina += global.player.staminaAcceleration;
	if (global.player.stamina >= global.player.maxStamina) shouldRecoverStamina = false;
}

damageSpeed = 10;

function playerGetHit(_direction, _damage, _force = 5, _type = damageType.blunt, _shouldRecoverOrGetPushed = true) {
	screenShake(10);
	decreaseHealth(_damage);
	createBloodEffect(_force, invertDirection(_direction), getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), _damage);
	var _velh = lengthdir_x(_force, _direction);
	var _velv = lengthdir_y(_force, _direction);
	var _maxAttempts = 30;
	while (place_meeting(x + _velh, y + _velv, obj_collision) && _maxAttempts > 0) {
		var _vD = sign(_velv);
		var _hD = sign(_velh);
		_velv += - _vD;
		_velh += - _hD;
		_maxAttempts --;
		if (_maxAttempts == 0) {
			_velv = 0;
			_velh = 0;
		}
	}
	
	var _willBleed = choose(false, false, false, true);
	if (_willBleed) {
		applyBleed();
	}
	
	if (!_shouldRecoverOrGetPushed) {
		return;
	}
	
	velv = _velv;
	velh = _velh;
	currentState = playerGetDamagedState;
}

function applyBleed() {
	var _buff = buildCustomBuffByBuffId(buffs.bleeding);
	obj_player_buff_controller.applyBuff(_buff);
}

function handleAngleOffset(_canJiggle, _speed = .3, _force = 3, _ignoreVel = false){
	if (!_ignoreVel && velh == 0 && velv == 0) return;
	if (_canJiggle) {
	    playerAngleTimer += 1;
		// _speed o quão mais alto mais rápido
	    playerAngleOffset = sin(playerAngleTimer * _speed) * _force;
		return;
	}
	playerAngleOffset = lerp(playerAngleOffset, 0, 0.1);
}

function drawPlayer() {
	var _skinColor = global.player.skinColor;
	var _hair = global.player.hair;
	var _armor = global.equipments.armor;
	var _helmet = global.equipments.head;
	var _bag = global.equipments.bag;
	var _drawState = currentState != playerIddleState ? drawStates.walking : drawStates.iddle;
	var _scale = 1;
	
	var _armorId = is_struct(_armor) ? _armor.itemId : -1;
	var _helmetId = is_struct(_helmet) ? _helmet.itemId : -1;
	var _bagId = is_struct(_bag) ? _bag.itemId : -1;
	
	drawPersonBody(
		x,
		y,
		global.player.gender,
		currentSpriteFrame,
		_scale,
		playerAngleOffset,
		image_alpha,
		_skinColor,
		_hair,
		_armorId,
		_helmetId,
		_bagId,
		spriteXscale,
		_drawState
	);
}

setClosestObjectToCatch = function () {
    var closestObject = noone;
    var shortestDistance = undefined;

    var mousePosX = mouse_x;
    var mousePosY = mouse_y;
	
	for (var i = 0; i < array_length(global.interactableObjects); i ++) {
		var _object = global.interactableObjects[i];
		var _nearestItem = instance_nearest(x, y, _object);
		if (_nearestItem == noone) continue;
	
		var _distance = point_distance(x, y, _nearestItem.x, _nearestItem.y);
		if (_distance > global.minimalDistanceToCollect) continue;
    
		with (_object) {
	        var centerX = getMiddlePoint(bbox_left, bbox_right);
	        var centerY = getMiddlePoint(bbox_top, bbox_bottom);
	        var distanceToMouse = point_distance(mousePosX, mousePosY, centerX, centerY);

	        if (shortestDistance == undefined || distanceToMouse < shortestDistance) {
	            shortestDistance = distanceToMouse;
	            closestObject = id;
	        }
		}		
	}
	
    closestObjectToCatch = closestObject;
}

#endregion

function executeItemMethod(
	_item,
	_methodKey,
	_comingFromInventory = false,
	_inventory = global.inventory,
	_inventoryJ = 0,
	_inventoryI = 0
) {
	
	switch(_methodKey) {
		case "eat":
			eat(_item, _comingFromInventory, _inventory, _inventoryJ, _inventoryI)
		break;
		case "drink":
			drink(_item, _comingFromInventory, _inventory, _inventoryJ, _inventoryI);
		break;
		case "unload":
			unload(_item, _inventory, _inventoryJ, _inventoryI);
			break;
		case "equip": 
			addToToolBar(_inventory);
			break;
		case "use":
			use(_item, _comingFromInventory, _inventory, _inventoryJ, _inventoryI);
			break;
		case "dismantle":
			dismantle(_inventoryJ, _inventoryI);
			break;
	}
}

function use(_item, _comingFromInventory, _inventory, _j, _i) {
	var _data = global.consumableUsageData[_item.itemId];
	
	if (_item.consumableType == consumableTypes.health) {
		increaseHealth(_data.increaseValue);
	}
	
	audio_play_sound(_data.sound, 0, false);
	
	handleOtherEffects(_data.otherEffects);
	
	var _buff = getBuffByItemId(_item.itemId);
	
	if (_buff != false) {
		applyBuff(_buff);
	}
	
	handleKnownConsumableItemEffects(_item.itemId);
	
	if (!_comingFromInventory) return;
	handleCleanInventoryAfterConsuming(_item, _data, _j, _i, _inventory);
}

function eat(_item, _comingFromInventory, _inventory, _j, _i) {
	var _data = global.consumableUsageData[_item.itemId];
	decreaseHunger(_data.increaseValue);
	audio_play_sound(_data.sound, 0, false);
	handleOtherEffects(_data.otherEffects);
	var _buff = getBuffByItemId(_item.itemId);
	if (_buff != false) {
		applyBuff(_buff);
	}
	if (!_comingFromInventory) return;
	handleCleanInventoryAfterConsuming(_item, _data, _j, _i, _inventory);
}

function drink(_item, _comingFromInventory, _inventory, _j, _i) {
	var _data = global.consumableUsageData[_item.itemId];
	decreaseThirst(_data.increaseValue);
	audio_play_sound(_data.sound, 0, false);
	handleOtherEffects(_data.otherEffects);
	var _buff = getBuffByItemId(_item.itemId);
	if (_buff != false) {
		applyBuff(_buff);
	}
	if (!_comingFromInventory) return;
	handleCleanInventoryAfterConsuming(_item, _data, _j, _i, _inventory);
}

function handleKnownConsumableItemEffects(_id) {
	if (_id == consumableItems.bandage) {
		stopBleed();
	}
}

function dismantle(_j, _i) {
	dismantleItem(_j, _i, -1);
}

function applyBuff(_buff) {
	obj_player_buff_controller.applyBuff(_buff);
}

function stopBleed() {
	instance_destroy(obj_player_bleeding_handler);
	obj_player_buff_controller.removeBuffByBuffId(buffs.bleeding);
}

function handleOtherEffects(_otherEffects) {
	array_foreach(_otherEffects, function (_effect) {
		var _value = _effect.value;
		switch (_effect.type) {
			case otherEffectTypes.healthIncrease:
				increaseHealth(_value)
			break;
			case otherEffectTypes.healthDecrease:
				decreaseHealth(_value);
			break;
			case otherEffectTypes.thirstDecrease:
				decreaseThirst(_value);
			break;
			case otherEffectTypes.hungerDecrease:
				decreaseHunger(_value)
			break;
			case otherEffectTypes.staminaIncrease:
				increaseStamina(_value);
			break;
		}
	});
}


function handleCleanInventoryAfterConsuming(_item, _data, _j, _i, _inventory) {
	var _itemToDrop = _data.itemToDrop;
	
	if (_itemToDrop == noone && !_item.stackable){
		cleanInventoryGrid(_inventory, _j, _i);
		return true;
	}
		
	if (_itemToDrop == noone && _item.stackable) {
		_item.quantity --;
		if (_item.quantity < 1) {
			cleanInventoryGrid(_inventory, _j, _i);
		}
		return true;
	}
		
	if (_itemToDrop == noone) {
		cleanInventoryGrid(_inventory, _j, _i);
		return true;
	}
		
	_item.quantity --;
	
	if (_item.quantity < 1) {
		cleanInventoryGrid(_inventory, _j, _i);
	}
	
	if (_itemToDrop == undefined) return;
	var _consumedItem = getConsumedItem(_itemToDrop);
	
	var _added = addItemToGrid(_inventory, _consumedItem);
	if (_added != false) return true;
	createIndicatorForDroppedItems(_consumedItem, 1); 
	createItem(_consumedItem, true);
	return true;
}

function unload(_item, _inventory, _j, _i) {
	var _totalAmmo = _item.bullets;

	if (_totalAmmo == 0) {
		createNotifyIndicator("Sem munição", getMouseXGui(), getMouseYGui());
		return false;
	}

	_item.bullets = 0;

	var _ammo = global.weapons[_item.itemId].allowedAmmo;
	var _ammoItem = constructItem(itemType.ammo, global.items[itemType.ammo][_ammo]);

	_ammoItem.quantity = _totalAmmo;

	var _inventoryPosition = findCleanIndexFromInventory(_inventory, global.blankInventorySpace);
	audio_play_sound(_ammoItem.sound, 0, false);

	if (_inventoryPosition[0] == -1 || _inventoryPosition[1] == -1) {
		createIndicatorForDroppedItems(_ammoItem, _ammoItem.quantity);
		createItem(_ammoItem, true);
	}
	_inventory[# _inventoryPosition[0], _inventoryPosition[1]] =  _ammoItem;
}

function addToToolBar(_inventory){
	with(obj_inventory){
		addItemToToolBar(undefined, _inventory, selectedItem);
	}
}

function handlePause() {
	velh = 0;
	velv = 0;
}

function handleInteriors() {
	var _interior = instance_place(x, y, obj_interior);
	global.isInsideInterior = instance_exists(_interior);
	
	if (!global.isInsideInterior) return;
	_interior.fade();
}

function getGrabbed(_enemyId) {
	instance_create_layer(x, y, "Controllers", obj_grabbing_controller, {
		enemy: _enemyId
	});
	
	currentState = playerGetGrabbedState;
}