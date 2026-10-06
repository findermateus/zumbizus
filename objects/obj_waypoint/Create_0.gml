event_inherited();
image_alpha = 0;
onClick = function () {}

getDrawPosition = function () {
    return {
        x: roomToGuiX(getMiddlePoint(bbox_left, bbox_right)),
        y: roomToGuiY(getMiddlePoint(bbox_top, bbox_bottom))
    };
}

state = function() {}

setOnclickAsTravel = function (_map, _callback = function () {}, _transitionType = TransitionType.Map) {
	travelMap = _map;
	travelCallback = _callback;
	travelTransitionType = _transitionType;

	onClick = function () {
		if (instance_exists(obj_map_transition)) return;
		
		playClickSound();
	
		travelCallback();
	
		instance_create_layer(0, 0, "Controllers", obj_map_transition, {
			destination: travelMap.room,
			mapName: travelMap.name,
			mapId: travelMap.id,
			transitionType: travelTransitionType
		});
	}
}