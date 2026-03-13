event_inherited();
destinyRange = range + 30;
alpha = .7;
flash_timer = 0.1;
uls_set_light_color(id, #FFD700);

uls_set_light_range(id, range);
uls_set_light_alpha(id, alpha);

if (alpha <= 0) {
	instance_destroy(id);
}