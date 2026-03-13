loadPlayerData();

var _roomWidth = room_width;
var _roomHeight = room_height;
var _grassSprite = tg_sGrass;

var _camW = global.defaultCameraWidth;
var _camH = global.defaultCameraHeight;

var _xScale = getScale(_camW, sprite_get_width(_grassSprite));
var _yScale = getScale(_camH, sprite_get_height(_grassSprite));

for (var _xx = 0; _xx < _roomWidth; _xx += _camW) {
    for (var _yy = 0; _yy < _roomHeight; _yy += _camH) {
        
        instance_create_layer(_xx, _yy, "GroundEffect", tg_oGrass, {
            image_xscale: _xScale,
            image_yscale: _yScale,
        });
    }
}

var _treeSprites = [
    spr_tree,
    spr_tree2,
    spr_tree3,
	spr_tree4,
	spr_tree5,
	spr_tree6
];

var _density = 0.5;          // Densidade (0.1 = 10% de ocupação, 0.2 = 20%, etc.)
var _minTreeSize = 250;
var _maxTreeSize = 300;
var _treeAverageSize = mean(_minTreeSize, _maxTreeSize);    // Espaço médio (em pixels) que uma árvore ocupa (largura/altura)

// Cálculo automático da quantidade
var _roomArea = _roomWidth * _roomHeight;
var _treeArea = _treeAverageSize * _treeAverageSize;
var _totalTrees = floor((_roomArea / _treeArea) * _density);

var _maxAttempts = 5;
var _margin = 32;

repeat(_totalTrees) {
    var _success = false;
    var _attempts = 0;
    
    while (!_success && _attempts < _maxAttempts) {
		var _xx = irandom_range(_margin, _roomWidth - _margin);
        var _yy = irandom_range(_margin, _roomHeight - _margin);
        
        var _randomSprite = _treeSprites[irandom(array_length(_treeSprites) - 1)];
        
		var _height = irandom_range(_minTreeSize, _maxTreeSize);
		var _scale = getScale(_height, sprite_get_height(_randomSprite));
		
        var _inst = instance_create_layer(_xx, _yy, "GroundEffect", obj_tree, {
			sprite_index: _randomSprite,
			image_xscale: _scale,
			image_yscale: _scale
		});
        
        with (_inst) {
            if (place_meeting(x, y, obj_tree)) {
                instance_destroy();
            } else {
                _success = true;
            }
        }
        _attempts++;
    }
}

var _possibleItems = [
	global.items[itemType.trash][trashItems.rock]
];

repeat(irandom_range(15, 30)) {
	var _itemsLength = array_length(_possibleItems);
	
	var _selectedIndex = irandom_range(0, _itemsLength - 1);
    var _selectedItem  = _possibleItems[_selectedIndex];
	
	var _itemToCreate = constructItem(_selectedItem.type, _selectedItem);

	var _x = irandom_range(64, _roomWidth - 64);
	var _y = irandom_range(64, _roomHeight - 64);

	var _droppedItem = instance_create_layer(_x, _y, "Items", obj_item);
	_droppedItem.item = _itemToCreate;
}

var _pairCount = irandom_range(1, 3);
var _spawnMargin = 100;
var _pairDistance = sprite_get_width(spr_deer_female_iddle) *  2;

repeat(_pairCount) {
    var _baseX = irandom_range(_spawnMargin, _roomWidth - _spawnMargin);
    var _baseY = irandom_range(_spawnMargin, _roomHeight - _spawnMargin);
    
    instance_create_layer(
        _baseX, 
        _baseY, 
        "Instances", 
        obj_animal_deer,
		{ gender: "male" }
    );
    
    var _offsetX = irandom_range(-_pairDistance, _pairDistance);
    var _offsetY = irandom_range(-_pairDistance, _pairDistance);
    
    instance_create_layer(
        _baseX + _offsetX, 
        _baseY + _offsetY, 
        "Instances", 
        obj_animal_deer,
		{ gender: "female" }
    );
}

// --- GERAÇÃO DE ARBUSTOS ---

var _bushDensity = 0.05;            // Ajuste para mais ou menos arbustos
var _minH = 60;                    // Altura mínima que o objeto aceita
var _maxH = 80;                   // Altura máxima que o objeto aceita
var _bushAvg = mean(_minH, _maxH);

// Quantidade baseada na área da sala
var _totalBushes = floor((_roomArea / (_bushAvg * _bushAvg)) * _bushDensity);

repeat(_totalBushes) {
    var _success = false;
    var _attempts = 0;
    
    while (!_success && _attempts < 10) {
        var _xx = irandom_range(_margin, _roomWidth - _margin);
        var _yy = irandom_range(_margin, _roomHeight - _margin);
        
        // Criamos passando apenas o parâmetro 'height'
        var _inst = instance_create_layer(_xx, _yy, "GroundEffect", obj_bush, {
            height: irandom_range(_minH, _maxH)
        });
        
        with (_inst) {
            // Verifica colisão com outras árvores ou arbustos
            // Nota: Como o objeto se ajusta sozinho, ele usará a máscara escalonada aqui
            if (place_meeting(x, y, obj_tree) || place_meeting(x, y, obj_bush)) {
                instance_destroy();
            } else {
                _success = true;
            }
        }
        _attempts++;
    }
}