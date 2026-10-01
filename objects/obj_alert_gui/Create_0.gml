textAlert = "";
alertColor = c_red;

targetY = yPosition - 35;
scale = 0.5;
lifeTimer = 60;

function execute() {
	yPosition = lerp(yPosition, targetY, 0.1);
	
	scale = lerp(scale, 1, 0.2);
	
	if (lifeTimer > 0) {
		lifeTimer--;
		
		return;
	}
	
	image_alpha = lerp(image_alpha, 0, 0.1);
	if (image_alpha <= 0.05) instance_destroy(id);
}