if (!instance_exists(enemy)) {
    instance_destroy();
    exit;
}

obj_camera.setTargetWithZoom(obj_player);

obj_player.x = lerp(obj_player.x, enemy.x, 0.1); 
obj_player.y = lerp(obj_player.y, enemy.y, 0.1);

if (keyboard_check_pressed(vk_space) || mouse_check_button_pressed(mb_left)) {
    struggle_progress += struggle_power;
    
	juice_scale = 1.3;
    juice_shake = 4;
	
	screenShake(struggle_power / 2);
	
    obj_player.x += random_range(-2, 2);
}

struggle_progress = max(0, struggle_progress - struggle_decay);

if (struggle_progress >= struggle_target) {
    var _dir = point_direction(obj_player.x, obj_player.y, enemy.x, enemy.y);
    enemy.x += lengthdir_x(20, _dir);
    enemy.y += lengthdir_y(20, _dir);
    
	obj_camera.setDefaultScale();
    instance_destroy();
}

juice_scale = lerp(juice_scale, 1, 0.15);
juice_shake = lerp(juice_shake, 0, 0.1);
text_wave += 0.1;
