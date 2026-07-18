event_inherited();

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