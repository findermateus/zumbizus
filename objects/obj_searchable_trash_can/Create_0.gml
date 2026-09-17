event_inherited();

textToDraw = "Vasculhar Lixo";
interactSound = snd_can;

dropItems = [
	{
		type: itemType.trash,
		itemId: trashItems.twig,
		min: 1,
		max: 2,
		chance: 80
	},
	{
		type: itemType.trash,
		itemId: trashItems.plant_fiber,
		min: 1,
		max: 2,
		chance: 70
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.watter_bottle,
		min: 1,
		max: 1,
		chance: 35
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.canned_pineapple,
		min: 1,
		max: 1,
		chance: 25
	}
];