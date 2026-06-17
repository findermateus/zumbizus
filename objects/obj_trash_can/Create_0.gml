event_inherited();

textToDraw = "Investigar";

base_scale = 1;

target_angle = 0;
target_xscale = base_scale;
target_yscale = base_scale;

lerp_speed = 0.15;

is_dying = false;
was_searched = false;

shake_timer = 0;
shake_duration = 24;
shake_strength = 6;

fade_speed = 0.015;

base_x = x;
shake_offset_x = 0;

questTag = "";

yPositionToDrawShadow = y - 20;

dropItems = [
	{
		type: itemType.trash,
		itemId: trashItems.twig,
		min: 1,
		max: 2,
		chance: 80
	},
	{
		type: itemType.trash,
		itemId: trashItems.plant_fiber,
		min: 1,
		max: 2,
		chance: 70
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.watter_bottle,
		min: 1,
		max: 1,
		chance: 35
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.canned_pineapple,
		min: 1,
		max: 1,
		chance: 25
	}
];

function handlePlayerCollision() {
	if (!instance_exists(obj_player)) return;

	if (!place_meeting(x, y, obj_player)) {
		target_angle = 0;
		target_yscale = base_scale;
		return;
	}

	var _side = sign(obj_player.x - x);

	if (_side == 0) {
		_side = 1;
	}

	target_angle = _side * 8;
	target_yscale = base_scale * 0.95;
}

function getTrashDropQuantity(_drop) {
	if (variable_struct_exists(_drop, "quantity")) {
		return _drop.quantity;
	}

	var _min = variable_struct_exists(_drop, "min") ? _drop.min : 1;
	var _max = variable_struct_exists(_drop, "max") ? _drop.max : _min;

	return irandom_range(_min, _max);
}

function shouldDropTrashItem(_drop) {
	if (!variable_struct_exists(_drop, "chance")) {
		return true;
	}

	return irandom(99) < _drop.chance;
}

function createTrashDrop(_drop) {
	if (!shouldDropTrashItem(_drop)) {
		return false;
	}

	var _itemConfig = global.items[_drop.type][_drop.itemId];
	var _buildedItem = constructItem(_drop.type, _itemConfig);

	_buildedItem.quantity = getTrashDropQuantity(_drop);

	createItemByObjectId(id, _buildedItem, true);

	return true;
}

function createTrashDrops() {
	var _createdAny = false;

	for (var i = 0; i < array_length(dropItems); i++) {
		if (createTrashDrop(dropItems[i])) {
			_createdAny = true;
		}
	}

	if (!_createdAny && array_length(dropItems) > 0) {
		var _drop = dropItems[irandom(array_length(dropItems) - 1)];
		var _itemConfig = global.items[_drop.type][_drop.itemId];
		var _buildedItem = constructItem(_drop.type, _itemConfig);

		_buildedItem.quantity = getTrashDropQuantity(_drop);

		createItemByObjectId(id, _buildedItem, true);
	}
}

function handleClickOnTrashCan() {
	if (was_searched || is_dying) {
		return;
	}

	was_searched = true;

	audio_play_sound(snd_can, 0, false);

	createTrashDrops();

	if (questTag != "") {
		obj_quest_manager.notifyEvent(QuestEvent.ObjectInteracted, {
			tag: questTag,
			object: id
		});
	}

	shake_timer = shake_duration;
	is_dying = true;
}

function handleDeath() {
	if (!is_dying) {
		handlePlayerCollision();
		return;
	}

	target_angle = 0;
	target_xscale = base_scale;
	target_yscale = base_scale;

	image_alpha = max(0, image_alpha - fade_speed);

	if (image_alpha <= 0.02) {
		instance_destroy();
	}
}