disabled = false;
textToDraw = "Entrar";
onClick = method(id, function () {
	if (instance_exists(obj_map_transition)) return;
	
	playClickSound();
	
	instance_create_layer(0, 0, "Controllers", obj_map_transition, {
		destination: rm_container,
		mapName: ""
	});
})