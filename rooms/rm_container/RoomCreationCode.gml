loadPlayerData();

var _roomId = global.persistentRoomId;

if (variable_struct_exists(global.visitedPersistentRooms, _roomId)) {
    loadRoomSnapshot(_roomId);
} else {
    global.containerRoomInitializer();
    
	global.visitedPersistentRooms[$ _roomId] = true;
}

global.containerRoomInitializer = undefined;
    