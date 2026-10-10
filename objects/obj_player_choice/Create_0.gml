if (!is_array(choices) || array_length(choices) == 0 || !instance_exists(obj_player)) {
	instance_destroy(id);
	exit;
}

openMenu(Menus.PlayerChoice);
blockPlayerMenus();

obj_player.currentState = playerDialogueState;
obj_camera.setTargetWithZoom(obj_player);

playSwiiimmmSound();

alpha = 0;
animProgress = 0;
hoverOffsets = array_create(array_length(choices), 0);
hasChosen = false;

function selectChoice(_index) {
	if (hasChosen) return;

	hasChosen = true;

	playClickSound();

	closeMenu();
	unBlockPlayerMenus();

	obj_camera.setDefaultValues();
	obj_camera.target = obj_player;

	obj_player.currentState = playerIddleState;

	var _choice = choices[_index];

	if (is_callable(_choice.onSelect)) {
		_choice.onSelect();
	}

	if (is_callable(onEnd)) {
		onEnd(_index);
	}

	instance_destroy(id);
}

// Posição final de cada escolha ao redor do player (em coordenadas de GUI)
function getChoiceTarget(_index, _count) {
	var _margin = 50;

	var _leftX  = roomToGuiX(obj_player.bbox_left) - _margin;
	var _rightX = roomToGuiX(obj_player.bbox_right) + _margin;
	var _sideY  = roomToGuiY(obj_player.bbox_bottom) - sprite_get_height(obj_player.sprite_index);
	var _topX   = roomToGuiX(getMiddlePoint(obj_player.bbox_left, obj_player.bbox_right));
	var _topY   = roomToGuiY(obj_player.bbox_top) - 140;

	if (_count == 1) {
		return { x: _topX, y: _topY, halign: fa_center };
	}

	if (_count <= 3) {
		switch (_index) {
			case 0: return { x: _leftX,  y: _sideY, halign: fa_right };
			case 1: return { x: _rightX, y: _sideY, halign: fa_left };
			default: return { x: _topX,  y: _topY,  halign: fa_center };
		}
	}

	// Mais de 3 escolhas: leque acima do player, da esquerda (180°) para a direita (0°)
	var _angle   = 180 - (180 / (_count - 1)) * _index;
	var _radiusX = (_rightX - _leftX) / 2;
	var _radiusY = _sideY - _topY;
	var _x = _topX + lengthdir_x(_radiusX, _angle);
	var _y = _sideY + lengthdir_y(_radiusY, _angle);

	var _halign = fa_center;
	if (_x < _topX - 1) _halign = fa_right;
	else if (_x > _topX + 1) _halign = fa_left;

	return { x: _x, y: _y, halign: _halign };
}
