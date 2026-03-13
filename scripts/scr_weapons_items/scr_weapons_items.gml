enum weaponItems {
	baseballBat,
	sword,
	nailBoard,
	pistol,
	ump,
	shotgun,
	assaultRifle,
	sniperRifle,
	baseballBatWithNails,
	axe
}

function WeaponConfig() {
	return {
		itemId: 0,
		name: "",
		description: "",
		sprite: spr_item_default,
		sound: snd_can,
		actionSound: snd_equip_item,
		fitInGrid: fitInGridType.verticaly,
		durability: undefined,
		maxDurability: undefined,
		durabilityDecrease: undefined,
		bullets: undefined,
		maxAmmo: undefined,
		soundRadius: 100,
		type: itemType.weapons
	};
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.baseballBat;
	_config.name = "Bastão de baseball";
	_config.description = "Bastão de baseball fudido e velho fudido, mas assim, muuito fudido";
	_config.sprite = spr_baseball_bat;
	_config.sound = snd_baseball_bat;
	_config.durability = 100;
	_config.maxDurability = 100;
	_config.durabilityDecrease = 6;

	global.items[itemType.weapons][weaponItems.baseballBat] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.baseballBatWithNails;
	_config.name = "Bastão de baseball com pregos";
	_config.description = "Bastão de baseball fudido e velho fudido, mas assim, com pregos";
	_config.sprite = spr_baseball_bat_with_nails;
	_config.sound = snd_baseball_bat;
	_config.durability = 100;
	_config.maxDurability = 100;
	_config.durabilityDecrease = 4;

	global.items[itemType.weapons][weaponItems.baseballBatWithNails] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.nailBoard;
	_config.name = "Tábua com pregos na ponta";
	_config.description = "Uma tábua de madeira reforçada, com vários pregos enferrujados cravados em sua superfície.";
	_config.sprite = spr_nail_board;
	_config.sound = snd_baseball_bat;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.durability = 100;
	_config.maxDurability = 100;
	_config.durabilityDecrease = 8;

	global.items[itemType.weapons][weaponItems.nailBoard] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.sword;
	_config.name = "Espada fudida";
	_config.description = "Espada fudida, mais um pouco e ela quebra";
	_config.sprite = spr_sword;
	_config.sound = snd_sword;
	_config.durability = 100;
	_config.maxDurability = 100;
	_config.durabilityDecrease = 3;

	global.items[itemType.weapons][weaponItems.sword] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.axe;
	_config.name = "Machado";
	_config.description = "Bom para cortar árvores";
	_config.sprite = spr_axe;
	_config.sound = snd_sword;
	_config.durability = 100;
	_config.maxDurability = 100;
	_config.durabilityDecrease = 2;

	global.items[itemType.weapons][weaponItems.axe] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.pistol;
	_config.name = "Glock Bolada";
	_config.description = "Pistola Glock, miro no cu e atiro";
	_config.sprite = spr_pistol;
	_config.sound = snd_pistol;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.bullets = 0;
	_config.maxAmmo = 12;
	_config.soundRadius = 500;
	global.items[itemType.weapons][weaponItems.pistol] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.ump;
	_config.name = "UMP em boa condição";
	_config.description = "SMG travada em tiros únicos";
	_config.sprite = spr_ump;
	_config.sound = snd_ump;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.bullets = 0;
	_config.maxAmmo = 30;
	_config.soundRadius = 600;
	global.items[itemType.weapons][weaponItems.ump] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.shotgun;
	_config.name = "Escopeta";
	_config.description = "Escopeta pesada com vários tiros";
	_config.sprite = spr_shotgun;
	_config.sound = snd_ump;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.bullets = 0;
	_config.maxAmmo = 6;
	_config.soundRadius = 1100;
	global.items[itemType.weapons][weaponItems.shotgun] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.assaultRifle;
	_config.name = "Rifle morderno";
	_config.description = "Rifle de assalto automático";
	_config.sprite = spr_assault_rifle;
	_config.sound = snd_ump;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.bullets = 0;
	_config.maxAmmo = 30;
	_config.soundRadius = 750;
	global.items[itemType.weapons][weaponItems.assaultRifle] = _config;
}

{
	var _config = WeaponConfig();
	_config.itemId = weaponItems.sniperRifle;
	_config.name = "Rifle de precisão";
	_config.description = "Kar 98 ótima para tiros longos";
	_config.sprite = spr_sniper_rifle;
	_config.sound = snd_ump;
	_config.fitInGrid = fitInGridType.horizontaly;
	_config.bullets = 0;
	_config.maxAmmo = 5;
	_config.soundRadius = 1000;
	global.items[itemType.weapons][weaponItems.sniperRifle] = _config;
}
