if (global.pause) exit;

guiCurrentState();
if (global.debug){
	var _itemsToDebug = [
		"activeSelectingFurniture: " + string(activeSelectingFurniture),
		"selectedFurniture: " + string(selectedFurniture),
		"alreadyPlacedSelectedFurniture: " + string(alreadyPlacedSelectedFurniture),
		"furnitureDisplayInfo.xPosition: " + string(furnitureDisplayInfo.xPosition),
		"furnitureDisplayInfo.yPosition: " + string(furnitureDisplayInfo.yPosition),
		"furnitureDisplayInfo.angle: " + string(furnitureDisplayInfo.angle) ,
		"requirementsCheck: " + string(requirementsCheck),
		"ignoreId: " + string(furnitureDisplay.ignoreId),
		"currentState: " + script_get_name(currentState)
	];
	for(var i = 0; i < array_length(_itemsToDebug); i ++){
		draw_text(display_get_gui_width()/2, 300 + (i*50), _itemsToDebug[i]);
	}
}