if (global.timeStopped) {
	exit;
}

currentState();
defineWeaponPosition();
adjustClosestDepth();