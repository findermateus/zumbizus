function enemyColision(_object){
    if (place_meeting(x + velh, y, _object)) {
        var _dirH = sign(velh);
        while (!place_meeting(x + _dirH, y, _object)) {
            x += _dirH;
        }
        
        velh = 0;
        endPath(); 
    }
    
    if (place_meeting(x, y + velv, _object)) {
        var _dirV = sign(velv);
        while (!place_meeting(x, y + _dirV, _object)) {
            y += _dirV;
        }
        
        velv = 0;
        endPath();
    }
}