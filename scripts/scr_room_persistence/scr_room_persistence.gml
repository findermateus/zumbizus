function initializeRoomPersistenceGlobals() {
    global.visitedPersistentRooms = {};
    global.roomSnapshots = {};
    global.persistentRoomId = "";
    global.persistentRoomInitializer = undefined;
}

initializeRoomPersistenceGlobals();

function savePersistentRoomSnapshot(_roomId) {
	var _itemList = [];

	with (obj_item) {
		var _itemData = {
			x: x,
			y: y,
			item: item,
			angle: angle,
			image_angle: image_angle
		};

		array_push(_itemList, _itemData);
	}
	
	var _lightList = [];
	
	with(obj_uls_light) {
		var _lightData = {
			x: x,
			y: y,
			objIndex: object_index,
			lightInitialRadius: light_initial_radius,
			imageBlend: image_blend,
			imageAlpha: image_alpha
		};
		
		array_push(_lightList, _lightData);
	}

	global.roomSnapshots[$ _roomId] = {
		items: _itemList,
		lights: _lightList
	};
}

function loadRoomSnapshot(_roomId) {
	var _roomSnapshot = global.roomSnapshots[$ _roomId];

	instance_destroy(obj_item);

	array_foreach(_roomSnapshot.items, function (_item) {
		var _itemInstance = instance_create_layer(
			_item.x,
			_item.y,
			"Items",
			obj_item,
			_item
		);

		_itemInstance.item = _item.item;
		_itemInstance.angle = _item.angle;
		_itemInstance.image_angle = _item.image_angle;
	});
	
	array_foreach(_roomSnapshot.lights, function (_light) {
		var _itemInstance = instance_create_layer(
			_light.x,
			_light.y,
			"Particles",
			_light.objIndex,
			{
				light_initial_radius: _light.lightInitialRadius,
				image_alpha: _light.imageAlpha,
				image_blend: _light.imageBlend
			}
		);
	});
}