# MapSync

MapSync is a Flutter offline-maps application for viewing remote locations,
downloading map regions, and managing local map data. It combines Mapbox,
Riverpod state management, a repository-based data layer, Hive, shared
preferences, and a REST client.

## Features

- Interactive Mapbox map with remote markers.
- Offline tile-region downloads with progress and cache management.
- Location, notification, and storage services.
- Light/dark theme and settings screens.
- Unit, widget, integration, performance, and end-to-end test coverage.

## Architecture

`lib/core` contains configuration, services, error handling, and utilities.
`lib/features` contains map, offline-map, and settings flows. `lib/shared`
contains reusable models, widgets, and state. Repositories isolate API and
Mapbox access from presentation code, while Riverpod coordinates state.

## Run locally

Requirements: Flutter 3.38 or compatible, Dart 3.10+, Android/iOS tooling, and
a Mapbox access token.

```bash
flutter pub get
cp .env.example .env
# Set MAPBOX_ACCESS_TOKEN in .env
flutter run
```

Never commit `.env`, tokens, signing keys, or other credentials.

## Verify

```bash
flutter analyze
flutter test test/core test/features test/shared
```

Tests that exercise Mapbox, location, notifications, Hive, or platform storage
must run on an Android/iOS device or emulator. See `REPORT.md` for the current
verification record and known environment limitations.

## Portfolio status

MapSync is a GitHub portfolio project demonstrating offline maps, native
Flutter integrations, and testable application architecture. It is not marked
as a Play Store release candidate.
