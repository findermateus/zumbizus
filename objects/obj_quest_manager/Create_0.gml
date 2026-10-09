#macro QUEST_TRACKER_WIDTH 380
#macro QUEST_TRACKER_PADDING 26
#macro QUEST_TRACKER_MARGIN 30
#macro QUEST_TRACKER_TOP 50
#macro QUEST_TRACKER_HEADER 44
#macro QUEST_ENTRY_GAP 18
#macro QUEST_ENTRY_INDENT 16
#macro QUEST_STEP_SCALE .75
#macro QUEST_PROGRESS_HEIGHT 34
#macro QUEST_LEAVE_TIME 80
#macro QUEST_STEP_DONE_TIME 70
#macro QUEST_TOAST_TIME 150
#macro QUEST_TOAST_WRAP 260

trackerOffsetX = 0;
trackerHover = 0;
trackerHeight = 0;
trackedQuests = [];
doneColor = merge_color(PRIMARY_COLOR, c_white, .35);

#region rastreamento das missões no HUD

function getTrackedQuestEntry(_quest) {
	for (var i = 0; i < array_length(trackedQuests); i++) {
		if (trackedQuests[i].quest == _quest) return trackedQuests[i];
	}
	return undefined;
}

function syncTrackedQuests() {
	for (var i = 0; i < array_length(activeQuests); i++) {
		var _quest = activeQuests[i];
		if (!is_undefined(getTrackedQuestEntry(_quest))) continue;

		array_push(trackedQuests, {
			quest: _quest,
			appear: 0,
			appearVelocity: 0,
			height: 0,
			measured: 0,
			flash: 1,
			leaving: false,
			leaveTimer: 0,
			stepIndex: _quest.currentStepIndex,
			stepSwap: 1,
			counters: {},
			completedStepText: "",
			completedTimer: 0,
			completedCheck: 0,
			toast: { text: "", timer: 0, progress: 0, velocity: 0 }
		});
	}

	for (var i = array_length(trackedQuests) - 1; i >= 0; i--) {
		var _entry = trackedQuests[i];

		if (!_entry.leaving && !array_contains(activeQuests, _entry.quest)) {
			_entry.leaving = true;
			_entry.leaveTimer = QUEST_LEAVE_TIME;
			_entry.flash = 1;
		}

		if (_entry.leaving && _entry.leaveTimer <= 0 && _entry.height < 1) {
			array_delete(trackedQuests, i, 1);
		}
	}
}

function onStepCompleted(_quest, _step, _hasNextStep) {
	var _entry = getTrackedQuestEntry(_quest);
	if (is_undefined(_entry) || !_hasNextStep) return;

	_entry.completedStepText = _step.description;
	_entry.completedTimer = QUEST_STEP_DONE_TIME;
	_entry.completedCheck = 0;
	_entry.flash = 1;

	_entry.toast.text = _step.description;
	_entry.toast.timer = QUEST_TOAST_TIME;

	playSwiiimmmSound(.4);
}

function updateQuestEntry(_entry) {
	if (_entry.leaving && _entry.leaveTimer > 0) _entry.leaveTimer--;

	var _isVisible = !_entry.leaving || _entry.leaveTimer > 0;

	_entry.appearVelocity += ((_isVisible ? 1 : 0) - _entry.appear) * .18;
	_entry.appearVelocity *= .65;
	_entry.appear += _entry.appearVelocity;
	_entry.height = lerp(_entry.height, _isVisible ? _entry.measured : 0, .2);
	_entry.flash = lerp(_entry.flash, 0, .05);
	_entry.stepSwap = lerp(_entry.stepSwap, 1, .15);

	if (_entry.completedTimer > 0) {
		_entry.completedTimer--;
		_entry.completedCheck = lerp(_entry.completedCheck, 1, .15);
		_entry.stepSwap = 0;
	}

	var _toast = _entry.toast;
	if (_toast.timer > 0) _toast.timer--;
	_toast.velocity += ((_toast.timer > 0 ? 1 : 0) - _toast.progress) * .2;
	_toast.velocity *= .65;
	_toast.progress += _toast.velocity;

	if (!_entry.leaving && _entry.stepIndex != _entry.quest.currentStepIndex) {
		_entry.stepIndex = _entry.quest.currentStepIndex;
		_entry.stepSwap = 0;
		_entry.flash = max(_entry.flash, .6);
		_entry.counters = {};
	}
}

