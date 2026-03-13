event_inherited();

var _shakeX = random_range(-shake_power, shake_power);

draw_sprite_ext(
    sprite_index, 
    image_index, 
    x + _shakeX, 
    y, 
    image_xscale * tree_scale_x, 
    image_yscale * tree_scale_y, 
    fall_angle, 
    image_blend, 
    image_alpha
);

if (hit_flash > 0) {
    gpu_set_fog(true, c_white, 0, 0);
    
    draw_sprite_ext(
        sprite_index, 
        image_index, 
        x + _shakeX, 
        y, 
        image_xscale * tree_scale_x, 
        image_yscale * tree_scale_y, 
        fall_angle, 
        c_white, 
        hit_flash * 0.5 
    );
    
    gpu_set_fog(false, c_white, 0, 0);
}