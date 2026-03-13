currentRadius = lerp(currentRadius, radiusMax, 0.12);

echoRadius = lerp(echoRadius, currentRadius, 0.1);

thicknessCurrent = lerp(thicknessCurrent, 0, 0.07);
currentAlpha = lerp(currentAlpha, 0, 0.06);

if (currentAlpha < 0.01) instance_destroy();