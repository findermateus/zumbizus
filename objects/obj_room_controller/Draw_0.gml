if (roomConfig.extraction.type != ExtractionType.point || !instance_exists(extractionPointInstance)) {
	exit;
}

if (!instance_exists(obj_player)) {
	exit;
}

if (extractionPointInstance.disabled) {
	exit;
}

if (extractionPathTimer <= 0) {
	extractionPathTimer = extractionPathDelay;

	var _target_x = getMiddlePoint(extractionPointInstance.bbox_left, extractionPointInstance.bbox_right);
	var _target_y = getMiddlePoint(extractionPointInstance.bbox_top, extractionPointInstance.bbox_bottom);

	extractionHasPath = mp_grid_path(global.motionPlanningGrid, extractionPath, obj_player.x, obj_player.y, _target_x, _target_y, true);
} else {
	extractionPathTimer--;
}

if (!extractionHasPath || !path_exists(extractionPath)) {
	exit;
}

if (global.debug) {
	draw_set_color(c_green);
	draw_path(extractionPath, path_get_x(extractionPath, 0), path_get_y(extractionPath, 0), true);
	draw_set_color(c_white);
}

if (global.timeStopped) {
	exit;
}

if (extractionTrailSpawnTimer > 0) {
	extractionTrailSpawnTimer--;
	exit;
}

extractionTrailSpawnTimer = extractionTrailSpawnDelay;
emitExtractionTrail();
