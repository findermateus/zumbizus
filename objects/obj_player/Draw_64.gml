var _screenWidth = display_get_gui_width();
var _screenHeight = display_get_gui_height();
drawGUIEquipedItem();
if(global.debug){
	var _debugInfo = [
		"State: " + string(script_get_name(currentState)),
		"Velh: " + string(velh) + ", Velv: " + string(velv),
		"Sprite: " + string(playerSprite),
		"Default Total Hunger: " + string(global.player.defaultTotalHunger),
		"Current Hunger: " + string(global.player.currentHunger),
		"Current Total Hunger: " + string(global.player.currentHunger),
		"Hunger: " + string(global.player.defaultTotalHunger),
	]
	var startY = 100;
	var offset = 40;
	draw_set_halign(fa_left);
	for (var i = 0; i < array_length(_debugInfo ); i++) {
	    draw_text(display_get_gui_width()/2, startY + (i * offset), _debugInfo[i]);
	}	
}