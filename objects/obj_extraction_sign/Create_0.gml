event_inherited();

actionDescription = "Voltar para casa";
hasSelected = false;

loadFurnitureByDefaultId();

xPositionToDrawShadow = x;
yPositionToDrawShadow = y - 5;

activationMethod = function () {
	if (instance_exists(obj_map_transition)) return;
	
	playClickSound();
	
	var _map = global.maps.playerBase;
	
	instance_create_layer(0, 0, "Controllers", obj_map_transition, {
		destination: _map.room,
		mapName: _map.name,
		mapId: _map.id
	});
}