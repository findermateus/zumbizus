if (global.pause) exit;

event_inherited();

if (checkConditionsToClose() && isUsing){
	audio_play_sound(snd_close_crafting_station, 0, false);
	hide();
}

yPositionToDrawShadow = getMiddlePoint(bbox_top, bbox_bottom);
