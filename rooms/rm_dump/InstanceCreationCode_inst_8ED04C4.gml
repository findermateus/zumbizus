containerInitializer = function() {
	createDroppedItem(consumableItems.canned_food, itemType.consumables, 860, 320, 1);
	
	instance_create_layer(880, 500, "Instances", obj_animal_rat);
}

roomId = "container_001";