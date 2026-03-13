event_inherited();
textToDraw = "Interagir";

sprite_index = choose(spr_bush, spr_bush2);

base_scale = getScale(height, sprite_get_height(sprite_index));

image_xscale = base_scale;
image_yscale = base_scale;

target_angle = 0;
target_yscale = base_scale;
lerp_speed = 0.15;
click_life = irandom_range(2, 5);
is_dying = false;

function handlePlayerCollision() {
	if (!instance_exists(obj_player)) return;
    if (!place_meeting(x, y, obj_player)) {
		target_angle = 0;
        target_yscale = base_scale;
		
		return;
    }
	
	var _side = sign(obj_player.x - x); 
    if (_side == 0) _side = 1;
    target_angle = _side * 15; 
        
    target_yscale = base_scale * 0.8;
}

function handleClickOnBush() {
	audio_play_sound(snd_bush_hit, 0, false);
    var _dropId = choose(trashItems.twig, trashItems.plant_fiber);
    var _itemConfig = global.items[itemType.trash][_dropId];
    
    var _buildedItem = constructItem(itemType.trash, _itemConfig);
    _buildedItem.quantity = 1;
    createItemByObjectId(id, _buildedItem, true);
    
    image_yscale = base_scale * 0.4;
    image_xscale = base_scale * 1.5;
    image_angle += irandom_range(-20, 20);
    
    click_life--;
    
    if (click_life <= 0) {
        is_dying = true;
    }
}

function handleDeath() {
	if (!is_dying) {
		handlePlayerCollision();
		return;
	}
	
    target_yscale = 0;
    target_angle += 15;
    
    if (image_yscale <= 0.05) {
        instance_destroy();
    }
}