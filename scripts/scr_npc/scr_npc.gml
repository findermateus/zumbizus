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
            obj_player.x, 
            obj_player.y, 
            "Instances",
            obj_npc, 
            { presetId: global.activeCompanionPreset }
        );
        
        _npc.becomeCompanion();
    }
}