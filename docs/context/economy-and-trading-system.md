# Economy and Trading System

Este documento descreve o sistema de economia, compra, venda e interface de negociação do jogo.

O objetivo deste contexto é servir como referência rápida para futuras implementações envolvendo comerciantes, dinheiro do jogador, itens vendidos/comprados, quests relacionadas a trade e UI de negociação.

---

## Estado atual

O sistema de economia/trading já possui:

- dinheiro do jogador em `global.player.money`
- propriedade `value` nos itens
- funções utilitárias para dinheiro
- cálculo de valor de compra
- cálculo de valor de venda
- compra de itens de NPC comerciante
- venda de itens do inventário do jogador
- venda parcial ou total de stacks
- validações de dinheiro, item inválido, quantidade inválida e espaço no inventário
- enum `TradeResult`
- NPCs com `canTrade`
- NPCs com lista `tradeItems`
- UI de trade com abas de compra e venda
- scroll da lista de itens
- controle de interação com `isInteracting`

A branch de desenvolvimento do sistema de economia/trading foi finalizada, commitada e fechada.

---

## Dinheiro do jogador

O dinheiro do jogador é armazenado em:

```gml
global.player.money
```

Funções utilitárias usadas pelo sistema:

```gml
playerHasMoney(_amount)
addPlayerMoney(_amount)
removePlayerMoney(_amount)
```

Uso esperado:

```gml
if (playerHasMoney(_price)) {
	removePlayerMoney(_price);
}
```

---

## Valor dos itens

A estrutura base dos itens possui a propriedade:

```gml
value = 1;
```

Esse valor representa o valor base do item.

Exemplo de configuração:

```gml
var _config = AmmoConfig();
_config.itemId = ammoItems.mm9;
_config.name = "Munição 9mm";
_config.description = "Munição 9mm compatível com pistolas e smg's";
_config.sprite = spr_ammo_9mm;
_config.limit = 64;
_config.quantity = 1;
_config.sound = snd_shells;
_config.fitInGrid = fitInGridType.verticaly;
_config.value = 13;

global.items[itemType.ammo][ammoItems.mm9] = _config;
```

O `value` é usado tanto para compra quanto para venda, dependendo da função chamada.

---

## Convenção importante: `.type` no trading

No sistema de trading, os itens de trade usam o campo:

```gml
type
```

E não:

```gml
itemType
```

Formato correto atual:

```gml
{
	type: itemType.ammo,
	itemId: ammoItems.mm9,
	quantity: 16
}
```

Ao interagir com sistemas que esperam `itemType`, como quests, o campo deve ser convertido no payload:

```gml
{
	itemId: _tradeItem.itemId,
	itemType: _tradeItem.type,
	quantity: _tradeItem.quantity
}
```

---

## Trade items do NPC

NPCs comerciantes possuem:

```gml
canTrade = true;
tradeItems = [];
```

Exemplo:

```gml
tradeItems = [
	{
		type: itemType.ammo,
		itemId: ammoItems.mm9,
		quantity: 16
	},
	{
		type: itemType.consumables,
		itemId: consumableItems.watter_bottle,
		quantity: 1
	}
];
```

Cada item representa um pacote vendido pelo comerciante.

Por enquanto, o preço de compra pode ser calculado usando o `value` do item em `global.items`.

---

## Cálculo de valor de compra

Função usada para calcular o valor total de compra com base no item configurado em `global.items`:

```gml
function getBuyItemValue(_id, _type, _quantity = 1) {
	if (!is_array(global.items)) return 0;

	var _itemData = global.items[_type][_id];

	if (!is_struct(_itemData)) return 0;
	if (!variable_struct_exists(_itemData, "value")) return 0;

	return _itemData.value * _quantity;
}
```

Uso esperado:

```gml
var _totalPrice = getBuyItemValue(
	_tradeItem.itemId,
	_tradeItem.type,
	_tradeItem.quantity
);
```

---

## Compra de itens

A compra de itens é feita a partir de um `_tradeItem` do comerciante.

Fluxo esperado:

