function adjustObjectDepth(){
	depth = -bbox_bottom;
}

function adjustClosestDepth(){
	depth = - room_height;
}

function getClosestDepth() {
	return -room_height;
}

function adjustDepthToASpecificObject(_object) {
	if (instance_exists(_object)) {
		depth = _object.depth - 1;
	}
}

function adjustAlphaToInterior() {
	var _inst_interior = instance_place(x, y, obj_interior);

	if (_inst_interior != noone) {
	    image_alpha = 1 - _inst_interior.alpha;
		
		return;
	}
	
	image_alpha = 1;
}