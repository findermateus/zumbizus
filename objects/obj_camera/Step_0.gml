if (global.pause) {
	exit;
}

if (instance_exists(obj_camera_point)) {
	target = obj_camera_point;
	currentState = followTarget;
}

currentState();

shakeCamera();
setCameraScale();