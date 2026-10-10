if (!instance_exists(obj_player)) {
	exit;
}

if (roomConfig.extraction.type == ExtractionType.point
	&& instance_exists(extractionPointInstance)
	&& !extractionPointInstance.disabled) {
	extractionTrail.update(extractionPointInstance);
}

if (instance_exists(trailPoint)) {
	trailPointTrail.update(trailPoint);
}
