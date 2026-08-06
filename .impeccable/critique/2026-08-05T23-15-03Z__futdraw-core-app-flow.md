---
timestamp: 2026-08-05T23-15-03Z
slug: futdraw-core-app-flow
---
Method: dual-agent (A: a2a64814be32f9562 · B: a1248b35fe30ba7f8)

## Design Health Score

| # | Heuristic | Score | Key Issue |
|---|-----------|-------|-----------|
| 1 | Visibility of System Status | 2 | Cross-swap mode active state is a subtle icon color change only; result screen has no reveal ceremony |
| 2 | Match System / Real World | 3 | Authentic Brazilian soccer vocabulary throughout; "Snake Draft" is unexplained American terminology |
| 3 | User Control and Freedom | 2 | No undo for any swap; no way to unsave a draw; cross-swap escape undiscoverable in field view |
| 4 | Consistency and Standards | 2 | Three typeface families, three feedback mechanisms, two verb pairs for "swap" |
| 5 | Error Prevention | 1 | Avatar tap triggers destructive delete dialog regardless of photo presence; skill slider allows 0.0 despite label showing 1.0 |
| 6 | Recognition Rather Than Recall | 2 | Five unlabeled icon-only actions at the most important screen; `Icons.tune` intent unreachable without long-press tooltip |
| 7 | Flexibility and Efficiency of Use | 2 | "Gerar Times" popup shortcut exists but buried; no quick-reroll from result screen; no last-used team count |
| 8 | Aesthetic and Minimalist Design | 2 | TeamsDisplayScreen appbar is the most cluttered screen at the emotional apex; GroupItem shows 8 data points per card |
| 9 | Error Recovery | 1 | Toast disappears in 5s with no retry; `_savePlayer` pops the form even on API failure; no undo anywhere post-swap |
| 10 | Help and Documentation | 1 | Single info button for "Como os Times são Formados"; no onboarding; AI screen is the only one with contextual help |
| **Total** | | **18/40** | **Poor** |

---

## Design Specificity Verdict

**LLM assessment**: FutDraw is a bifurcated product. The domain vocabulary — Titulares, Reservas, Sorteio, Capitão, goleiros fixos, the four field types — is authentic, built from the inside of Brazilian recreational soccer culture. The SoccerField widget is the single most distinctive element: a real painted pitch with team positions, not a placeholder. The AI instructions field with its WhatsApp-style example hint text ("Não colocar João e Pedro no mesmo time") is the most thoughtfully designed screen in the app.

But the structural scaffolding around these specific touches is interchangeable SaaS: a login template, a card list home screen, CRUD player cards, and — critically — a tabbed management screen as the emotional climax. The result screen, which should feel like a lottery reveal, presents itself as an admin panel. The app's character lives in its domain knowledge; its chrome is borrowed from a generic Material 3 template and has not been authored for the use case.

**Deterministic scan**: The Impeccable detector returned 0 findings across all runs. This is not evidence of a clean codebase — the detector's `SCANNABLE_EXTENSIONS` set covers HTML, CSS, JS/TS, Vue, Svelte, Astro, and Blade, but explicitly excludes `.dart`. Every source file in `lib/` was silently skipped. The only scannable file in the project (`web/index.html`) is a thin Flutter bootstrap shell with no detectable design patterns. All findings in this report come from the LLM design review.

**Visual overlays**: Browser visualization was not applicable — FutDraw is a native Flutter Android/iOS app, not a web target. No overlay injection was attempted.

---

## Overall Impression

The soccer knowledge embedded in this app is genuine and sets it apart from any competitor. But the joy of a group draw — the moment people have been waiting for — lands with a whimper. Opening TeamsDisplayScreen to five unlabeled icons and a tab bar is like announcing lottery winners by handing out a spreadsheet. Fix the result screen's reveal and gut the appbar clutter, and the app's best feature (the field view with its gradient scrim and team overlay) gets to breathe. Everything else is fixable in sequence.

---

## What's Working

**1. Authentic Brazilian soccer vocabulary throughout.**
"Titulares," "Reservas," "Sorteio," "Capitão," "goleiros fixos," and the four field types (campo, society, quadra, livre) are all genuine to how Brazilian recreational soccer is organized and discussed. This is not a translated generic product. It is built from the inside of the sport and culture it serves. This is FutDraw's single strongest differentiator.

