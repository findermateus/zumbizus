/// @method playSoundRelativeToPlayer(emitter, som, repeat, prioridade, distancia até o som começar a baixar, distancia máxima que o som pode ser ouvido, rapidez que o volume diminuí)
function playSoundRelativeToPlayer(_emitter, _sound, _repeat, _priority, _refDis, _maxDis, fallofFactor) {
	audio_falloff_set_model(audio_falloff_exponent_distance);
	audio_emitter_falloff(_emitter, _refDis, _maxDis, fallofFactor);
	return audio_play_sound_on(_emitter, _sound, _repeat, _priority);
}