if (!is_struct(dialogue) || array_length(dialogue.texts) == 0) {
	instance_destroy(id);
	exit;
}

openMenu(Menus.Dialogue);
blockPlayerMenus();

typeWritterSounds = [
	snd_tp_1,
	snd_tp_2,
	snd_tp_3,
	snd_tp_4,
	snd_tp_5,
	snd_tp_6,
	snd_tp_7,
	snd_tp_8,
	snd_tp_9,
	snd_tp_10,
	snd_tp_11,
];
typeWritterSoundInterval = 70;
lastTypeWritterSoundTime = 0;
lastTypeWritterSound = undefined;
voicePitch = 1;

playerAccentColor = PRIMARY_COLOR;
npcAccentColor = #ffd166;
textPadding = 30;

pageCount = array_length(dialogue.texts);
currentPage = 0;

isClosing = false;
hasEnded = false;
openness = 0;
opennessVelocity = 0;

punch = 0;
punchVelocity = 0;
accentProgress = 0;
hoverAmount = 0;
isHoveringBox = false;
hintAlpha = 0;
dotScales = array_create(pageCount, 1);

avatarTransitionProgress = 0;
avatarTransitionState = "in";
lastSpeakerKey = undefined;
displayedSpeaker = undefined;
pendingSpeaker = undefined;
portraitShake = 0;
talkPulse = 0;

nameplateScale = 0;
nameplateVelocity = 0;
nameplateAngle = 0;

typist = scribble_typist();
typist.in(dialogue.textSpeed, 3);
typist.ease(SCRIBBLE_EASE.BACK, 0, -10, 1.4, 1.4, 0, .3);

typistResumeTime = 0;

function getPunctuationDelay(_char) {
	switch (_char) {
		case ".":
		case "!":
		case "?":
			return 220;
		case "…":
			return 300;
		case ",":
		case ";":
		case ":":
			return 100;
	}
	return 0;
}

obj_player.currentState = playerDialogueState;

obj_camera.camSpeed = .05

function endDialogue() {
	closeMenu();
	unBlockPlayerMenus();

	obj_camera.setDefaultValues();
	obj_camera.target = obj_player;

	obj_player.currentState = playerIddleState;

	if (instance_exists(target)) {
		obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
			npc: target
		});
	}

	var _npcs = dialogue.npcs;
	for (var i = 0; i < array_length(_npcs); i++) {
		var _instance = _npcs[i].instance;

		if (_instance == target || !instance_exists(_instance)) continue;

		obj_quest_manager.notifyEvent(QuestEvent.DialogueEnded, {
			npc: _instance
		});
	}

	if (is_callable(dialogue.onEnd)) {
		dialogue.onEnd();
	}

	if (instance_exists(target)) {
		target.isInteracting = false;
	}
	instance_destroy(id);
}

#region falantes

function easeOutBack(_t) {
	var _c1 = 1.70158;
	var _c3 = _c1 + 1;
	return 1 + _c3 * power(_t - 1, 3) + _c1 * power(_t - 1, 2);
}

function getSpeakerForPage(_page) {
	var _text = dialogue.texts[_page];
	var _npcCount = array_length(dialogue.npcs);
	var _npcIndex = clamp(_text[$ "npcIndex"] ?? 0, 0, max(_npcCount - 1, 0));
	var _isNpc = !_text.isPlayer && _npcCount > 0;

	return {
		key: _isNpc ? _npcIndex : -1,
		isPlayer: !_isNpc,
		npcIndex: _npcIndex
	};
}

function getSpeakerName(_speaker) {
	return _speaker.isPlayer ? global.player.name : dialogue.npcs[_speaker.npcIndex].name;
}

function getSpeakerColor(_speaker) {
	return _speaker.isPlayer ? playerAccentColor : npcAccentColor;
}

function getVoicePitch(_speaker) {
	var _gender = _speaker.isPlayer ? global.player.gender : dialogue.npcs[_speaker.npcIndex].gender;
	var _name = getSpeakerName(_speaker);
	var _hash = 0;

	for (var i = 1; i <= string_length(_name); i++) {
		_hash += ord(string_char_at(_name, i));
	}

	var _base = _gender == genders.female ? 1.18 : 1;
	return _base + ((_hash mod 7) - 3) * .025;
}

