# ADR 0001 — Flutter and Dart for Finio

- **Status:** Accepted
- **Date recorded:** 2026-09-07
- **Decided:** at project start (`239b7d3 Initial commit: Finio MVP Phase 1`)

> **This is a retrospective ADR.** The choice was made before any decision record
> existed, and no notes from that moment survive in the repo. What follows is the
> rationale reconstructed from what the codebase actually needs, not a transcript
> of the original reasoning. Treat the *forces* below as the real content — they
> are what a reconsideration would have to argue against.

## Context

Finio is an offline-first personal finance app: a local relational database is
the source of truth, the cloud is optional, and the UI is gesture-heavy. It ships
in 8 languages. Android is the only platform with users today; `windows/` is
configured, `ios/` and `web/` are not.

The constraints that actually shape the choice:

1. **Local relational data with a long life.** Transactions, categories, budgets
   and wallets are relational, queried in several shapes, and the schema keeps
   moving — 8 migration steps to schema v9 so far, on databases holding real
   money records that must survive every upgrade.
2. **A dense, custom UI.** Swipe-to-edit/delete rows, swipe-to-change-month,
   swipe between tabs, a custom numeric keypad, pie/bar/sparkline charts, budget
   rings, gradient cards, a bespoke design system on top of Material 3.
3. **8 locales, including CJK.** Numbers, dates and currency all follow the
   selected language, independently of the currency setting.
4. **One developer.** Anything that costs a second implementation of the same
   screen is disproportionately expensive.
5. **Optional cloud sync** against Supabase, with soft-delete and
   last-write-wins.

## Decision

Build the app in Dart on Flutter, with Riverpod for state, Drift for the local
database, GoRouter for navigation, and `gen-l10n` for localization.

## Why it fits these forces

**The UI is drawn, not delegated.** Flutter renders its own widgets rather than
wrapping platform controls, so the gesture vocabulary and the design system look
and behave identically everywhere, and a custom keypad or a budget ring is
ordinary widget code rather than per-platform work. Against force 2 and 4 this is
the single biggest lever.

**Localization is compile-checked.** `gen-l10n` turns the ARB files into typed
getters, so a missing or misspelled key is a build error, not a runtime blank.
This is not theoretical: the "Accounts → Wallets" rename in v0.10.3 was caught
call-site by call-site by `flutter analyze`, including one in `auth_screen.dart`
that the plan had missed. `intl` covers the number and date halves of force 3.

**Drift makes the schema legible and the migrations testable.** Tables are Dart
classes, queries are typed, and each migration step is a few lines guarded by
`if (from < N)`. Every step from v6 onward has a test that writes a real database
file at the old schema, opens it through the app, and asserts the data survived.
For force 1 — money records that cannot be lost — that safety net is the reason
this stack holds up.

**Hot reload compresses the loop.** Sub-second UI iteration on a real device.

**Supabase has a first-party Flutter SDK** (`supabase_flutter`), which is most of
force 5 handled.

## Consequences

### Accepted costs

- **Binary size.** The release APK is ~63 MB because the Flutter engine ships
  inside it. A native Kotlin app of the same scope would be a few MB. For a
  utility app downloaded over mobile data this is the clearest price paid.
- **Dart is Flutter-specific.** The language transfers almost nowhere else, so
  time spent learning it is time spent on this ecosystem rather than a portable
  skill.
- **Platform capabilities arrive through plugins.** Notifications go through
  `flutter_local_notifications`, and its Android channel name and description
  can't be localized from Dart — they are hardcoded English strings in
  `budget_notifier.dart` for that reason.
- **Codegen is part of the build.** `build_runner` after any DB or provider
  change, `gen-l10n` after any ARB change. Both are committed to the repo, so
  forgetting to regenerate shows up as a confusing diff rather than a clean
  error.

### Not yet realized

The README says the codebase is "structured to extend to iOS / Web / Desktop
later". That is currently only half true, and the gap is worth naming:

- `ios/` does not exist. Generating it is cheap; the real cost is a Mac, an
  Apple developer account, and re-testing every gesture.
- `web/` does not exist, and Web is **not** a `flutter create --platforms=web`
  away: Drift on Web needs `sqlite3.wasm` plus a worker shipped as assets, and
  the sync layer would meet browser storage limits it has never been tested
  against.

So the cross-platform argument justified the choice but has not yet been cashed
in. If Android stays the only target indefinitely, the honest reckoning is that
Flutter was chosen mostly for forces 2 and 4 — the custom UI and the single
developer — and the 63 MB is what those cost.

## Alternatives, and what would reopen this

| Option | Why not |
|---|---|
| Native Kotlin (Android-only) | Smaller binary, best platform integration. Rejected: closes off every other platform permanently, and Compose plus Room would still need the same design system built by hand. |
| React Native | Familiar to the author from web work. Rejected: the local-database story is markedly weaker than Drift, and the gesture-heavy custom UI is where RN's bridge to platform components helps least. |
| Web app / PWA | One codebase, zero install. Rejected: offline-first with a real relational database and local notifications is exactly what a PWA is worst at. |

**Reconsider this decision if** binary size starts costing installs, or if iOS
becomes a real target and the Apple-side effort turns out to dominate anyway — at
which point "one codebase" would be buying less than it appears to.

## References

- `README.md` — feature list and tech-stack table
- `CLAUDE.md` — working conventions that follow from this stack
- `lib/core/database/app_database.dart` — the schema and its 8 migration steps
- `test/core/database/migration_v*_test.dart` — the upgrade-path safety net
