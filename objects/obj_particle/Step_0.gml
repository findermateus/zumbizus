
image_alpha = lerp(image_alpha, 0, alphaDecrease);
if(image_alpha <= 0)instance_destroy(id);

if (instance_place(x + speed, y + speed, obj_collision)){
	direction += 180;
}

speed = lerp(speed, 1, .1);