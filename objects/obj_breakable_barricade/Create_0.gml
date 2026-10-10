event_inherited();

spriteToDrawShadow = sprite_index;

hp = 30;
required_tool = noone;
tool_error_msg = "";

hit_sounds = [snd_hit_tree1, snd_hit_tree2];

drops = [
	drop(trashItems.nail, itemType.trash, 1, 3),
	drop(trashItems.wood_board, itemType.trash, 1, 2)
];

processDeath = function() {
    screenShake(5);
    handleDeath(); 
}