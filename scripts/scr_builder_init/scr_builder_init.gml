global.activeBuilding = false;
enum furnitureCategories {
	decoration,
	storage,
	resources,
	creation,
}

global.furnitureCategories = [
	{
		type: furnitureCategories.decoration,
		displayTitle: "Decoração"
	},
	{
		type: furnitureCategories.storage,
		displayTitle: "Armazenamento"
	},
	{
		type: furnitureCategories.creation,
		displayTitle: "Criação"
	},
	{
		type: furnitureCategories.resources,
		displayTitle: "Recursos"
	},
];

function FurnitureBuilder(_id, _type, _title, _sprite = spr_wooden_crate, _personalizedMargin = 20, _requirements = [], _icon = undefined) constructor {
	furnitureId = _id
	type = _type;
	title =  _title;
	sprite = _sprite;
	icon = _icon == undefined ? _sprite : _icon;
	personalizedMargin = _personalizedMargin;
	requirements = _requirements
}

function RequirementBuilder(_itemId, _quantity = 1, _type = itemType.trash) constructor {
	itemId = _itemId;
	quantity = _quantity;
	type = _type;
}

enum furnitureIds {
    sofa,
	woodenCrate,
	chest,
	metalCabinet,
	metalCabinetDoubleDoors,
	metalCabinetBroken,
	fridgeBroken,
    campfire,
    meeleCraftingStation,
	medicineCraftingStation,
	simpleCraftingStation
}

global.furniture = [];

var _chestRequirements = [
	new RequirementBuilder(trashItems.wood_board, 8),
	new RequirementBuilder(trashItems.nail, 4),
];
var _chairRequirements = [
	new RequirementBuilder(trashItems.wood_board, 4),
	new RequirementBuilder(trashItems.nail, 8),
	new RequirementBuilder(trashItems.empty_watter_bottle, 4),
	new RequirementBuilder(trashItems.empty_canned_food, 12),
]
var _meeleCraftingStationRequirements = [
	new RequirementBuilder(trashItems.wood_board, 10),
	new RequirementBuilder(trashItems.nail, 20),
	new RequirementBuilder(trashItems.empty_watter_bottle, 3)
];

var _woodenCrateRequirements = [
	new RequirementBuilder(trashItems.wood_board, 12, itemType.trash),
	new RequirementBuilder(trashItems.rope, 5, itemType.trash)
];

global.furniture[furnitureCategories.decoration] = [
    new FurnitureBuilder(furnitureIds.sofa, furnitureCategories.decoration, "Sofá", spr_sofa, 110, _chestRequirements),
];

global.furniture[furnitureCategories.storage] = [
	new FurnitureBuilder(furnitureIds.woodenCrate, furnitureCategories.storage, "Caixote de madeira", spr_wooden_crate, 100, _woodenCrateRequirements),
	new FurnitureBuilder(furnitureIds.chest, furnitureCategories.storage, "Gavetas de metal", spr_metal_chest, 100, _chestRequirements),
	new FurnitureBuilder(furnitureIds.metalCabinet, furnitureCategories.storage, "Armário de Metal (1 porta)", spr_metal_cabinet, 80, _chestRequirements)
];

var _campfireRequirements = [
	new RequirementBuilder(trashItems.wood_board, 1)
];

var _simpleCraftingStationRequirements = [
	new RequirementBuilder(trashItems.twig, 15, itemType.trash),
	new RequirementBuilder(trashItems.rock, 5, itemType.trash)
];

global.furniture[furnitureCategories.creation] = [
	new FurnitureBuilder(furnitureIds.simpleCraftingStation, furnitureCategories.creation, "Estação de criação", spr_simple_crafting_station, 80, _simpleCraftingStationRequirements),
    new FurnitureBuilder(furnitureIds.meeleCraftingStation, furnitureCategories.creation, "Estação de construção para armas corpo a corpo", spr_meele_crafting_station, 80, _meeleCraftingStationRequirements),
	new FurnitureBuilder(furnitureIds.medicineCraftingStation, furnitureCategories.creation, "Estação de construção para medicina", spr_medicine_crafting_station, 80, _meeleCraftingStationRequirements),
    new FurnitureBuilder(furnitureIds.campfire, furnitureCategories.creation, "Fogueira", spr_campfire, 80, _campfireRequirements, spr_campfire_icon),
];

global.furniture[furnitureCategories.resources] = [
    
];
