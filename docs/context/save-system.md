# Contexto — Save System

## Visão geral

O sistema de save/load do jogo é responsável por persistir os dados do jogador, inventário, quick use, equipamentos, progresso, atributos e estado da base.

Atualmente, o jogo sempre inicia pela room:

```gml
rm_boot
```

Essa room possui o objeto:

```gml
obj_game_boot
```

No `Create` do `obj_game_boot`, o jogo decide se deve carregar um save existente ou iniciar a introdução/tutorial:

```gml
if (saveExists()) {
	loadPlayerData();
	room_goto(rm_player_base);
	
	exit;
}

room_goto(rm_tutorial_intro);
```

Esse fluxo garante que:

- se já existir save válido, o jogo carrega os dados do jogador e envia o player para a base;
- se não existir save, o jogo inicia pela room introdutória do tutorial;
- a lógica de inicialização não fica dentro do `obj_player`;
- a base não é carregada antes de sua room estar ativa.

---

## Arquivos de save

O sistema utiliza dois arquivos principais:

```txt
player_save.json
player_base_save.json
```

### player_save.json

Armazena dados relacionados ao jogador e aos sistemas diretamente ligados a ele.

Inclui:

- inventário;
- toolbar;
- item equipado na mão;
- quick use;
- equipamentos;
- atributos do jogador;
- progressão;
- economia;
- fome e sede;
- vida;
- stamina;
- skills;
- stats;
- blueprints;
- buffs.

### player_base_save.json

Armazena dados relacionados à base do jogador.

Inclui:

- mobílias construídas;
- baús;
- conteúdo dos baús;
- itens soltos na base;
- dados produtivos de mobílias, quando existirem.

Esse arquivo não deve ser usado sozinho para decidir se existe um save real, pois o sistema pode criar um `player_base_save.json` vazio quando a base ainda não possui dados salvos.

Por isso, a função `saveExists()` usa principalmente o `player_save.json` como referência de save válido.

---

## Estrutura atual do player_save.json

A estrutura atual do save do player é versionada e organizada por blocos.

Formato geral:

```txt
player_save.json
├─ version
├─ inventory
├─ toolBar
├─ equipedItem
├─ quickUse
├─ equipments
└─ player
   ├─ identity
   ├─ progression
   ├─ economy
   ├─ survival
   ├─ health
   ├─ stamina
   ├─ movement
   └─ buffs
```

Exemplo conceitual:

```gml
var _saveData = {
	version: 2,
	inventory: getInventorySaveData(global.inventory),
	toolBar: getToolBarSaveData(),
	equipedItem: getEquipedItemSaveData(),
	quickUse: getQuickUseSaveData(),
	equipments: getEquipmentsSaveData(),
	player: getPlayerSaveData()
};
```

---

## saveExists

A função `saveExists()` verifica se existe um `player_save.json` válido.

Ela deve validar:

- existência do arquivo;
- conteúdo não vazio;
- JSON válido;
- estrutura principal do save;
- blocos internos obrigatórios.

Estrutura esperada:

```gml
function saveExists() {
	if (!file_exists("player_save.json")) {
		return false;
	}

	var _saveFile = file_text_open_read("player_save.json");
	var _saveJson = file_text_read_string(_saveFile);
	file_text_close(_saveFile);

	if (_saveJson == "") {
		return false;
	}

	try {
		var _saveData = json_parse(_saveJson);

		if (!is_struct(_saveData)) return false;
		if (!variable_struct_exists(_saveData, "version")) return false;
		if (!variable_struct_exists(_saveData, "inventory")) return false;
		if (!variable_struct_exists(_saveData, "toolBar")) return false;
		if (!variable_struct_exists(_saveData, "equipedItem")) return false;
		if (!variable_struct_exists(_saveData, "quickUse")) return false;
		if (!variable_struct_exists(_saveData, "equipments")) return false;
		if (!variable_struct_exists(_saveData, "player")) return false;

		var _player = _saveData.player;

		if (!is_struct(_player)) return false;
		if (!variable_struct_exists(_player, "identity")) return false;
		if (!variable_struct_exists(_player, "progression")) return false;
		if (!variable_struct_exists(_player, "economy")) return false;
		if (!variable_struct_exists(_player, "survival")) return false;
		if (!variable_struct_exists(_player, "health")) return false;
		if (!variable_struct_exists(_player, "stamina")) return false;
		if (!variable_struct_exists(_player, "movement")) return false;
		if (!variable_struct_exists(_player, "buffs")) return false;

		return true;
	} catch (_error) {
		return false;
	}
}
```

