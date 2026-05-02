event_inherited();

currentDialogue = noone;
angleOffset = 0;
drawState = drawStates.iddle;
currentImageIndex = 0;
currentSprite = spr_human_male_walking;
animationIndex = 0;
currentDirection = 1;
activeInteraction = false;
interactOptions = [];

greetingOptions = [
	"Olá"
];

function handleHover() {
	if(!verifyConditions()) {
		isHovering = false;
		return;
	}
	
	if (!isHovering) {
		curveAnimationIndex = 0;
		playHoverSound();
		isHovering = true;
		
		return;
	}
	
	if (!mouse_check_button_pressed(mb_left)) return;
	
	var _options = [];
	
	if (canTalk) {
		array_push(_options, {
			label: "Conversar",
			action: "talk"	
		});
	}
	
	if (canTrade) {
		array_push(_options, {
			label: "Negociar",
			action: "trade"
		});
	}
	
	handleInteract(_options);
}


function handleInteract(_options) {
	if (!array_length(_options)) {
		greet();
		
		return;
	}
	
	openMenu();
	interactOptions = _options;
	obj_camera.setTargetWithZoom(id);
	activeInteraction = true;
}

function closeInteractOptions() {
	closeMenu();
	
	if (!global.activeInventory) {
        obj_camera.setDefaultScale();
        obj_camera.target = obj_player;
    }
}

function handleNPCOption(option) {

	switch (option) {

		case "talk":
			show_message("Conversando");
			//startDialog(npc.dialog);
		break;

		case "trade":
			show_message("Negociando");
			//openTrade(npc);
		break;
	}
}

function greet() {
	var _greeting = pickRandomItemFromArray(greetingOptions);

	if (!instance_exists(currentDialogue)) {
		currentDialogue = speakSimple(_greeting, id);
	}
}

animationCurveItemDescription = animcurve_get_channel(ac_inventory,"item_description");
playedItemDescription = false;
curveAnimationIndex = 0;
isHovering = false;

drawInterface = function(){
	if(!isHovering) return;
	
	if(curveAnimationIndex>=1){
		curveAnimationIndex = 0;
		playedItemDescription = true;
	}
	
	curveAnimationIndex += (delta_time/1000000);
	
	var _curveLength = 25;
	var _textMarginFromSprite = 20;
	var _positionTransition = !playedItemDescription ? animcurve_channel_evaluate(animationCurveItemDescription, curveAnimationIndex) * _curveLength : 0;
	var _yPosition = (bbox_bottom + _textMarginFromSprite + string_height(name)) - _positionTransition;
	var _guiXPosition = roomToGuiX(bbox_left + (bbox_right - bbox_left) /2);
	var _guiYPosition = roomToGuiY(_yPosition);
	
	drawActionText(name, _guiXPosition, _guiYPosition);
}

function draw() {
	currentSprite = genderId == genders.female ? spr_human_female_walking : currentSprite;
	spriteToDrawShadow = currentSprite;
	
	var spriteLength = sprite_get_number(currentSprite);
	var spriteSpeed = sprite_get_speed(currentSprite) / 60;
	
	currentImageIndex  += spriteSpeed;
	currentImageIndex %= spriteLength;
	
	var _imageIndex = drawState == drawStates.iddle ? 0 : currentImageIndex;
	
	drawPersonBody(
		x,
		y,
		genderId,
		_imageIndex,
		1,
		angleOffset,
		image_alpha,
		skinColor,
		new PersonHair(hairOption, hairColor),
		outfitId,
		helmetId,
		backpack,
		currentDirection,
		drawState
	);
}