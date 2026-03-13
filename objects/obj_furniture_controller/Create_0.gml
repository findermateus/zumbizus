furnitureList = [];

function loadFurnitureList() {
	furnitureList = [];
	for (var i = 0; i < array_length(global.baseProductiveFurnitureData); i ++) {
		var _category = global.baseProductiveFurnitureData[i];
		if (_category == undefined) continue;
		for (var j = 0; j < array_length(_category); j ++) {
			var _furniture = _category[j];
			if (_furniture == undefined) continue;
			var _data = {
				objectId: j,
				furnitureId: i,
				data: _furniture
			};
			array_push(furnitureList, _data);
		}
	}
}

function handleFurnitures() {
	array_foreach(furnitureList, function (_furniture) {
		var _data = _furniture.data;
	});
}