Atualmente não há necessidade de compatibilidade com saves antigos. Saves em formato antigo podem ser considerados inválidos.

---

## saveGame

A função `saveGame()` apenas coordena quais partes serão salvas.

```gml
function saveGame(_playerData = true, _playerBase = false) {
	if (_playerData) {
		savePlayerData();
	}

	if (_playerBase) {
		savePlayerBase();
	}
}
```

Importante:

- `savePlayerData()` pode ser chamado em qualquer room, desde que os dados globais existam;
- `savePlayerBase()` só deve salvar quando a room atual for `rm_player_base`;
- o save da base depende de instâncias e layers da base.

---

## loadGame

O `loadGame()` não deve carregar a base diretamente.

Atualmente ele deve carregar apenas dados persistentes do jogador:

```gml
function loadGame() {
	loadPlayerData();
}
```

A base deve ser carregada somente quando `rm_player_base` já estiver ativa, porque `loadPlayerBase()` instancia mobílias e itens em layers da room.

---

## Ordem correta de load do player

A ordem do load é importante, principalmente por causa da mochila.

A mochila pode alterar o tamanho do inventário através de `handleBagSwitch()`.

Portanto, a ordem correta é:

```txt
1. carregar dados gerais do player
2. carregar equipamentos
3. aplicar efeitos dos equipamentos
4. carregar inventário
5. carregar toolbar
6. carregar item equipado na mão
7. carregar quick use
```

Exemplo:

```gml
function loadPlayerData() {
	if (!saveExists()) {
		return;
	}

	var _playerSaveFile = file_text_open_read("player_save.json");
	var _playerSaveJson = file_text_read_string(_playerSaveFile);
	file_text_close(_playerSaveFile);

	var _playerData = json_parse(_playerSaveJson);

	loadPlayerState(_playerData.player);

	loadPlayerEquipments(_playerData.equipments);
	applyEquipmentsAfterLoad();

	loadArrayToDsGrid(_playerData.inventory, global.inventory);

	loadPlayerToolBar(_playerData.toolBar);
	loadPlayerEquipedItem(_playerData.equipedItem);
	loadPlayerQuickUse(_playerData.quickUse);
}
```

---

## Inventário

O inventário é uma `ds_grid`.

Para salvar, ele é convertido para array usando o padrão:

```txt
array[linha][coluna]
grid[# coluna, linha]
```

Função:

```gml
function getInventorySaveData(_inventory) {
	var _inventoryData = [];

	var _width = ds_grid_width(_inventory);
	var _height = ds_grid_height(_inventory);

	for (var i = 0; i < _height; i++) {
		for (var j = 0; j < _width; j++) {
			_inventoryData[i][j] = _inventory[# j, i];
		}
	}

	return _inventoryData;
}
```

Para carregar:

```gml
function loadArrayToDsGrid(_data, _destiny) {
	var _height = ds_grid_height(_destiny);
	var _width = ds_grid_width(_destiny);

	for (var i = 0; i < _height; i++) {
		for (var j = 0; j < _width; j++) {
			_destiny[# j, i] = _data[i][j];
		}
	}
}
```

O marcador de slot vazio atual é:

```gml
BLANK_INVENTORY_SPACE
```

Não usar mais:

```gml
global.blankInventorySpace
```

---

## Toolbar

A toolbar é salva a partir de `global.equipedItems`, que é uma `ds_list`.

Save:

```gml
function getToolBarSaveData() {
	var _toolBarEquipedItems = [];

	for (var i = 0; i < ds_list_size(global.equipedItems); i++) {
		_toolBarEquipedItems[i] = global.equipedItems[| i];
	}

	return {
		equipedItems: _toolBarEquipedItems,
		toolBarSize: global.toolBarSize
	};
}
```

Load:

```gml
function loadPlayerToolBar(_toolBar) {
	global.toolBarSize = _toolBar.toolBarSize;

	for (var i = 0; i < array_length(_toolBar.equipedItems); i++) {
		global.equipedItems[| i] = _toolBar.equipedItems[i];
	}
}
```

---

## Item equipado na mão

O item ativo na mão é salvo separadamente.

