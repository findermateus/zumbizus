if(currentState == active){
	itemScale = lerp(itemScale, 1.5, .1);
} else {
	itemScale = lerp(itemScale, 1, .01);
}
drawSpriteShadow(x, y, item.sprite, 0, angle, itemScale, itemScale, 4, 4, image_alpha);
draw_sprite_ext(item.sprite, 0, x, y, itemScale, itemScale, angle, c_white, image_alpha);
if(currentState == active){
	drawSpriteWithGpuFog(c_white, item.sprite, 0, x, y, itemScale, itemScale, angle, .3);
}
