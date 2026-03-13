function AmmoConfig() {
	return {
		itemId: 0,
		name: "",
		description: "",
		sprite: spr_item_default,
		limit: 1,
		quantity: 1,
		sound: snd_can,
		fitInGrid: fitInGridType.verticaly,
		type: itemType.ammo
	}
}

{
	var _config = AmmoConfig();
	_config.itemId = ammoItems.mm9;
	_config.name = "Munição 9mm";
	_config.description = "Munição 9mm compátivel com pistolas e smg's";
	_config.sprite = spr_ammo_9mm;
	_config.limit = 64;
	_config.quantity = 1;
	_config.sound = snd_shells;
	_config.fitInGrid = fitInGridType.verticaly;

	global.items[itemType.ammo][ammoItems.mm9] = _config;
}

{
	var _config = AmmoConfig();
	_config.itemId = ammoItems.cal12;
	_config.name = "Munição Calibre 12";
	_config.description = "Munição calibre 12 compátivel com escopetas";
	_config.sprite = spr_ammo_12;
	_config.limit = 16;
	_config.quantity = 1;
	_config.sound = snd_shells;
	_config.fitInGrid = fitInGridType.verticaly;

	global.items[itemType.ammo][ammoItems.cal12] = _config;
}

{
	var _config = AmmoConfig();
	_config.itemId = ammoItems.rifle;
	_config.name = "Munição para rifles";
	_config.description = "Munição para rifles 7.62";
	_config.sprite = spr_ammo_rifle;
	_config.limit = 64;
	_config.quantity = 1;
	_config.sound = snd_shells;
	_config.fitInGrid = fitInGridType.verticaly;

	global.items[itemType.ammo][ammoItems.rifle] = _config;
}
