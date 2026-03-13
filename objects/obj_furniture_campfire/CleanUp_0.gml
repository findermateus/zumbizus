ds_map_destroy(allowedRecipees);
if (audio_emitter_exists(audioEmitter)) audio_emitter_free(audioEmitter);
if (part_system_exists(particleEmitter)) part_system_destroy(particleEmitter);
