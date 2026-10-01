event_inherited();

textToDraw = "Vasculhar Caixa";
interactSound = snd_open_container;

dropItems = [
	{
		type: itemType.trash,
		itemId: trashItems.nail,
		min: 1,
		max: 15,
		chance: 50
	},
	{
		type: itemType.trash,
		itemId: trashItems.duct_tape,
		min: 1,
		max: 2,
		chance: 50
	}
];