```text
calcula valor total
↓
verifica se o jogador tem dinheiro
↓
constrói o item
↓
verifica se o item cabe inteiro no inventário
↓
adiciona o item no inventário
↓
remove dinheiro do jogador
↓
retorna TradeResult.Success
```

A compra deve ser transacional. Ou seja:

- se não houver dinheiro, nada acontece
- se não houver espaço no inventário, nada acontece
- o jogador não deve receber parte do item
- o jogador não deve perder dinheiro se a compra falhar

Por isso, a compra usa:

```gml
addAbsoluteItemToGrid(global.inventory, _item)
```

---

## `addAbsoluteItemToGrid`

O sistema de trade não usa diretamente o `addItemToGrid`, porque ele pode alterar stacks parcialmente antes de saber se cabe tudo.

Para compra, foi criada uma abordagem absoluta/transacional:

```gml
canAddAbsoluteItemToGrid(_inventory, _item)
addAbsoluteItemToGrid(_inventory, _item)
```

A ideia é:

```text
verificar se cabe tudo
↓
se couber, adicionar
↓
se não couber, não modificar o inventário
```

Essa função deve usar:

```gml
BLANK_INVENTORY_SPACE
```

E não:

```gml
global.blankInventorySpace
```

---

## Resultado de trade

O sistema usa um enum para representar os resultados de compra e venda:

```gml
enum TradeResult {
	Success,
	NotEnoughMoney,
	NotEnoughInventory,
	InvalidItem,
	InvalidQuantity
}
```

Significados:

| Resultado | Uso |
|---|---|
| `Success` | operação concluída |
| `NotEnoughMoney` | jogador não tem dinheiro suficiente |
| `NotEnoughInventory` | inventário não possui espaço suficiente |
| `InvalidItem` | item inválido ou slot vazio |
| `InvalidQuantity` | quantidade inválida |

---

## Venda de itens

A venda usa o item real do inventário, não a configuração base em `global.items`.

Isso é importante porque o item real possui informações como:

```gml
_item.value
_item.quantity
_item.itemId
_item.type
```

A venda usa um multiplicador:

```gml
#macro SELL_PRICE_MULTIPLIER 0.5
```

Ou seja, por padrão, o jogador vende itens por 50% do valor base.

---

## Cálculo de valor de venda

```gml
function getSellItemValue(_item, _quantity = 1) {
	if (!is_struct(_item)) return 0;
	if (!variable_struct_exists(_item, "value")) return 0;

	return floor(_item.value * _quantity * SELL_PRICE_MULTIPLIER);
}
```

Exemplo:

```text
item.value = 13
quantity = 16
SELL_PRICE_MULTIPLIER = 0.5

floor(13 * 16 * 0.5) = 104
```

---

## Venda parcial de stack

A função principal de venda por quantidade é:

```gml
function sellInventoryItemQuantity(_inventory, _x, _y, _quantity) {
	var _item = _inventory[# _x, _y];

	if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) {
		return TradeResult.InvalidItem;
	}

	var _availableQuantity = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;

	if (_quantity <= 0 || _quantity > _availableQuantity) {
		return TradeResult.InvalidQuantity;
	}

	var _sellValue = getSellItemValue(_item, _quantity);

	addPlayerMoney(_sellValue);

	if (variable_struct_exists(_item, "quantity")) {
		_item.quantity -= _quantity;

		if (_item.quantity <= 0) {
			_inventory[# _x, _y] = BLANK_INVENTORY_SPACE;
		}
	} else {
		_inventory[# _x, _y] = BLANK_INVENTORY_SPACE;
	}

	return TradeResult.Success;
}
```

Essa função permite vender:

- 1 unidade
- parte da stack
- a stack inteira

---

## Venda de stack inteira

A venda da stack inteira pode ser mantida como wrapper:

```gml
function sellInventoryItem(_inventory, _x, _y) {
	var _item = _inventory[# _x, _y];

	if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) {
		return TradeResult.InvalidItem;
	}

	var _quantity = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;

	return sellInventoryItemQuantity(_inventory, _x, _y, _quantity);
}
```

