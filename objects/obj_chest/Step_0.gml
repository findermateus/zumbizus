if (global.pause) exit;

event_inherited();

yPositionToDrawShadow = getMiddlePoint(bbox_top, bbox_bottom);
xPositionToDrawShadow = x;

if(global.stopInteractions){
	currentState = innactive;
	return;
}

currentState();

closeIfShouldClose();

setShadow(sprite_index, image_index, image_xscale);
