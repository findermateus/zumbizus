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

currentY    = lerp(currentY, targetY, 0.1);
shakeAmount = lerp(shakeAmount, 0, 0.15);

switch (state) {
    case POPUP_STATE.FADE_IN:
        alpha += fadeSpeed;
        if (alpha >= 1) {
            alpha = 1;
            state = POPUP_STATE.WAIT;
        }
        break;

    case POPUP_STATE.WAIT:
        timer++;
        if (showLine && timer > 10) {
            lineProgress = lerp(lineProgress, 1, 0.1);
            if (lineProgress > 0.95 && !shook) {
                shook       = true;
                shakeAmount = shakeForce;
            }
        }
        if (timer >= waitTime) {
            state   = POPUP_STATE.FADE_OUT;
            targetY -= 30;
            global.quest_popup_active = noone;
        }
        break;

    case POPUP_STATE.FADE_OUT:
        alpha -= fadeSpeed;
        if (alpha <= 0) {
            instance_destroy();
        }
        break;
}