Save:

```gml
function getEquipedItemSaveData() {
	return {
		activeEquipedItem: global.activeEquipedItem,
		activeEquipedItemIndex: global.activeEquipedItemIndex
	};
}
```

Load:

```gml
function loadPlayerEquipedItem(_equipedItem) {
	global.activeEquipedItemIndex = _equipedItem.activeEquipedItemIndex;
	global.activeEquipedItem = _equipedItem.activeEquipedItem;
}
```

---

## Quick Use

O quick use é armazenado em:

```gml
global.quickUse
```

Ele é uma `ds_list` composta por:

```txt
buildedItem ou BLANK_INVENTORY_SPACE
```

Save:

```gml
function getQuickUseSaveData() {
	var _quickUseItems = [];

	for (var i = 0; i < ds_list_size(global.quickUse); i++) {
		_quickUseItems[i] = global.quickUse[| i];
	}

	return {
		items: _quickUseItems
	};
}
```

Load:

```gml
function loadPlayerQuickUse(_quickUse) {
	ds_list_clear(global.quickUse);

	for (var i = 0; i < array_length(_quickUse.items); i++) {
		ds_list_add(global.quickUse, _quickUse.items[i]);
	}
}
```

Esse sistema foi testado e validado.

---

## Equipamentos

Os equipamentos do jogador ficam em:

```gml
global.equipments = {
	head: BLANK_INVENTORY_SPACE,
	armor: BLANK_INVENTORY_SPACE,
	bag: BLANK_INVENTORY_SPACE
};
```

Cada slot pode conter:

```txt
buildedItem ou BLANK_INVENTORY_SPACE
```

Save:

```gml
function getEquipmentsSaveData() {
	return {
		head: global.equipments.head,
		armor: global.equipments.armor,
		bag: global.equipments.bag
	};
}
```

Load:

```gml
function loadPlayerEquipments(_equipments) {
	global.equipments.head = _equipments.head;
	global.equipments.armor = _equipments.armor;
	global.equipments.bag = _equipments.bag;
}
```

Após carregar os equipamentos, é necessário reaplicar seus efeitos:

```gml
function applyEquipmentsAfterLoad() {
	handleBagSwitch();
	handleArmorSwitch();
	handleHeadSwitch();
}
```

A mochila é especialmente importante porque altera o tamanho do inventário.

Função atual:

```gml
function handleBagSwitch() {
	if (global.equipments.bag == BLANK_INVENTORY_SPACE) {
		setInventorySize(global.inventoryWidth, global.inventoryHeight);
		return;
	}

	var _itemData = global.equipments.bag.equipmentData;
	var _inventoryWidth = global.inventoryWidth + _itemData.capacity;
	setInventorySize(_inventoryWidth, global.inventoryHeight);
}
```

Por isso, os equipamentos devem ser carregados antes do inventário.

Esse sistema foi testado e validado, incluindo a expansão do inventário pela mochila.

---

## Dados do player

Os dados do player são salvos em blocos.

### Identity

```gml
identity: {
	name: global.player.name,
	skinColor: global.player.skinColor,
	gender: global.player.gender,
	hair: global.player.hair
}
```

### Progression

```gml
progression: {
	level: global.player.level,
	xp: global.player.xp,
	skills: global.player.skills,
	stats: global.player.stats,
	blueprints: global.player.blueprints
}
```

### Economy

```gml
economy: {
	money: global.player.money
}
```

### Survival

```gml
survival: {
	defaultTotalThirst: global.player.defaultTotalThirst,
	defaultTotalHunger: global.player.defaultTotalHunger,
	currentThirst: global.player.currentThirst,
	currentHunger: global.player.currentHunger
}
```

### Health

```gml
health: {
	maxHealth: global.player.maxHealth,
	health: global.player.health,
	defaultMaxHealth: global.player.defaultMaxHealth
}
```

### Stamina

```gml
stamina: {
	maxStamina: global.player.maxStamina,
	defaultMaxStamina: global.player.defaultMaxStamina,
	stamina: global.player.stamina,
	staminaAcceleration: global.player.staminaAcceleration,
	staminaRecoveryDelay: global.player.staminaRecoveryDelay,
	staminaDecreaseAcceleration: global.player.staminaDecreaseAcceleration,
	sprintSpeed: global.player.sprintSpeed,
	sprintStaminaDecrease: global.player.sprintStaminaDecrease
}
```

