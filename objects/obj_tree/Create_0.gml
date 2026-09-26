event_inherited();

var _treeSprites = [
    spr_tree,
    spr_tree2,
    spr_tree3,
	spr_tree4,
	spr_tree5,
	spr_tree6
];

var _minTreeSize = 250;
var _maxTreeSize = 300;

var _randomSprite = _treeSprites[irandom(array_length(_treeSprites) - 1)];
        
var _height = irandom_range(_minTreeSize, _maxTreeSize);
var _scale = getScale(_height, sprite_get_height(_randomSprite));
		
sprite_index = _randomSprite;
image_xscale = _scale;
image_yscale = _scale;

spriteToDrawShadow = sprite_index
hp = irandom_range(70, 100);
required_tool = weaponItems.axe;
tool_error_msg = "É necessário um machado!";
hit_sounds = [snd_hit_tree1, snd_hit_tree2, snd_hit_tree3];

drops = [
	drop(trashItems.wood_log, itemType.trash, 3, 6),
	drop(trashItems.twig, itemType.trash, 1, 4)
];

fall_speed = 0;
fall_direction = 1;

onDeathStart = function() {
    fall_direction = (instance_exists(obj_player) && x - obj_player.x > 0) ? 1 : -1;
}

processDeath = function() {
    fall_speed += 0.4; 
    fall_angle += fall_speed * fall_direction;
    
    if (abs(fall_angle) >= 90) {
        screenShake(10);
        handleDeath();
    }
}