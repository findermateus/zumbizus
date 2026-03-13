function TrashConfig() {
	return {
		itemId: 0,
		name: "",
		description: "",
		sprite: spr_item_default,
		limit: 1,
		quantity: 1,
		sound: snd_can,
		fitInGrid: fitInGridType.verticaly,
		type: itemType.trash
	};
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.nail;
	_config.name = "Prego";
	_config.description = "Diversos pregos";
	_config.sprite = spr_nail;
	_config.limit = 64;

	global.items[itemType.trash][trashItems.nail] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.empty_watter_bottle;
	_config.name = "Garrafa vazia";
	_config.description = "Garra vazia que pode ser reutilizada";
	_config.sprite = spr_empty_water_bottle;
	_config.limit = 12;
	_config.sound = snd_empty_water_bottle;

	global.items[itemType.trash][trashItems.empty_watter_bottle] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.empty_canned_food;
	_config.name = "Lata vazia";
	_config.description = "Lata vazia, sem muito uso pois já foi aberta";
	_config.sprite = spr_empty_canned_food;
	_config.limit = 16;

	global.items[itemType.trash][trashItems.empty_canned_food] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.wood_board;
	_config.name = "Tábua de madeira";
	_config.description = "Muito utilizada em construções de mobília";
	_config.sprite = spr_wood_board;
	_config.limit = 8;
	_config.fitInGrid = fitInGridType.horizontaly;

	global.items[itemType.trash][trashItems.wood_board] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.empty_canned_fish;
	_config.name = "Lata vazia";
	_config.description = "Já conteve um saboroso peixe.";
	_config.sprite = spr_empty_canned_fish;
	_config.limit = 16;

	global.items[itemType.trash][trashItems.empty_canned_fish] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.empty_canned_pineapple;
	_config.name = "Lata vazia";
	_config.description = "Já conteve um abacaxi.";
	_config.sprite = spr_empty_canned_pineapple;
	_config.limit = 16;

	global.items[itemType.trash][trashItems.empty_canned_pineapple] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.duct_tape;
	_config.name = "Fita adesiva";
	_config.description = "Serve para remendar coisas (até certo ponto)";
	_config.sprite = spr_duct_tape;
	_config.limit = 32;

	global.items[itemType.trash][trashItems.duct_tape] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.twig;
	_config.name = "Graveto";
	_config.description = "Gravetos de Madeira";
	_config.sprite = spr_twig;
	_config.limit = 16;

	global.items[itemType.trash][trashItems.twig] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.rock;
	_config.name = "Pedra";
	_config.description = "Pequena Pedra";
	_config.sprite = spr_rock;
	_config.limit = 16;

	global.items[itemType.trash][trashItems.rock] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.wood_log;
	_config.name = "Tronco de Madeira";
	_config.description = "Ué";
	_config.sprite = spr_wood_log;
	_config.limit = 8;

	global.items[itemType.trash][trashItems.wood_log] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.rope;
	_config.name = "Corda";
	_config.description = "Utilizado para criação de diversos itens";
	_config.sprite = spr_rope;
	_config.limit = 8;

	global.items[itemType.trash][trashItems.rope] = _config;
}

{
	var _config = TrashConfig();
	_config.itemId = trashItems.plant_fiber;
	_config.name = "Fibra Vegetal";
	_config.description = "Utilizado para criação de diversos itens";
	_config.sprite = spr_plant_fiber;
	_config.limit = 32;

	global.items[itemType.trash][trashItems.plant_fiber] = _config;
}