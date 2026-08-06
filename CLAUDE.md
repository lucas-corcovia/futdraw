# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
flutter pub get          # install dependencies
flutter run              # run on connected device/emulator
flutter analyze          # static analysis (flutter_lints)
dart fix --apply         # auto-fix lint issues
flutter test             # run tests (minimal coverage currently)
flutter build apk --release
flutter build ios --release
dart run flutter_launcher_icons        # regenerate launcher icons
dart run flutter_native_splash:create  # regenerate splash screen
```

## Architecture

Single Flutter app (Dart SDK `^3.7.0`, Material 3) that talks to a separate .NET REST API running locally. No local SQLite — all persistence is REST + SharedPreferences. `DBHelper` in `lib/helpers/db_helper.dart` is a dead stub.

### Layer structure under `lib/`

| Layer | Path | Responsibility |
|---|---|---|
| Core | `core/` | DI, Dio client, auth interceptor, `AppResult<T>` sealed type, API constants |
| Data | `data/models/`, `data/remote/` | Request/response DTOs, remote data sources |
| Domain | `models/`, `repositories/` | Domain models, repository interfaces + impls |
| State | `controllers/` | ChangeNotifier controllers (Provider) |
| UI | `views/`, `components/` | Screens, widgets, dialogs |

### Key patterns

**Service Locator** (`core/di/service_locator.dart`): wires Dio, `AuthService`, all remote datasources, and repositories. Initialized in `main()` before `runApp`. Access via `ServiceLocator().<dependency>`.

**`AppResult<T>`** (`core/result/result.dart`): sealed type with `AppSuccess<T>` and `AppError<T>` subclasses. All repository/datasource methods return this. Use `.when(success:, error:)` or `.isSuccess`/`.errorMessage`.

**State management**: `MultiProvider` at root with four controllers — `AuthController`, `GroupController`, `PlayerController`, `ConfigurationsController`. Access via `context.read<X>()` / `context.watch<X>()`. `ReservePlayerController` is not in the root provider tree; it must be instantiated locally.

**Navigation**: fully imperative (`Navigator.push`, `pushReplacement`, `pushAndRemoveUntil`). No named routes.

### Data flow

`View → context.read<Controller>() → Repository → RemoteDataSource → Dio → REST API → DTO → domain model`

### Auth

`AuthService` persists JWT token, display name, and email in SharedPreferences. `AuthInterceptor` injects `Authorization: Bearer <token>` on every request and clears the session on 401.

### Configuration

`ConfigurationsController` persists a `Configuration` object as JSON under the key `_config` in SharedPreferences. Contains: `generationAlgorithm` (balanced|snakeDraft), `themeColor` (8 options), `isDarkMode`, `gerarIndependenteDaPosicao`.

### Theme

`ThemeSelector.build(ThemeColor, isDark)` creates Material 3 `ThemeData` via `ColorScheme.fromSeed`. Fonts: `Kanit` (body), `PervitinaDex` (brand/display).

## REST API

Base URL: `http://10.0.2.2:5020` (Android emulator loopback to host). **Must be changed** for a real device, iOS simulator, or production. Defined in `core/constants/api_constants.dart`.

Key endpoints:
- `POST /api/auth/login`, `/registrar`, `/confirmar-email`, `/google`
- `GET|POST|PUT|DELETE /api/grupos` — group CRUD
- `GET|POST /api/grupos/{grupoId}/jogadores` — player list and add
- `PUT|DELETE /api/jogadores/{id}` — player update/delete
- `POST /api/grupos/{grupoId}/sortear` — team draw (body: `{ numeroTimes, algoritmo, gerarIndependenteDaPosicao }`)
- `POST /api/grupos/{grupoId}/sorteios/sortear/ia` — AI team draw (body: `{ numeroTimes, instrucoes? }`)
- `POST /api/grupos/{grupoId}/sorteios` — save a draw

## Navigation flow

```
SplashScreen → LoginView | HomeView (based on stored token)
LoginView → HomeView | RegisterView → VerificarEmailView → HomeView
HomeView (GroupList) → PlayerListScreen → TeamGenerationScreen
  → TeamsDisplayScreen (field view, list view, share as PNG, save draw)
  → AITeamSortView → TeamsDisplayScreen
```

Legacy `DrawView` and `ResultsView` are still reachable from the drawer but are pre-API screens.

## Linting

`analysis_options.yaml` suppresses `must_be_immutable` and `use_build_context_synchronously` globally. Several view files also carry `// ignore_for_file: use_build_context_synchronously` — async navigation is done without `mounted` checks in some screens.
