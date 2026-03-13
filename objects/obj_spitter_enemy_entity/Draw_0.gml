draw_sprite_ext(spriteToDrawShadow, currentSpriteFrame, x, y, image_xscale, image_yscale, 0, c_white, 1);

var _color = #32CD32;

gpu_set_blendmode(bm_add);

draw_sprite_ext(
	spr_spitter_blur,
	0,
	getMiddlePoint(bbox_left, bbox_right),
	getMiddlePoint(bbox_top, bbox_bottom),
	image_xscale,
	image_yscale,
	0,
	_color,
	.2
);

gpu_set_blendmode(bm_normal);