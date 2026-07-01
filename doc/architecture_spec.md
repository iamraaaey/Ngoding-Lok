# NgeCode Juh! Architecture Spec

## Overview

NgeCode Juh! is a client-side, code-first educational game engine. It converts
plain-text command scripts into deterministic movement on a 2D grid without
any server-side compilation or sandboxing.

## Pipeline

```
Raw script text
      |
      v
  Lexer (lib/core/interpreter/lexer.dart)
      | tokenizes each line into a Token { type, raw, line }
      | unrecognized lines become TokenType.unknown (never throws)
      v
  Parser (lib/core/interpreter/parser.dart)
      | walks tokens against grid bounds and target coordinates
      | produces an ordered List<ExecutionStep> (the "execution queue")
      v
  ArenaView (lib/presentation/screens/arena_view.dart)
      | consumes ExecutionStep one at a time on a fixed tick interval
      | derives a new immutable GameState per step via copyWith
      v
  GameCanvas / CodeEditor (lib/presentation/widgets/)
      | pure renders of the current GameState snapshot
```

## Lexer

The lexer never fails on malformed input. Every line becomes exactly one
`Token`. Blank lines and `//` comments are preserved as their own token
types so the parser can skip them without losing line-number alignment —
this keeps error messages ("Line 4: Syntax Error") accurate even when the
script contains comments or blank spacing.

## Parser

The parser is a pure function: `List<Token> -> List<ExecutionStep>`. It
holds no reference to widgets or animation timing. Given identical tokens
and start/target coordinates, it always produces an identical step queue,
which makes it fully unit-testable without pumping a widget tree (see
`test/interpreter_test.dart`).

Execution stops at the first `outOfBounds`, `syntaxError`, or
`goalReached` step, mirroring how a real interpreter halts on a runtime
error or program completion.

## State

`GameState` (lib/core/state/game_state.dart) is immutable. Every mutation
goes through `copyWith`, which returns a new instance rather than mutating
fields in place. This lets the UI layer rely on Flutter's `setState`/widget
diffing to skip redundant repaints during long execution queues, rather
than manually tracking dirty regions.

## Rendering

`GameCanvas` and `CodeEditor` are stateless widgets that render a single
`GameState` (or controller) snapshot. All mutable/animated state is owned
by `GridGameScreen`, keeping the render layer trivially testable and free
of side effects.

## Module System

The app now hosts three playable modules instead of one. Each module is
described by a `CurriculumModule` (`lib/core/curriculum/curriculum_module.dart`)
holding a type-specific `ModuleConfig` — a **sealed class** union
(`LogicGridConfig` / `SqlTerminalConfig` / `RocketFlightConfig`) rather than
a loosely-typed map, so each game screen's `switch` on `module.config` is
exhaustive and type-checked instead of relying on runtime casts scattered
through the UI. `Curriculum.modules` (`lib/core/curriculum/curriculum.dart`)
is the static, in-memory list of all three.

### Per-module interpreters

Each module type has its own pure-function interpreter, all following the
Lexer/Parser contract above (never throw, no widget/timer references,
fully unit-testable without pumping a widget):

- **Logic grid**: unchanged — `Lexer`/`Parser`/`GameState`.
- **SQL terminal** (`lib/core/interpreter/sql_checker.dart`): the module
  doesn't need real SQL parsing (the original prototype used a substring
  check, not an AST), so `SqlChecker.check(query, config)` is a **single-shot**
  pure function returning one verdict, not a stepped queue. This is why
  there's no `SqlState` class analogous to `GameState`/`RocketState` — the
  module has a single pass/fail outcome, not a stepped simulation to
  snapshot.
- **Rocket flight** (`lib/core/interpreter/rocket_lexer.dart` +
  `rocket_parser.dart`): tokenizes `sys.preflight()` / `engine.start()` /
  `throttle(N)` and enforces ordering rules (igniting before preflight
  explodes; throttling before ignition errors) via `RocketParser.run() ->
  List<RocketStep>`, mirroring `Parser.run()` exactly. `RocketState`
  (`lib/core/state/rocket_state.dart`) mirrors `GameState`'s immutable
  `copyWith` shape.

### Shared chrome

`GameHeader`, `HintBanner`, and `ConsoleLog` (`lib/presentation/widgets/`)
are implemented once and reused by all three game screens instead of being
duplicated per module. `GameTimerController`
(`lib/core/timer/game_timer_controller.dart`) is a plain class wrapping a
`Timer.periodic` + `ValueNotifier<int>` — the project's answer to a
React-style `useGameTimer` hook, since Flutter has no hooks. Each game
screen's `State` owns one instance, starting it in `initState` and
disposing it in `dispose`, matching the existing rule that screens own all
mutable/timing state.

### Navigation and session state

`RootOrchestrator` (`lib/presentation/screens/root_orchestrator.dart`) is a
single `StatefulWidget` switching on an `AppRoute` enum (`auth` / `dashboard`
/ `game` / `ad`), rather than `Navigator`-based routing. This mirrors the
shape of the state it owns: `UserSession`, the active `CurriculumModule`,
and ad-flow parameters are all cross-cutting values every screen reads or
mutates through one owner — there's no meaningful back-stack (the ad screen
"returns" to wherever its `onComplete` callback decides, not to a nav
history entry).

When routing to the hint-ad screen, `RootOrchestrator` renders it as a
`Stack` overlay on top of the still-mounted game screen rather than
replacing the subtree. This keeps the game screen's `State` alive (its
in-progress code, hint flag, and elapsed timer) across the ad interruption.
The win-flow interstitial ad is the one case that's fine to fully replace
the game screen, since it always returns to the dashboard afterward.

`UserSession` (`lib/core/session/user_session.dart`) and the leaderboard
(`lib/core/session/leaderboard.dart`) are plain immutable data
classes/pure functions — no state-management package is used, consistent
with the rest of the app. `Leaderboard.withUser(session)` recomputes
rankings from the session on every call instead of keeping a separately
mutable list in sync.