function focusCameraOnSpeaker(_speaker) {
	if (_speaker.isPlayer) {
		obj_camera.setTargetWithZoom(obj_player);
		return;
	}

	var _speakerInstance = dialogue.npcs[_speaker.npcIndex].instance;

	if (instance_exists(_speakerInstance)) {
		obj_camera.setTargetWithZoom(_speakerInstance);
	} else if (instance_exists(target)) {
		obj_camera.setTargetWithZoom(target);
	}
}

function showSpeaker(_speaker) {
	displayedSpeaker = _speaker;
	avatarTransitionState = "in";
	avatarTransitionProgress = 0;
	nameplateScale = 0;
	nameplateVelocity = 0;
	nameplateAngle = choose(-6, 6);
}

#endregion

#region páginas e input

function startPage(_page) {
	currentPage = _page;
	typist.reset();
	accentProgress = 0;
	hintAlpha = 0;

	var _speaker = getSpeakerForPage(_page);
	voicePitch = getVoicePitch(_speaker);

	if (lastSpeakerKey == _speaker.key) return;

	lastSpeakerKey = _speaker.key;
	focusCameraOnSpeaker(_speaker);

	if (displayedSpeaker == undefined) {
		showSpeaker(_speaker);
	} else {
		pendingSpeaker = _speaker;
		avatarTransitionState = "out";
	}
}

function isPageComplete() {
	return avatarTransitionState != "out" && typist.get_state() >= 1;
}

function startClosing() {
	isClosing = true;
	playSwiiimmmSound(.6);
}

function onTypistCharacter(_scope, _index, _typist) {
	var _char = string_char_at(dialogue.texts[currentPage].text, _index + 1);

	if (_char == "!") portraitShake = 6;
	if (_char == " ") return;

	var _delay = getPunctuationDelay(_char);
	if (_delay > 0 && !typist.get_skip()) {
		typist.pause();
		typistResumeTime = current_time + _delay;
	}

	talkPulse = 1;

	if (current_time - lastTypeWritterSoundTime < typeWritterSoundInterval) return;

	if (!is_undefined(lastTypeWritterSound) && audio_is_playing(lastTypeWritterSound)) audio_stop_sound(lastTypeWritterSound);

	var _sound = typeWritterSounds[irandom(array_length(typeWritterSounds) - 1)];
	lastTypeWritterSound = audio_play_sound(_sound, 1, false, .4, 0, voicePitch + random_range(-.06, .06));
	lastTypeWritterSoundTime = current_time;
}

typist.function_per_char(method(self, onTypistCharacter));

function handleDialogueInput() {
	if (isClosing || avatarTransitionState == "out") return;

	var _pressed = keyboard_check_pressed(vk_space) || (openness > .5 && mouse_check_button_released(mb_left));
	if (!_pressed) return;

	if (!isPageComplete()) {
		typist.unpause();
		typist.skip();
		punch = .015;
		return;
	}

	punch = .03;
	playTickSound();

	if (currentPage < pageCount - 1) {
		startPage(currentPage + 1);
	} else {
		startClosing();
	}
}

#endregion

#region animação

function getDialogueLayout() {
	var _guiWidth  = display_get_gui_width();
	var _guiHeight = display_get_gui_height();

	var _marginSide   = 60;
	var _marginBottom = 20;

	var _boxW = _guiWidth - _marginSide * 2;
	var _boxH = _guiHeight * .25;
	var _boxY = _guiHeight - _boxH - _marginBottom + (_boxH + _marginBottom + 40) * (1 - openness);

	var _scale = 1 + punch;
	var _drawW = _boxW * _scale;
	var _drawH = _boxH * _scale;

	return {
		x: _marginSide,
		y: _boxY,
		width: _boxW,
		height: _boxH,
		drawX: _marginSide - (_drawW - _boxW) / 2,
		drawY: _boxY - (_drawH - _boxH) / 2,
		drawWidth: _drawW,
		drawHeight: _drawH
	};
}

