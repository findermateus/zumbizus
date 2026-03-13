event_inherited();

targetX = 0;
targetY = 0;
pathHandler = instance_create_layer(x, y, layer, obj_path_handler, { father: id })
scale = 2.2;
currentHealth = 30;

iddleTimeout = 0
animalId = animals.deer;
animalConfiguration = global.passiveAnimals[animalId];

lastHeardSoundX = 0;
lastHeardSoundY = 0;

var _spritesByGender = {
	"female": {
		iddle: spr_deer_female_iddle,
		walking: spr_deer_female_walking,
		eating: spr_deer_female_eating,
		running: spr_deer_female_running,
		dying: spr_deer_female_dying
	},
	"male": {
		iddle: spr_deer_male_iddle,
		walking: spr_deer_male_walking,
		eating: spr_deer_male_eating,
		running: spr_deer_male_running,
		dying: spr_deer_male_dying
	}
}

sprites = _spritesByGender[$ gender];

stateTimer = 0;

function switchState(_newState) {
    currentState = _newState;
    
    if (_newState == iddle) {
        changeSprite(sprites.iddle, scale, scale);
		loopAnimation = true;
        stateTimer = irandom_range(60, 180);
		
		return;
    } 
    
	if (_newState == wanderAround) {
        changeSprite(sprites.walking, scale, scale);
		loopAnimation = true
        chooseWanderDestination();
        
        return;
    }
	
	if (_newState == eat) {
		loopAnimation = false;
		changeSprite(sprites.eating, scale, scale);
		
		return;
	}
	
	if (_newState == runningAway) {
		changeSprite(sprites.running, scale, scale);
		loopAnimation = true;
		
		return;
	}
	
	if (_newState == dying) {
		changeSprite(sprites.dying, scale, scale);
		loopAnimation = false;
		
		instance_destroy(pathHandler);
		var _drop = animalConfiguration.drop;
		
		array_foreach(_drop, function (_itemConfig) {
			var _id = _itemConfig.id;
			var _type = _itemConfig.type;
			var _maxQuantity = _itemConfig.maxQuantity;
			
			var _quantity = irandom_range(1, _maxQuantity);
			
			var _item = global.items[_type][_id];
			
			for (var i = 0; i < _quantity; i++) {
				var _buildedItem = constructItem(_type, _item);
				_buildedItem.quantity = 1;
				createItemByObjectId(id, _buildedItem, true);
			}
		})
		return;
	}
}

function iddle() {
    if (stateTimer > 0) {
        stateTimer--;
		noticePlayer();
		return;
    }
    
	var _state = choose(wanderAround, iddle, eat);
	handlePositionWithPathHandler(true);
	switchState(_state);
}

function chooseWanderDestination() {
	var _radius = irandom_range(200, 600);
	var _angle = irandom(359);
	
	targetX = x + lengthdir_x(_radius, _angle);
	targetY = y + lengthdir_y(_radius, _angle);
	
	targetX = clamp(targetX, sprite_get_width(sprite_index) * scale, room_width);
	targetY = clamp(targetY, sprite_get_height(sprite_index) * scale, room_height);
}

function eat() {
	var _spriteLength = sprite_get_number(spriteToDraw);
	
	if (currentSpriteFrame == _spriteLength - 1) {
		switchState(iddle);
	}
}

function wanderAround() {
    var _result = pathHandler.calculatePath(
        animalConfiguration.iddleSpeed,
        targetX,
        targetY
    );
	
	if (point_distance(x, y, targetX, targetY) > 12) {
		if (abs(targetX - x) > 1) {
			directionToDraw = (targetX > x) ? 1 : -1;
			shadowDirection = directionToDraw;
		}
	}
	
	if (!_result) {
		chooseWanderDestination();
		pathHandler.calculatePath(
			animalConfiguration.iddleSpeed,
			targetX,
			targetY
		);
	}
	
	handlePositionWithPathHandler();
    
    var _dist = point_distance(x, y, targetX, targetY);
    if (_dist < 5) {
        switchState(iddle);
    }
	
	noticePlayer();
}

