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

bubble_scale = 0;
bubble_alpha = 0;
was_near = false;

hover_offset1 = 0;
hover_offset2 = 0;
hover_offset3 = 0;

defaultGreetingOptions = [
	"Olá"
];

greetingOptions = defaultGreetingOptions;

canTrade = false;
tradeItems = [];

isInteracting = false;

walkSpeed = irandom_range(3,5);

pathHandler = instance_create_layer(
	x, y,
	layer,
	obj_path_handler,
	{ father: id }
);

destinyX = x;
destinyY = y;

angleTimer = 0;

function handleAngleOffset(_canJiggle, _speed = .3, _force = 3){
	if (!_canJiggle) {
		angleOffset = lerp(angleOffset, 0, 0.1);
		return;
	}
	
	angleTimer += 1;
	angleOffset = sin(angleTimer * _speed) * _force;
}

iddle = function() {
	drawState = drawStates.iddle;
	handleAngleOffset(false);
}

currentState = iddle;

onArriveAtDestiny = function() {
	currentState = iddle;
}

function setDestiny(_x, _y, _onArrive, _walkSpeed = walkSpeed) {
	destinyX = _x;
	destinyY = _y;
	onArriveAtDestiny = _onArrive;
	walkSpeed = _walkSpeed;
	
	currentState = goToDestiny;
}

function goToDestiny() {
	handleAngleOffset(true, .25, 4);
	drawState = drawStates.walking;
	
	pathHandler.calculatePath(
		walkSpeed,
		destinyX,
		destinyY
	);
	
	if (point_distance(x, y, destinyX, destinyY) > 12) {
		if (abs(destinyX - x) > 1) {
			currentDirection = (destinyX > x) ? 1 : -1;
		}
	}
	
	var _velh = destinyX > x ? walkSpeed : -walkSpeed;
	var _velv = destinyY > y ? walkSpeed : -walkSpeed;
	
	if (choose(0, 1)) {
		createWalkingParticles(x, y, _velh, _velv, 1);
	}
	
	handleNpcPositionWithPathHandler();
	
	if (point_distance(x, y, destinyX, destinyY) < 16) {
		onArriveAtDestiny();
	}
}

function handleNpcPositionWithPathHandler(_shouldStop = false) {
	if (_shouldStop) {
		pathHandler.x = x;
		pathHandler.y = y;
		
		return;
	}
	
	var _speed = 0.08;

	if (point_distance(x, y, pathHandler.x, pathHandler.y) < 32) {
		_speed = 0.3;
	}

	x = lerp(x, pathHandler.x, _speed);
	y = lerp(y, pathHandler.y, _speed);
}

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

	if (array_length(_options) == 1) {
		handleNPCOption(_options[0].action);
		return;
	}
	
	playSwiiimmmSound();
	openMenu(menuId);
	interactOptions = _options;
	activeInteraction = true;
}

function closeInteractOptions() {
	activeInteraction = false;
	if (isCurrentMenu(menuId)) closeMenu();
}

function handleNPCOption(option) {
	if (isInteracting) return;

	playClickSound();	
	
	switch (option) {

		case "talk":
			var _dialogue = getCurrentDialogue();

			if (!is_struct(_dialogue)) return;

			isInteracting = true;
			closeInteractOptions();

			instance_create_layer(0, 0, "Controllers", obj_dialogue, {
				target: id,
				dialogue: _dialogue
			});
		break;

		case "trade":
			if (!canTrade) return;
			if (isInteracting) return;

			isInteracting = true;
			closeInteractOptions();

			instance_create_layer(0, 0, "Controllers", obj_trade_menu, {
				target: id
			});
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
		eyeId,
		outfitId,
		helmetId,
		bagId,
		currentDirection,
		drawState
	);
}

if (presetId != "") {    
    if (variable_struct_exists(global.npcPresets, presetId)) {
        
        var _preset = global.npcPresets[$ presetId];
        
        name = _preset.name;
        genderId = _preset.genderId;
        skinColor = _preset.skinColor;
        hairOption = _preset.hairOption;
        hairColor = _preset.hairColor;
		eyeId = _preset.eyeId;
		
		outfitId = _preset.outfitId;
		bagId = _preset.bagId;
		helmetId = _preset.helmetId;
		
        
    } else {
        show_debug_message("AVISO: Preset de NPC '" + presetId + "' não encontrado no banco de dados!");
    }
}

function fadeOutState() {
	iddle();
						
	image_alpha = lerp(image_alpha, 0, .1);
						
	if (image_alpha < .1) {
		instance_destroy(id);
	}
}