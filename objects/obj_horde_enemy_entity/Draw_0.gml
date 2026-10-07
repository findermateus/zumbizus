var _shakeX = getHitShakeOffset();
var _xScale = spriteXScale * hitScaleX;
var _yScale = abs(spriteXScale) * hitScaleY;

draw_sprite_ext(enemySprite, currentSpriteFrame, x + _shakeX, y, _xScale, _yScale, image_angle, c_white, image_alpha);
drawHitFlash(enemySprite, currentSpriteFrame, x + _shakeX, y, _xScale, _yScale, image_angle, c_white);

if (global.debug) {
	draw_text(x, y, "VELH: " + string(velh));
	draw_text(x, y + 30, "VELV: " + string(velv));
	draw_text(x, y + 60, "State: " + script_get_name(currentState));
}