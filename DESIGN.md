# DESIGN.md — FutDraw

Contrato de design do app. Toda sessao le este arquivo antes de mexer em UI.
Trabalho novo estende o que esta aqui; nunca contradiz em silencio. Quando o
usuario muda uma decisao, este arquivo muda no mesmo commit.

## Leitura

App de organizar pelada: um grupo, um elenco, um sorteio de times, um campo.
Publico sao jogadores de pelada no Brasil, no celular, quase sempre em Android,
quase sempre a noite antes do jogo.

- **Registro:** utilitario nas telas de gestao (grupo, elenco, partidas,
  ranking), expressivo na tela de times sobre o campo.
- **Dials:** VARIANCE 5 / MOTION 4 / DENSITY 6. A tela do campo sobe para
  VARIANCE 8 / MOTION 7, e e o unico lugar que sobe.
- **Idioma:** portugues do Brasil em toda string visivel.

## Cor

- **Seed:** escolhido pelo usuario entre 8 (`ThemeColor`), padrao violeta. O
  seed e dono do chrome: botoes, selecao, indicadores, FAB.
- **Modo primario:** escuro. O claro e desenhado, nao invertido, e ambos saem da
  mesma funcao (`AppTheme.build`).
- **Escada de superficie:** profundidade vem de `surfaceContainer*`, nunca de
  sombra no escuro.

Duas familias de cor **nao** seguem o seed, de proposito:

1. **A cena do campo** (`PitchTheme`): turfa, linhas e refletor sao fotografia,
   nao tema. Com seed carmesim o gramado ficaria vermelho.
2. **O codigo de posicao** (`PositionPalette`): quatro matizes fixas que o
   usuario aprende a ler. Harmonizar com o seed faria as quatro convergirem (no
   tema esmeralda, todas para o verde).

### Codigo de posicao

Fonte unica: `lib/theme/position_palette.dart`. Nao existe segunda copia --
`PitchTheme.positionColors` sai de `kPositionTurfColors`.

| Posicao | Matiz | Icone |
|---|---|---|
| Goleiro | ambar | `Icons.back_hand` |
| Defensor | azul | `Icons.shield` |
| Meio-campo | verde | `Icons.hub` |
| Atacante | vermelho | `Icons.sports_soccer` |

Regras que valem sempre:

- **Tres sinais, nunca so a cor.** Cor, icone e nome juntos. Cor sozinha nao
  serve para quem nao distingue vermelho de verde.
- **Dois tons por matiz.** `ink`/`container`/`outline` para chips sobre a
  superficie do app; `onTurf` para o campo, onde o chip tem fundo quase preto
  proprio.
- **A regra do campo e luminancia, nao matiz.** O verde antigo sumia porque era
  `Colors.green` cru direto sobre a turfa. Sobre `chipSurface` ele contrasta.
- Dessaturadas de proposito: quatro cores em saturacao cheia numa lista de vinte
  linhas viram ruido.
- Travado em `test/theme/position_palette_test.dart`: contraste >= 4.5:1 do ink
  sobre o container nos dois modos, >= 3:1 sobre o chip do campo, e as quatro
  matizes a pelo menos 40 graus uma da outra.

### Cores fixas fora do codigo de posicao

- `captainGold` (`#F5C542`) para bracadeira e anel de capitao. Bracadeira de
  capitao e dourada, nao roxa.
- `teamAccents`: seis acentos de time, fixos. Derivar seis cores de um seed so
  produz seis matizes quase iguais.


### A turfa

Desenhada por fragment shader (`assets/shaders/pitch_turf.frag`), com fallback
obrigatorio em `PitchSurfacePainter`. `PitchSurface` escolhe entre os dois.

O shader existe por um motivo so, e vale a pena ser explicito: **a listra do
campo nao e uma cor diferente.** O rolo do cortador deita a grama para um lado
em cada passada; a faixa deitada para longe de quem olha devolve luz, a deitada
para perto engole. O efeito depende da direcao da luz, e por isso o contraste
das listras **inverte de sinal** ao cruzar o eixo do refletor. Duas cores
alternadas, que era o que o painter fazia, dao aspecto de adesivo.

