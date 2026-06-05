var _lerpSpeed = 0.2;

if (!isClosing) {
	headerAnimYOffset = lerp(headerAnimYOffset, 0, _lerpSpeed);
	headerAnimAlpha = lerp(headerAnimAlpha, 1, _lerpSpeed);

	if (headerAnimAlpha > 0.2) {
		listBgAnimYOffset = lerp(listBgAnimYOffset, 0, _lerpSpeed);
		listBgAnimAlpha = lerp(listBgAnimAlpha, 1, _lerpSpeed);
	}

	for (var i = 0; i < visibleRows; i++) {
		var _canStart = (i == 0) ? (listBgAnimAlpha > 0.3) : (itemAnimAlpha[i-1] > 0.5);
		if (_canStart) {
			itemAnimYOffset[i] = lerp(itemAnimYOffset[i], 0, _lerpSpeed);
			itemAnimAlpha[i] = lerp(itemAnimAlpha[i], 1, _lerpSpeed);
		}
	}
	
	if (keyboard_check_pressed(vk_escape)) {
		closeTrade();
	}

	handleTradeScroll();

} else {
	headerAnimYOffset = lerp(headerAnimYOffset, -50, _lerpSpeed);
	headerAnimAlpha = lerp(headerAnimAlpha, 0, _lerpSpeed);
	
	listBgAnimYOffset = lerp(listBgAnimYOffset, -30, _lerpSpeed);
	listBgAnimAlpha = lerp(listBgAnimAlpha, 0, _lerpSpeed);

	for (var i = 0; i < visibleRows; i++) {
		itemAnimYOffset[i] = lerp(itemAnimYOffset[i], -20, _lerpSpeed);
		itemAnimAlpha[i] = lerp(itemAnimAlpha[i], 0, _lerpSpeed);
	}

	if (headerAnimAlpha < 0.05) {
		performClose();
	}
}

for (var i = 0; i < visibleRows; i++) {
	if (itemShakeAmount[i] > 0) {
		itemShakeAmount[i] = max(0, itemShakeAmount[i] - 1); 
	}
}
