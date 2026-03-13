textAlert = "";
alertColor = c_red;
function execute(){
	yPosition -= .5;
	image_alpha = lerp(image_alpha, 0, .03);
	if(image_alpha <= 0) instance_destroy(id);
}