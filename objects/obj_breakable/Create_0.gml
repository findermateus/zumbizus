event_inherited();

hp = 10; 
isDying = false;
required_tool = noone;
tool_error_msg = "Ferramenta incorreta!";
hit_sounds = [];
drops = [];

shake_power = 0;
shake_decay = 0.25;
scale_x = 1;
scale_y = 1;
fall_angle = 0;

drop = function (_id, _type, _minQtd, _maxQtd) {
	return {
		id: _id,
		type: _type,
		maxQtd: _maxQtd,
		minQtd: _minQtd
	};
}

spawnDrops = function() {
    array_foreach(drops, function (_drop) {
        var _qtd = irandom_range(_drop.minQtd, _drop.maxQtd);
        repeat(_qtd) {
            var _item = constructItem(_drop.type, global.items[_drop.type][_drop.id]);
            createItemByObjectId(id, _item, true);
        }
    });
}

function handleDeath() {
	obj_quest_manager.notifyEvent(QuestEvent.ObjectDestroyed, {
		tag: destroyed_tag
	});
	
    spawnDrops();
    instance_destroy();
}

processDeath = function() {
	handleDeath();
}

getHit = function(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
	if (isDying) return;

    var _hasCorrectTool = (required_tool == noone) || (_weaponId == required_tool);
    
    if (array_length(hit_sounds) > 0) {
        audio_play_sound(hit_sounds[irandom(array_length(hit_sounds)-1)], 0, false);
    }
	
	if (!_hasCorrectTool) {
		_damage = 1;
        if (tool_error_msg != "") {
		    createRoomNotifyIndicator(tool_error_msg, x, getMiddlePoint(bbox_top, bbox_bottom));
        }
	} else {
		hitFlash = 1;
	}
	
	shake_power = 5;
	scale_x = 1.2;
	scale_y = 0.8;
	
	addDamageToGuiList(x + choose(-32, 32), y, _damage);
	hp -= _damage;
	
	if (hp <= 0) {
		isDying = true;
        if (variable_instance_exists(id, "onDeathStart")) onDeathStart();
	}
}