**2. Cross-swap banner in list view is the best UX pattern in the app.**
`_buildCrossSwapBanner()` in `teams_display_view.dart` adapts its icon and copy based on selection state (touch_app vs person_pin), shows the selected player's name and team, communicates the next step, and provides Cancel. This is how all contextual help should work in FutDraw — contextual, progressive, never permanent chrome.

**3. AI instructions field sets the standard for the whole app.**
The multiline hint text with concrete WhatsApp-group examples, the "opcional" badge, and the historical-sorteios note in `ai_team_sort_view.dart` demonstrate exactly the level of product character missing from the rest of the interface. This screen knows its users.

---

## Priority Issues

**[P0] The draw result opens as an admin panel, not a reveal**
- **What**: `TeamsDisplayScreen` navigates directly from a loading spinner into a tab bar with five icon-only actions simultaneously visible. There is no transition, no animation, no moment of suspense.
- **Why it matters**: The entire product exists for this moment. Friends gathered at the quadra hit the button. What they see is a management interface. The payoff — the emotional apex that makes the app worth opening every week — is absent.
- **Fix**: Gate the management affordances behind the reveal. Show team names appearing one by one (staggered `AnimatedOpacity`/`SlideTransition`), hold for 1–2 seconds before the action icons fade in. Move all secondary actions (tune, bookmark, share) to a bottom sheet or FAB menu that expands on tap. The field view with its gradient scrim and team name overlay already has the right aesthetic — make that the first thing users see, full-screen, before controls appear.
- **Suggested command**: `/impeccable animate`

**[P0] Avatar tap in AddPlayer triggers a destructive deletion dialog with no photo present**
- **What**: In `add.player.dart`, `GestureDetector(onTap: _deletePlayerPhoto)` wraps the CircleAvatar regardless of whether a photo exists. Tapping the empty avatar placeholder opens "Deseja realmente excluir a foto do jogador?" with a red FilledButton.
- **Why it matters**: First interaction with the most common creation flow in the app. A new user exploring the form taps the avatar expecting to add a photo and gets a destructive confirmation. This is a classic accidental deletion trap at the worst moment.
- **Fix**: Gate the `onTap` on photo presence: `onTap: (_photoPath != null || _imageFile != null) ? _deletePlayerPhoto : _pickPhoto`. Add a visible camera/edit icon overlay on the avatar so the tap affordance is clear.
- **Suggested command**: `/impeccable harden`

**[P1] Algorithm selection is a per-draw decision buried in the global settings drawer**
- **What**: "Balanceado" vs "Snake Draft" lives in `DrawerComponent._AlgorithmSelector`, opened from any screen's hamburger menu, as a persistent global preference.
- **Why it matters**: A user who wants to try both algorithms must generate, navigate back, open the drawer, switch, generate again. The algorithm is a draw-time decision, not a persistent preference. "Snake Draft" is unexplained American fantasy-sports terminology with no Brazilian recreational soccer equivalent.
- **Fix**: Move the algorithm selector onto `TeamGenerationScreen` as a visible `SegmentedButton` or labeled `ChoiceChip` row below the team count card. Rename "Snake Draft" to something the target audience understands ("Cobra" or "Alternado"). Remove it from the drawer.
- **Suggested command**: `/impeccable shape`

**[P1] TeamsDisplayScreen has five icon-only actions at the emotional climax**
- **What**: `swap_horiz`, the field/list toggle, `Icons.tune`, `bookmark_add_rounded`, and `share` appear simultaneously in the appbar of the result screen. `Icons.tune` ("Reorganizar por Tática") is entirely non-inferrable from its icon without a long-press tooltip.
- **Why it matters**: Five unlabeled actions at once violates the working memory limit (≤4 items), clutters the single screen that should be clean and celebratory, and hides the most important secondary action (share) behind equal visual weight with four competing icons.
- **Fix**: Keep only the view-toggle (field/list) and a share `FloatingActionButton` in the primary chrome. Move swap, tune, and bookmark into a `BottomSheet` triggered by a single `Icons.more_vert` or a FAB menu with labeled items.
- **Suggested command**: `/impeccable distill`

