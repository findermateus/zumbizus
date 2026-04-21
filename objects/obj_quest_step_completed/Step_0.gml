current_y = lerp(current_y, target_y, 0.1);

switch (state) {
    case "fade_in":
        alpha += fade_speed;
        if (alpha >= 1) {
            alpha = 1;
            state = "wait";
        }
        break;
        
    case "wait":
        timer++;
        
        if (timer > 10) {
            line_progress = lerp(line_progress, 1, 0.1); 
        }
        
        if (timer >= wait_time) {
            state = "fade_out";
            target_y -= 30;
        }
        break;
        
    case "fade_out":
        alpha -= fade_speed;
        if (alpha <= 0) {
            instance_destroy();
        }
        break;
}

adjustClosestDepth();