if (instance_exists(obj_weapon) && obj_weapon.currentState == obj_weapon.weaponIdleState) {
	var _backData = obj_weapon.getWeaponBackDrawData();
	
	if (_backData != noone) {
		draw_sprite_ext(
			_backData.sprite, 0,
			_backData.x, _backData.y,
			_backData.xscale, _backData.yscale,
			_backData.angle,
			c_white, _backData.alpha
		);
	}
}

drawPlayer();