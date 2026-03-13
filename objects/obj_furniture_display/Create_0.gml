imageColor = c_white;
isColiding = false;
isDisplaying = false;
ignoreId = noone;
display = {
	x: x,
	y: y
}
function setFurniture(_sprite){
	sprite_index = _sprite;
}

function setColor(){
	var _wallColision = place_meeting(x, y, obj_collision);
	var _furnitureColision = instance_place(x, y, obj_furniture);
	var _playerColision = place_meeting(x, y, obj_player);
	if (_furnitureColision == ignoreId) _furnitureColision = false;
	isColiding = _wallColision || _furnitureColision || _playerColision;
	imageColor = isColiding ? c_red : c_lime;
}

function setPosition() {
	var _gridSize = 32;
	var _x = floor(mouse_x / _gridSize) * _gridSize;
	var _y = floor(mouse_y / _gridSize) * _gridSize;
	x = _x;
	y = _y;
	var _lerpEffect = 0.2;
	display.x = lerp(display.x, x, _lerpEffect);
	display.y = lerp(display.y, y, _lerpEffect);
}


function drawFurniture(){
	if(!isDisplaying) return;
	draw_sprite_ext(sprite_index, 0, display.x, display.y, 1, 1, image_angle, c_white, .6);
	gpu_set_fog(true, imageColor, 0, 0);
	draw_sprite_ext(sprite_index, 0, display.x, display.y, 1, 1, image_angle, c_white, .6);
	gpu_set_fog(false, imageColor, 0, 0);
}