O fallback nao e provisorio. Responde por tres casos permanentes:

1. **Primeiro frame.** `FragmentProgram.fromAsset` e assincrono; sem fallback o
   campo pisca preto.
2. **A imagem compartilhada.** flutter/flutter#163521: shader dentro de
   `RepaintBoundary.toImage` sai espelhado em parte dos Android. O PNG e o
   produto que sai do app, entao ele desenha pelo painter, sempre.
3. **O teste.** Em `flutter test` o `.frag` nao esta compilado no bundle.

Regras:

- **`highp`, nunca `mediump`.** Em GLES movel mediump e float de 16 bits e o
  `43758.5453123` do hash nao cabe: o grao vira faixa nos Android baratos, que
  sao o aparelho principal deste app.
- **Uniformes sao contrato.** A ordem de declaracao no GLSL e a ordem dos slots
  em `PitchTurfPainter`. Trocar uma sem a outra nao da erro de compilacao, da um
  campo roxo. Travado em `test/views/pitch_surface_test.dart`.
- Os dois caminhos saem do mesmo `PitchTheme`. Nenhum numero de cor mora no
  `.frag`.
- `tool/pitch_preview.dart` roda a cena isolada em aparelho, com botao para
  alternar shader e painter. Nao entra no app.


### Travado e destravado

O campo comeca **travado** e tem um botao com rotulo para destravar
(`FieldControls`). Cada modo tem um gesto so:

| Modo | Gesto | O que faz |
|---|---|---|
| Travado | segurar 250 ms e arrastar | troca dois jogadores |
| Destravado | arrastar | move o jogador para onde o dedo soltar |

**Um gesto nao pode significar duas coisas.** Se destravado tambem trocasse ao
soltar em cima de alguem, o resultado do arrasto dependeria de acertar um alvo
de 48 dp no meio de um campo cheio -- e o usuario descobriria qual foi so
depois de soltar.

O cadeado **nunca aparece sozinho**: o botao diz o estado em que esta
("Travado" / "Livre") e a linha acima diz o gesto que vale. Um glifo de cadeado
sozinho nao distingue estado atual de acao ao tocar.

Travado e o padrao porque trocar jogador e a operacao do dia a dia, e porque um
campo que se desmonta no primeiro arraste acidental perde o desenho que o
sorteio entregou. "Restaurar" so aparece quando ha posicao movida.

As posicoes movidas vivem em `Formation.overrides`, normalizadas, **nao** num
mapa de pixels no `State`: e assim que sobrevivem a troca de aba e a rotacao e
entram no PNG compartilhado. Nao vao para a API; saem ao deixar a tela.

### Tatica

`TeamTactic` (`lib/models/formation/team_tactic.dart`) e a fonte unica de
"quantos de cada setor". Quem decide **quem** vai em cada slot continua sendo o
`FormationAssigner`.

- **A tatica e proporcao, nao teto.** Grupo em 4-4-2 com 12 jogadores na linha
  vira 4-5-3, nunca 4-4-2 com dois jogadores apagados. Travado em
  `test/models/team_tactic_test.dart`, que varre todo elenco de 1 a 30.
- **Abrir o campo nao reescala ninguem.** A forma inicial sai da composicao
  real do sorteio, porque ela e um fato e a tatica e um desejo; esconder que o
  time caiu com tres zagueiros seria mentir sobre o sorteio. A tatica entra
  quando o usuario pede, em "Reorganizar por Tatica".
- **Reorganizar muda a forma do campo, nunca o `Player`.** A versao anterior
  escrevia em `Player.position` e cortava o elenco com `.take()`.

## Tipografia

- **PervitinaDex** para marca e display. **Kanit** para todo o resto (w400,
  w500, w600, w700, todas empacotadas em assets).
- Kanit **nao tem algarismo tabular**. Numero que precisa alinhar em coluna
  recebe largura minima explicita, nunca fixa.
- Escala e estilos em `lib/theme/app_typography.dart`. Numeros de destaque tem
  nome: `scoreboardValue` (placar), `ratingValue` (nota em linha de lista).

## Espaco, raio, movimento

