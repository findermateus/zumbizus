var baseColor = choose(#6a040f, #a4161a, #e5383b);
var brightnessOffset = irandom_range(-20, 20);
image_blend = make_color_hsv(
    color_get_hue(baseColor),
    color_get_saturation(baseColor),
    clamp(color_get_value(baseColor) + brightnessOffset, 0, 255)
);

image_index = irandom(image_number - 1);
image_angle = random(360);
image_alpha = 0;
image_xscale = 0.7 + random(0.3);
image_yscale = image_xscale;
depth = 100;

fadeInSpeed = 0.05 + random(0.02);
fadeOutSpeed = 0.005 + random(0.005);
fadeState = 0;

function handle() {
	if (fadeState == 0) {
		image_alpha = lerp(image_alpha, 1, fadeInSpeed);
        image_xscale += 0.005;
        image_yscale = image_xscale;

        if (image_alpha >= 0.95) {
            fadeState = 1;
        }
		return;
	}
	image_alpha = lerp(image_alpha, 0, fadeOutSpeed);
    image_angle += random_range(-0.5, 0.5);
    if (image_alpha <= 0.05) instance_destroy();
}