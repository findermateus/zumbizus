if (global.pause) exit;

event_inherited();

if (isUsing && checkConditionsToClose()) {
	hide();
}

if (isMenuVisible()) updateCraftingMenu();

yPositionToDrawShadow = getMiddlePoint(bbox_top, bbox_bottom);
