shadowSurface = surface_create(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));

function drawShadow(_sprite, _frame, _x, _y, _direction = 1, _alpha = 1, _xScale = 1, _yScale = 1) {
	var _spriteWidth = sprite_get_width(_sprite) * _xScale;
	var _spriteHeight = sprite_get_height(_sprite) * _yScale;
	
	var _shadowHeightFactor = 0.5; 
	var _shadowY = -(_spriteHeight * _shadowHeightFactor);
	
	var _shadowX = 0;
	
	var cX = camera_get_view_x(view_camera[0]);
	var cY = camera_get_view_y(view_camera[0]);

	var leftX   = _x - (_spriteWidth / 2) - _shadowX - cX;
	var rightX  = _x + (_spriteWidth / 2) - _shadowX - cX;
	var topLeft = _x - (_spriteWidth / 2) - cX;
	var topRight= _x + (_spriteWidth / 2) - cX;

	if (_direction == -1) {
		var temp = leftX;
		leftX = rightX;
		rightX = temp;

		temp = topLeft;
		topLeft = topRight;
		topRight = temp;
	}
	
	draw_sprite_pos(
		_sprite,
		_frame,
		leftX,
		_y - _shadowY - cY,
		rightX,
		_y - _shadowY - cY,
		topRight,
		_y - cY,
		topLeft,
		_y - cY,
		_alpha
	);
}

function setSurface() {
	if (!surface_exists(shadowSurface)) {
		shadowSurface = surface_create(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
	}
	
	surface_set_target(shadowSurface);
}