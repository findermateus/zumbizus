// Suaviza a transparência se o player estiver atrás
if (instance_exists(obj_player)) {
    var _isPlayerUnder = point_in_rectangle(obj_player.x, obj_player.y, x - sprite_xoffset, y - sprite_yoffset, x - sprite_xoffset + sprite_width, y - sprite_yoffset + sprite_height);
    image_alpha = lerp(image_alpha, _isPlayerUnder ? 0.3 : 1.0, 0.1);
}

// Recupera a escala original suavemente (O segredo do Juice)
tree_scale_x = lerp(tree_scale_x, 1, 0.15);
tree_scale_y = lerp(tree_scale_y, 1, 0.15);

// Reduz tremor e flash
shake_power = max(0, shake_power - shake_decay);
hit_flash = max(0, hit_flash - 0.1);

// Lógica de Queda
if (isDying) {
    fall_speed += 0.4; 
    fall_angle += fall_speed * fall_direction;
    
    if (abs(fall_angle) >= 90) {
        // Drop de itens
        array_foreach(drops, function (_drop) {
            var _qtd = irandom_range(_drop.minQtd, _drop.maxQtd);
            repeat(_qtd) {
                var _item = constructItem(_drop.type, global.items[_drop.type][_drop.id]);
                createItemByObjectId(id, _item, true);
            }
        });
        
        screenShake(10); // Impacto no chão
        instance_destroy();
    }
}