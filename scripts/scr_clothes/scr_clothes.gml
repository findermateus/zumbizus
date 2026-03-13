global.clothesDisplay = {
	armor: [],
	head: [],
	bag: []
};

function Clothing(_sprite, _spriteFemale, _color = c_white) constructor {
	sprite = _sprite;
	spriteFemale = _spriteFemale;
	color = _color;
	
	getSprite = function (_gender = genders.male) {
		return _gender == genders.female ? spriteFemale : sprite;
	}
}

function ArmorClothing(_spriteIddle, _spriteWalking, _spriteIddleFemale, _spriteWalkingFemale, _color = c_white): Clothing(_spriteIddle, _spriteIddleFemale, _color) constructor {
	spriteWalking = _spriteWalking;
	spriteWalkingFemale = _spriteWalkingFemale;
	
	getWalkingSprite = function(_gender = genders.male) {
		return _gender == genders.female ? spriteWalkingFemale : spriteWalking;
	}
}

function HelmetClothing(_sprite, _color = c_white): Clothing(_sprite, _color) constructor {

}

function BagClothing(_sprite, _color = c_white): Clothing(_sprite, _color) constructor {

}

global.clothesDisplay.armor[equipmentItems.simpleOutfit] = new ArmorClothing(spr_cosmetic_simple_shirt_iddle, spr_cosmetic_simple_shirt_walking, spr_cosmetic_female_simple_shirt_iddle, spr_cosmetic_female_simple_shirt_walking);
global.clothesDisplay.armor[equipmentItems.leatherJacket] = new ArmorClothing(spr_cosmetic_leather_jacket_iddle, spr_cosmetic_leather_jacket_walking, spr_cosmetic_female_leather_jacket_iddle, spr_cosmetic_female_leather_jacket_walking);

global.clothesDisplay.head[equipmentItems.simpleCap] = new HelmetClothing(spr_cosmetic_simple_cap);
global.clothesDisplay.head[equipmentItems.boonieHat] = new HelmetClothing(spr_cosmetic_boonie_hat);
global.clothesDisplay.bag[equipmentItems.simpleBag] = new BagClothing(spr_cosmetic_simple_bag);