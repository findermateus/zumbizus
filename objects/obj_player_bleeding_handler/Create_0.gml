tick_delay = game_get_speed(gamespeed_fps) * 2;

alarm[0] = tick_delay;

function handleDropBlood() {
	if (!instance_exists(obj_player)) return;
    if (global.player.health > global.player.maxHealth * .1) decreaseHealth(4);
	var _bloodQuantity = irandom_range(4, 9);
	repeat(_bloodQuantity) {
	    var _offsetX = irandom_range(-12, 12); 
	    var _offsetY = irandom_range(-10, 10); 
	    instance_create_layer(obj_player.x + _offsetX, obj_player.y + _offsetY, "Instances", obj_blood_splat);
	}
}