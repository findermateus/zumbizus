if (instance_exists(enemy)) {
    obj_player.playerGetHit(0, 2, 0, damageType.blunt, false);
    
    juice_shake += 5; 
    
    alarm[0] = damage_interval;
}