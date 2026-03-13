fadeInSequence = transitionPlaceSequence(sq_fade_in);
fadeOutSequence = undefined;

pauseSystems();
openMenu();

function changeRoom() {
	layer_set_target_room(destination);
	fadeOutSequence = transitionPlaceSequence(sq_fade_out);
	layer_reset_target_room();
	
	room_goto(destination);
}

function finishTransition() {
	unPauseSystems();
	closeMenu();
	instance_destroy();
	
	if (mapName != "") {
		instance_create_layer(0, 0, "Controllers", obj_map_title, {
		 title: mapName
		});
	}
}