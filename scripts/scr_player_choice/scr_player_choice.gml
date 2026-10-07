function PlayerChoice(_label, _onSelect = undefined) constructor {
	label    = _label;
	onSelect = _onSelect;
}

/// @param {Array} _choices array de PlayerChoice
/// @param {Function} _onEnd chamado com o índice escolhido, depois do onSelect da escolha
function createPlayerChoice(_choices, _onEnd = undefined) {
	return instance_create_layer(0, 0, "Controllers", obj_player_choice, {
		choices: _choices,
		onEnd: _onEnd
	});
}
