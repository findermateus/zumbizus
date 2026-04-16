hover_anim = 0;
menu_offset_x = 0;

function drawQuests() {
	var _questsCount = array_length(activeQuests);

	if (_questsCount == 0) return;;

	var _maxTextWidth = 350;
	var _margin = 30;
	var _padding = 12;

	var _targetX = global.activeMenu ? -(_maxTextWidth + _margin + _padding * 2 + 50) : 0;

	menu_offset_x = lerp(menu_offset_x, _targetX, 0.1);

	if (global.activeMenu && abs(menu_offset_x - _targetX) < 2) {
	    return;
	}

	var _guiWidth = display_get_gui_width();
	var _initialY = display_get_gui_height() * 0.2;

	var _baseTextX = _margin + menu_offset_x; 

	draw_set_valign(fa_top);
	draw_set_halign(fa_left);

	draw_set_font(fnt_gui_title);
	var _mainTitle = "Missões Ativas";
	var _mainTitleHeight = string_height(_mainTitle);
	draw_set_font(fnt_gui_long_text);
	var _totalQuestsHeight = 0;

	for (var i = 0; i < _questsCount; i++) {
	    var q = activeQuests[i];
	    var step = q.getCurrentStep();
    
	    _totalQuestsHeight += string_height_ext(q.name, -1, _maxTextWidth) + 5;
    
	    if (!is_undefined(step)) {
	        var text = step.description;
	        if (variable_struct_exists(step, "killTarget")) {
	            text += " (" + string(step.killCount) + "/" + string(step.killTarget) + ")";
	        }
        
	        var _stepScale = 0.7;
	        var _scaledMaxWidth = _maxTextWidth / _stepScale; 
        
	        _totalQuestsHeight += (string_height_ext(text, -1, _scaledMaxWidth) * _stepScale) + 15;
	    }
	}

	var _totalHeight = _mainTitleHeight + 15 + _totalQuestsHeight;
    
	var _rectX1 = _baseTextX - _padding;
	var _rectY1 = _initialY + 10 - _padding;
	var _rectX2 = _baseTextX + _maxTextWidth + _padding;
	var _rectY2 = (_initialY + 10) + _totalHeight + _padding;

	var _isHovering = mouseIsOnRectangle(_rectX1, _rectY1, _rectX2, _rectY2);
	hover_anim = lerp(hover_anim, _isHovering ? 1 : 0, 0.15);

	var _textX = _baseTextX + (hover_anim * 6);

	var _drawRectX1 = _textX - _padding;
	var _drawRectX2 = _textX + _maxTextWidth + _padding;

	draw_set_alpha(1);
	draw_set_color(c_black);
	draw_sprite_stretched(spr_bar, 0, _drawRectX1, _rectY1, _drawRectX2 - _drawRectX1, _rectY2 - _rectY1);
    
	draw_set_alpha(1);
	draw_set_color(c_white);

	var _y = _initialY + 10;
    
	draw_set_font(fnt_gui_title);

	drawTextExtShadow(_textX, _y, _mainTitle, -1, _maxTextWidth, 1, 3, 1);
	draw_text(_textX, _y, _mainTitle);
    
	_y += _mainTitleHeight + 15; 

	draw_set_font(fnt_gui_long_text);
    
	for (var i = 0; i < _questsCount; i++) {
	    var q = activeQuests[i];
	    var step = q.getCurrentStep();
        
	    drawTextExtShadow(_textX, _y, q.name, -1, _maxTextWidth, 1, 3, 1);
	    draw_set_color(#FFB86C);
	    draw_text_ext(_textX, _y, q.name, -1, _maxTextWidth);
	    draw_set_color(c_white);
	    _y += string_height_ext(q.name, -1, _maxTextWidth) + 5;
        
	    if (!is_undefined(step)) {
	        var text = step.description;
            
	        if (variable_struct_exists(step, "killTarget")) {
	            text += " (" + string(step.killCount) + "/" + string(step.killTarget) + ")";
	        }
            
	        var _stepScale = 0.7;
	        var _scaledMaxWidth = _maxTextWidth / _stepScale; 
            
	        drawTextExtShadow(_textX, _y, text, -1, _scaledMaxWidth, 1, 2, _stepScale);
	        draw_set_color(#FFDC64);
	        draw_text_ext_transformed(_textX, _y, text, -1, _scaledMaxWidth, _stepScale, _stepScale, 0);
	        draw_set_color(c_white);
            
	        _y += (string_height_ext(text, -1, _scaledMaxWidth) * _stepScale) + 15;
	    }
	}

	draw_set_font(fnt_gui_default);
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
	
	array_push(completedQuests, _quest);
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

var _quest = new Quest("test", "Killing in the name of Love");

_quest.onComplete = function () {
	xpAdd(100);
}

var _step = new QuestStep("Matar 5 Zumbis");
_step.killCount = 0;
_step.killTarget = 5;

_step.onEvent = function(_event, _data) {
	if (_event != QuestEvent.EnemyKilled) return;

	self.killCount++;

	if (self.killCount >= self.killTarget) {
		self.quest.completeCurrentStep();
	}
};

_quest.addStep(_step); 

addQuest(_quest);
startQuest(_quest);