**[P2] "Gerar por posição" toggle is a semantic inversion**
- **What**: In `drawer.dart`, the `SwitchListTile` title "Gerar por posição" binds to `controller.configuration.gerarIndependenteDaPosicao`. Turning the toggle ON sets `gerarIndependenteDaPosicao = true` — the opposite of what the label communicates.
- **Why it matters**: A user who enables "Gerar por posição" believing they are enabling position-aware generation is actually enabling the inverse. Team generation will silently produce wrong results with no error.
- **Fix**: Either invert the boolean (`!gerarIndependenteDaPosicao` on read/write at the toggle site) or rename the state variable and its API field to match the label's semantics. The variable name and the label must agree.
- **Suggested command**: `/impeccable harden`

---

## Persona Red Flags

**Jordan (First-Timer)**: Taps the CircleAvatar to add a photo → gets a red "Excluir" confirmation dialog on an empty form. Dismisses confused. Sets player skill to 0.0 (slider allows it despite "1.0" minimum label). Generates teams. Arrives at TeamsDisplayScreen with five unlabeled icons and no understanding of the view they're on. Does not discover the field view because the list is the default. Shares the list view screenshot rather than the visually compelling field view. Jordan completes the flow but the product's best feature — the painted soccer field — was never seen.

**Casey (Distracted Mobile User)**: At the quadra, needs 3 teams not 2. Opens the team count card on a narrow phone — the chip for "3" may be in a second row requiring a scroll inside the card. Changes to 3 teams. Generates. Views result. Notices Zé and Marcão are on the same team (not allowed). Taps `swap_horiz` in appbar. Icon changes color — Casey doesn't notice the mode is active. In field view, taps Marcão. Nothing visible happens. Casey switches to list view (the view-toggle is in the appbar, reachable but small). The cross-swap banner appears. Casey selects Marcão, then navigates to Team B tab. Banner correctly shows "Toque em um jogador do Time B". Completes swap. The banner UX saves Casey — but only if Casey discovers the list view first.

**Riley (Stress Tester)**: Saves a draw. Taps the static `bookmark_add_rounded` icon again expecting to navigate to saved history. Nothing happens — there is no saved-draws history screen accessible from TeamsDisplayScreen. Activates `_reorganizeTeamByTactic`. Positions shift silently — no confirmation of what formation was applied, no undo. Generates teams with 3 players and 8 teams requested. API returns an error. Toast appears for 5 seconds. No retry button. Navigates back to TeamGenerationScreen — no error state, no "last attempt failed" indicator. Makes the same 3-player/8-team mistake again.

---

## Minor Observations

- `group.item.dart` line 357: `"$days ás $time"` — typographic error; correct Portuguese is `"às"` (grave accent).
- `player.list.view.dart` lines 75–81: Back navigation from PlayerListScreen calls `GroupController.getAll()` before every pop, triggering a full API round-trip on what should be instant navigation.
- `teams_display_view.dart`: `_exportTeamsImage` captures only the currently visible tab (one team). The tooltip reads "Compartilhar Times" (plural). Users expecting a full-result share will receive a single-team image.
- `drawer.dart`: Logout tile background is `errorContainer.withValues(alpha: 0.3)` — the danger signal is near-invisible at this opacity on most themes.
- The substitution interaction in PlayerListScreen requires a long-press to confirm (`GestureDetector onLongPress`) with zero visible hint. Tapping a reserve card in the substitution screen produces no feedback. This interaction must be discoverable via tap, with long-press reserved for a secondary confirmation or removed.

---

## Questions to Consider

1. **Where is FutDraw actually used, and who holds the phone?** If the draw happens at the quadra with a crowd watching, every extra tap is felt by 15 people. Has any part of this flow been tested in real field conditions, in noise, with friends watching?

2. **What if the result screen existed in two phases: reveal, then manage?** The first 2–3 seconds are the reveal — team names appearing, the field populating, no chrome. Then the management UI fades in. The architecture already supports this; it's a question of adding an `AnimationController` and deferring icon visibility.

3. **Is the Titulares/Reservas model the right abstraction?** The real operational question before every game is "who's playing tonight?" — not which players are permanently in the starting lineup. A weekly availability model (players mark themselves in/out) would eliminate the administrator burden of manually swapping before every draw and make the app useful the day before each game, not just at the field.