function getPortraitX(_layout, _isPlayer) {
	var _avatarW = _layout.width * .14;
	var _avatarMargin = 120;

	if (_isPlayer) return _layout.x + _avatarMargin + _avatarW / 2;
	return _layout.x + _layout.width - _avatarMargin - _avatarW / 2;
}

function updateOpenness() {
	opennessVelocity += ((isClosing ? 0 : 1) - openness) * .12;
	opennessVelocity *= .68;
	openness += opennessVelocity;

	if (isClosing && openness < .02 && !hasEnded) {
		hasEnded = true;
		endDialogue();
	}
}

function updatePortraitTransition() {
	if (avatarTransitionState == "out") {
		avatarTransitionProgress -= .14;
		if (avatarTransitionProgress <= 0) showSpeaker(pendingSpeaker);
	} else if (avatarTransitionState == "in") {
		avatarTransitionProgress += .05;
		if (avatarTransitionProgress >= 1) {
			avatarTransitionProgress = 1;
			avatarTransitionState = "idle";
		}
	}

	nameplateVelocity += ((avatarTransitionState == "out" ? 0 : 1) - nameplateScale) * .25;
	nameplateVelocity *= .65;
	nameplateScale += nameplateVelocity;
	nameplateAngle = lerp(nameplateAngle, 0, .15);

	portraitShake = lerp(portraitShake, 0, .2);
	talkPulse = lerp(talkPulse, 0, .2);
}

function updateDialogue() {
	updateOpenness();
	if (hasEnded) return;

	if (typist.get_paused() && current_time >= typistResumeTime) typist.unpause();

	handleDialogueInput();
	updatePortraitTransition();

	punchVelocity += -punch * .3;
	punchVelocity *= .6;
	punch += punchVelocity;

	accentProgress = lerp(accentProgress, 1, .12);
	hintAlpha = lerp(hintAlpha, isPageComplete() && !isClosing, .15);

	for (var i = 0; i < pageCount; i++) {
		dotScales[i] = lerp(dotScales[i], i == currentPage ? 1.6 : 1, .2);
	}

	var _layout = getDialogueLayout();
	var _isHovering = !isClosing && mouseIsOnRectangle(_layout.x, _layout.y, _layout.x + _layout.width, _layout.y + _layout.height);
	if (_isHovering && !isHoveringBox) playHoverSound();
	isHoveringBox = _isHovering;
	hoverAmount = lerp(hoverAmount, _isHovering, .2);
}

#endregion

#region desenho

function drawCinematicBars() {
	var _progress = clamp(openness, 0, 1);
	if (_progress <= .01) return;

	var _guiWidth  = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	var _barHeight = _guiHeight * .08 * _progress;

	draw_set_color(c_black);
	draw_set_alpha(.25 * _progress);
	draw_rectangle(0, 0, _guiWidth, _guiHeight, false);

	draw_set_alpha(1);
	draw_rectangle(0, 0, _guiWidth, _barHeight, false);
	draw_rectangle(0, _guiHeight - _barHeight, _guiWidth, _guiHeight, false);
	draw_set_color(c_white);
}

function drawPortrait(_layout) {
	if (displayedSpeaker == undefined) return;

	var _progress = avatarTransitionProgress;
	var _isLeaving = avatarTransitionState == "out";
	var _ease = _isLeaving ? 1 - sqr(1 - _progress) : easeOutBack(_progress);
	var _side = displayedSpeaker.isPlayer ? -1 : 1;
	var _alpha = clamp(_progress * 2, 0, 1) * clamp(openness, 0, 1);

	var _bodyHeight = _layout.height * .78;
	var _scale = getScale(_bodyHeight, sprite_get_height(spr_human_male_iddle));
	_scale *= 1 + sin(current_time / 500) * .012 + talkPulse * .02;

	var _shakeX = portraitShake > .2 ? random_range(-portraitShake, portraitShake) : 0;
	var _x = getPortraitX(_layout, displayedSpeaker.isPlayer) + _side * (1 - _ease) * 60 + _shakeX;
	var _y = _layout.y + _bodyHeight * .12 + (1 - _ease) * 160 - talkPulse * 5;

	gpu_set_fog(true, c_black, 0, 0);
	drawSpeakerBody(displayedSpeaker, _x + 6, _y + 6, _scale, _alpha * .35);
	gpu_set_fog(false, c_black, 0, 0);
	drawSpeakerBody(displayedSpeaker, _x, _y, _scale, _alpha);
}

