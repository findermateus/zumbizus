#macro EXTRACTION_WAYPOINT_TAG "extraction_point"

enum ExtractionType {
    none,
    free,
    point
}

roomConfig = {
    extraction: {
        enabled: false,
        type: ExtractionType.none
    }
};

extractionNone = function() {
	roomConfig.extraction.enabled = false;
	roomConfig.extraction.type = ExtractionType.none;
}

extractionFree = function() {
	roomConfig.extraction.enabled = true;
	roomConfig.extraction.type = ExtractionType.free;
}

extractionPoint = function(_enabled = false) {
	roomConfig.extraction.enabled = _enabled;
	roomConfig.extraction.type = ExtractionType.point;
}

extractionPointInstance = noone;

extractionTrail = new PathTrail(PRIMARY_COLOR);

trailPoint = noone;
trailPointTrail = new PathTrail(QUEST_COLOR, 4);
