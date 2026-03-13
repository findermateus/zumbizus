if (global.timeStopped) {
	handlePause();
	exit;
}

loadInputs();
updateEquipedItems();
updateQuickUseBar();
currentState();
verticalColision();
horizontalColision();
handleStamina();
setClosestObjectToCatch();
audio_listener_position(x, y, 0);
handleInteriors();

global.player.currentThirst = clamp(global.player.currentThirst, 0, global.player.defaultTotalThirst);
global.player.currentHunger = clamp(global.player.currentHunger, 0, global.player.defaultTotalHunger);
global.player.stamina = clamp(global.player.stamina, 0, global.player.maxStamina);
global.player.health = clamp(global.player.health, 0, global.player.maxHealth);

if (keyboard_check_pressed(vk_right)) {
	if (global.player.gender == genders.male) {
		global.player.gender = genders.female
	} else {
		global.player.gender = genders.male;
	}	
}


var _keyUp = keyboard_check_pressed(vk_up);
var _keyDown = keyboard_check_pressed(vk_down);

if (_keyUp or _keyDown) {

	var _currentId = global.player.hair.hairId;
	
	var _totalOptions = array_length(global.hairOptions);

	var _move = _keyDown - _keyUp;

	var _newId = _currentId + _move;

	if (_newId >= _totalOptions) {
		_newId = 1;
	}
	
	if (_newId < 1) {
		_newId = _totalOptions - 1;
	}

	global.player.hair.hairId = global.hairOptions[_newId].hairId;
}

if (keyboard_check_pressed(vk_backspace)) {
	var _direction = irandom(365);
	var _damage = irandom(25);
	playerGetHit(_direction, _damage, irandom_range(5, 15));
}


if (keyboard_check_pressed(ord("U"))) {
	var _item = global.items[itemType.consumables][consumableItems.canned_food]
	createItem(constructItem(itemType.consumables, _item), true);
}