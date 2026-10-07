# Fase 4: Persistência dos residentes

> Status: **planejado, não implementado**.
> Depende das Fases 1–3 da refatoração de residentes/workers, que já estão aplicadas.

## Contexto

Hoje os residentes da base existem **só em memória** (`global.baseResidents`). Fechar o jogo apaga todos eles: os recrutados na história (Clara/Hank), os atributos (nível/XP) e as atribuições a mobílias.

Desde a Fase 2 a atribuição de trabalho fica **dentro do residente** (`BaseResident.workplace`). Então salvar os residentes já salva também onde cada um trabalha. Não existe mais estado de workers duplicado em mobília nem em `global.workingNpcs`.

### Estado atual relevante

| Item | Onde | Situação |
|---|---|---|
| Residentes | `global.baseResidents` (struct `residentId → BaseResident`), `scripts/scr_npc_list/scr_npc_list.gml` | só em memória |
| Próximo id | `global.nextResidentId` | só em memória |
| Atribuição | `BaseResident.workplace = { furnitureId, objectId, slot }` | vai junto com o residente |
| Cache de workers | `global.furnitureWorkersCache`, `scripts/scr_base_furniture_workers/scr_base_furniture_workers.gml` | derivado, **não salvar** |
| Save da base | `savePlayerBase()` / `loadPlayerBase()`, `scripts/scr_save/scr_save.gml` | salva mobílias e itens |
| Quando a base é salva | `obj_controller/Other_5.gml` (Room End), só se `room == rm_player_base` | — |
| Quando a base é carregada | `rooms/rm_player_base/RoomCreationCode.gml`: `loadPlayerBase()` → `createNpcs()` → `setUpBaseForQuests()` | toda vez que a base é aberta |

## Objetivo

1. Residentes, atributos e atribuições sobrevivem a fechar e reabrir o jogo.
2. Entrar e sair da base **não** sobrescreve o estado em memória com o que está no disco.
3. Saves sem o bloco `residents` carregam sem erro, com lista vazia.

## Formato no `player_base_save.json`

Adicionar o bloco `residents` ao lado de `furnitures` e `items`:

```json
{
  "furnitures": [ ... ],
  "items": [ ... ],
  "residents": {
    "nextResidentId": 14,
    "list": [
      {
        "residentId": 12,
        "name": "Clara",
        "genderId": 1,
        "skinColor": 6986707,
        "hairOption": 3,
        "hairColor": 538457,
        "eyeId": 0,
        "outfitId": 2,
        "helmetId": -1,
        "bagId": 5,
        "attributes": [ { "id": 0, "xp": 40, "level": 2 }, ... ],
        "workplace": { "furnitureId": "campfire", "objectId": 3, "slot": 0 }
      }
    ]
  }
}
```

- Salvar **só dados primitivos**. O `json_stringify` não leva os métodos (`getHair`, `increaseXp`), então tudo precisa ser reconstruído no load.
- `workplace` vai como `undefined`/ausente quando o residente não trabalha.

## Implementação

### 1. Serialização (`scripts/scr_npc_list/scr_npc_list.gml`)

- `getBaseResidentsSaveData()` → `{ nextResidentId, list: [...] }`, montado a partir de `getBaseResidentList()`. Copia campo a campo para structs simples, sem passar o `BaseResident` direto.
- `loadBaseResidentsSaveData(_data)`:
  - limpa `global.baseResidents = {}`;
  - para cada item, cria `new BaseResident(_item.residentId, _item)` e copia `xp`/`level` de cada atributo **pelo `id`**, não pela posição. Assim um atributo novo adicionado no futuro não quebra o save;
  - restaura `workplace` se existir;
  - `global.nextResidentId = max(_data.nextResidentId, maior residentId + 1)`, para nunca reutilizar um id;
  - chama `invalidateFurnitureWorkersCache()` e `loadResidentList()` no `obj_base_residents_controller`.
- Ajuste no construtor: `BaseResident(_residentId, _data)` já aceita o struct de aparência. Só falta garantir que `createBaseResident` **não** seja usado no load, porque ele gera um id novo.

### 2. Save (`scripts/scr_save/scr_save.gml`)

- `savePlayerBase()`: adicionar `residents: getBaseResidentsSaveData()`.
- **Mock de teste**: com `DEBUG_MOCK_RESIDENTS` ligado, **não** gravar os residentes de teste no save real. Sugestão: o mock marca os residentes com `isMock = true`, e `getBaseResidentsSaveData` filtra esses residentes.

### 3. Load uma vez por sessão

