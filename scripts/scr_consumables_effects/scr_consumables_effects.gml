function ConsumableUsageData(_increaseValue, _sound, _itemToDrop = undefined, _otherEffects = []) constructor {
	increaseValue = _increaseValue;
	sound = _sound;
	otherEffects = _otherEffects;
	itemToDrop = _itemToDrop;
}

enum otherEffectTypes {
	healthIncrease,
	thirstDecrease,
	hungerDecrease,
	staminaIncrease,
	healthDecrease
}

function otherEffectsData(_type, _value) {
	return {
		type: _type,
		value: _value
	};
}
