function Damage(_x, _y, _value) constructor 
{
    x = _x;
    y = _y - 20;
    value = _value;
    alpha = 1;
    
    vsp = -5;
    hsp = random_range(-3, 3);
    grav = 0.3;
    scale = 2;
}

damageList = [];