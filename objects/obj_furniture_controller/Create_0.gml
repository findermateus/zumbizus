furnitureList = [];

function loadFurnitureList() {
    furnitureList = [];
    
    var _keys = ds_map_keys_to_array(global.baseProductiveFurnitureData);
    var _keysLength = array_length(_keys);
    
    for (var i = 0; i < _keysLength; i++) {
        var _furnitureId = _keys[i];
        var _category = global.baseProductiveFurnitureData[? _furnitureId];
        
        if (is_undefined(_category) || !is_array(_category)) continue;
        
        for (var j = 0; j < array_length(_category); j++) {
            var _furniture = _category[j];
            
            if (is_undefined(_furniture)) continue;
            
            var _data = {
                objectId: j,
                furnitureId: _furnitureId,
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