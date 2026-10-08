//drawSpriteShadow(xPosition, yPosition, sprite_index, image_index, image_angle, 1, 1, 0, 8);
updatePlaceBounce();

if (placeSquash == 0) {
	draw_sprite_ext(sprite_index, image_index, xPosition, yPosition, image_xscale, image_yscale, image_angle, image_blend, image_alpha);
} else {
	var _base = getSpriteBottomCenter(sprite_index, xPosition, yPosition, image_xscale, image_yscale, image_angle);
	drawSpriteFromBottomCenter(sprite_index, image_index, _base[0], _base[1], image_xscale * (1 + placeSquash), image_yscale * (1 - placeSquash), image_angle, image_blend, image_alpha);
}
