enum weaponTypes {
	impact,
	bladed,
	piercing,
	shoot
}

enum weaponAttackType {
	swing,
	singleShot,
	automaticShot,
	tripleBullets
}

enum reloadingTypes {
	perBullet,
	magazine
}

function FireWeapon(_config) constructor {
	sprite = _config.sprite;
	damage = _config.damage;
	pushForce = _config.pushForce;
	type = _config.type;
	recoilForce = _config.recoilForce;
	delayToShoot = _config.delayToShoot;
	bulletDistance = _config.bulletDistance;
	attackType = _config.attackType;
	attackingSound = _config.attackingSound;
	allowedAmmo = _config.allowedAmmo;
	emptyShot = _config.emptyShot;
	thickness = _config.thickness;
	reloadSound = _config.reloadSound;
	reloadingType = _config.reloadingType;
	lightSpread = _config.lightSpread;
	reloadTime = _config.reloadTime ?? 60;
	reloadingSprite = _config.reloadingSprite ?? spr_item_default;
}

function FireWeaponConfig() {
	return {
		sprite: spr_item_default,
		damage: 0,
		pushForce: 0,
		type: weaponTypes.shoot,
		recoilForce: 0,
		delayToShoot: 0,
		bulletDistance: 1000,
		attackType: weaponAttackType.singleShot,
		attackingSound: [],
		allowedAmmo: -1,
		emptyShot: noone,
		thickness: 1,
		reloadSound: noone,
		reloadingType: reloadingTypes.magazine,
		lightSpread: 0,
		reloadTime: 60,
		reloadingSprite: spr_item_default
	};
}


function MeeleWeapon(
	_sprite,
	_hitBox,
	_damage,
	_pushForce,
	_attackSpeed,
	_staminaCost,
	_type,
	_attackType,
	_attackingSound,
	_angleToSwitch = 180
) constructor 
{
	sprite = _sprite;
	hitBox = _hitBox;
	damage = _damage;
	pushForce = _pushForce;
	attackSpeed = _attackSpeed;
	staminaCost = _staminaCost;
	type = _type;
	attackType = _attackType;
	attackingSound = _attackingSound;
	angleToSwitch = _angleToSwitch;
}

global.weapons = [];
global.weapons[weaponItems.baseballBat] = new MeeleWeapon(
	spr_weapon_baseball_bat,
	spr_hitbox_weapon_basebal,
	8,
	15,
	.2,
	6,
	weaponTypes.impact,
	weaponAttackType.swing,
	[
		snd_baseball_bat_attack_1,
		snd_baseball_bat_attack_2,
		snd_baseball_bat_attack_3,
	],
	270
);

global.weapons[weaponItems.baseballBatWithNails] = new MeeleWeapon(
	spr_weapon_baseball_bat_with_nails,
	spr_hitbox_weapon_basebal,
	12,
	15,
	.2,
	8,
	weaponTypes.impact,
	weaponAttackType.swing,
	[
		snd_baseball_bat_attack_1,
		snd_baseball_bat_attack_2,
		snd_baseball_bat_attack_3,
	],
	270
);

global.weapons[weaponItems.sword] = new MeeleWeapon(
	spr_weapon_sword,
	spr_hitbox_weapon_sword,
	5,
	10,
	.5,
	3,
	weaponTypes.bladed,
	weaponAttackType.swing,
	[
		snd_sword_attack_1,
		snd_sword_attack_2,
		snd_sword_attack_3
	]
);

global.weapons[weaponItems.nailBoard] = new MeeleWeapon(
	spr_weapon_nail_board,
	spr_hitbox_weapon_nail_board,
	8,
	7,
	.2,
	5,
	weaponTypes.impact,
	weaponAttackType.swing,
	[
		snd_baseball_bat_attack_1,
		snd_baseball_bat_attack_2,
		snd_baseball_bat_attack_3,
	]
);

global.weapons[weaponItems.axe] = new MeeleWeapon(
	spr_weapon_axe,
	spr_hitbox_weapon_sword,
	20,
	15,
	.2,
	12,
	weaponTypes.bladed,
	weaponAttackType.swing,
	[
		snd_sword_attack_1,
		snd_sword_attack_2,
		snd_sword_attack_3
	],
	270
);

