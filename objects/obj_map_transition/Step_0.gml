var _camX = camera_get_view_x(view_camera[0]);
var _camY = camera_get_view_y(view_camera[0]);

if (fadeInSequence != undefined && layer_sequence_exists("Transition", fadeInSequence)) {
	layer_sequence_x(fadeInSequence, _camX);
	layer_sequence_y(fadeInSequence, _camY);
}

if (fadeOutSequence != undefined && layer_sequence_exists("Transition", fadeOutSequence)) {
	layer_sequence_x(fadeOutSequence, _camX);
	layer_sequence_y(fadeOutSequence, _camY);
}