enum buffTypes {
    health,
    stamina,
    damageAbsortion,
	custom
}

enum buffs {
	cookedMeat,
	cookedMeat2,
	dirtWater,
	rawMeat,
	rawMeat2,
	hungry,
	veryHungry,
	thirst,
	veryThirst,
	bleeding
};

buffConfig = function(_id, _multiplier, _type, _description, _timeInSeconds, _positive, _icon = undefined, _customDescription = "") {
    return {
        id: _id,
		multiplier: _multiplier,
        type: _type,
        description: _description,
        timeInSeconds: _timeInSeconds,
        positive: _positive,
		icon: _icon,
		customDescription: _customDescription
    };
};

function initConsumableBuffs() {
    global.consumableBuffs = [];

    global.consumableBuffs[consumableItems.cooked_meat_1] = buffConfig(buffs.cookedMeat, 1.1, buffTypes.health, "Comeu uma boa carne nutritiva", 60, true);
    global.consumableBuffs[consumableItems.cooked_meat_2] = buffConfig(buffs.cookedMeat2, 1.1, buffTypes.health, "Comeu uma boa carne nutritiva", 60, true);
    global.consumableBuffs[consumableItems.dirt_water]    = buffConfig(buffs.dirtWater, 0.9, buffTypes.health, "Bebeu uma água de procedência duvidosa", 120, false);
	global.consumableBuffs[consumableItems.raw_meat_1]    = buffConfig(buffs.rawMeat, 0.9, buffTypes.health, "Cormeu carne crua irmãooooooo", 120, false);
	global.consumableBuffs[consumableItems.raw_meat_2]    = buffConfig(buffs.rawMeat2, 0.9, buffTypes.health, "Cormeu carne crua irmãooooooo", 120, false);
}

function initCustomBuffs() {
	global.customBuffs[buffs.bleeding] = buffConfig(buffs.bleeding, 1, buffTypes.custom, "Sangramento", -1, false, spr_bleed_icon, "Perda de vida constante");
}

initConsumableBuffs();
initCustomBuffs();

function Buff(_id, _multiplier, _type, _description, _timeInSeconds = 60, _positive = true, _icon = undefined, _customDescription = "") constructor {
    id = _id;
	multiplier = _multiplier;
    type = _type;
    description = _description;
    timeInSeconds = _timeInSeconds;
    currentTime = _timeInSeconds;
    positive = _positive;
	icon = _icon;
	customDescription = _customDescription;

    passTime = function () {
		if (timeInSeconds == -1) return;
        currentTime -= (delta_time / 1000000) * 1;
        if (currentTime < 0) currentTime = 0;
    }
}

function getBuffByItemId(_id) {
    if (arrayKeyExists(global.consumableBuffs, _id)) {
        var _config = global.consumableBuffs[_id];
        return new Buff(
			_config.id,
            _config.multiplier,
            _config.type,
            _config.description,
            _config.timeInSeconds,
            _config.positive
        );
    }
    return false;
}

function buildCustomBuffByBuffId(_id) {
	if (arrayKeyExists(global.customBuffs, _id)) {
        var _config = global.customBuffs[_id];
        
		return new Buff(
			_config.id,
            _config.multiplier,
            _config.type,
            _config.description,
            _config.timeInSeconds,
            _config.positive,
			_config.icon,
			_config.customDescription
        );
    }
    return false;
}