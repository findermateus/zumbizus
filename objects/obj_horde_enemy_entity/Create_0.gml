event_inherited();

enum states {
	unoccupied,
	walkRandomDirection,
	chasing,
	hit,
	dying,
	chasePoint,
	setUpAttack,
	attack,
	grabPlayer
}

timeToChangeStates = irandom(620);
defaultAcceleration = .1;
spriteXScale = 1;

enemySprite = sprite_index;

switchSprite = false;

currentSpriteFrame = 0;

spriteSpeed = sprite_get_speed(enemySprite);
spriteLength = sprite_get_number(enemySprite);

var _spriteList = [
	{
		iddle: spr_zombie1_iddle,
		running: spr_zombie1_running,
		death: spr_zombie1_death_hit,
		deathByShot: spr_zombie1_death_shot,
		deathByHit: spr_zombie1_death_hit
	},
	{
		iddle: spr_zombie2_iddle,
		running: spr_zombie2_running,
		death: spr_zombie2_death_hit,
		deathByShot: spr_zombie2_death_shot,
		deathByHit: spr_zombie2_death_hit
	}
];

sprites = _spriteList[irandom(array_length(_spriteList)-1)];
state = states.unoccupied;
maxIddleVel = 4;
chasingVel = irandom_range(maxIddleVel, maxIddleVel + 3);
distanceToChase = 500;
iddleDirection = 0;
iddleSpeed = 0;

#region combat
velh = 0;
velv = 0;
enemyHealth = 20;
fallDirection = 0;
pushForce = 0;
#endregion

#region chasePoint
destinyX = 0;
destinyY = 0;
soundX = 0;
soundY = 0;
radius = 0;
#endregion

#region attack
attackDistance = 80;
attackVel = 12;
attackVelh = 0
attackVelv = 0;
attackDirection = 0
#endregion

function adjustDirection(_hSpeed) {
	spriteXScale = _hSpeed != 0 ? sign(_hSpeed) : 1;
	shadowDirection = spriteXScale;
}

function updateSpriteWithState(_sprite, _state){
	if(state != _state){
		state = _state;
		switchSprite = true;
		currentSpriteFrame = 0;
		spriteToDrawShadow = _sprite;
	}
	enemySprite = _sprite;
	spriteLength = sprite_get_number(enemySprite);
	spriteSpeed = sprite_get_speed(enemySprite) / 60;
	currentSpriteFrame  += spriteSpeed;
	currentSpriteFrame %= spriteLength;
}

function enemyIddleState(){
	updateSpriteWithState(sprites.iddle, states.unoccupied);
	switchFromDifferentStatesWhenNotAttacking();
	handlePositionWithPathHandler(true);
	endPath();
}

function collisionWithEntities(){
	
}

function enemyChasePlayerState(){
	updateSpriteWithState(sprites.running, states.chasing);
	var _playerX = obj_player.x;
	var _playerY = obj_player.y;
	pathHandler.calculatePath(chasingVel, _playerX, _playerY);
	adjustDirection(pathHandler.currentDirection < x ? -1 : 1);
	handlePositionWithPathHandler();
	if (point_distance(x, y, _playerX, _playerY) < attackDistance) {
		currentState = setUpAttackState;
	}
}

function enemyWalkToRandomDirectionState() {
	switchFromDifferentStatesWhenNotAttacking();
	handlePositionWithPathHandler(true);
	if (state != states.walkRandomDirection) {
		iddleDirection = irandom(365);
		iddleSpeed = irandom(maxIddleVel);
	}
	updateSpriteWithState(sprites.running, states.walkRandomDirection);
	var _hMovementSpeed = lengthdir_x(iddleSpeed, iddleDirection);
	var _vMovementSpeed = lengthdir_y(iddleSpeed, iddleDirection);
	var _horizontalCollision = genericCollision(x + _hMovementSpeed, y)
	var _verticalCollision = genericCollision(x, y + _vMovementSpeed);
	adjustDirection(_hMovementSpeed);
	if (_horizontalCollision) {
		iddleDirection = 180 - iddleDirection;
	}
	if (_verticalCollision) {
		iddleDirection = 360 - iddleDirection;
	} 
	
	if (_horizontalCollision || _verticalCollision) return;
	
	x += _hMovementSpeed;
	y += _vMovementSpeed;
}

