var _drawX = x + getHitOffsetX();
var _drawY = y + getHitOffsetY();
var _xScale = xscaleToDraw * directionToDraw * hitScaleX;
var _yScale = yscaleToDraw * hitScaleY;
var _angle = angleToDraw + hitTilt;

draw_sprite_ext(spriteToDraw, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle, colorToDraw, alphaToDraw);
drawHitTint(spriteToDraw, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle);
drawHitFlash(spriteToDraw, currentSpriteFrame, _drawX, _drawY, _xScale, _yScale, _angle, c_white);
drawHitImpact();
