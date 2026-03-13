enum baseAttribute {
	crafting,
	production,
	supplies,
	battle,
	economy
}

function BaseAttributeDisplay(_id, _displayName, _icon) constructor {
	id = _id;
	displayName = _displayName;
	icon = _icon;
}

function IconMenu (_title, _key, _icon, _id, _backgroundColor = false) constructor {
	title = _title;
	key = _key;
	icon = _icon;
	backgroundColor = _backgroundColor;
	id = _id;
}

global.attributes = [];
global.baseFurnitureIdCount = 0;
global.attributes[baseAttribute.crafting] = new BaseAttributeDisplay(baseAttribute.crafting, "Criação", spr_attribute_crafting);
global.attributes[baseAttribute.production] = new BaseAttributeDisplay(baseAttribute.production, "Produção e reciclagem", spr_attribute_production);
global.attributes[baseAttribute.supplies] = new BaseAttributeDisplay(baseAttribute.supplies, "Suprimentos", spr_attribute_supply);
global.attributes[baseAttribute.economy] = new BaseAttributeDisplay(baseAttribute.economy, "Ecônomia", spr_attribute_economy);
global.attributes[baseAttribute.battle] = new BaseAttributeDisplay(baseAttribute.battle, "Combate", spr_attribute_battle);

enum menu {
	builder,
	resident
}

function selectLateralMenuOption(_option){
	if (global.currentBaseMenuOption != -1) {
		deactivateLateralMenuOption(global.currentBaseMenuOption);
	}
	global.currentBaseMenuOption = _option;
	with obj_base_controller {
		lateralMenuGUIInfo.shakeEffect = 5;
		lateralMenuGUIInfo.selectedOption = _option;
	}
	closeInventory();
	openMenu();
	if (_option == menu.builder) {
		with obj_base_controller {
			setUpResourceViewer(true);
		}
		with (obj_builder) {
			setUpModal();
		}
		return;
	}
	if (_option == menu.resident) {
		with obj_resident_gui_controller {
			setUpModal();
		}
	}
}

function deactivateLateralMenuOption(_option) {
	global.currentBaseMenuOption = -1;
	with obj_base_controller {
		setUpResourceViewer(false);
	}
	closeMenu();
	if (_option == menu.builder) {
		with obj_builder {
			hideMenu();
		}
	}
	
	if (_option == menu.resident) {
		with obj_resident_gui_controller {
			hideMenu();
		}
	}
}