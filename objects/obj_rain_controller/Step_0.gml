if (!isRaining) exit;

var _cam_x = camera_get_view_x(view_camera[0]);
var _cam_y = camera_get_view_y(view_camera[0]);
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);

var _rain_intensity = 15;

for (var i = 0; i < _rain_intensity; i++) {
    
    var _drop_x = _cam_x + random_range(-200, _cam_w + 200);
    var _drop_y = _cam_y + random_range(-200, _cam_h);
    part_particles_create(sys_rain_drops, _drop_x, _drop_y, part_drop, 1);
    
    var _splash_x = _cam_x + random(_cam_w);
    var _splash_y = _cam_y + random(_cam_h);
    
    var _is_colision = position_meeting(_splash_x, _splash_y, obj_collision);
    var _is_interior = position_meeting(_splash_x, _splash_y, obj_interior);
    
    if (!_is_colision && !_is_interior) {
        part_particles_create(sys_rain_splashes, _splash_x, _splash_y, part_splash, 1);
    }
}