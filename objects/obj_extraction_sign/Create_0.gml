event_inherited();

actionDescription = "Voltar para casa";
hasSelected = false;

loadFurnitureByDefaultId();

xPositionToDrawShadow = x;
yPositionToDrawShadow = y - 5;

activationMethod = function () {
	
	//sons
	playClickSound();
	
	instance_create_layer(0, 0, "Controllers", obj_map_transition, {
		destination: rm_player_base,
		mapName: "Base"
	});
}