### Movement

```gml
movement: {
	walkingAceleration: global.player.walkingAceleration,
	walkingSpeed: global.player.walkingSpeed
}
```

### Buffs

```gml
buffs: {
	buffList: global.player.buffList
}
```

---

## Load dos dados do player

O load dos dados do player é dividido em funções específicas:

```gml
function loadPlayerState(_playerData) {
	loadPlayerIdentity(_playerData.identity);
	loadPlayerProgression(_playerData.progression);
	loadPlayerEconomy(_playerData.economy);
	loadPlayerSurvival(_playerData.survival);
	loadPlayerHealth(_playerData.health);
	loadPlayerStamina(_playerData.stamina);
	loadPlayerMovement(_playerData.movement);
	loadPlayerBuffs(_playerData.buffs);
}
```

Funções específicas:

```gml
function loadPlayerIdentity(_identity) {
	global.player.name = _identity.name;
	global.player.skinColor = _identity.skinColor;
	global.player.gender = _identity.gender;
	global.player.hair = _identity.hair;
}
```

```gml
function loadPlayerProgression(_progression) {
	global.player.level = _progression.level;
	global.player.xp = _progression.xp;
	global.player.skills = _progression.skills;
	global.player.stats = _progression.stats;
	global.player.blueprints = _progression.blueprints;
}
```

```gml
function loadPlayerEconomy(_economy) {
	global.player.money = _economy.money;
}
```

```gml
function loadPlayerSurvival(_survival) {
	global.player.defaultTotalThirst = _survival.defaultTotalThirst;
	global.player.defaultTotalHunger = _survival.defaultTotalHunger;
	global.player.currentThirst = _survival.currentThirst;
	global.player.currentHunger = _survival.currentHunger;
}
```

```gml
function loadPlayerHealth(_health) {
	global.player.maxHealth = _health.maxHealth;
	global.player.health = _health.health;
	global.player.defaultMaxHealth = _health.defaultMaxHealth;
}
```

```gml
function loadPlayerStamina(_stamina) {
	global.player.maxStamina = _stamina.maxStamina;
	global.player.defaultMaxStamina = _stamina.defaultMaxStamina;
	global.player.stamina = _stamina.stamina;
	global.player.staminaAcceleration = _stamina.staminaAcceleration;
	global.player.staminaRecoveryDelay = _stamina.staminaRecoveryDelay;
	global.player.staminaDecreaseAcceleration = _stamina.staminaDecreaseAcceleration;
	global.player.sprintSpeed = _stamina.sprintSpeed;
	global.player.sprintStaminaDecrease = _stamina.sprintStaminaDecrease;
}
```

```gml
function loadPlayerMovement(_movement) {
	global.player.walkingAceleration = _movement.walkingAceleration;
	global.player.walkingSpeed = _movement.walkingSpeed;
}
```

```gml
function loadPlayerBuffs(_buffs) {
	global.player.buffList = _buffs.buffList;
}
```

---

## Save da base

O save da base é feito apenas se a room atual for:

```gml
rm_player_base
```

Função:

```gml
function savePlayerBase() {
	if (room != rm_player_base) return;

	var _furnitureList = getPlayerBaseFurnitures();
	var _itemList = getPlayerBaseItems();

	var _playerBaseData = {
		furnitures: _furnitureList,
		items: _itemList
	};

	var _saveFile = file_text_open_write("player_base_save.json");
	file_text_write_string(_saveFile, json_stringify(_playerBaseData));
	file_text_close(_saveFile);
}
```

---

## Load da base

O load da base instancia objetos na room, então deve acontecer apenas quando `rm_player_base` já estiver ativa.

A função `loadPlayerBase()` deve tratar:

- arquivo inexistente;
- arquivo vazio;
- JSON inválido;
- save sem dados;
- base padrão.

Versão recomendada:

