global.activeCompanionPreset = "";

function createActiveCompanion() {
	var _alreadyExists = false;
    with (obj_npc) {
        if (presetId == global.activeCompanionPreset) {
            _alreadyExists = true;
            becomeCompanion();
        }
    }
    
    if (!_alreadyExists && instance_exists(obj_player)) {
        var _npc = instance_create_layer(
            obj_player.bbox_left - 70, 
            obj_player.y,
            "Instances",
            obj_npc, 
            { presetId: global.activeCompanionPreset }
        );
        
        _npc.becomeCompanion();
    }
}

function spawnResidentInstance(_residentId, _x, _y) {
	return instance_create_layer(_x, _y, "Instances", obj_npc_resident, {
		residentId: _residentId
	});
}

function convertNpcToResident(_npc) {
	if (!instance_exists(_npc)) return noone;

	var _resident = noone;

	with (_npc) {
		var _residentId = addBaseResident(id);

		if (presetId != "" && presetId == global.activeCompanionPreset) {
			global.activeCompanionPreset = "";
		}

		_resident = spawnResidentInstance(_residentId, x, y);

		with (_resident) {
			currentDirection = other.currentDirection;
			currentImageIndex = other.currentImageIndex;
			angleOffset = other.angleOffset;
			drawState = other.drawState;
		}

		if (variable_global_exists("tutorialGuide") && global.tutorialGuide == id) {
			global.tutorialGuide = _resident;
		}

		if (instance_exists(pathHandler)) {
			instance_destroy(pathHandler);
		}

		instance_destroy();
	}

	return _resident;
}