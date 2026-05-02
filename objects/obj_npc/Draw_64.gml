event_inherited();

drawInterface();

if (!activeInteraction) return;

if (global.activeBuilding || global.activeInventory) {
	activeInteraction = false;
}


if(!checkObstacules(obj_player) || !checkDistance(obj_player)) return;
closeContainer();

if (!verifyConditions()) {
	activeInteraction = false;
}

if (array_length(interactOptions) == 1) {
	handleNPCOption(interactOptions[0].action);
	activeInteraction = false;	
	return;
}

activeInteraction = false;
