if (instance_exists(obj_player_sound_controller)) {
    obj_player_sound_controller.addSound(150, x, y, soundIntensity.high);
}

if (variable_global_exists("partSystem") && variable_global_exists("partTypeSlimeSplatter")) {
    var _qtd = irandom_range(50, 75);
    part_particles_create(global.partSystem, x, y, global.partTypeSlimeSplatter, _qtd);
}