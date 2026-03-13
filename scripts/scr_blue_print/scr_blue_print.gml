enum blueprints {
	nailBoard,
	ironSword,
	hammer,
	purifiedWater,
	cookedMeat1,
	cookedMeat2,
	baseballBatWithNails,
	axe
}

function Blueprint(_id, _name, _description) constructor {
    id = _id;
    name = _name;
    description = _description;
}

global.blueprints = {
    weapons: [
        new Blueprint(blueprints.nailBoard, "Blueprint: Nail Board", "Permite criar uma arma com tábuas e pregos."),
        new Blueprint(blueprints.ironSword, "Blueprint: Iron Sword", "Uma espada simples de ferro.")
    ],
	cooking: [
		new Blueprint(blueprints.purifiedWater, "Blueprint: Água Purificada", "Permite criar água purificada")
	]
};