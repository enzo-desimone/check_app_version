# Changelog

## 3.0.0

- **Clean Architecture Migration**: Re-architected the package into logical layers (`data`, `domain`, `presentation`) for enhanced modularity, clean boundaries, and complete testability (44 unit/integration tests).
- **Unified & Intelligent Entrypoint**: Introduced `CheckAppVersion.get()` which dynamically handles both remote HTTP API endpoints and raw local JSON strings.
- **Granular Platform-Specific Schema**: Upgraded from flat JSON config keys to platform-specific nodes. Different platforms can now have distinct bundle IDs, minimum version thresholds (`min_required_version` / `min_required_build`), and independent `force_update` requirements.
- **In-Memory Caching**: Added intelligent result caching with a default 10-minute TTL, configurable or bypassable using `UpdatePolicy`.
- **Modern Material 3 Presentations**: Included beautiful built-in UI components (Dialog, Modal Bottom Sheet, Full-Screen blocking page, and Overlay banner) that automatically adapt to light/dark themes.
- **Improved SDK Compatibility**: Fixed compile errors on Flutter versions below 3.22 by using retro-compatible color opacity APIs.
- **Robust Crash-Prevention**: Broadened exception handling to catch both `Exception` and `Error` types (e.g., `TypeError` from malformed JSON and `FlutterError` from missing local assets) returning clean error decisions instead of crashing.
- **Automatic Dialog Dismissal (`popAfterPressed`)**: Implemented a new `popAfterPressed` parameter (defaults to `true`) across all UI helpers to automatically dismiss dialogs and modals upon tapping update.

## 2.1.0

- Updated `http` and package.

## 2.0.2

- Updated `http` and package.

## 2.0.1

- Huge thanks [huanguan1978](https://github.com/huanguan1978)
  and [CabelloIsaac](https://github.com/CabelloIsaac) for this
  fork [#7](https://github.com/enzo-desimone/check_app_version/pull/7)
  and [#6](https://github.com/enzo-desimone/check_app_version/pull/6).
- Updated `http` and `package_info_plus` packages.
- Updated documentation.

## 2.0.0

- Huge thanks [huanguan1978](https://github.com/huanguan1978) for this
  fork [#3](https://github.com/enzo-desimone/check_app_version/pull/3).
- Updated `http` and `package_info_plus` packages
  by [huanguan1978](https://github.com/huanguan1978).
- Added a new `AppVersionOverlayDialog` by [huanguan1978](https://github.com/huanguan1978).
- Refactored APIs for improved `readability`, `relationships`, and `documentation`.
- Replaced `ShowCustomDialog` and `ShowDialog` with `AppVersionCustomDialog` and `AppVersionDialog`.
- Improved code by removing redundant parts.
- Optimized parsing algorithms.

## 1.0.1

- Update package
- Add new ShowCustomDialog for custom dialog
- Update Example
- Update documentation

## 1.0.0+1

- Fix Null Pointer cupertinoDialog
- Fix screenshot documentation

## 1.0.0

- Add: Windows, MacOS, Linux, Web support
- Add new properties on Show Dialog
- Add new Confirm & Decline Button custom Function
- Update Json key
- Update project plugins
- Update example
- Increase null safety
- Clean code

## 0.6.0

- Update project plugins

## 0.5.0

- Fix cupertino Style
- Update example

## 0.4.0

- Add Auto Cupertino Style
- Bugs fixed

## 0.3.0

- Migrate to NULL SAFETY
- Bugs fixed

## 0.2.1

- General bug fixed
- Fix iOS bug
- New documentation

## 0.1.0

- Update http package

## 0.0.8

- Fix iOS bug

## 0.0.6

- Fix GUI bug

## 0.0.5

- Fix iOS platform

## 0.0.4

- Bug fix, add comment on widget properties

## 0.0.3

- Bug fix

## 0.0.2

- Bug fix

## 0.0.1

- Published plugin
