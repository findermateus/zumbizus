#macro CURSOR_SIZE 32

enum CursorType {
	Default,
	Aim,
	PreciseAim
}

window_set_cursor(cr_none);

function cursorConfig(_spr, _size){
	return {
		sprite: _spr,
		size: _size
	}
}

cursorType = CursorType.Default;

cursorSprites[CursorType.Default] = cursorConfig(spr_cursor_default, CURSOR_SIZE);
cursorSprites[CursorType.Aim] = cursorConfig(spr_cursor_aim, 40);
cursorSprites[CursorType.PreciseAim] = cursorConfig(spr_cursor_precise_aim, 40);

function setCursor(_type) {
	cursorType = _type;
}

recoilScale = 0;

function triggerRecoil() {
	recoilScale += 2; 
}