```gml
function loadPlayerBase() {
	if (!file_exists("player_base_save.json")) {
		createBlankBaseSaveFile();
	}

	var _playerBaseSaveFile = file_text_open_read("player_base_save.json");
	var _baseSaveJson = file_text_read_string(_playerBaseSaveFile);
	file_text_close(_playerBaseSaveFile);

	if (_baseSaveJson == "" || _baseSaveJson == BLANK_INVENTORY_SPACE) {
		loadDefaultBaseData();
		return;
	}

	try {
		var _baseData = json_parse(_baseSaveJson);

		if (is_struct(_baseData)) {
			loadBaseFurnitures(_baseData.furnitures);
			loadBaseItems(_baseData.items);
		} else {
			loadDefaultBaseData();
		}
	} catch (_error) {
		loadDefaultBaseData();
		return;
	}

	if (!instance_exists(obj_furniture_map_selector)) {
		loadDefaultBaseData();
	}
}
```

O dado padrão atual da base cria o seletor de mapa:

```gml
function loadDefaultBaseData() {
	instance_create_layer(400, 700, "Items", obj_furniture_map_selector);
}
```

---

## Mobílias da base

As mobílias são salvas com:

- `objectIndex`;
- `objectId`;
- posição;
- sprite;
- ângulo;
- `furnitureInfo`;
- `furniture`;
- `furnitureHealth`;
- dados de container, se for baú;
- dados produtivos, se existirem.

Ao carregar, o sistema instancia novamente os objetos na layer `Items`.

Se a mobília for um baú, seu `containerData` é recriado com `ds_grid_create()` e preenchido com `loadArrayToDsGrid()`.

---

## Itens soltos na base

Os itens soltos na base são salvos com:

```gml
{
	x: x,
	y: y,
	item: item,
	angle: angle,
	image_angle: image_angle
}
```

E carregados recriando instâncias de `obj_item` na layer `Items`.

---

## Fluxo atual validado

Foram testados e validados:

```txt
- inventário;
- toolbar;
- item equipado na mão;
- quick use;
- equipamentos;
- expansão do inventário pela mochila;
- dinheiro;
- XP;
- level;
- fome;
- sede;
- vida;
- stamina;
- skills;
- stats;
- blueprints.
```

Também já existia suporte de save/load da base para:

```txt
- mobílias;
- baús;
- conteúdo dos baús;
- itens largados na base.
```

---

## Pontos de atenção

### Base não deve carregar no boot

Não chamar `loadPlayerBase()` dentro de `rm_boot`, porque a base instancia objetos em layers específicas da `rm_player_base`.

Fluxo correto:

```txt
rm_boot
↓
saveExists()
↓
loadPlayerData()
↓
room_goto(rm_player_base)
↓
rm_player_base ativa
↓
loadPlayerBase()
```

### Equipamentos antes do inventário

A mochila altera o tamanho do inventário, então equipamentos devem ser carregados antes do inventário.

Fluxo correto:

```txt
loadPlayerEquipments()
↓
handleBagSwitch()
↓
setInventorySize()
↓
loadArrayToDsGrid()
```

### PersonHair

Atualmente `global.player.hair` é salvo diretamente.

Se `PersonHair` for apenas uma struct de dados, isso funciona.

Se futuramente `PersonHair` tiver métodos internos no constructor, será melhor salvar somente dados primitivos, como:

```gml
hair: {
	hairId: global.player.hair.hairId,
	hairColor: global.player.hair.hairColor
}
```

E reconstruir no load:

```gml
global.player.hair = new PersonHair(_identity.hair.hairId, _identity.hair.hairColor);
```

### Saves antigos

Não há necessidade atual de compatibilidade com saves antigos.

Se a estrutura do JSON não bater com a versão nova, `saveExists()` pode retornar `false` e iniciar um novo jogo/tutorial.

---

## Próximos sistemas que podem entrar no save futuramente

Ainda podem ser adicionados ao save em etapas futuras:

```txt
- quests ativas;
- quests completadas;
- estado do tutorial;
- room atual;
- posição do player;
- NPCs recrutados;
- estado de comerciantes;
- estado de mapas explorados;
- notas/documentos encontrados;
- progresso da cidade/hub Finderosky.
```

---

## Estado atual do fluxo de início do jogo

O jogo agora nasce sempre em:

```gml
rm_boot
```

Com:

```gml
obj_game_boot
```

Fluxo:

```txt
Se existe save válido:
    carrega dados do player
    vai para rm_player_base

Se não existe save válido:
    vai para rm_tutorial_intro
```

Isso prepara o projeto para a próxima etapa de desenvolvimento: criar e modelar a introdução jogável do tutorial, onde o protagonista acorda sem memória antes de chegar à base e conhecer o primeiro NPC sobrevivente.
