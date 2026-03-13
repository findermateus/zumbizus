event_inherited();

function itemHorizontalColision(){
	var _collision = instance_place(x, y, obj_collision);
	if(!_collision) return;
	var _spriteWidth = sprite_get_width(sprite_index);
	if(place_meeting(bbox_left, y, _collision)){
		x = _collision.bbox_right + _spriteWidth/2; 
		return
	}
	if(place_meeting(bbox_right, y, _collision)){
		x = _collision.bbox_left - _spriteWidth/2;
		return;
	}
}
function itemVerticalCollision(){
	var _collision = instance_place(x, y, obj_collision);
    if (!_collision) return;
    var _spriteHeight = sprite_get_height(sprite_index);
    if (place_meeting(x, bbox_top, _collision)) {
        y = _collision.bbox_bottom + _spriteHeight / 2;
        return;
    }
    if (place_meeting(x, bbox_bottom, _collision)) {
        y = _collision.bbox_top - _spriteHeight / 2;
        return;
    }
}

function checkPlaceToExist(){
	if (!place_meeting(x, y, obj_collision)) return;
	var _spriteWidth = sprite_get_width(sprite_index) / 3;
	var _spriteHeight = sprite_get_height(sprite_index) / 3;
	var _angles = [
		0,
		45,
		90,
		135,
		180,
		225,
		270,
		315
	];
	while(instance_place(x, y, obj_collision)){
		for(var i = 0; i < array_length(_angles); i++){
			var _xDirection = lengthdir_x(_spriteWidth, _angles[i]);
			var _yDirection = lengthdir_y(_spriteHeight, _angles[i]);
			var _x = x + _xDirection;
			var _y = y + _yDirection;
			if (!instance_place(_x, _y, obj_collision)){
				x = _x;
				y = _y;
				return;
			}
		}
		_spriteWidth++;
		_spriteHeight++;
	}
	
}

checkPlaceToExist();
