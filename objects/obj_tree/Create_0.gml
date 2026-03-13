event_inherited();

treeHealth = irandom_range(70, 100);
alpha = 1;
isDying = false;

shake_power = 0;
shake_decay = 0.2;

// --- JUICE DE IMPACTO ---
shake_power = 0;
shake_decay = 0.25;
hit_flash = 0; 
tree_scale_x = 1;
tree_scale_y = 1;

// --- JUICE DE QUEDA ---
fall_angle = 0;
fall_speed = 0;
fall_direction = 1;

drop = function (_id, _type, _minQtd, _maxQtd) {
	return {
		id: _id,
		type: _type,
		maxQtd: _maxQtd,
		minQtd: _minQtd
	};
}

drops = [
	drop(trashItems.wood_log, itemType.trash, 3, 6),
	drop(trashItems.twig, itemType.trash, 1, 4)
];

function getHit(_damage, _direction = 0, _force = 0, _attackType = false, _weaponId = noone){
	if (isDying) return;

	var _isHittingWithAnAxe = (_weaponId == weaponItems.axe);
	audio_play_sound(choose(snd_hit_tree1, snd_hit_tree2, snd_hit_tree3), 0, false);
	
	if (!_isHittingWithAnAxe) {
		_damage = 1;
		var _alert = instance_create_layer(roomToGuiX(x), roomToGuiY(y), "Alert", obj_alert);
		_alert.textAlert = "É necessário um machado!";
	}
	
	if (_isHittingWithAnAxe) {
		hit_flash = 1;
	}
	shake_power = 5;
	tree_scale_x = 1.2;
	tree_scale_y = 0.8;
	
	addDamageToGuiList(x + choose(-32, 32), y, _damage);
	treeHealth -= _damage;
	
	if (treeHealth <= 0) {
		isDying = true;
		fall_direction = (instance_exists(obj_player) && x - obj_player.x > 0) ? 1 : -1;
	}
}