var _residentData = getBaseResident(residentId);

if (is_struct(_residentData)) {
	name = _residentData.name;
	genderId = _residentData.genderId;
	skinColor = _residentData.skinColor;
	hairOption = _residentData.hairOption;
	hairColor = _residentData.hairColor;
	eyeId = _residentData.eyeId;
	outfitId = _residentData.outfitId;
	helmetId = _residentData.helmetId;
	bagId = _residentData.bagId;
} else {
	show_debug_message("AVISO: obj_npc_resident criado sem residente válido (residentId: " + string(residentId) + ")");
}

event_inherited();

canTalk = false;
canTrade = false;

enum npcStates {
	iddle,
	walkingWithoutDestiny,
	goingToWork,
	working
}

iddle = function() {
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

workerData = undefined;
furniture = false;
walkSpeed = irandom_range(3,5);
wanderSpeed = irandom_range(1, 2);
angleOffset = 0;

wanderTargetX = x;
wanderTargetY = y;
wanderTimer = 0;
wanderCooldown = irandom_range(60, 180);

greetingOptions = [
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

function updateWorkerData() {
	var _resident = getBaseResident(residentId);
	var _workplace = is_struct(_resident) ? _resident.workplace : undefined;

	workerData = is_struct(_workplace) ? _workplace : false;
	
	if (workerData != false) {
		handleWorkingStation();
	} else {
		furniture = false;
	}
}

function handleWorkingStation() {
	// Só procura a mobília de novo quando o local de trabalho muda ou a instância deixa de existir
	var _isSameFurniture = furniture != false
		&& instance_exists(furniture)
		&& furniture.objectId == workerData.objectId
		&& furniture.furnitureId == workerData.furnitureId;

	if (_isSameFurniture) return;

	var _newFurniture = getFurnitureInstance(workerData.furnitureId, workerData.objectId);

	if (_newFurniture == noone) {
		furniture = false;
		currentState = iddle;
		return;
	}

	furniture = _newFurniture;
	currentState = goingToWork;
}

function goingToWork() {
	state = npcStates.goingToWork;
	drawState = drawStates.walking;

	handleAngleOffset(true, .2, 5);
	handleHover();
	updateWorkerData();

	if (workerData == false || furniture == false || !instance_exists(furniture)) {
		furniture = false;
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
	
	handleNpcPositionWithPathHandler();

	if (point_distance(x, y, _destinyX, _destinyY) < 8) {
		onArriveAtWork();
	}
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

	updateWorkerData();

	if (workerData == false || furniture == false || !instance_exists(furniture)) {
		furniture = false;
		currentState = iddle;
		return;
	}

	var _positions = furniture.workerPositions[workerData.slot];

	var _distance = point_distance(x, y, _positions.x, _positions.y);

	if (_distance > 12) {
		currentState = goingToWork;
	}
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

	if (wanderTimer > wanderCooldown || point_distance(x, y, wanderTargetX, wanderTargetY) < 16) {
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

	var _result = pathHandler.calculatePath(
		wanderSpeed,
		wanderTargetX,
		wanderTargetY
	);
	
	if (!_result) {
		chooseWanderDestination();
	}
	
	handleNpcPositionWithPathHandler();
}

updateWorkerData();

if (workerData == false || furniture == false) exit;

var _positions = furniture.workerPositions[workerData.slot];

x = _positions.x;
y = _positions.y;
