
global.minimalDistanceToCollect = 300;

global.playerStopInteractions = false;

global.blockMenus = false;

function PersonHair(_id, _color) constructor
{
	hairId = _id;
	if (is_string(_color)) {
		_color = getHexFromString(_color);
	}
	color = _color;
}


global.isInsideInterior = false;

global.staminaPerLevel = 15;
global.healthPerLevel = 15;
global.initialHealth = 100;
global.initialStamina = 100;

global.player = {
	skinColor: #D39B6A,
	gender: genders.male,
	hair: new PersonHair(hairIds.buzzCut, #593708),
	
	level: 1,
	xp: 0,
	
	walkingAceleration: .3,
	walkingSpeed: 5,
	
	defaultTotalThirst: 1000,
	defaultTotalHunger: 1000,
	currentThirst: 1000,
	currentHunger: 1000,
	
	maxHealth: global.initialHealth,
	health: global.initialHealth,
	defaultMaxHealth: global.initialHealth,
	
	maxStamina: global.initialStamina,
	defaultMaxStamina: global.initialStamina,
	stamina: global.initialStamina,
	staminaAcceleration: .5,
	
	staminaRecoveryDelay: 60,
	staminaDecreaseAcceleration: .3,
	sprintSpeed: 8,
	sprintStaminaDecrease: .4,
	
	skills: {
		cooking: 1,
		crafting: 1
	},
	stats: {
		healthLevel: 1,
		staminaLevel: 1
	},
	
	buffList: [],
	
	blueprints: [
		blueprints.nailBoard,
		blueprints.baseballBatWithNails,
		blueprints.axe
	]
};

enum damageType {
	blunt,
	cut,
	shot
}