function getQuestContentWidth() {
	return QUEST_TRACKER_WIDTH - QUEST_TRACKER_PADDING * 2 - QUEST_ENTRY_INDENT;
}

function getStepProgressList(_step) {
	var _list = [];

	for (var i = 0; i < array_length(_step.objectives); i++) {
		var _objective = _step.objectives[i];
		array_push(_list, {
			label: global.items[_objective.type][_objective.itemId].name,
			count: _objective.count,
			target: _objective.target
		});
	}

	if (array_length(_list) > 0) return _list;

	if (variable_struct_exists(_step, "killTarget")) {
		array_push(_list, { label: "Abates", count: _step.killCount, target: _step.killTarget });
	} else if (variable_struct_exists(_step, "collectCount")) {
		array_push(_list, { label: "Coletados", count: _step.collectCount, target: _step.collectTarget });
	}

	return _list;
}

function measureQuestEntry(_entry) {
	var _width = getQuestContentWidth();
	var _step = _entry.quest.getCurrentStep();

	draw_set_font(fnt_gui_long_text);
	var _height = string_height_ext(_entry.quest.name, -1, _width) + 8;

	if (_entry.leaving || is_undefined(_step)) {
		return _height + string_height("A") * QUEST_STEP_SCALE;
	}

	if (_entry.completedTimer > 0) {
		return _height + string_height_ext(_entry.completedStepText, -1, (_width - 24) / QUEST_STEP_SCALE) * QUEST_STEP_SCALE;
	}

	_height += string_height_ext(_step.description, -1, _width / QUEST_STEP_SCALE) * QUEST_STEP_SCALE;
	_height += array_length(getStepProgressList(_step)) * QUEST_PROGRESS_HEIGHT;

	return _height;
}

#endregion

#region desenho do HUD

