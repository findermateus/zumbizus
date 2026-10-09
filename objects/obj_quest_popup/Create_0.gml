secondaryText = variable_instance_exists(id, "secondaryText") ? secondaryText : "";
reward        = variable_instance_exists(id, "reward") ? reward : undefined;

doneColor = merge_color(PRIMARY_COLOR, c_white, .35);

switch (popupType) {
    case QUEST_POPUP_TYPE.QUEST_COMPLETED:
        textScale      = 1.4;
        textColor      = c_white;
        accentColor    = doneColor;
        waitTime       = 180;
        label          = "MISSÃO CONCLUÍDA";
        secondaryLabel = "RECOMPENSAS";
        showCheck      = true;
        shakeForce     = 6;
        break;
    case QUEST_POPUP_TYPE.QUEST_ADDED:
        textScale      = 1.3;
        textColor      = QUEST_COLOR;
        accentColor    = QUEST_COLOR;
        waitTime       = 180;
        label          = "NOVA MISSÃO";
        secondaryLabel = "OBJETIVO";
        showCheck      = false;
        shakeForce     = 0;
        break;
}

rewardEntries = [];
rewardXpText = "";
if (popupType == QUEST_POPUP_TYPE.QUEST_COMPLETED && is_struct(reward)) {
	if (reward.xp > 0) rewardXpText = "+" + string(reward.xp) + " XP";

	for (var i = 0; i < array_length(reward.items); i++) {
		var _rewardItem = reward.items[i];
		var _config = global.items[_rewardItem.itemType][_rewardItem.itemId];
		var _quantity = _rewardItem[$ "quantity"] ?? 1;

		array_push(rewardEntries, {
			sprite: _config.sprite,
			text: (_quantity > 1 ? string(_quantity) + "x " : "") + _config.name,
			pop: 0,
			velocity: 0
		});
	}
}

hasRewards = rewardXpText != "" || array_length(rewardEntries) > 0;
hasSecondary = secondaryText != "" || hasRewards;
if (hasSecondary) waitTime += 60;

guiW = display_get_gui_width();
guiH = display_get_gui_height();
targetY  = guiH * 0.2;
currentY = targetY + 50;

state     = POPUP_STATE.QUEUED;
alpha     = 0;
timer     = 0;

openness          = 0;
openVelocity      = 0;
titlePop          = 0;
titlePopVelocity  = 0;
flash             = 0;
checkProgress     = 0;
lineProgress      = 0;
secondaryProgress = 0;
secondaryShown    = false;
shakeAmount       = 0;
shook             = false;

if (!variable_global_exists("quest_popup_queue")) {
    global.quest_popup_queue  = [];
    global.quest_popup_active = noone;
}
array_push(global.quest_popup_queue, id);
