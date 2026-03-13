event_inherited();

enum npcStates {
	iddle,
	walkingWithoutDestiny,
	goingToWork,
	working
}

drawState = drawStates.iddle;
currentImageIndex = 0;
currentDialogue = noone;

function iddle() {
	state = npcStates.iddle;
	drawState = drawStates.iddle;
	
	handleNpcPositionWithPathHandler(true);
	handleAngleOffset(false);
	handleHover();
	updateWorkerData();

	if (irandom(100) < 2) {
		chooseWanderDestination();
		
		currentState = walkingWithoutDestiny;
	}
}

currentState = iddle;
state = npcStates.iddle;
currentSprite = spr_human_male_walking;
animationIndex = 0;
currentDirection = 1;
workerData = undefined;
furniture = false;
walkSpeed = irandom_range(3,5);
wanderSpeed = irandom_range(1, 2);
angleOffset = 0;
pathHandler = instance_create_layer(
	x, y,
	layer,
	obj_path_handler,
	{ father: id }
);
wanderTargetX = x;
wanderTargetY = y;
wanderTimer = 0;
wanderCooldown = irandom_range(60, 180);

function updateWorkerData() {
	workerData = workerId != -1 ? getWorkerData(workerId) : false;
	
	if (workerData != false) {
		handleWorkingStation();
	}
}

function getInstanceByObjectId(_objectId) {
	with(obj_furniture) {
		if (objectId == _objectId) return self;
	}
	
	return false;
}

angleTimer = 0;

function handleAngleOffset(_canJiggle, _speed = .3, _force = 3){
	if (!_canJiggle) {
		angleOffset = lerp(angleOffset, 0, 0.1);
		return;
	}
	
	angleTimer += 1;
	angleOffset = sin(angleTimer * _speed) * _force;
}

function handleWorkingStation() {
    var _newFurniture = getInstanceByObjectId(workerData.objectId);
    
    if (_newFurniture == false) {
        furniture = false;
        currentState = iddle;
        return;
    }
    
    var _isNewDestination = (furniture == false) || (furniture != _newFurniture);
    
    if (_isNewDestination) {
        furniture = _newFurniture;
        currentState = goingToWork;
    }
}

function goingToWork() {
	state = npcStates.goingToWork;
	drawState = drawStates.walking;

	handleAngleOffset(true, .2, 5);
	handleHover();

	if (furniture == false || !instance_exists(furniture)) {
		currentState = iddle;
		return;
	}

	var _positions = furniture.workerPositions[workerData.slot];

	var _destinyX = _positions.x;
	var _destinyY = _positions.y;

	pathHandler.calculatePath(
		walkSpeed,
		_destinyX,
		_destinyY
	);
	
	if (point_distance(x, y, _destinyX, _destinyY) > 12) {
		if (abs(_destinyX - x) > 1) {
			currentDirection = (_destinyX > x) ? 1 : -1;
		}
	}
	
	var _velh = _destinyX > x ? walkSpeed : -walkSpeed;
	var _velv = _destinyY > y ? walkSpeed : -walkSpeed;
	
	if (choose(0, 1)) {
		createWalkingParticles(x, y, _velh, _velv, 1);
	}
	
	handleNpcPositionWithPathHandler();

	if (point_distance(x, y, _destinyX, _destinyY) < 8) {
		onArriveAtWork();
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

function onArriveAtWork() {
	currentState = working;
	isHovering = false;
	
	if (instance_exists(pathHandler)) {
		with (pathHandler) {
			path_end();
		}
	}
}

function working() {
	state = npcStates.working;
	drawState = drawStates.iddle;
	handleAngleOffset(false);
	
	var _positions = furniture.workerPositions[workerData.slot];
	
	var _distance = point_distance(x, y, _positions.x, _positions.y);
	
	if (_distance > 12) {
		currentState = goingToWork;
	}
	
	updateWorkerData();
}

function chooseWanderDestination() {
	var _radius = irandom_range(900, 1200);
	var _angle = irandom(359);
	
	wanderTargetX = x + lengthdir_x(_radius, _angle);
	wanderTargetY = y + lengthdir_y(_radius, _angle);
	
	wanderTargetX = clamp(wanderTargetX, sprite_get_width(currentSprite), room_width);
	wanderTargetY = clamp(wanderTargetY, sprite_get_height(currentSprite), room_height);
}

function walkingWithoutDestiny() {
	state = npcStates.walkingWithoutDestiny;
	drawState = drawStates.walking;

	handleAngleOffset(true, .25, 4);
	handleHover();
	updateWorkerData();

	if (workerData != false) {
		currentState = goingToWork;
		return;
	}

	if (wanderTimer > wanderCooldown || point_distance(x, y, wanderTargetX, wanderTargetY) < 8) {
		wanderTimer = 0;
		wanderCooldown = irandom_range(200, 260);
		
		var _willWalk = choose(false, true, true);
		
		if (!_willWalk) {
			currentState = iddle;
			return;
		}
		
		handleNpcPositionWithPathHandler(true);
		chooseWanderDestination();
	}

	pathHandler.calculatePath(
		wanderSpeed,
		wanderTargetX,
		wanderTargetY
	);
	
	handleNpcPositionWithPathHandler();

	if (choose(0, 1)) {
		var _velh = currentDirection * wanderSpeed;
		createWalkingParticles(x, y, _velh, 0, 1);
	}
}

animationCurveItemDescription = animcurve_get_channel(ac_inventory,"item_description");
playedItemDescription = false;
curveAnimationIndex = 0;
isHovering = false;

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
	
	var _greetingOptions = [
	    "Olá!",
	    "Opa, tudo certo?",
	    "Aoba",
	    "BÃO?",
	    "Oi!",
	    "E aí!",
	    "Salve!",
	    "Fala!",
	    "Tá tudo em ordem?",
	    "Mais um dia por aqui...",
	    "Ainda estamos vivos!",
	    "Nada explodiu hoje.",
	    "Fica atento aí fora.",
	    "Não vacila lá fora.",
	    "Se ouvir barulho, corre."
	];

	var _greeting = pickRandomItemFromArray(_greetingOptions);

	if (!instance_exists(currentDialogue)) {
		currentDialogue = speakSimple(_greeting, id);
	}
}

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

updateWorkerData();

if (workerData == false || furniture == false) return;

var _positions = furniture.workerPositions[workerData.slot];

x = _positions.x;
y = _positions.y;
