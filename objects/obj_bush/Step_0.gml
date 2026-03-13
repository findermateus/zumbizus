handleHover();
adjustObjectDepth();

handleDeath();

image_angle = lerp(image_angle, target_angle, lerp_speed);
image_yscale = lerp(image_yscale, target_yscale, lerp_speed);

var _targetX = is_dying ? 0 : base_scale + (base_scale - image_yscale) * 0.5;
image_xscale = lerp(image_xscale, _targetX, lerp_speed);

if (!is_dying && isHovering && mouse_check_button_pressed(mb_left)) {
    handleClickOnBush();
}