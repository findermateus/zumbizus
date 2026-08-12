adjustClosestDepth();

if (recoilScale > 0) {
	recoilScale = lerp(recoilScale, 0, 0.15);
	
	if (recoilScale < 0.01) {
		recoilScale = 0;
	}
}