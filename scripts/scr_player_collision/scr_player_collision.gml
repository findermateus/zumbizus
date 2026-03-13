function horizontalColision(){
	for(var i = 0; i < array_length(global.collidableObjects); i++){
		var _col = instance_place(x + velh, y, global.collidableObjects[i]);
		var _dir = velh;
		if(_col){
			velh = 0;
			x = _dir > 0 ? _col.bbox_left - sprite_width/2 : _col.bbox_right + sprite_width/2;
		}
	}
}
function verticalColision(){
	for(var i = 0; i < array_length(global.collidableObjects); i++){
		var _col = instance_place(x, y + velv, global.collidableObjects[i]);
		var _dir = velv;
		if(_col){
			velv = 0;
			y = _dir > 0 ? _col.bbox_top : _col.bbox_bottom + 22;
		}
	}
}