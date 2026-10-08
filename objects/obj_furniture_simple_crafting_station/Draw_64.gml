if (global.pause) exit;

event_inherited();

if (!isMenuVisible()) return;
drawSimpleCraftingStationUI();
