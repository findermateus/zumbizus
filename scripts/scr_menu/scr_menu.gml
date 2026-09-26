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
	Trade,
	Cutscene
}

function isCurrentMenu(_menu) {
	return global.activeMenu == _menu;
}

function handleMenuEscape() {
	if (closeItemOptionsMenu()) return true;

	var _onEscape = global.activeMenuOnEscape;

	if (!is_callable(_onEscape)) return false;

	_onEscape();

	return true;
}