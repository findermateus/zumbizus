event_inherited();

if (global.timeStopped) exit;

currentState();

currentSpriteFrame += spriteSpeed / 60;

if (currentSpriteFrame >= sprite_get_number(spriteToDrawShadow)) {
    currentSpriteFrame = 0;
}