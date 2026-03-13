function setVariablesOpenFurniture() {
	global.stopInteractions = true;	
	global.playerStopInteractions = true;
}

function setVariablesCloseFurniture() {
	global.stopInteractions = false;
	global.playerStopInteractions = false;
}

function loadFurnitureDataById(_furnitureId, _objectId) {
	cleanFurnitureData(_furnitureId, _objectId);
	return getFurnitureData(_furnitureId, _objectId);
}