openMenu(Menus.Dialogue);
blockPlayerMenus();

obj_player.currentState = playerDialogueState;

if (!is_struct(dialogue)) {
	instance_destroy(id);
}

if (instance_exists(target)) {
	obj_camera.setTargetWithZoom(target);
}