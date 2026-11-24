# MapSync project report

## Project summary

MapSync is a Flutter offline-map application built around Mapbox, Riverpod,
Hive, shared preferences, and a REST marker service. The repository is a
portfolio/GitHub project rather than a Play Store candidate.

## Verification

- `flutter pub get`: passed.
- Targeted settings and region-widget tests: passed.
- `flutter analyze`: no errors; remaining findings are non-blocking lints and
  platform/deprecation notices.
- Full desktop-VM tests cannot represent Mapbox, location, notifications, and
  platform-storage behavior; those suites require Android/iOS execution.
- Android Gradle configuration was aligned with Flutter’s supported toolchain,
  but this machine cannot resolve Flutter’s included Gradle plugin artifact
  offline and online resolution repeatedly timed out.

## Security and release notes

Keep `.env`, Mapbox tokens, API credentials, signing keys, and keystores out of
Git. Before distribution, test on a physical device, configure release
signing, validate permissions/privacy copy, and run the native integration
suites.
