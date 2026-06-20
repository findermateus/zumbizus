handleHover();
adjustObjectDepth();

if (!isRemoving && isHovering && mouse_check_button_pressed(mb_left)) {
	if (canRemoveBlockage()) {
		removeBlockage();
	} else {
		showWeakDialogue();
	}
}

if (isRemoving) {
	image_alpha = max(0, image_alpha - removeSpeed);

	if (image_alpha <= 0.02) {
		instance_destroy();
	}
}