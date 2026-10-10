function Damage(_x, _y, _value, _isKill = false) constructor
{
    x = _x;
    y = _y - 20;
    value = _value;
    alpha = 1;
	isKill = _isKill;

    vsp = _isKill ? -7 : -5;
    hsp = random_range(-3, 3);
    grav = 0.3;
    scale = _isKill ? 3.4 : 2.4;
	targetScale = _isKill ? 1.5 : 1;
	angle = random_range(-12, 12);
	color = _isKill ? "[#ff5a3c]" : "";
}

damageList = [];
