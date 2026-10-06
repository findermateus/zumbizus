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

extractionPath = path_add();
extractionPathDelay = 8;
extractionPathTimer = 0;
extractionHasPath = false;

#region
{
	extractionTrailLength = 1000;
	extractionTrailParticleScale = .6;
	extractionTrailStartOffset = 16;
	extractionTrailSpawnDelay = 1;
	extractionTrailSpawnTimer = 0;

	extractionTrailSystem = part_system_create();
	extractionTrailParticle = part_type_create();

	part_type_sprite(extractionTrailParticle, spr_particle, 0, 0, 1);
	part_type_life(extractionTrailParticle, 60, 90);
	part_type_speed(extractionTrailParticle, .5, .9, -.004, 0);
	part_type_size(extractionTrailParticle, .9, 2, .006, 0);
	part_type_scale(extractionTrailParticle, extractionTrailParticleScale, extractionTrailParticleScale);
	part_type_alpha3(extractionTrailParticle, 0, 1, 0);
	part_type_color2(extractionTrailParticle, $80FFD4, $49A045);
	part_type_blend(extractionTrailParticle, true);
	part_type_orientation(extractionTrailParticle, 0, 360, .5, 0, false);
}
#endregion

emitExtractionTrail = function() {
	var _path_length = path_get_length(extractionPath);
	if (_path_length <= extractionTrailStartOffset) {
		return;
	}

	var _trail_end = min(_path_length, extractionTrailStartOffset + extractionTrailLength);
	var _distance = random_range(extractionTrailStartOffset, _trail_end);
	var _position = _distance / _path_length;
	var _ahead_position = min(1, (_distance + 8) / _path_length);

	var _x = path_get_x(extractionPath, _position);
	var _y = path_get_y(extractionPath, _position);
	var _direction = point_direction(_x, _y, path_get_x(extractionPath, _ahead_position), path_get_y(extractionPath, _ahead_position));

	part_type_direction(extractionTrailParticle, _direction - 12, _direction + 12, 0, 1.5);
	part_particles_create(extractionTrailSystem, _x + random_range(-4, 4), _y + random_range(-4, 4), extractionTrailParticle, 2);
}
