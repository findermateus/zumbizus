event_inherited();
sprite_index = choose(spr_destroyed_car, spr_destroyed_car2);
yPositionToDrawShadow = bbox_bottom - 15;
image_index = irandom_range(0, sprite_get_number(sprite_index) - 1);
image_speed = 0;