function runningAway() {
	var _result = pathHandler.calculatePath(
        animalConfiguration.runningSpeed,
        targetX,
        targetY
    );
	
	if (point_distance(x, y, targetX, targetY) > 12) {
		if (abs(targetX - x) > 1) {
			directionToDraw = (targetX > x) ? 1 : -1;
			shadowDirection = directionToDraw;
		}
	}
	
	if (!_result) {
		chooseRunningDestination(lastHeardSoundX, lastHeardSoundY);
		pathHandler.calculatePath(
			animalConfiguration.iddleSpeed,
			targetX,
			targetY
		);
	}
	
	handlePositionWithPathHandler();
    
    var _dist = point_distance(x, y, targetX, targetY);
    if (_dist < 10) {
        switchState(iddle);
    }
}

function handlePositionWithPathHandler(_shouldReset = false) {
	if (_shouldReset) {
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

function hearSound(_x, _y, _destinyRadius) {
    if (currentState == runningAway || currentState == dying) return;
	
	lastHeardSoundX = _x;
	lastHeardSoundY = _y;
	handlePositionWithPathHandler(true);
	chooseRunningDestination(_x, _y);
    
    switchState(runningAway);
}

function chooseRunningDestination(_soundX, _soundY) {
    var _minimalDistance = 1300;
    var _maxDistance = 2000; 
    var _escapeThreshold = 1000;
    
    var _radius = irandom_range(_minimalDistance, _maxDistance);
    var _baseAngle = point_direction(_soundX, _soundY, x, y);
    var _angle = _baseAngle + irandom_range(-30, 30);
    
    var _tX = _soundX + lengthdir_x(_radius, _angle);
    var _tY = _soundY + lengthdir_y(_radius, _angle);
    
    var _margin = sprite_get_width(sprites.walking) * scale;
    _tX = clamp(_tX, _margin, room_width - _margin);
    _tY = clamp(_tY, _margin, room_height - _margin);
    
    // 3. VERIFICAÇÃO DE ENCURRALAMENTO
    // Se a distância entre onde estou e onde posso chegar for menor que o limite
	var _maxAttempts = 20;
	var _attempts = 0;
	
    while (point_distance(x, y, _tX, _tY) < _escapeThreshold && _attempts < _maxAttempts) {
        var _panicAngle = irandom(359);
        
		_tX = x + lengthdir_x(_radius, _panicAngle);
        _tY = y + lengthdir_y(_radius, _panicAngle);
		
        _tX = clamp(_tX, _margin, room_width - _margin);
        _tY = clamp(_tY, _margin, room_height - _margin);
		
		_attempts++;
    }
    
    targetX = _tX;
    targetY = _tY;
}

function dying() {
	var _spriteLength = sprite_get_number(spriteToDraw) - 1;
	var _finishedAnimation = currentSpriteFrame == _spriteLength;
	
	if (!_finishedAnimation) return;
	
	
	directionToDraw = shadowDirection;
	alphaToDraw = lerp(alphaToDraw, 0, .08);
	
	currentSpriteFrame = sprite_get_number(spriteToDraw) - 1;
	
	if (alphaToDraw < .1) {
		instance_destroy(id);
	}
}

function getHit(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
	if (currentState == dying) return;
	
	addDamageToGuiList(x, y - sprite_get_height(spriteToDraw) * scale, _damage);
	screenShake(_damage);
	
	var _xMiddlePoint = getMiddlePoint(bbox_left, bbox_right);
	var _yMiddlePoint = getMiddlePoint(bbox_top, bbox_bottom);
	
	createBloodEffect(_force, _direction, _xMiddlePoint, _yMiddlePoint, _damage * 2);
	currentHealth -= _damage;
	
	if (currentHealth <= 0) {
		switchState(dying);
		
		return;
	}
	
	if (currentState != runningAway) {
		handlePositionWithPathHandler(true);
		switchState(runningAway);
	}
}

function noticePlayer () {
	if (!instance_exists(obj_player)) return;
	var _distanceToRunAway = 400;
	
	if (point_distance(x, y, obj_player.x, obj_player.y) <= _distanceToRunAway) {
		lastHeardSoundX = obj_player.x;
		lastHeardSoundY = obj_player.y;
		chooseRunningDestination(lastHeardSoundX, lastHeardSoundY);
    
		switchState(runningAway);
	}
}

switchState(iddle);

checkPlaceToExist();