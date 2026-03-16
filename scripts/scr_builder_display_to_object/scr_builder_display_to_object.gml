function FurnitureObjectConversorBuilder(_obj, _info = {}) constructor{
	object = _obj;
	info = _info;
}

function initializeFurnitureObjectConversion() {
	global.furnitureObjectConversor = ds_map_create();

	global.furnitureObjectConversor[? global.furnitureIds.sofa] = new FurnitureObjectConversorBuilder(obj_furniture_colidable, {
		furnitureHealth: 100
	});

	global.furnitureObjectConversor[? global.furnitureIds.woodenCrate] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.woodenCrate]);
	global.furnitureObjectConversor[? global.furnitureIds.chest] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.chest]);
	global.furnitureObjectConversor[? global.furnitureIds.metalCabinet] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.metalCabinet]);
	global.furnitureObjectConversor[? global.furnitureIds.metalCabinetDoubleDoors] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.metalCabinetDoubleDoors]);
	global.furnitureObjectConversor[? global.furnitureIds.metalCabinetBroken] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.metalCabinetBroken]);
	global.furnitureObjectConversor[? global.furnitureIds.fridgeBroken] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[? global.furnitureIds.fridgeBroken]);

	global.furnitureObjectConversor[? global.furnitureIds.meeleCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_crafting, {
		furnitureHealth: 200
	});

	global.furnitureObjectConversor[? global.furnitureIds.medicineCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_crafting, {
		furnitureHealth: 200
	});

	global.furnitureObjectConversor[? global.furnitureIds.campfire] = new FurnitureObjectConversorBuilder(obj_furniture_campfire, {
		furnitureHealth: 50
	});

	global.furnitureObjectConversor[? global.furnitureIds.simpleCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_simple_crafting_station, {
		furnitureHealth: 50
	});
}