scale_x = lerp(scale_x, 1, 0.15);
scale_y = lerp(scale_y, 1, 0.15);
shake_power = max(0, shake_power - shake_decay);

if (isDying) {
    processDeath();
}

var _inst_interior = instance_place(x, y, obj_interior);

if (_inst_interior != noone) {
    image_alpha = 1 - _inst_interior.alpha;
} else {
    image_alpha = 1;
}