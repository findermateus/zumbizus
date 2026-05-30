var _shakeX = 0;
var _shakeY = 0;
if (chargeAmount > 0.6) {
    _shakeX = random_range(-1.5, 1.5) * chargeAmount;
    _shakeY = random_range(-1.5, 1.5) * chargeAmount;
}

var _finalXScale = image_xscale * drawScaleX;

draw_sprite_ext(spriteToDrawShadow, currentSpriteFrame, x + _shakeX, y + _shakeY, _finalXScale, drawScaleY, 0, c_white, 1);

drawHitFlash(spriteToDrawShadow, currentSpriteFrame, x + _shakeX, y + _shakeY, _finalXScale, drawScaleY, image_angle, c_white);

var _color = #32CD32;

gpu_set_blendmode(bm_add);

var _blurAlpha = 0.2 + (0.4 * chargeAmount);

draw_sprite_ext(
    spr_spitter_blur,
    0,
    getMiddlePoint(bbox_left, bbox_right) + _shakeX,
    getMiddlePoint(bbox_top, bbox_bottom) + _shakeY,
    image_xscale * (1 + (chargeAmount * 0.2)),
    image_yscale * (1 + (chargeAmount * 0.2)),
    0,
    _color,
    _blurAlpha
);

gpu_set_blendmode(bm_normal);