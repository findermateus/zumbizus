enum sectorList {
	crafting,
	production,
	supply,
	defense,
	trade
}

function DevelopmentSector(_title, _id) constructor {
	title = _title;
	id = _id;
	value = 0;
	level = 1;
	xp = 0
}

global.baseSectorList = [
	new DevelopmentSector("Criação", sectorList.crafting),
	new DevelopmentSector("Produção", sectorList.production),
	new DevelopmentSector("Mantimentos", sectorList.supply),
	new DevelopmentSector("Defesa", sectorList.defense),
	new DevelopmentSector("Comercio", sectorList.defense),
];