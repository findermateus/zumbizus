if (global.pause) return;
adjustClosestDepth();

if (global.activeInventory) {
	adjustDepthToASpecificObject(obj_inventory);
}

if (state == POPUP_STATE.QUEUED) {
    if (global.quest_popup_active == noone
    &&  global.quest_popup_queue[0] == id) {
        global.quest_popup_active = id;
        array_delete(global.quest_popup_queue, 0, 1);
        state = POPUP_STATE.FADE_IN;
        playSwiiimmmSound();
    }
    return;
}

timer++;

currentY    = lerp(currentY, targetY, 0.1);
shakeAmount = lerp(shakeAmount, 0, 0.15);
flash       = lerp(flash, 0, 0.08);

openVelocity += ((state == POPUP_STATE.FADE_OUT ? 0 : 1) - openness) * .16;
openVelocity *= .64;
openness += openVelocity;

titlePopVelocity += -titlePop * .3;
titlePopVelocity *= .6;
titlePop += titlePopVelocity;

if (timer == 6) {
	titlePop = .5;
	flash = 1;
}

if (timer > 10) {
	if (showCheck) checkProgress = lerp(checkProgress, 1, .12);
	lineProgress = lerp(lineProgress, 1, .1);

	if (lineProgress > .95 && !shook) {
		shook = true;
		shakeAmount = shakeForce;
	}
}

if (hasSecondary && timer > 40) secondaryShown = true;
secondaryProgress = lerp(secondaryProgress, secondaryShown, .12);

for (var i = 0; i < array_length(rewardEntries); i++) {
	var _entry = rewardEntries[i];
	var _target = timer > 48 + i * 8 ? 1 : 0;
	_entry.velocity += (_target - _entry.pop) * .25;
	_entry.velocity *= .62;
	_entry.pop += _entry.velocity;
}

switch (state) {
    case POPUP_STATE.FADE_IN:
        alpha += .1;
        if (alpha >= 1) {
            alpha = 1;
            state = POPUP_STATE.WAIT;
        }
        break;

    case POPUP_STATE.WAIT:
        if (timer >= waitTime) {
            state   = POPUP_STATE.FADE_OUT;
            targetY -= 30;
            global.quest_popup_active = noone;
        }
        break;

    case POPUP_STATE.FADE_OUT:
        alpha -= .06;
        if (alpha <= 0) {
            instance_destroy();
        }
        break;
}
