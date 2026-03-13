global.weaponHitSounds = [];
global.weaponHitSounds[weaponTypes.bladed] = [
	snd_enemy_hit_bladed_1,
	snd_enemy_hit_bladed_2,
	snd_enemy_hit_bladed_3
];

global.weaponHitSounds[weaponTypes.impact] = [

];

global.weaponHitSounds[weaponTypes.shoot] = [

];

function playWeaponEffectSound(_attackType){
	var _list = global.weaponHitSounds[_attackType];
	var _listLength = array_length(_list);
	if (!_listLength) return;
	var _effectSound = global.weaponHitSounds[_attackType][irandom(_listLength - 1)];
	audio_play_sound(_effectSound, 0, false);
}