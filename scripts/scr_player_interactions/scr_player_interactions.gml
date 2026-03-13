function setVisibilityByLineOfSight() {
	var _playerX = getMiddlePoint(obj_player.bbox_left, obj_player.bbox_right);
	var _playerY = getMiddlePoint(obj_player.bbox_top, obj_player.bbox_bottom);
	if(!collision_line(x, y, _playerX, _playerY, obj_collision, false, true)) {
		image_alpha = lerp(image_alpha, 1, .1);
		return;
	}
	image_alpha = lerp(image_alpha, 0, .05);
}