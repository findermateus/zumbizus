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
alpha = 0;
animProgress = 0;
isInteracting = false;
alpha = 0;
animProgress = 0;

hover_offset1 = 0;
hover_offset2 = 0;
hover_offset3 = 0;

defaultGreetingOptions = [
	"Olá"
];

greetingOptions = defaultGreetingOptions;

canTrade = false;
isInteracting = false;

function canPlayerTalk() {
	return is_struct(getCurrentDialogue());
}

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
	
	if (canPlayerTalk()) {
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

menuId = Menus.NpcInteraction;

function getCurrentDialogue() {
	return noone;
}

function handleInteract(_options) {
	if (!array_length(_options)) {
		greet();
		
		return;
	}
	
	playSwiiimmmSound();
	openMenu(menuId);
	interactOptions = _options;
	activeInteraction = true;
}

function closeInteractOptions() {
	activeInteraction = false;
	if (global.activeMenu == menuId) closeMenu();
}

function handleNPCOption(option) {
	playClickSound();	
	isInteracting = true;
	switch (option) {

		case "talk":
			closeInteractOptions();

			instance_create_layer(0, 0, "Controllers", obj_dialogue, {
				target: id,
				dialogue: getCurrentDialogue()
			});
		break;

		case "trade":
			show_message("Negociando");
			//openTrade(npc);
		break;
	}
}

function draw_interaction_button(_sprite, _box_x, _box_y, _box_w, _box_h, _text_x, _text_y, _text, _halign, _alpha) {
    draw_sprite_stretched(_sprite, 0, _box_x, _box_y, _box_w, _box_h);
    
    draw_set_halign(_halign);
    drawTextShadow(_text_x, _text_y, _text, _alpha);
    draw_set_color(c_white);
    draw_text(_text_x, _text_y, _text);
}

function draw_ui_connection(_startX, _startY, _endX, _endY, _alpha) {
    var _old_color = draw_get_color();
    
    draw_set_color(c_white);
    draw_set_alpha(_alpha * 0.5);
    draw_line_width(_startX, _startY, _endX, _endY, 2);
    
    draw_set_alpha(_alpha * 0.8);
    draw_circle(_startX, _startY, 3, false);
    
    draw_set_color(_old_color);
    draw_set_alpha(_alpha);
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