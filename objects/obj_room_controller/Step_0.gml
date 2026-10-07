if (!instance_exists(trailPoint)) {
	trailPoint = noone;
}

if (instance_exists(extractionPointInstance)) {
	exit;
}

if (!instance_exists(obj_waypoint)) {
	extractionPointInstance = noone;
		
	exit;
}

with (obj_waypoint) {
	if (tag == EXTRACTION_WAYPOINT_TAG) {
		other.extractionPointInstance = id;
	}
}
