adjustObjectDepth();

if (x < 0 || x > room_width || y > room_height || y < 0) {
	instance_destroy(id);
}

x += lengthdir_x(spitSpeed, direction);
y += lengthdir_y(spitSpeed, direction);