shadowSurface = surface_create(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));

function drawShadow(_sprite, _frame, _x, _y, _direction = 1, _alpha = 1, _xScale = 1) {
	// 1. Aplicamos a escala na largura base do sprite
	var _spriteWidth = sprite_get_width(_sprite) * _xScale;
	
	// Mantive seus valores fixos de offset da segunda função
	var _shadowX = 10;
	var _shadowY = -30; 
	
	var cX = camera_get_view_x(view_camera[0]);
	var cY = camera_get_view_y(view_camera[0]);

	// 2. O cálculo agora usa a largura já escalada
	var leftX   = _x - (_spriteWidth / 2) - _shadowX - cX;
	var rightX  = _x + (_spriteWidth / 2) - _shadowX - cX;
	var topLeft = _x - (_spriteWidth / 2) - cX;
	var topRight= _x + (_spriteWidth / 2) - cX;

	// Inversão de direção (Horizontal Flip)
	if (_direction == -1) {
		var temp = leftX;
		leftX = rightX;
		rightX = temp;

		temp = topLeft;
		topLeft = topRight;
		topRight = temp;
	}
	
	var _drawAlpha = 1 * _alpha;
	
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
		_drawAlpha
	);
}

function setSurface() {
	if (!surface_exists(shadowSurface)) {
		shadowSurface = surface_create(camera_get_view_width(view_camera[0]), camera_get_view_height(view_camera[0]));
	}
	
	surface_set_target(shadowSurface);
}