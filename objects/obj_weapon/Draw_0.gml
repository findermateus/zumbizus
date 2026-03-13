drawWeaponAiming();
drawState();

if(global.debug){
	draw_text(father.x, father.y, "State: " + script_get_name(currentState));
	draw_text(father.x, father.y + 30, "DrawState: " + script_get_name(drawState));
}