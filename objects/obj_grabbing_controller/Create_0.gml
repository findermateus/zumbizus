struggle_progress = 0;
struggle_target = 100;
struggle_decay = 0.5;
struggle_power = 15;

juice_scale = 1;
juice_shake = 0;
text_wave = 0;
last_progress = 0;

blockPlayerMenus();

damage_interval = game_get_speed(gamespeed_fps) * 0.5; 
alarm[0] = damage_interval;