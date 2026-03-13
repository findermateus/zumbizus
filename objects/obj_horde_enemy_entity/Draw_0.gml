draw_sprite_ext(enemySprite, currentSpriteFrame, x, y, spriteXScale, abs(spriteXScale), image_angle, c_white, image_alpha);
if(global.debug){
	draw_text(x + 20, y, script_get_name(currentState))
	draw_text(x + 20, y + 30, enemyHealth);
	draw_text(x + 20, y + 60, "Frame: " + string(currentSpriteFrame));
	draw_text(x + 20, y + 90, "Sprite Length: " + string(spriteLength));
	draw_text(x + 20, y + 120, "Sprite Speed: " + string(spriteSpeed));
	draw_text(x + 20, y + 160, "Xscale: " + string(spriteXScale));
}

if (position_meeting(mouse_x, mouse_y, id)) {
	draw_text(x, y, iddleDirection);
	draw_text(x, y+ 30, iddleSpeed);
}