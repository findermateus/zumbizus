if (instance_exists(enemy) && !escaped) {
	var _direction = point_direction(enemy.x, enemy.y, obj_player.x, obj_player.y);
    obj_player.playerGetHit(_direction, 2, 0, damageType.blunt, false);

	ringShake = 8;
	redFlash = max(redFlash, .3);

    alarm[0] = damage_interval;
}
