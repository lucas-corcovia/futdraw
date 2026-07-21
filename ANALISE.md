# FutDraw — Análise do Projeto

App Flutter para sorteio balanceado de times de futebol por nota.

---

## Dependências Principais

| Pacote | Finalidade |
|---|---|
| `provider ^6.1.4` | Gerenciamento de estado |
| `sqflite ^2.4.2` | Banco de dados local SQLite |
| `shared_preferences ^2.5.3` | Persistência de configurações |
| `image_picker ^1.1.2` | Foto do jogador (câmera/galeria) |
| `screenshot + share_plus` | Exportar/compartilhar times |
| `file_picker` | Importar banco de dados |
| `http ^1.3.0` | Upload de imagens para ImgBB |

---

## Modelos de Dados

**Player** — `lib/models/player.dart`
- `id`, `grupoId`, `nome`, `nota (0–10)`, `urlFoto?`, `position (PlayerPosition)`, `ehCapitao`, `reserva`

**Group** — `lib/models/group.dart`
- `id`, `nome`, `playerCount`, `captainCount`, `players: List<Player>`

**Team** — `lib/helpers/team_generator.dart` (apenas em memória)
- `name`, `players`, `averageSkill`, `goalkeepersCount`, `captainsCount`

**Configuration** — `lib/models/configuration.dart` (SharedPreferences)
- `generationAlgorithm: balanced | snakeDraft`
- `themeColor: green | blue | red | purple`

**SQLite:** tabelas `players` e `groups`

---

## Telas

| Tela | Arquivo | Função |
|---|---|---|
| HomeView | `lib/views/home_view.dart` | Lista de grupos; ponto de entrada |
| PlayerListScreen | `lib/views/player.list.view.dart` | Jogadores do grupo (Titulares/Reservas) com filtros por posição |
| TeamGenerationScreen | `lib/views/team_generator_view.dart` | Configura quantidade de times e dispara sorteio |
| TeamsDisplayScreen | `lib/views/teams_display_view.dart` | Exibe times; vista de campo (drag & drop) ou lista |
| DrawView | `lib/views/draw_view.dart` | Fluxo legado de sorteio sem grupo |
| ResultsView | `lib/views/results_view.dart` | Resultado legado em cards; exporta PNG |

---

## Estado (Provider / ChangeNotifier)

| Controller | Responsabilidade |
|---|---|
| `GroupController` | CRUD de grupos, grupo selecionado |
| `PlayerController` | CRUD de jogadores, filtros, import/export JSON |
| `ConfigurationsController` | Tema e algoritmo (SharedPreferences) |
| `ImgBBController` | Upload de foto via HTTP |
| `DrawController` | Algoritmo legado (sem estado) |

---

## Algoritmos de Sorteio (`lib/helpers/team_generator.dart`)

- **balanced:** distribui aleatoriamente, depois itera trocas entre o time mais forte e mais fraco até diferença < 1.0
- **snakeDraft:** ordena por nota desc, distribui em ordem de cobra (1-2-3-3-2-1)
- Capitães e goleiros são distribuídos separadamente por round-robin em ambos

---

## Fluxo de Navegação

```
HomeView
 └── GroupItem → PlayerListScreen
       ├── FAB → AddPlayer (novo/editar)
       └── AppBar → TeamGenerationScreen
                     └── TeamsDisplayScreen (drag & drop, share)
Drawer → DrawView → ResultsView  (fluxo legado)
```

---

## Widgets Relevantes

| Widget | Função |
|---|---|
| `SoccerField` | Campo visual com CustomPainter; modo tático e modo livre |
| `PlayerCard` | Card com foto, nota, posição, menu de ações |
| `AddPlayer` | Formulário completo com upload de foto |
| `AddGroup` | Formulário de grupo |
| `AddManyPlayers` | Adição em massa |
| `FiltersPlayerList` | Barra de filtros por posição (animada) |

---

## Observações

- Fotos hospedadas externamente no **ImgBB** via HTTP.
- `GroupItem` tem dados hardcoded (data, local, formato) — funcionalidades planejadas não implementadas.
- Exportação/importação do banco SQLite disponível (visível apenas em dev).
- `DrawView`/`ResultsView` são fluxo legado; o fluxo principal é `TeamGenerationScreen` → `TeamsDisplayScreen`.
