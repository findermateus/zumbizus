if (isLevelingUp) {
	pauseSystems();
	drawLevelUpWarning();
}

if (global.pause) exit;

if (barWidth > 5) {
	drawXpBar();
}

handleXpPopUps();