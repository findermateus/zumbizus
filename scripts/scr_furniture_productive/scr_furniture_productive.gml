function WorkerRequirement(_attribute, _level) constructor {
	attribute = _attribute;
	level = _level;
	
	function verifyWorker(_worker) {
		return _worker.attributes[self.attribute].level >= self.level;
	}
}

function ProductiveFurniture(_id, _attribute, _workerQuantity, _workerRequirements) constructor {
	id = _id
	attribute = _attribute;
	workerQuantity = _workerQuantity;
	workerRequirements = _workerRequirements;
}

function ProductiveFurnitureData(_id, _objectId) constructor {
	id = _id;
	objectId = _objectId;
	workers = [];
}

global.productiveFurnitures = [];

global.productiveFurnitures[furnitureIds.campfire] = new ProductiveFurniture(furnitureIds.campfire, baseAttribute.supplies, 1, [
	new WorkerRequirement(baseAttribute.supplies, 1)
]);
global.productiveFurnitures[furnitureIds.meeleCraftingStation] = new ProductiveFurniture(furnitureIds.meeleCraftingStation, baseAttribute.crafting, 1, [
	new WorkerRequirement(baseAttribute.crafting, 1)
]);
global.productiveFurnitures[furnitureIds.medicineCraftingStation] = new ProductiveFurniture(furnitureIds.medicineCraftingStation, baseAttribute.crafting, 1, [
	new WorkerRequirement(baseAttribute.supplies, 1)
]);