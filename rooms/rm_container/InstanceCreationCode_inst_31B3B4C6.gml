disabled = false;	
textToDraw = "Sair";

onClick = method(id, function () {
	if (instance_exists(obj_map_transition)) return;
	
	playClickSound();
	
	var _roomId = global.persistentRoomId
	
	savePersistentRoomSnapshot(_roomId);
	
	global.persistentRoomId = "";
	
	var _map = global.maps.junkyard;
	
	instance_create_layer(0, 0, "Controllers", obj_map_transition, {
		destination: _map.room,
		mapName: _map.name,
		mapId: _map.id,
		transitionType: TransitionType.Interior
	});
})