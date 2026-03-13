if (global.pause) exit;

xMouseToGui = device_mouse_x_to_gui(0);
yMouseToGui = device_mouse_y_to_gui(0);

healthStatus.value = lerp(healthStatus.value, global.player.health, .2);
healthStatus.max = global.player.maxHealth;

staminaStatus.value = lerp(staminaStatus.value, global.player.stamina, .2);
staminaStatus.max = global.player.maxStamina;

if (array_length(equipedItemsUI) != ds_list_size(global.equipedItems)) {
	for (var i = 0; i < ds_list_size(global.equipedItems); i ++) {
		if (!arrayKeyExists(equipedItemsUI, i)) {
			equipedItemsUI[i] = equipedItemUi();
		}
	}
}