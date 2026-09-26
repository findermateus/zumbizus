event_inherited();

hitFlash = 0;

function drawHitFlash(_sprite, _index, _x, _y, _xscale, _yscale, _angle, _color) {
	hitFlash = max(0, hitFlash - 0.1);
	
	if (hitFlash <= 0) return;
	
    gpu_set_fog(true, c_white, 0, 0);
    draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, _angle, _color, hitFlash);
    gpu_set_fog(false, c_white, 0, 0);
}

function getHit(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
}