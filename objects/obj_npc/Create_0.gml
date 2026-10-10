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
initBodyMotion();

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
	
	handleNpcPositionWithPathHandler();
	
	if (point_distance(x, y, destinyX, destinyY) < 16) {
		handleNpcPositionWithPathHandler(true);
		onArriveAtDestiny();
	}
}

function handleNpcPositionWithPathHandler(_shouldStop = false) {
	if (_shouldStop) {
		pathHandler.x = x;
		pathHandler.y = y;
		with (pathHandler) {
			path_end();
		}
		
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
	var _motion = getBodyMotionDraw(1);

	drawPersonBody(
		x,
		y + _motion.yOffset,
		genderId,
		_imageIndex,
		_motion.scaleY,
		angleOffset * .5 + _motion.angle,
		image_alpha,
		skinColor,
		new PersonHair(hairOption, hairColor),
		eyeId,
		outfitId,
		helmetId,
		bagId,
		_motion.direction,
		drawState
	);
}

minFollowDistance = 70;
maxFollowDistance = 75;
repathTimer = 0;
repathInterval = 12;

companionState = function() {
    var _targetToFollow = obj_player;
    
    if (!instance_exists(_targetToFollow)) {
        iddle();
        return;
    }
    
    if (isInteracting || activeInteraction) {
        drawState = drawStates.iddle;
        handleAngleOffset(false);
        handleNpcPositionWithPathHandler(true);
        return;
    }

    var _dist = point_distance(x, y, _targetToFollow.x, _targetToFollow.y);

    if (_dist <= minFollowDistance) {
        drawState = drawStates.iddle;
        handleAngleOffset(false);
        handleNpcPositionWithPathHandler(true);
        repathTimer = repathInterval;
        
		return;
    }
    
    if (_dist <= maxFollowDistance && drawState != drawStates.walking) {
		handleAngleOffset(false);
		handleNpcPositionWithPathHandler(true);
		
		return;
	}
	
    repathTimer++;

    if (repathTimer >= repathInterval) {
        repathTimer = 0;
        destinyX = _targetToFollow.x;
        destinyY = _targetToFollow.y;
            
        var _canWalk = pathHandler.calculatePath(walkSpeed, destinyX, destinyY);
        drawState = _canWalk ? drawStates.walking : drawStates.iddle;
    }

    if (drawState == drawStates.walking) {
        handleAngleOffset(true, .25, 4);
    } else {
        handleAngleOffset(false);
		handleNpcPositionWithPathHandler(true);
		
		return;
    }

    if (point_distance(x, y, destinyX, destinyY) > 12) {
        if (abs(destinyX - x) > 1) {
            currentDirection = (destinyX > x) ? 1 : -1;
        }
    }

    handleNpcPositionWithPathHandler();
}

function becomeCompanion() {
    currentState = companionState;
	
    global.activeCompanionPreset = presetId;
}

function removeCompanion() {
    currentState = iddle;
	
    global.activeCompanionPreset = "";
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

onFadeOutEnd = undefined;

function fadeOutState() {
	iddle();

	image_alpha = lerp(image_alpha, 0, .1);

	if (image_alpha < .1) {
		if (is_callable(onFadeOutEnd)) {
			onFadeOutEnd();
		}

		if (instance_exists(pathHandler)) {
			instance_destroy(pathHandler);
		}

		instance_destroy(id);
	}
}

isLeaving = false;
leaveTimer = 0;
maxLeaveTime = game_get_speed(gamespeed_fps) * 8;

function leaveTo(_x, _y, _onGone = undefined) {
	onFadeOutEnd = _onGone;
	isLeaving = true;
	leaveTimer = 0;

	setDestiny(_x, _y, function () {
		isLeaving = false;
		currentState = fadeOutState;
	});

	currentState = leavingState;
}

function leavingState() {
	goToDestiny();

	leaveTimer++;

	if (isLeaving && leaveTimer > maxLeaveTime) {
		isLeaving = false;
		currentState = fadeOutState;
	}
}