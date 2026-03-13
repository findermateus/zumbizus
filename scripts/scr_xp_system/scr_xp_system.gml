enum upgradeStatusOption {
	health,
	stamina
}

function xpInit() {
	global.xpCurveFactor = 1.25;    
	global.xpNext = 100;
}

xpInit();

function xpGetNextRequired(_level) {
    return round(100 * power(global.xpCurveFactor, _level - 1));
}

function xpAdd(_amount) {
    global.player.xp += _amount;

    while (global.player.xp >= global.xpNext) {
        global.player.xp -= global.xpNext;
        xpLevelUp();
    }
	
	if (instance_exists(obj_xp_controller)) {
		obj_xp_controller.handleGainXp(_amount);
	}
}

function xpLevelUp() {
    global.player.level += 1;
    global.xpNext = xpGetNextRequired(global.player.level);
	
	if (instance_exists(obj_xp_controller)) {
		obj_xp_controller.handleLevelUp();
	}
}

function increaseStaminaLevel() {
	global.player.stats.staminaLevel ++;
	evaluateHealthAndStaminaStats();
}

function increaseHealthLevel() {
	global.player.stats.healthLevel ++;
	evaluateHealthAndStaminaStats();
}

function evaluateHealthAndStaminaStats() {
	var _healthLevel = global.player.stats.healthLevel - 1;
	var _staminaLevel = global.player.stats.staminaLevel - 1;
	
	var _staminaPerLevel = global.staminaPerLevel;
	var _healthPerLevel = global.healthPerLevel;
	
	global.player.defaultMaxHealth = global.initialHealth + _healthPerLevel * _healthLevel;
	global.player.defaultMaxStamina = global.initialStamina + _staminaPerLevel * _staminaLevel;
	
	global.player.health = global.player.defaultMaxHealth;
	global.player.stamina = global.player.defaultMaxStamina;
}