# VoicePath

An offline-first AAC (Augmentative and Alternative Communication) app for
nonspeaking and minimally speaking users, built with Flutter. Original UI,
branding, and codebase — not a clone of any existing app's assets or code.

## Status

This was built in a sandbox with **no Flutter/Dart SDK and no access to
pub.dev**, so nothing here has been compiled or run. Every file was
hand-written and manually cross-checked (import graph, method signatures
between providers/repositories/screens, brace balance) but **you are the
first compiler this code will meet.** Start with:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

and expect to fix a handful of small issues — a missing named parameter, a
version-specific API on one of the plugins, that kind of thing — before it
builds clean. The architecture and logic have had real scrutiny; the exact
syntax has not had a compiler's. See **Getting started** below for the one
required setup step (`flutter create`) before any of this will run.

## Getting started

Requires Flutter 3.19+ (Dart 3.3+).

This repo ships `lib/`, `test/`, and `pubspec.yaml` only — no `android/`/
`ios/` platform folders, since generating those requires the Flutter SDK
this sandbox doesn't have. Before the first run, scaffold them once:

```bash
flutter create --platforms=android,ios .
flutter pub get
flutter run
```

`flutter create .` on a directory that already has a `pubspec.yaml` adds the
platform folders without touching `lib/`. If it prompts about overwriting
`pubspec.yaml`, say no (or re-check the diff) so your dependency list isn't
reset to the default template.

No API keys, no backend, no account — the app works fully offline from
first launch.

## Architecture

Feature-based, offline-first:

```
lib/
  core/               # cross-cutting: db, theming, l10n, routing, services
    constants/        # grid sizes, seed vocabulary, app constants
    database/         # sqflite schema + migrations (versioned)
    l10n/             # hand-rolled localization (en, ne) — no codegen step
    providers/        # app-wide state (TtsProvider)
    routing/          # AppRouter, route names, bottom-nav shell
    services/         # TTS, secure storage, PIN, backup, image storage
    theme/            # colors, text styles, standard + high-contrast themes
    widgets/          # shared error views, confirm dialog
  features/
    profiles/         # multi-profile support (spec section 7)
    vocabulary/        # categories + buttons: domain, repository, provider
    board/             # the main AAC screen: grid, sentence bar, categories
    vocabulary_editor/ # caregiver CRUD + reordering for categories/buttons
    text_mode/          # keyboard mode + lightweight word prediction
    caregiver/          # PIN/biometric lock, caregiver settings hub
    settings/           # accessibility, TTS, language settings
    backup_restore/     # export/import as a portable .vpbackup file
```

Each feature follows `domain/` (models) → `data/` (repository, SQL) →
`presentation/` (provider + screens/widgets). Screens never touch SQL
directly; repositories never touch Flutter widgets.

**State management:** `provider` (ChangeNotifier). No codegen (no Riverpod
generators, no `build_runner`, no `flutter gen-l10n`) — every file here is
directly readable and editable without a generation step.

**Database:** sqflite with a hand-written, versioned schema
(`core/database/db_schema.dart`). New columns/tables must be added as a new
`if (oldVersion < N)` migration step — never by editing an existing
`CREATE TABLE` — so upgrading the app never destroys a user's saved
vocabulary.

**TTS:** `TtsService` is an abstract interface; `FlutterTtsService` is the
only implementation today, but the app (and the test suite) talks to the
interface, so a different speech engine is a one-class swap.

## Testing

```bash
flutter test
```

Tests run against an in-memory/temp-file SQLite database via
`sqflite_common_ffi` — no emulator or device required. Coverage:

- Profile creation, switching, seeding, deletion, grid-size persistence
- Vocabulary CRUD: categories, buttons, core-vs-fringe separation, reordering
- Database persistence (real close/reopen of a file-backed database)
- Sentence building (add/delete/clear/repeat semantics)
- PIN protection (set/verify/wrong-PIN/clear, salted-hash storage)
- TTS integration logic, via a fake `TtsService` (rate/pitch/volume/voice
  application, speaking-state tracking) — not the real device speech engine,
  which `flutter test` can't exercise anyway
- Backup export → import round-trip, including a caregiver's appearance/
  speech settings

Not covered by automated tests here: widget-level UI tests (button taps
rendering correctly, screen navigation) and on-device features that need a
real platform channel (actual TTS audio, actual biometric prompts, actual
Keychain/Keystore). Those are best exercised with `integration_test` on a
real device/emulator, which this sandbox doesn't have.

## Known limitations / next steps

- **Nepali vocabulary translations** (`core/l10n/translations/ne.dart`,
  `core/constants/core_vocabulary.dart`) were written carefully but should
  be reviewed by a native-speaking SLP before clinical use — AAC word choice
  has real communication stakes.
- **Symbols:** buttons use emoji + user photos + first-letter fallback, not
  a bespoke or licensed symbol set (e.g. SymbolStix). The data model
  (`iconKey` is just a string) supports swapping in a real symbol library
  later without a schema change.
- **Deleting a single profile** doesn't clean up that profile's photo files
  from disk (the "delete all data" nuclear option does clean up everything,
  including secure-storage PINs and all media). Low-severity — wasted
  storage, not a correctness or privacy issue — but worth fixing before a
  real release.
- **Grid position** is currently order-based (`sortOrder`), not a literal
  2D slot map — reordering in the caregiver editor is a drag-to-reorder
  list, not free-form 2D placement. This still satisfies "preserve button
  positions for motor planning" (order never changes on its own) with much
  less complexity than a full 2D drag-and-drop grid.
- **Word/sentence prediction** in text mode is a small hand-built heuristic
  (vocabulary-prefix matching + a short "what usually comes next" table),
  not a trained language model — see the doc comment in
  `word_prediction_service.dart` for the reasoning and the swap-out point.
- Hindi was scoped out of localization per product decision during
  development; English and Nepali are complete.
