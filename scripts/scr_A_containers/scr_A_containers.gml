//GRID HEIGHT E GRIDWIDTH é legado, considere a contagem total
function containerConfig() {
	return {
		id: -1,
		gridWidth: 1,
		gridHeight: 1,
		sprite: spr_item_default,
		soundOpen: snd_open_container,
		soundClose: snd_close_inventory,
		furnitureHealth: 100
	}
}

function initializeContainerList() {
	global.containerMapping = ds_map_create();
	global.containerMapping[? "woodenCrate"] = furnitureIds.woodenCrate;
	global.containerMapping[? "chest"] = furnitureIds.chest;
	global.containerMapping[? "metalCabinet"] = furnitureIds.metalCabinet;
	global.containerMapping[? "metalCabinetBroken"] = furnitureIds.metalCabinetBroken;
	global.containerMapping[? "fridgeBroken"] = furnitureIds.fridgeBroken;
	global.containerMapping[? "metalCabinetDoubleDoors"] = furnitureIds.metalCabinetDoubleDoors;
	
	global.containerList = [];

	{
		var config = containerConfig();
		config.id = furnitureIds.chest;
		config.gridWidth = 4;
		config.gridHeight = 4;
		config.sprite = spr_metal_chest;
	
		global.containerList[config.id] = config;
	}

	{
		var config = containerConfig();
		config.id = furnitureIds.metalCabinet;
		config.gridWidth = 2;
		config.gridHeight = 7;
		config.sprite = spr_metal_cabinet;

		global.containerList[config.id] = config;
	}
	
	{
		var config = containerConfig();
		config.id = furnitureIds.metalCabinetBroken;
		config.gridWidth = 2;
		config.gridHeight = 7;
		config.sprite = spr_metal_cabinet_broken;

		global.containerList[config.id] = config;
	}
	
	{
		var config = containerConfig();
		config.id = furnitureIds.fridgeBroken;
		config.gridWidth = 3;
		config.gridHeight = 5;
		config.sprite = spr_fridge_broken;

		global.containerList[config.id] = config;
	}

	{
		var config = containerConfig();
		config.id = furnitureIds.metalCabinetDoubleDoors;
		config.gridWidth = 2;
		config.gridHeight = 14;
		config.sprite = spr_metal_cabinet_double_doors;

		global.containerList[config.id] = config;
	}

	{
		var config = containerConfig();
		config.id = furnitureIds.woodenCrate;
		config.gridWidth = 5;
		config.gridHeight = 2;
		config.sprite = spr_wooden_crate;

		global.containerList[config.id] = config;
	}
}