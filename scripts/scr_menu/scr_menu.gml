enum Menus {
	Campfire,
	FurnitureCrafting,
	MapSelector,
	SimpleCrafting,
	Builder,
	ResidentController,
	Inventory,
	Dialogue,
	NpcInteraction,
	Trade
}

function isCurrentMenu(_menu) {
	return global.activeMenu == _menu;
}