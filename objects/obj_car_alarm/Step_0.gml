event_inherited();

if (!instance_exists(obj_player)) exit;

if (willRingTheAlarm && !alarmTriggered) {
    if (distance_to_object(obj_player) < 15) {
        alarmActive = true;
        alarmTriggered = true;
        alarmCount = 0;
        alarmTotal = irandom_range(4, 7);
    }
}

if (alarmActive) {
    if (currentSoundInst == -1 || !audio_is_playing(currentSoundInst)) {
        
        if (alarmCount < alarmTotal) {
            var _snd = possibleSounds[irandom(array_length(possibleSounds) - 1)];
            
            currentSoundInst = playSoundRelativeToPlayer(
                audioEmitter,
                _snd,
                false,
                10,
                300,
                1200,
                1.5
            );
            
            alarmCount++;
            
            if (instance_exists(obj_player_sound_controller)) {
                obj_player_sound_controller.addSound(975, getMiddlePoint(bbox_left, bbox_right), getMiddlePoint(bbox_top, bbox_bottom), soundIntensity.high, id);
            }
        } else {
            alarmActive = false;
        }
    }
}