event_inherited();

textToDraw = "Vasculhar Caixa";
interactSound = snd_open_container;

dropItems = [
	{
		type: itemType.consumables,
		itemId: consumableItems.watter_bottle,
		min: 1,
		max: 1,
		chance: 25
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.canned_food,
		min: 1,
		max: 1,
		chance: 15
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.canned_fish,
		min: 1,
		max: 1,
		chance: 15
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.canned_pineapple,
		min: 1,
		max: 1,
		chance: 15
	}
];