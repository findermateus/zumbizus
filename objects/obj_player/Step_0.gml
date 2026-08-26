if (global.timeStopped) {
	handlePause();
	exit;
}

if (grabCooldownTimer > 0) {
    grabCooldownTimer--;
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

var _keyUp = keyboard_check_pressed(vk_up);
var _keyDown = keyboard_check_pressed(vk_down);
var _keyLeft = keyboard_check_pressed(vk_left);
var _keyRight = keyboard_check_pressed(vk_right);

if (_keyUp || _keyDown) {
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

if (_keyLeft || _keyRight) {
    var _currentEyeId = global.player.eyeId;
    var _totalEyeOptions = array_length(global.EYE_OPTIONS);
    
    var _moveEye = _keyRight - _keyLeft;
    var _newEyeId = _currentEyeId + _moveEye;

    if (_newEyeId >= _totalEyeOptions) {
        _newEyeId = 0;
    }
    
    if (_newEyeId < 0) {
        _newEyeId = _totalEyeOptions - 1;
    }
	
    global.player.eyeId = _newEyeId;
}

if (keyboard_check_pressed(ord("U"))) {
	var _item = global.items[itemType.consumables][consumableItems.canned_food]
	createItem(constructItem(itemType.consumables, _item), true);
}