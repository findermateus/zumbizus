var _pulse = sin(current_time * pulse_speed) * pulse_amount;
angle += angleSpeed;

var _scaleX = 1 + _pulse;
var _scaleY = 1 - _pulse;

draw_sprite_ext(
    sprite_index, 
    image_index, 
    x, 
    y, 
    _scaleX, 
    _scaleY, 
    angle,
    image_blend,
    image_alpha
);

gpu_set_blendmode(bm_add);
draw_sprite_ext(
    spr_slime_ball_blurr, 
    0, 
    x, 
    y, 
    _scaleX * 1.5, 
    _scaleY * 1.5,
    0,
    image_blend,
    .3
);
gpu_set_blendmode(bm_normal);