event_inherited();

#region PARTICLE SYSTEM
if (!variable_global_exists("partSystem")) {
    global.partSystem = part_system_create();
    part_system_depth(global.partSystem, -9999);
}

global.partTypeSlimeSplatter = part_type_create();

// USA O SEU SPRITE DE PIXEL AQUI!
part_type_sprite(global.partTypeSlimeSplatter, spr_pixel, false, false, false);

part_type_scale(global.partTypeSlimeSplatter, 6, 6);

part_type_color_mix(global.partTypeSlimeSplatter, #32CD32, #228B22);

part_type_alpha2(global.partTypeSlimeSplatter, 1, 0);

part_type_direction(global.partTypeSlimeSplatter, 0, 360, 0, 0);

part_type_speed(global.partTypeSlimeSplatter, 2, 6, -0.15, 0);

part_type_gravity(global.partTypeSlimeSplatter, 0.2, 270);

part_type_orientation(global.partTypeSlimeSplatter, 0, 360, random_range(-5, 5), 0, false);

part_type_life(global.partTypeSlimeSplatter, 30, 60);
#endregion

attackDistance = 900;
distanceToAttack = 900;
fleeDistance = 175;
attackCooldown = 90;
attackTimer = 0;
spriteToDrawShadow = sprite_index
targetX = x;
targetY = y;
spriteSpeed = 0
currentHealth = 15;

sprites = {
	iddle: spr_spitter_iddle,
	running: spr_spitter_running
};

function updateSprite(_sprite) {
	spriteToDrawShadow = _sprite;
	currentSpriteFrame = 0;
	spriteSpeed = sprite_get_speed(_sprite);
}

updateSprite(sprites.iddle);

function spitterIddle() {
	handlePositionWithPathHandler(true);
	switchToAttack();
}

function attackPlayer() {
    if (!instance_exists(obj_player)) {
        currentState = spitterIddle;
        return;
    }
	handlePositionWithPathHandler(true);
    image_xscale = (obj_player.x > x) ? 1 : -1;
	shadowDirection = image_xscale;
	var _dist = point_distance(x, y, obj_player.x, obj_player.y);

	if (_dist < fleeDistance) {
		updateSprite(sprites.running);
		chooseFleeDestination();
		currentState = runAway;
		
		return;
	}

    if (attackTimer > 0) {
        attackTimer--;
		
		return;
    }
    
	var _dir = point_direction(x, y, obj_player.x, obj_player.y);
        
	var _x = getMiddlePoint(bbox_left, bbox_right);
	var _y = getMiddlePoint(bbox_top, bbox_bottom);
		
    var _slime = instance_create_layer(_x, _y, "Instances", obj_spitter_spit, {
		direction: _dir
	});

    if (instance_exists(obj_player_sound_controller)) {
        obj_player_sound_controller.addSound(120, _x, _y, soundIntensity.standard, id);
    }

    attackTimer = attackCooldown;

    var _wall = collision_line(x, y, obj_player.x, obj_player.y, obj_collision, false, false);

    if (_dist > distanceToAttack + 100 || _wall) {
        currentState = spitterIddle;
    }
}

function chooseFleeDestination() {
    var _player = obj_player;
	handlePositionWithPathHandler(true);
    if (!instance_exists(_player)) return;

    var _attempts = 0;
    var _found = false;
    
    while (_attempts < 3 && !_found) {
        var _radius = irandom_range(400, 600); 
        var _baseAngle = point_direction(_player.x, _player.y, x, y);
        var _angle = _baseAngle + irandom_range(-45, 45);
        
        var _tX = x + lengthdir_x(_radius, _angle);
        var _tY = y + lengthdir_y(_radius, _angle);
        
        _tX = clamp(_tX, 64, room_width - 64);
        _tY = clamp(_tY, 64, room_height - 64);

        if (!position_meeting(_tX, _tY, obj_collision)) {
            targetX = _tX;
            targetY = _tY;
            _found = true;
        }
        _attempts++;
    }
}

function runAway() {
    var _runningSpeed = 4;
    
    var _result = pathHandler.calculatePath(_runningSpeed, targetX, targetY);
    
	if (!_result) {
		handlePositionWithPathHandler(true);
		chooseFleeDestination();
		
		pathHandler.calculatePath(_runningSpeed, targetX, targetY);
	}
	
	handlePositionWithPathHandler();

    if (abs(pathHandler.x - x) > 1) {
        image_xscale = (pathHandler.x > x) ? 1 : -1;
        shadowDirection = image_xscale;
    }

    var _distToTarget = point_distance(x, y, targetX, targetY);
    
    if (_distToTarget < 20) {
        currentState = attackPlayer;
    }
}

function getWarned() {
	currentState = attackPlayer;
	
	gotWarned = true;
}

function switchToAttack(){
	if (!instance_exists(obj_player)) return;
	
	var _interior = instance_place(x, y, obj_interior)
	
	if (instance_exists(_interior)) {
		if (!_interior.hasFadeOut) return;
	}
	
	var _distanceToPlayer = point_distance(x, y, obj_player.x, obj_player.y);
	
	if(_distanceToPlayer > distanceToAttack) return;
	
	if(collision_line(x, y, obj_player.x, obj_player.y, obj_collision, false, false)){
		return false;
	}
	
	warnOtherEnemies();
	updateSprite(sprites.iddle);
	currentState = attackPlayer;
}

function getKilled(_force, _direction, _damage) {
	createBloodEffect(_force, _direction, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), 50);
	
	if (instance_exists(obj_player_sound_controller)) {
	    obj_player_sound_controller.addSound(150, x, y, soundIntensity.high);
	}

	if (variable_global_exists("partSystem") && variable_global_exists("partTypeSlimeSplatter")) {
	    var _qtd = irandom_range(100, 125);
	    part_particles_create(global.partSystem, x, bbox_top, global.partTypeSlimeSplatter, _qtd);
	}
	
	screenShake(25);
	
	instance_destroy(id);
}

function getHit(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
	
	audio_play_sound(snd_enemy_hit, 0, false);
	currentHealth -= _damage;
	
	if(_attackType) playWeaponEffectSound(_attackType);	
	
	addDamageToGuiList(x, y - sprite_get_height(spriteToDrawShadow), _damage);
	
	if (currentHealth <= 0) {
		getKilled(_force, _direction, _damage);
	
		return;
	}
	
	createBloodEffect(_force, _direction, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), _damage);

	warnOtherEnemies();
}

currentState = spitterIddle;