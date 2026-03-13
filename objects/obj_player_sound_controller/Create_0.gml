soundList = [];

function Sound(_radius, _x, _y, _intensity, _father) constructor {
    radius = _radius;
    x = _x;
    y = _y;
    intensity = _intensity;
    father = _father;
    hasAnalized = false;
    isFinished = false;
}

function handleSound() {
	for (var i = array_length(soundList) - 1; i >= 0; i--) {
		var _sound = soundList[i];
		if (is_undefined(_sound)) continue;

		if (!_sound.hasAnalized) {
			warnEnemies(_sound);
			
			var _inst = instance_create_layer(_sound.x, _sound.y, "Alert", obj_draw_circle_in_object);
			_inst.radiusMax = _sound.radius;
			_inst.setIntensity(_sound.intensity);
			_sound.hasAnalized = true;
			_sound.isFinished = true;
			_sound.father = obj_player;
		}

		if (_sound.isFinished) {
			array_delete(soundList, i, 1);
		}
	}
}

function warnEnemies(_sound) {
	var _list = ds_list_create();
	collision_circle_list(_sound.x, _sound.y, _sound.radius, obj_hittable, false, true, _list, false);
	
	for (var i = 0; i < ds_list_size(_list); i++) {
		if (variable_instance_exists(_list[| i], "hearSound")) {
			_list[| i].hearSound(_sound.x, _sound.y, _sound.radius);
		}
	}
	ds_list_destroy(_list);
}

function addSound(_radius, _x, _y, _intensity = soundIntensity.standard, _father = noone) {
    array_push(soundList, new Sound(_radius, _x, _y, _intensity, _father));
}