function drawSpriteShadow(_x, _y, _sprite, _imageIndex, _angle, _xScale, _yScale, shadow_offset_x = 4, shadow_offset_y = 4, _alpha = draw_get_alpha()) {
    var shadow_color = c_black;
    var shadow_alpha = 0.5 * _alpha;

    drawSpriteWithGpuFog(
		shadow_color,
		_sprite,
		_imageIndex,
		_x + shadow_offset_x,
		_y + shadow_offset_y,
		_xScale,
		_yScale,
		_angle, 
		shadow_alpha
	);
}

function drawSpriteShadowStretched(_x, _y, _sprite, _imageIndex, _angle, _xSize, _ySize, shadow_offset_x = 4, shadow_offset_y = 4) {
	var shadow_color = c_black;
    var shadow_alpha = 0.5 * draw_get_alpha();

    drawSpriteWithGpuFogStretched(
		shadow_color,
		_sprite,
		_imageIndex,
		_x + shadow_offset_x,
		_y + shadow_offset_y,
		_xSize,
		_ySize,
		_angle, 
		shadow_alpha
	);
}

function addDamageToGuiList(_x, _y, _value){
	if (!instance_exists(obj_damage_controller)) return;
	with (obj_damage_controller) {
		var _damage = new Damage(_x, _y, _value);
		array_push(damageList, _damage);
	}
}