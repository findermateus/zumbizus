event_inherited();
sprite_index = choose(spr_decoration_destroyed_car, spr_decoration_destroyed_car1);
yPositionToDrawShadow = bbox_bottom - 15;
image_index = irandom_range(0, sprite_get_number(sprite_index) - 1);
image_speed = 0;

possibleSounds = [
	snd_car_alarm,
	snd_car_alarm_2,
	snd_car_alarm_3,
	snd_car_alarm_4
];

willRingTheAlarm = choose(false, false, true);

alarmActive = false;
alarmTriggered = false;
alarmCount = 0;
alarmTotal = 0;
currentSoundInst = -1;

audioEmitter = audio_emitter_create();

audio_emitter_position(audioEmitter, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), 0);