alphaDecrease = .3;
function checkInitialCollision(){
	if (instance_place(x, y, obj_collision)){
		x = obj_player.x;
		y = obj_player.y;
	}
}