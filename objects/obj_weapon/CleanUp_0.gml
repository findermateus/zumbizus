if (part_emitter_exists(explosionParticleSystem, ps_emissor)) {
	part_emitter_destroy(explosionParticleSystem, ps_emissor)
}

part_system_destroy(explosionParticleSystem);
part_type_destroy(faiscaParticleType);
part_type_destroy(smokeParticleType);