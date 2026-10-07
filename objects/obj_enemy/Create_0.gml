event_inherited();

gotWarned = false;
iwarned = false;
defeated = false;

pathHandler = instance_create_layer(x, y, layer, obj_path_handler, {
	father: id
});

function handlePositionWithPathHandler(_shouldReset = false){
	if (_shouldReset) {
		pathHandler.x = x;
		pathHandler.y = y;
		
		return;
	}
	
	var _speed = .1;
	
	if (point_distance(x, y, pathHandler.x, pathHandler.y) < attackDistance + 50) {
		_speed = .5
	}
	
	x = lerp(x, pathHandler.x, _speed);
	y = lerp(y, pathHandler.y, _speed);
}

function getKilled() {

}

function warnOtherEnemies() {
	if (gotWarned || iwarned) {
		return;
	}
	
	iwarned = true;
	
	var _radius = 250;
	var _instance = instance_create_layer(x, y, "Alert", obj_draw_circle_in_object, {
		father: id,
		radius: _radius
	});
	
	var _enemyList = ds_list_create();
	
	collision_circle_list(x, y, _radius, obj_enemy, false, true, _enemyList, false);
	
	for (var i = 0; i < ds_list_size(_enemyList); i ++) {
		_enemyList[| i].getWarned();
	}
	
	ds_list_destroy(_enemyList);
}

function getWarned() {

}

genericCollision = function(_positionX, _posititonY) {
	for(var i = 0; i < array_length(global.collidableObjects); i++){
		var _collidableObject = global.collidableObjects[i];
		var _col = instance_place(_positionX, _posititonY, _collidableObject);

		if (_col) return true;
	}

	return false;
}

#region
hitShakePower = 0;
hitShakeDecay = 0.25;
hitScaleX = 1;
hitScaleY = 1;

function applyHitShake() {
	hitShakePower = 5;
	hitScaleX = 1.2;
	hitScaleY = 0.6;
}

function updateHitShake() {
	hitScaleX = lerp(hitScaleX, 1, 0.15);
	hitScaleY = lerp(hitScaleY, 1, 0.15);
	hitShakePower = max(0, hitShakePower - hitShakeDecay);
}

function getHitShakeOffset() {
	return random_range(-hitShakePower, hitShakePower);
}
#endregion
