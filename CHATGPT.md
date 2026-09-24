# CHATGPT.md — Guia do Projeto FutDraw

Use este arquivo como contexto de trabalho ao atender pedidos sobre este repositório. Ele consolida a documentação atual; quando houver conflito, priorize o código e este guia em vez de anotações históricas.

## Produto

FutDraw é um aplicativo Flutter (Material 3, Dart `^3.7.0`) para organizar grupos de futebol, cadastrar jogadores e sortear times equilibrados. O app consome uma API REST .NET separada. Não há persistência local de dados de domínio: grupos, jogadores e sorteios ficam na API; apenas sessão e configurações ficam em `SharedPreferences`.

## Comandos úteis

```bash
flutter pub get
flutter run
flutter analyze
flutter test
dart fix --apply
flutter build apk --release
flutter build ios --release
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

Execute `flutter analyze` após alterações de código e execute testes quando a área modificada os possuir.

## Arquitetura

O código em `lib/` segue esta separação:

| Camada | Caminho | Responsabilidade |
|---|---|---|
| Core | `core/` | DI, Dio, autenticação, resultados e constantes da API |
| Data | `data/models/`, `data/remote/` | DTOs e fontes remotas |
| Domínio | `models/`, `repositories/` | Modelos e contratos/implementações de repositórios |
| Estado | `controllers/` | `ChangeNotifier`s usados com Provider |
| Interface | `views/`, `components/` | Telas, widgets e diálogos |

Fluxo esperado:

```text
View → Controller → Repository → RemoteDataSource → Dio → REST API → DTO → modelo de domínio
```

Ao adicionar uma funcionalidade, mantenha esse fluxo. A interface não deve chamar Dio ou uma fonte remota diretamente.

## Convenções importantes

- `ServiceLocator` (`core/di/service_locator.dart`) registra Dio, `AuthService`, fontes remotas e repositórios. É inicializado em `main()` antes de `runApp`; obtenha dependências por `ServiceLocator().<dependencia>`.
- Métodos de repositórios e fontes remotas retornam `AppResult<T>`, com `AppSuccess<T>` ou `AppError<T>`. Trate o resultado com `.when(success:, error:)` ou com `isSuccess`/`errorMessage`.
- O `MultiProvider` raiz expõe `AuthController`, `GroupController`, `PlayerController` e `ConfigurationsController`. Use `context.read<T>()` para ações e `context.watch<T>()` para observar estado.
- `ReservePlayerController` não está no `MultiProvider`; crie-o localmente quando necessário.
- A navegação é imperativa (`Navigator.push`, `pushReplacement`, `pushAndRemoveUntil`); não introduza rotas nomeadas sem uma decisão explícita de arquitetura.
- A análise estática suprime globalmente `must_be_immutable` e `use_build_context_synchronously`. Ainda assim, prefira verificações de `mounted` depois de operações assíncronas ao alterar código novo.

## Autenticação e persistência local

`AuthService` guarda token JWT, nome de exibição e e-mail em `SharedPreferences`. `AuthInterceptor` envia `Authorization: Bearer <token>` em cada requisição e limpa a sessão ao receber 401.

`ConfigurationsController` persiste a configuração no campo `_config` de `SharedPreferences`. Ela inclui:

- `generationAlgorithm`: `balanced` ou `snakeDraft`;
- `themeColor`: uma das oito opções suportadas;
- `isDarkMode`;
- `gerarIndependenteDaPosicao`.

`DBHelper` em `lib/helpers/db_helper.dart` é um stub legado; não o use como persistência nova.

## Tema e interface

`ThemeSelector.build(ThemeColor, isDark)` constrói o `ThemeData` por meio de `ColorScheme.fromSeed`.

- Fonte de texto: `Kanit`.
- Fonte de marca e display: `PervitinaDex`.

Preserve Material 3 e reutilize os componentes existentes em `components/` antes de criar equivalentes.

## API REST

A URL de desenvolvimento está em `core/constants/api_constants.dart`:

```text
http://10.0.2.2:5020
```

Ela funciona para o emulador Android e deve ser alterada para dispositivo físico, simulador iOS ou produção.

Principais endpoints:

- `POST /api/auth/login`, `/registrar`, `/confirmar-email`, `/google`
- `GET|POST|PUT|DELETE /api/grupos`
- `GET|POST /api/grupos/{grupoId}/jogadores`
- `PUT|DELETE /api/jogadores/{id}`
- `POST /api/grupos/{grupoId}/sortear` — corpo: `{ numeroTimes, algoritmo, gerarIndependenteDaPosicao }`
- `POST /api/grupos/{grupoId}/sorteios/sortear/ia` — corpo: `{ numeroTimes, instrucoes? }`
- `POST /api/grupos/{grupoId}/sorteios` — salva um sorteio

## Navegação principal

```text
SplashScreen → LoginView ou HomeView
LoginView → HomeView
LoginView → RegisterView → VerificarEmailView → HomeView
HomeView (lista de grupos) → PlayerListScreen → TeamGenerationScreen
                                        ├→ TeamsDisplayScreen
                                        └→ AITeamSortView → TeamsDisplayScreen
```

`TeamsDisplayScreen` apresenta os times em campo ou lista, permite compartilhar como PNG e salvar o sorteio.

`DrawView` e `ResultsView` ainda podem ser acessados pelo menu lateral, mas pertencem ao fluxo anterior à API. Não os tome como referência para novas funcionalidades sem confirmar que o pedido é especificamente sobre o legado.

## Limites deste guia

`ANALISE.md` descreve uma versão anterior baseada em SQLite e alguns controladores e recursos legados. Use-a apenas como referência histórica. O `README.md` ainda é o modelo padrão do Flutter e não descreve o produto.