---

## Controle de venda por clique

A UI controla a quantidade vendida com base no botão do mouse:

```text
clique esquerdo  -> vende 1 unidade
clique direito   -> vende tudo do slot
```

Exemplo de implementação na aba `SELL`:

```gml
if (currentTab == "SELL") {
	var _item = global.inventory[# _tradeItem.gridx, _tradeItem.gridy];

	if (_item == BLANK_INVENTORY_SPACE || !is_struct(_item)) {
		playFailSound();
		itemShakeAmount[_drawIndex] = 10;
		break;
	}

	var _quantityToSell = 0;

	if (mouse_check_button_released(mb_left)) {
		_quantityToSell = 1;
	}

	if (mouse_check_button_released(mb_right)) {
		_quantityToSell = variable_struct_exists(_item, "quantity") ? _item.quantity : 1;
	}

	if (_quantityToSell <= 0) {
		break;
	}

	var _result = sellInventoryItemQuantity(
		global.inventory,
		_tradeItem.gridx,
		_tradeItem.gridy,
		_quantityToSell
	);
	
	if (_result == TradeResult.Success) {
		audio_play_sound(snd_shells, 0, false);

		tradeItems = generatePlayerSellList(); 
		
		var _maxScroll = max(0, array_length(tradeItems) - visibleRows);
		scrollIndex = clamp(scrollIndex, 0, _maxScroll);

		break; 
	} else {
		playFailSound();
		itemShakeAmount[_drawIndex] = 10; 
	}
}
```

A lógica de mouse fica na UI, não dentro da função de venda.

Isso mantém o sistema mais limpo e permite futuramente adicionar modal de quantidade sem alterar a regra principal da venda.

---

## Lista de itens vendáveis do jogador

A aba de venda usa uma lista gerada a partir do inventário do jogador:

```gml
generatePlayerSellList()
```

Essa lista deve conter informações suficientes para a UI localizar o item no grid:

```gml
{
	itemId: _item.itemId,
	type: _item.type,
	quantity: _item.quantity,
	gridx: _x,
	gridy: _y
}
```

Os campos `gridx` e `gridy` são importantes porque a venda opera diretamente sobre o slot do inventário:

```gml
sellInventoryItemQuantity(global.inventory, _tradeItem.gridx, _tradeItem.gridy, _quantity)
```

---

## UI de Trade

A UI de trade possui duas abas principais:

```text
[ Comprar ] [ Vender ]
```

A aba de compra lista:

```gml
merchant.tradeItems
```

A aba de venda lista:

```gml
generatePlayerSellList()
```

A UI exibe:

- nome do comerciante
- dinheiro atual do jogador
- lista de itens
- quantidade
- preço
- seleção de item
- feedback visual de erro/acerto
- scroll quando há muitos itens

---

## `obj_trade`

O objeto de trade recebe o NPC como `target`:

```gml
instance_create_layer(0, 0, "Controllers", obj_trade, {
	target: id
});
```

No `obj_trade`:

```gml
merchant = target;
tradeItems = merchant.tradeItems;
```

O objeto acessa:

```gml
merchant.name
merchant.tradeItems
merchant.isInteracting
```

Ao fechar o trade, deve liberar o NPC:

```gml
merchant.isInteracting = false;
```

---

## Estado do player durante trade

Durante o trade, o player deve ficar travado, semelhante ao diálogo.

Função planejada/usada:

```gml
function playerTradeState() {
	handleAngleOffset(true, .2, 0);
	adjustPlayerInteractions(false);
	updateSpriteWithState(sprites.iddle);

	velh = 0;
	velv = 0;
}
```

Ao abrir trade:

```gml
obj_player.currentState = playerTradeState;
```

Ao fechar trade:

```gml
obj_player.currentState = playerIddleState;
```

---

## Interação com NPC

No NPC, o trade é aberto pela opção `trade`.

Fluxo esperado:

