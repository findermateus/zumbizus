event_inherited();
item = undefined;
itemScale = 1;
textEffect = "wave"
function defineItem(_itemType = undefined, _itemIndex = undefined){
	if (_itemType == undefined || _itemIndex == undefined){
		_itemType = choose(itemType.consumables, itemType.trash, itemType.weapons, itemType.ammo, itemType.equipment);
		//_itemType = itemType.trash;
		var _itemIndexMax = array_length(global.items[_itemType]) -1;
		_itemIndex = irandom(_itemIndexMax);
	}
	item = constructItem(_itemType, global.items[_itemType][_itemIndex]);
	if (item.stackable && item.type != itemType.consumables){
		item.quantity = irandom_range(1, item.limit);
	}
	image_index = item.sprite;
}
defineItem();

curveAnimationIndex = 0;
angle = random_range(90, -90);
#region behaviours

animationCurveItemDescription = animcurve_get_channel(ac_inventory,"item_description");
playedItemDescription = false;
drawInterface = function(){
	if(currentState != active) return;
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		playedItemDescription = true;
	}
	var _spriteHeight = sprite_get_height(item.sprite);
	curveAnimationIndex += (delta_time/1000000);
	var _curveLength = 25;
	var _textMarginFromSprite = 30;
	var _positionTransition = !playedItemDescription ? animcurve_channel_evaluate(animationCurveItemDescription, curveAnimationIndex) * _curveLength : 0;
	var _yPosition = (y + (_spriteHeight/2) + _textMarginFromSprite) - _positionTransition;
	var _guiXPosition = roomToGuiX(x);
	var _guiYPosition = roomToGuiY(_yPosition);
	var _quantity = "";
	if(item.stackable){
		if(item.quantity > 1) _quantity = "(x" + string(item.quantity) + ") ";
	}
	var _text = _quantity + item.name;
	drawActionText(_text, _guiXPosition, _guiYPosition);
}
#endregion

#region states
itemDescriptionAlarmSet = false;
function innactive(){
	if(!verifyConditions()) return;
	curveAnimationIndex = 0;
	playHoverSound();
	currentState = active;
}

function active(){
	if(!verifyConditions()) currentState = innactive;
	if(!mouse_check_button_pressed(mb_left)) return;
	playClickSound();
	var _result = getCollected();
	if(_result != false){
		if (_result == true) instance_destroy(id);
		var _quantity = variable_struct_exists(item, "quantity") ? item.quantity : 1;
		createIndicatorModal(item, _result != true ? _result : _quantity);
		audio_play_sound(item.sound, 0, false);
		return;
	}
	var _alert = instance_create_layer(x, y, "Alert", obj_alert, {
		y: (y - sprite_get_height(item.sprite) - 32)
	});
	_alert.textAlert = "Inventário cheio!";
	playFailSound();
	curveAnimationIndex = 0;
	currentState = inventoryFull;
}


animationCurveInventoryFull = animcurve_get_channel(ac_inventory,"inventory_full");
function inventoryFull(){
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		currentState = innactive;
	}
	curveAnimationIndex += (delta_time/1000000);
	x += animcurve_channel_evaluate(animationCurveInventoryFull, curveAnimationIndex) * 2;
}

function getCollected(){
	return addItemToGrid(global.inventory, item);
}

bounceAnimation = animcurve_get_channel(ac_item, "bounce");
bounceAnimIndex = 0;
isBouncing = false;
bounceDuration = 1;
yOriginal = y;
bounceDirection = choose(1, -1);
bounceDistance = 40;
bounceHeight = 30;
bounceHSpeed = 1;

function createdWithBounce() {
    if (isBouncing) return;
    isBouncing = true;
    bounceAnimIndex = 0;
	bounceDirection = choose(1, -1);
	bounceHSpeed = irandom_range(4, 10);
}

function handleBounce() {
    if (!isBouncing) return;

    bounceAnimIndex += delta_time / 1000000 / bounceDuration;

    if (bounceAnimIndex >= 1) {
        bounceAnimIndex = 1;
        isBouncing = false;
    }

    var curveVal = animcurve_channel_evaluate(bounceAnimation, bounceAnimIndex);

    y = yOriginal + (curveVal * bounceHeight);
	
	if (instance_place(x + sign(bounceDirection) * bounceHSpeed, y, obj_collision)) {
		bounceDirection *= -1;
	}
	
	x += sign(bounceDirection) * bounceHSpeed;
	bounceHSpeed = lerp(bounceHSpeed, 0, .1);
    if (!isBouncing) {
        y = yOriginal;
    }
}

function stayInRoom(){
	x = clamp(x, 0, room_width);
	y = clamp(y, 0, room_height);
}

currentState = innactive;
#endregion