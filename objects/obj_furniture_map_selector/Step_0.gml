if (global.pause) exit;

event_inherited();

if (isUsing && checkConditionsToClose()){
	hide();
}