O `loadPlayerBase()` roda **toda vez** que `rm_player_base` é aberta. Se ele recarregasse os residentes sempre, perderia o que mudou em memória desde o último save, como XP ganho ou residentes atribuídos.

- Flag `global.baseResidentsLoaded = false` em `scr_npc_list`.
- Em `loadPlayerBase()`, depois do `json_parse`:
  ```gml
  if (!global.baseResidentsLoaded) {
      loadBaseResidentsSaveData(_baseData[$ "residents"] ?? { nextResidentId: 0, list: [] });
      global.baseResidentsLoaded = true;
  }
  ```
- Fazer o mesmo nos caminhos de "arquivo vazio" e "JSON inválido", marcando a flag com a lista vazia.
- **Ordem**: o `RoomCreationCode` já chama `loadPlayerBase()` **antes** de `createNpcs()`, então os residentes existem quando as instâncias são criadas. Não precisa mudar.
- **Mock**: o `loadNpcMock()` roda no Create do `obj_base_residents_controller`, que acontece **antes** do `RoomCreationCode`. Com o load real, ele precisa rodar **depois** do `loadBaseResidentsSaveData`, senão os residentes de teste ficam com ids que colidem com os do save. Opções:
  - chamar `loadNpcMock()` dentro de `loadPlayerBase()`, logo após carregar os residentes (recomendado);
  - ou garantir que o mock só gere ids a partir de `global.nextResidentId`, o que já acontece via `createBaseResident`, e que rode depois do load.

### 4. `objectId` estável nas mobílias

A atribuição salva aponta para `{ furnitureId, objectId }`. Mobílias criadas pelo `loadDefaultBaseData()` ou colocadas no editor da room ficam com `objectId = -1` (default do `.yy`), e a checagem `is_undefined(objectId)` em `iterateBaseFurniture` nunca é verdadeira.

- Em `loadDefaultBaseData()`: chamar `setFurnitureBaseId(_instancia)` para cada mobília criada.
- Em `iterateBaseFurniture()` (`scripts/scr_base_furnitures/scr_base_furnitures.gml`): trocar `is_undefined(objectId)` por `objectId == -1`.
- Conferir que `global.baseFurnitureIdCount` é restaurado **antes** de gerar ids novos. O `loadBaseFurnitures` já faz isso, mas só quando existe save.

### 5. Quando salvar

Hoje a base só é salva no Room End. Se o jogo fechar com o player ainda na base, o que mudou se perde.

- Chamar `saveGame(false, true)`:
  - depois de `convertNpcToResident` (recrutar Clara/Hank);
  - depois de `assignResidentToFurniture` / `unassignResident`, ou com um debounce de alguns segundos para não gravar a cada arrasto.
- **Limitação**: `savePlayerBase()` só grava quando `room == rm_player_base`. Recrutar fora da base não salva até a próxima visita. Avaliar se os residentes devem ir para um arquivo próprio (`player_residents_save.json`), que pode ser gravado de qualquer room. **Recomendado**, porque residentes não dependem de instâncias da room.

### 6. Atribuições órfãs

Ao carregar, uma atribuição pode apontar para uma mobília que não existe mais (save editado, mobília desmontada no futuro).

- O `obj_npc_resident` já trata isso: `getFurnitureInstance` retorna `noone` e o residente fica `iddle`.
- Quando existir "desmontar mobília", chamar `unassignFurnitureWorkers(furnitureId, objectId)`, que já existe e foi mantida para isso.

## Fora do escopo (dependências conhecidas)

- **Quests não são salvas.** `setUpBaseForQuests()` recria o Hank enquanto `Quests.ExploreDump` não estiver completa. Depois de reiniciar o jogo, o Hank pode reaparecer como NPC de quest **e** como residente salvo. Resolver junto com o save de quests, ou checar se já existe um residente com o nome do preset antes de recriar.
- `global.activeCompanionPreset` também não é salvo.

## Verificação

1. `npx @gamemaker/gm-cli compile --errors-only`
2. Em jogo:
   - Recrutar a Clara, atribuí-la à fogueira, sair da base, **fechar e reabrir o jogo**. A Clara deve aparecer na base e voltar a trabalhar na fogueira.
   - Ganhar XP num residente (botão direito no menu), sair e voltar para a base **sem fechar o jogo**. O XP deve continuar igual (o load não sobrescreve a memória).
   - Apagar `residents` do `player_base_save.json` e abrir o jogo. Deve carregar sem erro, com a lista vazia.
   - Com `DEBUG_MOCK_RESIDENTS = true`, os residentes de teste não devem aparecer no JSON salvo.
   - Ids: recrutar um residente depois de reabrir o jogo. Ele deve receber um `residentId` que ainda não foi usado.
