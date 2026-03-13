if(global.debug){
	if(keyboard_check(ord("P"))){
		mp_grid_draw(global.motionPlanningGrid);
	}
}

//if (position_meeting(mouse_x, mouse_y, obj_collision)){
//	if(mouse_check_button_released(mb_left)){
//		var _col = instance_nearest(mouse_x, mouse_y, obj_collision);
//		instance_destroy(_col);
//		calculateMotionPlanningGrid();
//	}
//}