function drawQuests() {
	syncTrackedQuests();

	var _count = array_length(trackedQuests);
	if (_count == 0) {
		trackerHeight = 0;
		return;
	}

	var _targetOffset = isMenuOpen() ? -(QUEST_TRACKER_WIDTH + QUEST_TRACKER_MARGIN + 40) : 0;
	trackerOffsetX = lerp(trackerOffsetX, _targetOffset, .12);

	var _contentHeight = 0;
	for (var i = 0; i < _count; i++) {
		var _entry = trackedQuests[i];
		_entry.measured = measureQuestEntry(_entry);
		updateQuestEntry(_entry);

		if (i > 0) _contentHeight += QUEST_ENTRY_GAP * clamp(_entry.height / max(1, _entry.measured), 0, 1);
		_contentHeight += _entry.height;
	}

	var _targetHeight = QUEST_TRACKER_PADDING * 2 + QUEST_TRACKER_HEADER + _contentHeight;
	trackerHeight = trackerHeight == 0 ? _targetHeight : lerp(trackerHeight, _targetHeight, .25);

	if (isMenuOpen() && abs(trackerOffsetX - _targetOffset) < 2) return;

	var _x = QUEST_TRACKER_MARGIN + trackerOffsetX;
	var _y = QUEST_TRACKER_TOP;

	var _isHovering = mouseIsOnRectangle(_x, _y, _x + QUEST_TRACKER_WIDTH, _y + trackerHeight);
	trackerHover = lerp(trackerHover, _isHovering, .15);

	var _contentX = _x + QUEST_TRACKER_PADDING;
	var _entryPositions = [];
	var _entryY = _y + QUEST_TRACKER_PADDING + QUEST_TRACKER_HEADER;

	for (var i = 0; i < _count; i++) {
		var _entry = trackedQuests[i];
		if (i > 0) _entryY += QUEST_ENTRY_GAP * clamp(_entry.height / max(1, _entry.measured), 0, 1);
		_entryPositions[i] = _entryY;
		_entryY += _entry.height;
	}

	for (var i = 0; i < _count; i++) {
		drawQuestToast(trackedQuests[i], _x + QUEST_TRACKER_WIDTH, _entryPositions[i]);
	}

	draw_set_alpha(.92);
	drawInventoryPanelBackground(_x, _y, QUEST_TRACKER_WIDTH, trackerHeight);
	draw_set_alpha(1);

	if (trackerHover > .05) {
		var _padding = 4 + (1 - trackerHover) * 8 + sin(current_time / 180) * 2;
		drawCornerBrackets(_x - _padding, _y - _padding, _x + QUEST_TRACKER_WIDTH + _padding, _y + trackerHeight + _padding, c_white, trackerHover * .6, 12, 2);
	}

	drawTrackerHeader(_contentX, _y + QUEST_TRACKER_PADDING);

	for (var i = 0; i < _count; i++) {
		var _entry = trackedQuests[i];
		var _alpha = clamp(_entry.appear, 0, 1);
		if (_alpha > .02) drawQuestEntry(_entry, _contentX, _entryPositions[i], _alpha);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_font(fnt_gui_default);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawTrackerHeader(_x, _y) {
	var _centerY = _y + QUEST_TRACKER_HEADER / 2 - 6;

	draw_set_font(fnt_gui_title);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	drawTextShadow(_x, _centerY, "Missões", 1);
	draw_text(_x, _centerY, "Missões");

	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	return _y + QUEST_TRACKER_HEADER;
}

function drawQuestEntry(_entry, _x, _y, _alpha) {
	var _quest = _entry.quest;
	var _width = getQuestContentWidth();
	var _isDone = _entry.leaving;
	var _accent = _isDone ? doneColor : QUEST_COLOR;
	var _textX = _x + QUEST_ENTRY_INDENT - (1 - _entry.appear) * 30;
	var _visibleHeight = min(_entry.height, _entry.measured);

	draw_set_alpha(_alpha);
	draw_set_color(_accent);
	draw_rectangle(_x, _y + 2, _x + 3, _y + max(2, _visibleHeight - 4), false);

	if (_entry.flash > .02) {
		draw_set_color(c_white);
		draw_set_alpha(_alpha * _entry.flash * .12);
		draw_rectangle(_x, _y - 4, _x + QUEST_TRACKER_WIDTH - QUEST_TRACKER_PADDING * 2, _y + _visibleHeight, false);
		draw_set_alpha(_alpha);
	}

	draw_set_font(fnt_gui_long_text);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);

	var _nameHeight = string_height_ext(_quest.name, -1, _width);
	drawTextExtShadow(_textX, _y, _quest.name, -1, _width, _alpha, 3, 1);
	draw_set_color(merge_color(_accent, c_white, _entry.flash * .6));
	draw_text_ext(_textX, _y, _quest.name, -1, _width);

	if (_isDone) {
		var _strike = clamp((QUEST_LEAVE_TIME - _entry.leaveTimer) / 20, 0, 1);
		var _strikeY = _y + string_height("A") / 2;
		draw_set_color(_accent);
		draw_line_width(_textX - 4, _strikeY, _textX - 4 + (min(string_width(_quest.name), _width) + 8) * _strike, _strikeY, 3);
	}

	var _stepY = _y + _nameHeight + 8;
	var _step = _quest.getCurrentStep();

	if (_isDone || is_undefined(_step)) {
		var _doneText = "Missão concluída!";
		var _pulse = .8 + sin(current_time / 120) * .2;
		drawCheckMark(_textX + 8, _stepY + string_height("A") * QUEST_STEP_SCALE / 2, 8, doneColor, _alpha, 1);
		drawTextExtShadow(_textX + 24, _stepY, _doneText, -1, _width, _alpha, 2, QUEST_STEP_SCALE);
		draw_set_color(doneColor);
		draw_set_alpha(_alpha * _pulse);
		draw_text_transformed(_textX + 24, _stepY, _doneText, QUEST_STEP_SCALE, QUEST_STEP_SCALE, 0);
		draw_set_alpha(1);
		draw_set_color(c_white);
		return;
	}

	if (_entry.completedTimer > 0) {
		drawCompletedStep(_entry, _textX, _stepY, _width, _alpha);
		return;
	}

	var _stepAlpha = _alpha * _entry.stepSwap;
	var _stepX = _textX + (1 - _entry.stepSwap) * 16;
	var _scaledWidth = _width / QUEST_STEP_SCALE;

	drawTextExtShadow(_stepX, _stepY, _step.description, -1, _scaledWidth, _stepAlpha, 2, QUEST_STEP_SCALE);
	draw_set_alpha(_stepAlpha);
	draw_set_color(c_white);
	draw_text_ext_transformed(_stepX, _stepY, _step.description, -1, _scaledWidth, QUEST_STEP_SCALE, QUEST_STEP_SCALE, 0);

	var _progressY = _stepY + string_height_ext(_step.description, -1, _scaledWidth) * QUEST_STEP_SCALE;
	var _progressList = getStepProgressList(_step);

	for (var i = 0; i < array_length(_progressList); i++) {
		drawQuestProgress(_entry, "p" + string(i), _progressList[i], _stepX, _progressY + i * QUEST_PROGRESS_HEIGHT, _width, _stepAlpha);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawCompletedStep(_entry, _x, _y, _width, _alpha) {
	var _textX = _x + 24;
	var _scaledWidth = (_width - 24) / QUEST_STEP_SCALE;
	var _text = _entry.completedStepText;
	var _lineHeight = string_height("A") * QUEST_STEP_SCALE;

	drawCheckMark(_x + 8, _y + _lineHeight / 2, 8, doneColor, _alpha, _entry.completedCheck);

	drawTextExtShadow(_textX, _y, _text, -1, _scaledWidth, _alpha, 2, QUEST_STEP_SCALE);
	draw_set_alpha(_alpha);
	draw_set_color(doneColor);
	draw_text_ext_transformed(_textX, _y, _text, -1, _scaledWidth, QUEST_STEP_SCALE, QUEST_STEP_SCALE, 0);

	var _strike = clamp((QUEST_STEP_DONE_TIME - _entry.completedTimer) / 18, 0, 1);
	var _strikeWidth = min(string_width(_text) * QUEST_STEP_SCALE, _width - 24) + 8;
	draw_line_width(_textX - 4, _y + _lineHeight / 2, _textX - 4 + _strikeWidth * _strike, _y + _lineHeight / 2, 2);

	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawQuestToast(_entry, _panelRight, _y) {
	var _toast = _entry.toast;
	if (_toast.progress < .02 || _toast.text == "") return;

	var _padding = 14;
	var _label = "Etapa concluída";
	var _labelScale = .75;

	draw_set_font(fnt_gui_long_text);
	var _textWidth = min(string_width(_toast.text) * QUEST_STEP_SCALE, QUEST_TOAST_WRAP);
	var _textHeight = string_height_ext(_toast.text, -1, QUEST_TOAST_WRAP / QUEST_STEP_SCALE) * QUEST_STEP_SCALE;

	draw_set_font(fnt_gui_default);
	var _labelWidth = string_width(_label) * _labelScale + 26;
	var _labelHeight = string_height(_label) * _labelScale;

	var _width = max(_textWidth, _labelWidth) + _padding * 2;
	var _height = _padding * 2 + _labelHeight + 6 + _textHeight;
	var _x = _panelRight - _width + (_width + 12) * _toast.progress;
	var _alpha = clamp(_toast.progress * 2, 0, 1);

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_x, _y, spr_dialogue, 0, 0, _width, _height, 0, 5);
	draw_sprite_stretched_ext(spr_dialogue, 0, _x, _y, _width, _height, c_white, _alpha);

	var _contentX = _x + _padding;
	var _contentY = _y + _padding;

	drawCheckMark(_contentX + 7, _contentY + _labelHeight / 2, 7, doneColor, _alpha, clamp(_toast.progress, 0, 1));

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	drawTextShadow(_contentX + 26, _contentY, _label, _alpha, 2, _labelScale);
	draw_set_alpha(_alpha);
	draw_set_color(QUEST_COLOR);
	draw_text_transformed(_contentX + 26, _contentY, _label, _labelScale, _labelScale, 0);

	draw_set_font(fnt_gui_long_text);
	var _textY = _contentY + _labelHeight + 6;
	drawTextExtShadow(_contentX, _textY, _toast.text, -1, QUEST_TOAST_WRAP / QUEST_STEP_SCALE, _alpha, 2, QUEST_STEP_SCALE);
	draw_set_color(c_white);
	draw_text_ext_transformed(_contentX, _textY, _toast.text, -1, QUEST_TOAST_WRAP / QUEST_STEP_SCALE, QUEST_STEP_SCALE, QUEST_STEP_SCALE, 0);

	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawQuestProgress(_entry, _key, _progress, _x, _y, _width, _alpha) {
	var _counter = _entry.counters[$ _key];
	if (is_undefined(_counter)) {
		_counter = { display: _progress.count, last: _progress.count, pop: 0 };
		_entry.counters[$ _key] = _counter;
	}

	if (_progress.count > _counter.last) _counter.pop = 1;
	_counter.last = _progress.count;
	_counter.display = lerp(_counter.display, _progress.count, .12);
	_counter.pop = lerp(_counter.pop, 0, .1);

	var _isComplete = _progress.count >= _progress.target;
	var _color = _isComplete ? doneColor : QUEST_COLOR;
	var _ratio = clamp(_counter.display / max(1, _progress.target), 0, 1);
	var _textY = _y + 12;
	var _countScale = .8 * (1 + _counter.pop * .35);
	var _countText = string(_progress.count) + "/" + string(_progress.target);

	draw_set_font(fnt_gui_default);
	draw_set_valign(fa_middle);

	var _labelX = _x;
	if (_isComplete) {
		drawCheckMark(_x + 6, _textY, 6, doneColor, _alpha, 1);
		_labelX += 18;
	}

	draw_set_halign(fa_left);
	drawTextShadow(_labelX, _textY, _progress.label, _alpha, 2, .8);
	draw_set_alpha(_alpha);
	draw_set_color(_isComplete ? doneColor : #d8d8d8);
	draw_text_transformed(_labelX, _textY, _progress.label, .8, .8, 0);

	draw_set_halign(fa_right);
	drawTextShadow(_x + _width, _textY, _countText, _alpha, 2, _countScale);
	draw_set_color(merge_color(_color, c_white, _counter.pop));
	draw_text_transformed(_x + _width, _textY, _countText, _countScale, _countScale, 0);

	var _barY = _y + 24;
	draw_set_color(c_black);
	draw_set_alpha(_alpha * .5);
	draw_rectangle(_x, _barY, _x + _width, _barY + 5, false);
	draw_set_alpha(_alpha);
	draw_set_color(_color);
	draw_rectangle(_x, _barY, _x + _width * _ratio, _barY + 5, false);

	if (_counter.pop > .02) {
		draw_set_color(c_white);
		draw_set_alpha(_alpha * _counter.pop * .7);
		draw_rectangle(_x, _barY - 1, _x + _width * _ratio, _barY + 6, false);
	}

	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

#endregion

function getQuestStepById(_quest, _stepId) {
	if (!is_struct(_quest)) return undefined;
	if (!variable_struct_exists(_quest, "steps")) return undefined;

	for (var i = 0; i < array_length(_quest.steps); i++) {
		var _step = _quest.steps[i];

		if (_step.id == _stepId) {
			return _step;
		}
	}

	return undefined;
}

quests = [];
activeQuests = [];
completedQuests = [];

addQuest = function(_quest) {
	array_push(quests, _quest);
};

startQuest = function(_quest) {
	_quest.start();
	
	array_push(activeQuests, _quest);

	var _firstStep = _quest.getCurrentStep();

	instance_create_layer(0, 0, "Alert", obj_quest_popup, {
		textContent: _quest.name,
		popupType: QUEST_POPUP_TYPE.QUEST_ADDED,
		secondaryText: is_undefined(_firstStep) ? "" : _firstStep.description
	});
};

completeQuest = function(_quest) {
	_quest.isCompleted = true;

	var index = -1;

	for (var i = 0; i < array_length(activeQuests); i++) {
		if (activeQuests[i] == _quest) {
			index = i;
			break;
		}
	}

	if (index != -1) {
		array_delete(activeQuests, index, 1);
	}
	
	instance_create_layer(0, 0, "Alert", obj_quest_popup, {
		textContent: _quest.name,
		popupType: QUEST_POPUP_TYPE.QUEST_COMPLETED,
		reward: _quest.reward
	});
	
	array_push(
		completedQuests, 
		{
			id: _quest.id,
			name: _quest.name
		}
	);
};

notifyEvent = function(_event, _data) {
	for (var i = 0; i < array_length(activeQuests); i++) {
		var _quest = activeQuests[i];
		
		if (!_quest.isActive || _quest.isCompleted) continue;
		
		var _step = _quest.getCurrentStep();
		
		if (is_undefined(_step)) continue;
		
		var _fn = method(_step, _step.onEvent);
		_fn(_event, _data);
	}
};

hasActiveQuest = function(_questId) {
	for (var i = 0; i < array_length(activeQuests); i++) {
		var _quest = activeQuests[i];

		if (_quest.id == _questId && !_quest.isCompleted) {
			return true;
		}
	}

	return false;
}

function hasCompletedQuest(_questId) {
	for (var i = 0; i < array_length(completedQuests); i++) {
		var _quest = completedQuests[i];
		
		if (_questId == _quest.id) {
			return true;
		}
	}
	
	return false;
}


function getQuest(_questId) {
	for (var i = 0; i < array_length(quests); i++) {
		var _quest = quests[i];

		if (_quest.id == _questId) {
			return _quest;
		}
	}

	return undefined;
}