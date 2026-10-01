enum TransitionType {
	Map,
	Interior
}

var _fadeIn = transitionType == TransitionType.Map ? sq_fade_in : sq_fade_in_interior;

fadeInSequence = transitionPlaceSequence(_fadeIn);
fadeOutSequence = undefined;

pauseSystems();
openMenu();

function changeRoom() {
	layer_set_target_room(destination);
	
	var _fadeOut = transitionType == TransitionType.Map ? sq_fade_out : sq_fade_out_interior;
	
	fadeOutSequence = transitionPlaceSequence(_fadeOut);
	layer_reset_target_room();

	global.persistentRoomId = persistentRoomId;
	
	room_goto(destination);
}

function finishTransition() {
	unPauseSystems();
	closeMenu();
	instance_destroy();
	
	obj_quest_manager.notifyEvent(QuestEvent.AreaEntered, {
		area: destination
	});
	
	if (mapName != "" && transitionType == TransitionType.Map) {
		instance_create_layer(0, 0, "Controllers", obj_map_title, {
		 title: mapName
		});
	}
}