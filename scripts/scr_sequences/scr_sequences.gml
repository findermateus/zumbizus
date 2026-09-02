
//chamado na sequence sq_fade_out
function transitionFinished() {
	if (!instance_exists(obj_map_transition)) return;
	
	layer_sequence_destroy(self.elementID);
	obj_map_transition.finishTransition();
}

//chamado na sequence sq_fade_in
function transitionChangeRoom() {
	if (!instance_exists(obj_map_transition)) return;
	obj_map_transition.changeRoom();
	
	if (obj_map_transition.mapId == "") return;
	
	var _map = global.maps[$ obj_map_transition.mapId];
	
	if (!is_struct(_map)) return;
	
	var _rainChance = _map.rainChance;
	
	obj_rain_controller.updateRainChance(_rainChance);
}

function transitionPlaceSequence(_transitionType ) {
	var _targetLayer = "Transition";
	if (layer_exists(_targetLayer)) layer_destroy(_targetLayer);
	
	var _layer = layer_create(-99999, _targetLayer);
	
	var _camX = camera_get_view_x(view_camera[0]);
	var _camY = camera_get_view_y(view_camera[0]);
	
	var _sequence = layer_sequence_create(_layer, _camX, _camY, _transitionType);
	
	var _xScale = getScale(DEFAULT_CAM_W, 1920);
	var _yScale = getScale(DEFAULT_CAM_H, 1080);
	
	layer_sequence_xscale(_sequence, _xScale);
	layer_sequence_yscale(_sequence, _yScale);
	
	return _sequence;
}