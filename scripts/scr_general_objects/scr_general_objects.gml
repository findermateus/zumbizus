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