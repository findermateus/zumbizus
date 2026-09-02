scale_x = lerp(scale_x, 1, 0.15);
scale_y = lerp(scale_y, 1, 0.15);
shake_power = max(0, shake_power - shake_decay);

if (isDying) {
    processDeath();
}

if (instance_exists(obj_player)) {
    var _isPlayerUnder = point_in_rectangle(obj_player.x, obj_player.y, x - sprite_xoffset, y - sprite_yoffset, x - sprite_xoffset + sprite_width, y - sprite_yoffset + sprite_height);
    image_alpha = lerp(image_alpha, _isPlayerUnder ? 0.2 : 1.0, 0.1);
}