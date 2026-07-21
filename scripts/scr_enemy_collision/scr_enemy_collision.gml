function enemyColision(_object){
	// Sempre resolve sobreposição, independente da velocidade atual
	if (place_meeting(x, y, _object)) {
		depenetrateFromCollision(_object);
	}
	
	if (velh == 0 && velv == 0) return;
	
	var _col = place_meeting(x + velh, y + velv, _object);
	if (!_col) return;
	
	handleEnemyHorizontalColision(_object);
	handleEnemyVerticalColision(_object);
	velh = 0;
	velv = 0;
}

function handleEnemyHorizontalColision(_object) {
	var _sign = sign(velh);
	if (_sign == 0) return;
	var _steps = ceil(abs(velh));
	for (var i = 0; i < _steps; i++) {
		if (!place_meeting(x + _sign, y, _object)) {
			x += _sign;
		} else {
			break;
		}
	}
}

function handleEnemyVerticalColision(_object) {
	var _sign = sign(velv);
	if (_sign == 0) return;
	var _steps = ceil(abs(velv));
	for (var i = 0; i < _steps; i++) {
		if (!place_meeting(x, y + _sign, _object)) {
			y += _sign;
		} else {
			break;
		}
	}
}

// Empurra o inimigo pra fora de qualquer sobreposição, testando as 4 direções
function depenetrateFromCollision(_object) {
	var _maxPush = 16;
	for (var dist = 1; dist <= _maxPush; dist++) {
		if (!place_meeting(x + dist, y, _object)) { x += dist; return; }
		if (!place_meeting(x - dist, y, _object)) { x -= dist; return; }
		if (!place_meeting(x, y + dist, _object)) { y += dist; return; }
		if (!place_meeting(x, y - dist, _object)) { y -= dist; return; }
	}
}