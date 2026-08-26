keysPressedStatus = array_create(array_length(keysToPress), false);
promptSubimg = 0; 

alpha = 0; 
slideY = 20; 
scale = 1;   
floatTimer = 0; 
shakeX = 0;
shakeY = 0;
shakeIntensity = 0;
offsetY = 30;
offsetX = 0;

STATE_FADE_IN = 0;
STATE_WAITING = 1;
STATE_FADE_OUT = 2;
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

checkAllKeys = function() {
    var _allPressed = true;
    var _keysLength = array_length(keysToPress);

    for (var _i = 0; _i < _keysLength; _i++) {
        if (!keysPressedStatus[_i] && keyboard_check_pressed(keysToPress[_i])) {
            keysPressedStatus[_i] = true;
            scale = 1.3;
        }
        
        if (!keysPressedStatus[_i]) {
            _allPressed = false;
        }
    }
    return _allPressed;
};

checkAnyKey = function() {
    var _keysLength = array_length(keysToPress);
    for (var _i = 0; _i < _keysLength; _i++) {
        if (keyboard_check(keysToPress[_i])) { 
            
			return true;
        }
    }
	
    return false;
};

processFadeIn = function() {
    slideY = lerp(slideY, 0, 0.1);
    alpha = lerp(alpha, 1, 0.1);
    
    if (alpha >= 0.95) {
        slideY = 0;
        alpha = 1;
        fadeState = STATE_WAITING; 
    }
};

processWaitingInput = function() {
    var _isCompleted = requireAll ? checkAllKeys() : checkAnyKey();

    if (_isCompleted) {
        fadeState = STATE_FADE_OUT; 
        shakeIntensity = 4; 
		
		return;
    }
    
	scale = lerp(scale, 1, 0.1);
};

processFadeOut = function() {
    slideY = lerp(slideY, -30, 0.08);
    alpha -= fadeSpeed;
    
    if (alpha <= 0) {
        instance_destroy();
    }
};