```gml
case "trade":
	if (!canTrade) return;
	if (isInteracting) return;

	isInteracting = true;
	closeInteractOptions();

	instance_create_layer(0, 0, "Controllers", obj_trade, {
		target: id
	});
break;
```

O `isInteracting` evita múltiplas interações simultâneas com o mesmo NPC.

---

## Scroll da UI

Variáveis usadas no `obj_trade`:

```gml
scrollIndex = 0;
visibleRows = 6;
rowHeight = 42;
selectedIndex = -1;
```

A lista deve desenhar apenas os itens visíveis:

```gml
var _start = scrollIndex;
var _end = min(scrollIndex + visibleRows, array_length(tradeItems));

for (var i = _start; i < _end; i++) {
	var _drawIndex = i - scrollIndex;
	var _rowY = _listY + (_drawIndex * rowHeight);

	var _tradeItem = tradeItems[i];
}
```

Após comprar ou vender, a lista pode mudar. Por isso o scroll deve ser ajustado:

```gml
var _maxScroll = max(0, array_length(tradeItems) - visibleRows);
scrollIndex = clamp(scrollIndex, 0, _maxScroll);
```

---

## Integração futura com quests

Para integrar o sistema de trading ao tutorial, o próximo passo é criar eventos de quest para compra e venda.

Eventos recomendados:

```gml
QuestEvent.ItemBought
QuestEvent.ItemSold
```

A compra deve disparar o evento apenas depois de concluída com sucesso:

```gml
obj_quest_manager.notifyEvent(QuestEvent.ItemBought, {
	itemId: _tradeItem.itemId,
	itemType: _tradeItem.type,
	quantity: _tradeItem.quantity
});
```

A venda deve guardar os dados do item antes de alterar/remover a stack:

```gml
var _itemId = _item.itemId;
var _itemType = _item.type;
```

E disparar depois da venda bem-sucedida:

```gml
obj_quest_manager.notifyEvent(QuestEvent.ItemSold, {
	itemId: _itemId,
	itemType: _itemType,
	quantity: _quantity
});
```

Esses eventos permitirão quests como:

```text
Compre uma garrafa de água
Venda um item para o comerciante
Volte ao sobrevivente
```

---

## Convenções importantes

### Itens em sistemas de gameplay

Ao comparar ou identificar itens em regras de gameplay, usar sempre:

```gml
itemId + type
```

ou, em payloads de quest:

```gml
itemId + itemType
```

Nunca depender apenas de `itemId`.

---

### Espaço vazio no inventário

Usar:

```gml
BLANK_INVENTORY_SPACE
```

Não usar:

```gml
global.blankInventorySpace
```

---

### Compra

Compra deve ser transacional:

```text
não tem dinheiro -> falha
não tem espaço -> falha
não adiciona parcialmente
não remove dinheiro se falhar
```

---

### Venda

Venda usa o item real do inventário.

A venda pode ser:

```text
clique esquerdo -> 1 unidade
clique direito -> stack inteira
```

A UI decide a quantidade.

A função de venda apenas recebe a quantidade e executa a regra.

---

## Estado validado

Foi validado anteriormente que:

- player com 300 de dinheiro comprou 16 munições
- valor unitário era 13
- valor total foi 208
- dinheiro final ficou 92
- 16 munições entraram no inventário
- validação de dinheiro funcionou
- validação de inventário funcionou
- venda de item funcionou
- venda parcial por clique foi implementada na UI

Cálculo de compra validado:

```text
13 * 16 = 208
300 - 208 = 92
```

---

## Próximos passos recomendados

1. Criar `QuestEvent.ItemBought`
2. Criar `QuestEvent.ItemSold`
3. Disparar os eventos após compra/venda bem-sucedidas
4. Criar uma quest simples para introduzir o comerciante no tutorial
5. Integrar comerciante ao fluxo após a quest da fogueira
6. Fazer o jogador comprar um item básico
7. Fazer o jogador retornar ao sobrevivente

Fluxo sugerido:

```text
machado
↓
fogueira
↓
conhecer comerciante
↓
comprar suprimento
↓
voltar ao sobrevivente
```
