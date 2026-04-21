if (isStep) {
    textScale   = 1;
    textColor   = c_yellow;
    waitTime    = 120;
} else {
    textScale   = 1.6;
    textColor   = #4ccf1a;
    waitTime    = 180;
}

guiW = display_get_gui_width();
guiH = display_get_gui_height();

targetY  = guiH * 0.2;
currentY = targetY + 50;

enum POPUP_STATE {
    QUEUED,
    FADE_IN,
    WAIT,
    FADE_OUT
}
state = POPUP_STATE.QUEUED;

alpha     = 0;
fadeSpeed = 0.05;

timer        = 0;
lineProgress = 0;
linePadding  = 40;

shakeAmount = 0;
shook       = false;

if (!variable_global_exists("quest_popup_queue")) {
    global.quest_popup_queue  = [];
    global.quest_popup_active = noone;
}
array_push(global.quest_popup_queue, id);