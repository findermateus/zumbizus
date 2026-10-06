disabled = false;
textToDraw = "Sair";

setOnclickAsTravel(global.maps.junkyard, function () {
	savePersistentRoomSnapshot(global.persistentRoomId);
	
	global.persistentRoomId = "";
}, TransitionType.Interior);