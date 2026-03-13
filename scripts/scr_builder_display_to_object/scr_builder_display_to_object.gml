function FurnitureObjectConversorBuilder(_obj, _info = {}) constructor{
	object = _obj;
	info = _info;
}

function initializeFurnitureObjectConversion() {
	global.furnitureObjectConversor = [];

	global.furnitureObjectConversor[furnitureIds.sofa] = new FurnitureObjectConversorBuilder(obj_furniture_colidable, {
		furnitureHealth: 100
	});

	global.furnitureObjectConversor[furnitureIds.woodenCrate] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.woodenCrate]);
	global.furnitureObjectConversor[furnitureIds.chest] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.chest]);
	global.furnitureObjectConversor[furnitureIds.metalCabinet] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.metalCabinet]);
	global.furnitureObjectConversor[furnitureIds.metalCabinetDoubleDoors] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.metalCabinetDoubleDoors]);
	global.furnitureObjectConversor[furnitureIds.metalCabinetBroken] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.metalCabinetBroken]);
	global.furnitureObjectConversor[furnitureIds.fridgeBroken] = new FurnitureObjectConversorBuilder(obj_chest, global.containerList[furnitureIds.fridgeBroken]);

	global.furnitureObjectConversor[furnitureIds.meeleCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_crafting, {
		furnitureHealth: 200
	});

	global.furnitureObjectConversor[furnitureIds.medicineCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_crafting, {
		furnitureHealth: 200
	});

	global.furnitureObjectConversor[furnitureIds.campfire] = new FurnitureObjectConversorBuilder(obj_furniture_campfire, {
		furnitureHealth: 50
	});

	global.furnitureObjectConversor[furnitureIds.simpleCraftingStation] = new FurnitureObjectConversorBuilder(obj_furniture_simple_crafting_station, {
		furnitureHealth: 50
	});
}

initializeContainerList();
initializeFurnitureObjectConversion();