if (array_length(possibleItems) == 0) {
	instance_destroy(id);
}

var _selectedItem = getWeightItemRandom(possibleItems);

instance_create_layer(x, y, "Items", obj_item_spawner, {
	itemId: _selectedItem.id,
	type: _selectedItem.type,
	quantity: 1
});

instance_destroy(id);