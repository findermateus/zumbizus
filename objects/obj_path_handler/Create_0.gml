currentPath = path_add();
calculationPathDelay = 15;
calculationPathTimer = irandom(60);
currentDirection = 1;

function calculatePath(_vel, _destinyX, _destinyY){
	if (calculationPathTimer > 0){
		calculationPathTimer --;
	
		return true;
	}
	
	calculationPathTimer = calculationPathDelay;
	
	var _hasAccessDirection = mp_grid_path(global.motionPlanningGrid, currentPath, x, y, _destinyX, _destinyY, choose(false, true));
	
	if (!_hasAccessDirection) return false;
	
	path_start(currentPath, _vel, path_action_stop, false);
	
	var _nextIndex = floor(path_position + 1);
	
	if (_nextIndex < path_get_number(currentPath)) {
	    var _nextPoint = path_get_point_x(currentPath, _nextIndex);
		currentDirection = _nextPoint;
	}
	
	return true;
}