function drawSpeakerBody(_speaker, _x, _y, _scale, _alpha) {
	if (_speaker.isPlayer) {
		drawPersonBody(
			_x, _y,
			global.player.gender, 0, _scale, 0, _alpha,
			global.player.skinColor,
			global.player.hair,
			global.player.eyeId,
			is_struct(global.equipments.armor) ? global.equipments.armor.itemId : -1,
			is_struct(global.equipments.head)  ? global.equipments.head.itemId  : -1,
			is_struct(global.equipments.bag)   ? global.equipments.bag.itemId   : -1
		);
		return;
	}

	var _npc = dialogue.npcs[_speaker.npcIndex];
	drawPersonBody(
		_x, _y,
		_npc.gender, 0, _scale, 0, _alpha,
		_npc.skinColor,
		new PersonHair(_npc.hairId, _npc.hairColor),
		_npc.eyeId,
		_npc.outfitId, _npc.helmetId, _npc.bagId, -1
	);
}

function drawBox(_layout) {
	drawSpriteShadowStretched(_layout.drawX, _layout.drawY, spr_dialogue, 0, 0, _layout.drawWidth, _layout.drawHeight, 0, 6);
	draw_sprite_stretched(spr_dialogue, 0, _layout.drawX, _layout.drawY, _layout.drawWidth, _layout.drawHeight);

	if (displayedSpeaker != undefined) {
		var _color = getSpeakerColor(displayedSpeaker);
		var _halfWidth = (_layout.width / 2 - 24) * (1 - sqr(1 - accentProgress));
		var _centerX = _layout.x + _layout.width / 2;
		var _accentY = _layout.drawY + 10;

		draw_set_color(_color);
		draw_set_alpha(.3);
		draw_rectangle(_centerX - _halfWidth - 4, _accentY - 2, _centerX + _halfWidth + 4, _accentY + 5, false);
		draw_set_alpha(1);
		draw_rectangle(_centerX - _halfWidth, _accentY, _centerX + _halfWidth, _accentY + 2, false);
		draw_set_color(c_white);
	}

	if (hoverAmount > .05) {
		var _padding = 6 + (1 - hoverAmount) * 10 + sin(current_time / 180) * 2;
		drawCornerBrackets(
			_layout.drawX - _padding, _layout.drawY - _padding,
			_layout.drawX + _layout.drawWidth + _padding, _layout.drawY + _layout.drawHeight + _padding,
			c_white, hoverAmount * .8, 18, 3
		);
	}
}

function drawDialogueText(_layout) {
	if (avatarTransitionState == "out") return;

	var _alpha = clamp(openness, 0, 1);
	var _x = _layout.x + textPadding;
	var _y = _layout.y + textPadding;

	var _element = scribble(dialogue.texts[currentPage].text, "dialogue_page_" + string(currentPage))
		.starting_format(font_get_name(fnt_gui_default), c_white)
		.wrap(_layout.width - textPadding * 2);

	_element.blend(c_black, _alpha * .6).draw(_x + 4, _y + 4, typist);
	_element.blend(c_white, _alpha).draw(_x, _y, typist);
}

