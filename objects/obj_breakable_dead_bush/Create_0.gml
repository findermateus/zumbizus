event_inherited();

image_index = irandom_range(0, sprite_get_number(sprite_index) - 1);

currentSpriteFrame = image_index;
spriteToDrawShadow = sprite_index;

hp = 5;
required_tool = noone;
tool_error_msg = "";

hit_sounds = [snd_hit_tree1, snd_hit_tree2, snd_hit_tree3];

drops = [
	drop(trashItems.twig, itemType.trash, 1, 3)
];

processDeath = function() {
    screenShake(5);
    handleDeath(); 
}