{
	var config = FireWeaponConfig();
	config.sprite = spr_weapon_pistol;
	config.damage = 6;
	config.pushForce = 10;
	config.recoilForce = 8;
	config.delayToShoot = 3;
	config.bulletDistance = 1000;
	config.attackType = weaponAttackType.singleShot;
	config.attackingSound = [ snd_pistol_shoot_1, snd_pistol_shoot_2 ];
	config.allowedAmmo = ammoItems.mm9;
	config.emptyShot = snd_pistol_empty_shot;
	config.thickness = 1;
	config.reloadSound = snd_pistol_reload;
	config.reloadingType = reloadingTypes.magazine;
	config.lightSpread = 50;

	global.weapons[weaponItems.pistol] = new FireWeapon(config);
}

{
	var umpConfig = FireWeaponConfig();
	umpConfig.sprite = spr_weapon_ump;
	umpConfig.damage = 8;
	umpConfig.pushForce = 10;
	umpConfig.recoilForce = 15;
	umpConfig.delayToShoot = 6;
	umpConfig.bulletDistance = 1000;
	umpConfig.attackType = weaponAttackType.singleShot;
	umpConfig.attackingSound = [ snd_ump_shoot_1, snd_ump_shoot_2 ];
	umpConfig.allowedAmmo = ammoItems.mm9;
	umpConfig.emptyShot = snd_ump_empty_shot;
	umpConfig.thickness = 2;
	umpConfig.reloadSound = snd_ump_reload;
	umpConfig.reloadingType = reloadingTypes.magazine;
	umpConfig.lightSpread = 30;
	global.weapons[weaponItems.ump] = new FireWeapon(umpConfig);
}
{
	var config = FireWeaponConfig();
	config.sprite = spr_weapon_shotgun;
	config.damage = 30;
	config.pushForce = 20;
	config.recoilForce = 20;
	config.delayToShoot = 1;
	config.bulletDistance = 500;
	config.attackType = weaponAttackType.tripleBullets;
	config.attackingSound = [ snd_shoot_shotgun_1, snd_shoot_shotgun_2 ];
	config.allowedAmmo = ammoItems.cal12;
	config.emptyShot = snd_ump_empty_shot;
	config.thickness = 7;
	config.reloadSound = snd_shotgun_reload;
	config.reloadingType = reloadingTypes.perBullet;
	config.lightSpread = 107;
	config.reloadTime = 60;
	config.reloadingSprite = spr_weapon_shotgun_reload;

	global.weapons[weaponItems.shotgun] = new FireWeapon(config);
}

{
	var config = FireWeaponConfig();
	config.sprite = spr_weapon_assault_rifle;
	config.damage = 14;
	config.pushForce = 5;
	config.recoilForce = 10;
	config.delayToShoot = 7;
	config.bulletDistance = 3000;
	config.attackType = weaponAttackType.automaticShot;
	config.attackingSound = [ snd_ump_shoot_1, snd_ump_shoot_2 ];
	config.allowedAmmo = ammoItems.rifle;
	config.emptyShot = snd_ump_empty_shot;
	config.thickness = 4;
	config.reloadSound = snd_ump_reload;
	config.reloadingType = reloadingTypes.magazine;
	config.lightSpread = 40;
	config.reloadTime = 100;
	config.reloadingSprite = spr_weapon_assault_rifle_reload;

	global.weapons[weaponItems.assaultRifle] = new FireWeapon(config);
}

{
	var config = FireWeaponConfig();
	config.sprite = spr_weapon_sniper_rifle;
	config.damage = 60;
	config.pushForce = 1;
	config.recoilForce = 10;
	config.delayToShoot = .7;
	config.bulletDistance = 6000;
	config.attackType = weaponAttackType.singleShot;
	config.attackingSound = [ snd_shoot_sniper_rifle_1 ];
	config.allowedAmmo = ammoItems.rifle;
	config.emptyShot = snd_sniper_rifle_empty_shoot;
	config.thickness = 4;
	config.reloadSound = snd_sniper_rifle_reload;
	config.reloadingType = reloadingTypes.perBullet;
	config.lightSpread = 40;
	config.reloadTime = 100;
	config.reloadingSprite = spr_weapon_sniper_rifle_reload;
	
	global.weapons[weaponItems.sniperRifle] = new FireWeapon(config);
}