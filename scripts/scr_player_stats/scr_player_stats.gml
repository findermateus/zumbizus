function increaseThirst(_value, _natural = true){
	if (_natural && room == rm_player_base) return;
	global.player.currentThirst -= _value
}

function increaseHunger(_value, _natural = true){
	if (_natural && room == rm_player_base) return;
	global.player.currentHunger -= _value;
}

function decreaseThirst(_value){
	global.player.currentThirst += _value
}

function decreaseHunger(_value){
	global.player.currentHunger += _value
}

function decreaseHealth(_value) {
	global.player.health -= abs(_value);
	global.player.health = clamp(global.player.health, 0, global.player.maxHealth);
	obj_player_stats.setHealthGuiJiggle();
}

function increaseHealth(_value) {
	global.player.health += abs(_value);
	global.player.health = clamp(global.player.health, 0, global.player.maxHealth);
	obj_player_stats.setHealthGuiJiggle();
}