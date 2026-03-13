if (lifeSpan < 0) {
	alpha = lerp(alpha, -1, .1);
	
	if (alpha < 0) {
		instance_destroy(id);
	}
} else {
	alpha = lerp(alpha, 1, .1);
}

