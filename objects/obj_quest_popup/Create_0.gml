switch (popupType) {
    case QUEST_POPUP_TYPE.STEP_COMPLETED:
        textScale  = 1;
        textColor  = c_yellow;
        waitTime   = 120;
        label      = "";
        showLine   = true;
        shakeForce = 2;
        break;
    case QUEST_POPUP_TYPE.QUEST_COMPLETED:
        textScale  = 1.6;
        textColor  = #4ccf1a;
        waitTime   = 180;
        label      = "";
        showLine   = true;
        shakeForce = 6;
        break;
    case QUEST_POPUP_TYPE.QUEST_ADDED:
        textScale  = 1.4;
        textColor  = #FFE566;
        waitTime   = 180;
        label      = "QUEST ADICIONADA";
        showLine   = false;
        break;
}

guiW = display_get_gui_width();
guiH = display_get_gui_height();
targetY  = guiH * 0.2;
currentY = targetY + 50;

state     = POPUP_STATE.QUEUED;
alpha     = 0;
fadeSpeed = 0.05;
timer        = 0;
lineProgress = 0;
linePadding  = 40;
shakeAmount  = 0;
shook        = false;

if (!variable_global_exists("quest_popup_queue")) {
    global.quest_popup_queue  = [];
    global.quest_popup_active = noone;
}
array_push(global.quest_popup_queue, id);