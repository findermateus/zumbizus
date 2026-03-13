event_inherited();

function setPosition(){
	if (father == noone || ! instance_exists(father)){
		instance_destroy(id);
		return;
	};
	
	var _fatherWidth = sprite_get_width(father.sprite_index);
	var _fatherHeight = sprite_get_height(father.sprite_index);
	
	x = father.x + _fatherWidth/2;
	y = father.y + _fatherHeight/2;
}