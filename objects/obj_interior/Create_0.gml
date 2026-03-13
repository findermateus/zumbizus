alpha = 1;
hasFadeOut = false;
isFadingOut = false;

function fade() {
	isFadingOut = true;
	alpha = lerp(alpha, 0, .1);
	
	if (alpha <= .08) { 
		hasFadeOut = true;
		alpha = 0;
	}
}