isRaining = false;

sys_rain_drops = part_system_create();
part_system_depth(sys_rain_drops, -9999);

sys_rain_splashes = part_system_create();
part_system_depth(sys_rain_splashes, 100);

part_drop = part_type_create();
part_type_shape(part_drop, pt_shape_line);
part_type_size(part_drop, 0.2, 0.5, 0, 0);
part_type_orientation(part_drop, 0, 0, 0, 0, true);
part_type_color1(part_drop, c_white);
part_type_alpha2(part_drop, 0.6, 0.1);
part_type_speed(part_drop, 12, 18, 0, 0);
part_type_direction(part_drop, 250, 260, 0, 0);
part_type_life(part_drop, 30, 40);

part_splash = part_type_create();
part_type_sprite(part_splash, spr_rain_splash, true, true, false);
//part_type_size(part_splash, 0.8, 1.2, 0, 0);
part_type_alpha2(part_splash, 0.8, 0);
part_type_life(part_splash, 15, 20);

function updateRainChance(_chance) {
 isRaining = (random(100) <= _chance);
}