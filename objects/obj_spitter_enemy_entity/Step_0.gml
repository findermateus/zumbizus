event_inherited();

if (global.timeStopped) exit;

currentState();

currentSpriteFrame += spriteSpeed / 60;

if (currentSpriteFrame >= sprite_get_number(spriteToDrawShadow)) {
    currentSpriteFrame = 0;
}

drawScaleX = lerp(drawScaleX, 1, 0.15);
drawScaleY = lerp(drawScaleY, 1, 0.15);