function checkCollision() {
	
}

function switchFromDifferentStatesWhenNotAttacking(){
	switchToChase();
	
	if(timeToChangeStates > 0) {
		timeToChangeStates --;
		return;
	}
	currentState = choose(enemyWalkToRandomDirectionState, enemyIddleState);
	timeToChangeStates = irandom(640);
}

function switchToChase(){
	if (!instance_exists(obj_player)) return;
	var _interior = instance_place(x, y, obj_interior)
	
	if (instance_exists(_interior)) {
		if (!_interior.hasFadeOut) return;
	}
	
	var _distanceToPlayer = point_distance(x, y, obj_player.x, obj_player.y);
	if(_distanceToPlayer > distanceToChase) return;
	if(collision_line(x, y, obj_player.x, obj_player.y, obj_collision, false, false)){
		return false;
	}
	warnOtherEnemies();
	currentState = enemyChasePlayerState;
}

function getKilledState(){
	var _shouldDie = false;
	velh = lerp(velh, 0, .1);
	velv = lerp(velv, 0, .1);
	endPath();
	if (state == states.dying && currentSpriteFrame + spriteSpeed > spriteLength - 1) {
		_shouldDie = true;
	}
	
	if (_shouldDie) {
		fadeOutOfExistence();
	} else {
		updateSpriteWithState(sprites.death, states.dying);
	}
}

function fadeOutOfExistence() {
	currentSpriteFrame = spriteLength - 1;
	image_alpha = lerp(image_alpha, 0, .03);
	if (image_alpha <= .2) instance_destroy(id);
}

function getHit(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
	if (state == states.dying || currentState == getKilledState) return;
	audio_play_sound(snd_enemy_hit, 0, false);
	enemyHealth -= _damage;
	
	if(_attackType) playWeaponEffectSound(_attackType);	
	
	addDamageToGuiList(x, y - sprite_get_height(enemySprite), _damage);
	
	if (enemyHealth <= 0) {
		if (_attackType == weaponTypes.shoot) sprites.death = sprites.deathByShot;
		createBloodEffect(_force * 2, _direction, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), _damage);
		getKilled();
	
		return;
	}
	
	createBloodEffect(_force, _direction, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), _damage);
	
	pushForce = _force;
	fallDirection = _direction;
	velh = lengthdir_x(pushForce, fallDirection);
	velv = lengthdir_y(pushForce, fallDirection);
	
	warnOtherEnemies();
	
	currentState = recoverFromGettingHitState;
}

function getKilled() {
	currentState = getKilledState;
	xpAdd(choose(1, 2, 3));
	var _shouldDropItem = choose(false, true);
	
	if (!_shouldDropItem) return false;
	
	var _trashThatCanBeDropped = [
		trashItems.empty_canned_fish,
		trashItems.empty_canned_food,
		trashItems.empty_watter_bottle
	];
	
	var _foodThatCanBeDropped = [
		consumableItems.dirt_water,
		consumableItems.canned_food
	];
	
	var _category = choose(itemType.consumables, itemType.trash, itemType.trash, itemType.trash);
	
	var _mappedItems = [];
	
	_mappedItems[itemType.consumables] = _foodThatCanBeDropped;
	_mappedItems[itemType.trash] = _trashThatCanBeDropped;
	
	var _availableItems = _mappedItems[_category]
	
	var _itemIndex = irandom(array_length(_availableItems) -1);
	
	var _item = constructItem(_category, global.items[_category][_itemIndex]);
	
	if (_item.stackable && _item.type != itemType.consumables){
		_item.quantity = irandom_range(1, _item.limit);
	}
	
	createItemByObjectId(id, _item, true);
}

