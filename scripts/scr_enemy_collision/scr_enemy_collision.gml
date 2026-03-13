function enemyColision(_object){
	var _dir = velh;
	var _col = place_meeting(x + velh, y + velv, _object);
	if (!_col) return;
	handleEnemyHorizontalColision(_object);
	handleEnemyVerticalColision(_object);
	velh = 0;
	velv = 0;
}

function handleEnemyHorizontalColision(_object) {
	for (var i = 0; i < abs(velh); i ++) {
		if (!place_meeting(x + 1, y, _object)) {
			x ++;
			continue
		}
		return;
	}
}

function handleEnemyVerticalColision(_object) {
	for (var i = 0; i < abs(velv); i ++) {
		if (!place_meeting(x, y + 1, _object)) {
			y ++;
			continue
		}
		return;
	}
}