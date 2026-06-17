handleHover();
adjustObjectDepth();

handleDeath();

if (shake_timer > 0) {
	shake_timer--;

	var _progress = shake_timer / shake_duration;
	shake_offset_x = irandom_range(-shake_strength, shake_strength) * _progress;
	target_angle = irandom_range(-3, 3) * _progress;

	x = base_x + shake_offset_x;

	if (shake_timer <= 0) {
		x = base_x;
		shake_offset_x = 0;
		target_angle = 0;
	}
}

image_angle = lerp(image_angle, target_angle, lerp_speed);
image_yscale = lerp(image_yscale, target_yscale, lerp_speed);
image_xscale = lerp(image_xscale, target_xscale, lerp_speed);

if (!is_dying && isHovering && mouse_check_button_pressed(mb_left)) {
	handleClickOnTrashCan();
}