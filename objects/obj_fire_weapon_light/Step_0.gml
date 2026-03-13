event_inherited();

alpha = lerp(alpha, 0, .1);
range = lerp(range, destinyRange, .05);
uls_set_light_range(id, range);
uls_set_light_alpha(id, alpha);

if (alpha <= .05) instance_destroy(id);