textEquip = "Equipe uma arma";
textAim = "Segure M2 para Mirar";
textAttack = "Aperte M1 para Atacar";

currentText = textAim;

alpha = 0; 
slideY = 20; 
scale = 1;   
floatTimer = 0; 
shakeX = 0;
shakeY = 0;
shakeIntensity = 0;
offsetY = sprite_get_height(spr_human_male_iddle);
offsetX = 0;

lineProgress = 0;
linePadding = 20;
fadeSpeed = 0.05;

STATE_FADE_IN = 0;
STATE_WAITING = 1;
STATE_COMPLETED = 2;
STATE_FADE_OUT = 3;
fadeState = STATE_FADE_IN;

updateJuice = function() {
    floatTimer += 0.05; 

    if (shakeIntensity > 0) {
        shakeX = random_range(-shakeIntensity, shakeIntensity);
        shakeY = random_range(-shakeIntensity, shakeIntensity);
        shakeIntensity = lerp(shakeIntensity, 0, 0.2); 
        return;
    }
    shakeX = 0;
    shakeY = 0;
};

processFadeIn = function() {
    slideY = lerp(slideY, 0, 0.1);
    alpha = lerp(alpha, 1, 0.1);
    
    if (alpha < 0.95) return;
    
    slideY = 0;
    alpha = 1;
    fadeState = STATE_WAITING;
};

processWaitingInput = function() {
    scale = lerp(scale, 1, 0.1);

    if (getEquipedItem() == BLANK_INVENTORY_SPACE) {
        currentText = textEquip;
        return;
    }

    if (!mouse_check_button(mb_right)) {
        currentText = textAim;
        return;
    }

    currentText = textAttack;
    
    if (!mouse_check_button_pressed(mb_left)) return;
    
    fadeState = STATE_COMPLETED;
    shakeIntensity = 4;
};

processCompleted = function() {
    lineProgress = lerp(lineProgress, 1, 0.15);
    
    if (lineProgress <= 0.95) return;
    
    fadeState = STATE_FADE_OUT;
};

processFadeOut = function() {
    slideY = lerp(slideY, -30, 0.08);
    alpha -= fadeSpeed;
    
    if (alpha > 0) return;
    
    instance_destroy();
};