function drawNameplate(_layout) {
	if (displayedSpeaker == undefined || nameplateScale < .05) return;

	var _name = getSpeakerName(displayedSpeaker);
	var _color = getSpeakerColor(displayedSpeaker);
	var _alpha = clamp(openness, 0, 1) * clamp(nameplateScale, 0, 1);

	draw_set_font(fnt_gui_title);
	var _textScale = min(1, getScale(_layout.width * .2, string_width(_name)));
	var _plateW = (string_width(_name) * _textScale + 48) * nameplateScale;
	var _plateH = (string_height(_name) * _textScale + 20) * nameplateScale;

	var _centerX = getPortraitX(_layout, displayedSpeaker.isPlayer);
	var _centerY = _layout.y + 10 - (string_height(_name) * _textScale + 20) / 2;
	var _x1 = _centerX - _plateW / 2;
	var _y1 = _centerY - _plateH / 2;

	draw_set_alpha(_alpha);
	drawSpriteShadowStretched(_x1, _y1, spr_dialogue, 0, 0, _plateW, _plateH);
	draw_sprite_stretched_ext(spr_dialogue, 0, _x1, _y1, _plateW, _plateH, c_white, _alpha);

	draw_set_color(_color);
	draw_rectangle(_x1 + 12 * nameplateScale, _y1 + _plateH - 9 * nameplateScale, _x1 + _plateW - 12 * nameplateScale, _y1 + _plateH - 6 * nameplateScale, false);
	draw_set_color(c_white);

	var _scale = _textScale * nameplateScale;
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	drawTextShadow(_centerX, _centerY, _name, _alpha, 3, _scale);
	draw_text_transformed(_centerX, _centerY, _name, _scale, _scale, nameplateAngle);

	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawPageDots(_layout) {
	if (pageCount <= 1) return;

	var _alpha = clamp(openness, 0, 1);
	var _radius = 5;
	var _gap = 22;
	var _x = _layout.x + textPadding + _radius;
	var _y = _layout.y + _layout.height - textPadding;
	var _accent = displayedSpeaker != undefined ? getSpeakerColor(displayedSpeaker) : playerAccentColor;

	draw_set_alpha(_alpha);
	for (var i = 0; i < pageCount; i++) {
		var _size = _radius * dotScales[i];
		var _dotX = _x + i * _gap;

		draw_set_color(c_black);
		draw_circle(_dotX + 2, _y + 2, _size, false);
		draw_set_color(i == currentPage ? _accent : (i < currentPage ? c_white : #5a5a5a));
		draw_circle(_dotX, _y, _size, false);
	}
	draw_set_alpha(1);
	draw_set_color(c_white);
}

function drawAdvanceHint(_layout) {
	var _alpha = hintAlpha * clamp(openness, 0, 1);
	if (_alpha < .02) return;

	var _isLastPage = currentPage >= pageCount - 1;
	var _accent = displayedSpeaker != undefined ? getSpeakerColor(displayedSpeaker) : playerAccentColor;
	var _iconX = _layout.x + _layout.width - textPadding - 10;
	var _iconY = _layout.y + _layout.height - textPadding + abs(sin(current_time * .008)) * -6;

	draw_set_alpha(_alpha);
	if (_isLastPage) {
		draw_set_color(c_black);
		draw_rectangle(_iconX - 7 + 3, _iconY - 7 + 3, _iconX + 7 + 3, _iconY + 7 + 3, false);
		draw_set_color(_accent);
		draw_rectangle(_iconX - 7, _iconY - 7, _iconX + 7, _iconY + 7, false);
	} else {
		draw_set_color(c_black);
		draw_triangle(_iconX - 10 + 3, _iconY - 7 + 3, _iconX + 10 + 3, _iconY - 7 + 3, _iconX + 3, _iconY + 8 + 3, false);
		draw_set_color(_accent);
		draw_triangle(_iconX - 10, _iconY - 7, _iconX + 10, _iconY - 7, _iconX, _iconY + 8, false);
	}
	draw_set_color(c_white);

	var _action = _isLastPage ? "fechar" : "avançar";
	var _hintText = "[fa_right][fa_middle]Pressione Espaço ou [scale,1.5][spr_mouse][/scale] para " + _action;
	var _hintX = _iconX - 26 + (1 - hintAlpha) * 16;
	var _hintY = _layout.y + _layout.height - textPadding;

	draw_set_font(fnt_gui_default);
	drawTextShadowScribble(_hintX, _hintY, _hintText, _alpha * .85, 3);
	draw_set_alpha(_alpha * .85);
	draw_text_scribble(_hintX, _hintY, _hintText);

	draw_set_alpha(1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}

function drawDialogue() {
	var _layout = getDialogueLayout();

	drawCinematicBars();
	drawPortrait(_layout);
	drawBox(_layout);
	drawDialogueText(_layout);
	drawNameplate(_layout);
	drawPageDots(_layout);
	drawAdvanceHint(_layout);

	draw_set_font(fnt_gui_default);
	draw_set_color(c_white);
	draw_set_alpha(1);
}

#endregion

playSwiiimmmSound();
startPage(0);
