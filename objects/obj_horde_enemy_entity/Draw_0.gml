var _drawX = x + getHitOffsetX();
var _drawY = y + getHitOffsetY();
var _xScale = spriteXScale * hitScaleX;
var _yScale = abs(spriteXScale) * hitScaleY;
var _angle = image_angle + hitTilt;

draw_sprite_ext(enemySprite, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle, c_white, image_alpha);
drawHitTint(enemySprite, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle);
drawHitFlash(enemySprite, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle, c_white);
drawHitImpact();

if (global.debug) {
	draw_text(x, y, "VELH: " + string(velh));
	draw_text(x, y + 30, "VELV: " + string(velv));
	draw_text(x, y + 60, "State: " + script_get_name(currentState));
}
