switch (state) {
    case "in":
        alpha = lerp(alpha, 1, 0.1);
        scale = lerp(scale, target_scale, 0.1);
        
        if (alpha > 0.99) {
            alpha = 1;
            scale = target_scale;
            state = "wait";
        }
    break;

    case "wait":
        timer--;
        if (timer <= 0) {
            state = "out";
			playSwiiimmmSound(.1);
        }
    break;

    case "out":
        alpha = lerp(alpha, 0, 0.1);
        scale = lerp(scale, target_scale + 0.5, 0.1);
        
        if (alpha < 0.01) {
            instance_destroy();
        }
    break;
}