function getWarned() {
	if (state == states.hit || state == states.dying) return;
	
	currentState = enemyChasePlayerState;
	
	gotWarned = true;
}

function endPath() {
	with (pathHandler) {
		path_end();
	}
}


function recoverFromGettingHitState(){
	endPath();
	handlePositionWithPathHandler(true);
	updateSpriteWithState(sprites.iddle, states.hit);
	
	velh = lerp(velh, 0, .07);
	velv = lerp(velv, 0, .07);
	if (abs(velh) < .5 && abs(velv) <.5) currentState = enemyChasePlayerState;
	x += velh;
	y += velv;
}

function chasePoint(){
	updateSpriteWithState(sprites.running, states.chasePoint);
		
	var _canWalk = pathHandler.calculatePath(chasingVel, destinyX, destinyY);
	
	adjustDirection(pathHandler.currentDirection < x ? -1 : 1);
	
	handlePositionWithPathHandler();
	switchToChase();
	if (!_canWalk) {
		currentState = enemyWalkToRandomDirectionState;
		return;
	}
}

function hearSound(_x, _y, _radius) {
	if (state != states.unoccupied && state != states.walkRandomDirection && state != states.chasePoint) {
		return;
	}
	var _useableRadius = _radius * .4;
    var _positions = getRandomPositionOnCircle(_x, _y, _radius * .6);
	if (_positions == false) return;
	destinyX = _positions[0]; destinyY = _positions[1];
	soundX = _x; soundY = _y;
	currentState = chasePoint;
}

function getRandomPositionOnCircle(_x, _y, _radius) {
	var max_attempts = 20;
    var target_x, target_y;

    for (var i = 0; i < max_attempts; i++) {
        var angle = random(360);
        var dist = sqrt(random(1)) * _radius;
        var dx = lengthdir_x(dist, angle);
        var dy = lengthdir_y(dist, angle);

        target_x = _x + dx;
        target_y = _y + dy;

        if (!position_meeting(target_x, target_y, obj_collision)) {
            return [target_x, target_y];
        }
    }
	return false;
}

function setUpAttackState() {
	hasHit = false;
	updateSpriteWithState(sprites.iddle, states.setUpAttack);
	var _playerX = getMiddlePoint(obj_player.bbox_left, obj_player.bbox_right);
	var _playerY = getMiddlePoint(obj_player.bbox_top, obj_player.bbox_bottom);
	var _attackDestinyX = _playerX;
	var _attackDestinyY = _playerY;
	var _direction = point_direction(x, y, _attackDestinyX, _attackDestinyY);
	velh = lengthdir_x(attackVel, _direction);
	velv = lengthdir_y(attackVel, _direction);
	attackDirection = _direction;
	currentState = attackState;
}

hasHit = false;

function grabPlayerState() {
	velh = 0;
	velv = 0;
	hasHit = false;
	updateSpriteWithState(sprites.iddle, states.grabPlayer);
	
	if (!instance_exists(obj_grabbing_controller)) {
		getHit(1, irandom(360), 10, weaponAttackType.swing, weaponItems.baseballBat);
	}
}

function attackState() {
	velh = lerp(velh, 0, .05);
	velv = lerp(velv, 0, .05);
	
	x += velh;
	y += velv;
	
	var _playerIsGrabbed = instance_exists(obj_grabbing_controller);
	
	if (!_playerIsGrabbed && !hasHit) {
		if (instance_place(x, y, obj_player)) {
			var _damage = irandom_range(12, 17);
			var _willGrab = choose(false, false, true);
			
			if (_willGrab) {
				obj_player.getGrabbed(id);
				hasHit = true;
				currentState = grabPlayerState;
				
				return;
			}
			
			obj_player.playerGetHit(attackDirection, _damage, 10, damageType.blunt);
			hasHit = true;
		}
	}	
	
	if (abs(velh) < .5 && abs(velv) < .5) {
		currentState = recoverFromGettingHitState;
	}
}

currentState = enemyWalkToRandomDirectionState;