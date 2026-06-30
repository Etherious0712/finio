# Finio

**An AI-assisted personal finance app that gets smarter the more you use it.**

Finio is a fast, gesture-first money manager built with Flutter. It works fully
offline, keeps your data private on-device, auto-categorizes transactions with a
local rule engine, and optionally syncs across devices. The UI is built on a
custom design system and ships in 8 languages.

> Android-first today; the codebase is structured to extend to iOS / Web /
> Desktop later.

---

## Features

- **Fast entry** — quick-add bottom sheet with a custom numeric keypad,
  one-tap category chips, and an automatic category suggestion from the note.
- **Gesture-first UX** — swipe between tabs, swipe a transaction to edit or
  delete, swipe the month header to change month.
- **Dashboard** — all-time **Total Balance** headline, this-month income/expense,
  a spending-trend sparkline, a category donut, and animated budget rings. The
  graphs tap through to Statistics.
- **Records** — browse transactions grouped **By Date**, **By Month**, or
  **By Year**, each with its own period selector and net totals.
- **Statistics** — interactive pie + 6-month bar charts, category drill-down,
  and a month-over-month delta.
- **Budgets** — overall and per-category monthly budgets with circular progress
  and local notifications at 80% / 100%.
- **Categories** — add/edit custom categories (icon + color), with per-category
  usage counts.
- **Auto-categorization** — a local keyword rule engine that learns from your
  corrections (no network, no model download).
- **Cloud sync (optional)** — Supabase auth + backup + multi-device sync with
  soft-delete and last-write-wins.
- **8 languages** — English, German, Spanish, French, Japanese, Korean, Malay,
  Chinese. Numbers and dates follow the selected language; the currency symbol
  follows a separate currency setting.

## Tech stack

| Layer | Choice |
|-------|--------|
| UI | Flutter, Material 3, custom design system (bundled Inter font), `fl_chart` |
| State | Riverpod |
| Navigation | GoRouter |
| Local database | Drift (type-safe SQLite) |
| Cloud (optional) | Supabase (Auth + Postgres) |
| Localization | Flutter `gen-l10n` from ARB files (8 locales) |
| Local AI | Keyword rule classifier (TFLite planned) |

## Project structure

```
lib/
├── main.dart                 # bootstrap (Supabase init, ProviderScope)
├── app.dart                  # MaterialApp.router, GoRouter, MainShell (tabs)
├── core/
│   ├── database/             # Drift database, DAOs, migrations
│   ├── sync/                 # Supabase sync service
│   ├── ai/                   # rule_classifier
│   ├── notifications/        # budget notifier
│   └── theme/                # design tokens: colors, typography, spacing, motion
├── features/                 # dashboard, transactions, statistics, budget,
│                             # categories, settings, auth
├── shared/
│   ├── providers/            # Riverpod providers
│   ├── widgets/              # design-system widgets
│   └── utils/                # formatters, category icons/localization
└── l10n/                     # app_*.arb (8 locales)
```

## Getting started

Prerequisites: Flutter SDK (Dart 3.11+), an Android emulator or device.

```bash
flutter pub get

# Generate Drift / Riverpod code (after changing DB tables or providers)
dart run build_runner build --delete-conflicting-outputs

# Generate localizations (after editing lib/l10n/*.arb)
flutter gen-l10n

flutter run
```

Quality gates:

```bash
flutter analyze
flutter test
```

### Cloud sync configuration (optional)

Cloud features need Supabase credentials in `lib/core/config/supabase_config.dart`.
Without them the app runs fully offline — sync simply does nothing.

## Localization

All user-facing strings live in `lib/l10n/app_<locale>.arb`, with English
(`app_en.arb`) as the source of truth. To add a string: add the key to **every**
locale file, then run `flutter gen-l10n`. Missing keys fall back to English.

## Conventions

- **English only** for all code, comments, and docs. The single exception is the
  app's localization content (the `.arb` translations) — that's the user-facing
  multi-language feature.
- One state-management approach: **Riverpod** (no mixing with `setState` for app
  state).
- Read colors/spacing/motion from the design tokens in `lib/core/theme/` — don't
  hardcode.
- The data layer (Drift schema + migrations, sync, ARB translations) is stable;
  extend it rather than rewriting.

## Roadmap

- TFLite classification model (replacing the rule engine)
- Real-time Supabase sync subscriptions
- iOS / Web / Desktop targets
