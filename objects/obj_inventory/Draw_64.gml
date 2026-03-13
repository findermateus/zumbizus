if (global.pause) {
	exit;
}

draw_set_font(fnt_gui_default);

drawInventory();
currentState();

draw_set_halign(fa_left);
if(global.debug && keyboard_check(vk_backspace)){
	var _debugInfo = [
		"Current Option Menu: " + string(global.currentOptionMenu),
	    "Estado : " + string(script_get_name(currentState)),
	    "Holding Item: " + string(holdingItem),
	    "Active hold Item: " + string(activeHoldingItem),
	    "Hover Item: " + string(hoverItem),
	    "Active hover Item: " + string(activeHoverItem),
	    "Mouse hold toolbar: " + string(holdingItemFromToolBar),
	    "Active inventory: " + string(global.activeInventoryAction),
	    "Mouse is on Inventory: " + string(mouseIsOnInventory),
	    "Mouse is on Inventory Grid: " + string(mouseIsOnInventoryGrid),
	    "Secundary Inventory: " + string(secundaryInventory),
	    "Primary Inventory: " + string(primaryInventory),
		"Animation Curve Index: " + string(curveAnimationIndex),
		"Active Inventory: " + string(global.activeInventory),
		"Holding From ToolBar: " + string(holdingItemFromToolBar),
		"Mouse is on quick USE: " + string(mouseIsOnQuickUseBar)
	];

	var startY = 100;
	var offset = 40;
	for (var i = 0; i < array_length(_debugInfo ); i++) {
	    draw_text(20, startY + (i * offset), _debugInfo[i]);
	}
	draw_text(20, gui_height - 100, "item equipado: " + string(global.activeEquipedItem));
}
draw_set_font(fnt_default);