Tokens em `lib/theme/app_tokens.dart`. Sao os unicos valores que existem.

- `AppSpacing`: 2/4/8/12/16/24/32/48.
- `AppRadii`: uma familia so -- 8/12/16/20, mais `pill`.
- `AppMotion`: saidas correm a 50-75% da entrada; nada que o usuario dispara
  dezenas de vezes por dia ganha animacao; `AppMotion.at` respeita
  "reduzir movimento" do sistema.

## Componentes

- **Estilo mora no tema**, nunca no widget. Sem cor, tamanho de fonte, raio ou
  padding avulso dentro de `build`.
- **Card nao e o padrao.** Itens homogeneos numa lista sao linhas separadas por
  hairline `outlineVariant`; a afordancia de toque quem da e o `InkWell`. Card
  so quando a elevacao comunica hierarquia de verdade.
- **Icone sem rotulo so se o glifo for universal.** Uma bola, um calendario e um
  grafico de barras nao sao.
- **Estado vazio tem proximo passo.** Carregamento tem a forma do conteudo final
  (esqueleto), nao um spinner centralizado.
- Avatar de jogador e sempre `PlayerAvatar`: ele resolve `cacheWidth`, erro de
  rede e nome vazio.

## Verificacao

`test/theme/theme_probe.dart` tem um exemplar de cada atomo tematizado. Atomo
novo entra nele e ganha de graca a varredura de
`test/theme/theme_sweep_test.dart`: 8 seeds x 2 brilhancias x 4 tamanhos, com
checagem de contraste, alvo de toque e estouro.

## Log de decisoes

| Data | Decisao | Porque |
|---|---|---|
| 2026-09-04 | Sistema de tema proprio (`lib/theme/`), `ThemeSelector` removido | O app era `ColorScheme.fromSeed` cru com estilo inline espalhado |
| 2026-09-04 | Campo nao segue o seed | Seed carmesim dava gramado vermelho |
| 2026-09-04 | `captainGold` fixo | Bracadeira ficava roxa no tema violeta |
| 2026-09-16 | Codigo de posicao sai de `PitchTheme` para `PositionPalette` | O usuario le a posicao na lista e no formulario muito antes de chegar ao campo |
| 2026-09-16 | Meio-campo passa de roxo para verde, defensor de ciano para azul | Pedido do usuario; a restricao antiga era luminancia sobre a turfa, nao matiz, e o chip do campo hoje tem fundo proprio |
| 2026-09-16 | `PlayerCard` vira `PlayerRow` | O card gastava ~156 dp para mostrar dois campos; cabiam quatro jogadores por tela |
| 2026-09-16 | As tres acoes do grupo saem da AppBar e viram botoes com nome | Cinco icones sem rotulo disputavam a barra e truncavam o nome do grupo |
| 2026-09-17 | `PitchView` substitui `SoccerField` na tela de times | O antigo posicionava por `largura / (n + 1)`: nao tinha formacao, o desenho saia de quantos jogadores calhavam de ter cada posicao |
| 2026-09-17 | Turfa por shader, com fallback obrigatorio | A listra de corte e luz anisotropica, nao cor alternada; o fallback cobre primeiro frame, captura de PNG e teste |
| 2026-09-17 | A imagem compartilhada nunca usa shader | flutter/flutter#163521 espelha o shader dentro de `toImage` em parte dos Android |
| 2026-09-17 | Campo comeca travado; destravar libera arrasto livre | Pedido do usuario. Cada modo tem um gesto so: destravado que tambem trocasse tornaria o resultado dependente de acertar um alvo pequeno num campo cheio |
| 2026-09-17 | O cadeado sempre com rotulo de estado | Glifo de cadeado sozinho nao distingue estado atual de acao ao tocar |
| 2026-09-17 | `TeamTactic`: tatica e proporcao, nao teto | "Reorganizar por Tatica" cortava o elenco com `.take()` sobre contagens cravadas; um time de campo com 10 na linha voltava com 6 |
| 2026-09-17 | A forma inicial do campo sai da composicao, nao da tatica | A composicao e um fato e a tatica e um desejo; abrir ja reescalado esconderia que o sorteio deu tres zagueiros |
