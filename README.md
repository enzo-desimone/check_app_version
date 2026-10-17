# 🚀 Check App Version

<p align="center">
  <img src="https://raw.githubusercontent.com/enzo-desimone/check_app_version/master/example/check-app-version.webp" alt="Check App Version Preview" width="420" style="border-radius: 16px; box-shadow: 0 8px 24px rgba(0,0,0,0.12);" />
</p>

<p align="center">
  <a href="https://pub.dev/packages/check_app_version"><img src="https://img.shields.io/pub/v/check_app_version?style=for-the-badge&logo=dart&color=0052CC" alt="Pub Version" /></a>
  <a href="https://pub.dev/packages/check_app_version/score"><img src="https://img.shields.io/pub/points/check_app_version?style=for-the-badge&color=0052CC" alt="Pub Points" /></a>
  <a href="https://pub.dev/packages/check_app_version"><img src="https://img.shields.io/badge/Platforms-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-0052CC?style=for-the-badge" alt="Platform Support" /></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-333333?style=for-the-badge" alt="License" /></a>
</p>

---

**Check App Version** is the complete **Flutter in-app update and version checker** for **Android, iOS, Web, macOS, Windows, and Linux**. Check installed versions automatically against the **Apple App Store**, **Google Play Store**, or a custom **remote/local JSON** config. Handle **force updates**, **soft updates**, **smart snooze ("remind me later")**, and **version skipping** with declarative **`UpdateGate`** widgets and ready-to-use **Material 3 & adaptive Cupertino** UIs.

---

## 📑 Table of Contents

- [✨ Features](#-features)
- [📦 Installation](#-installation)
- [🚀 Quick Start](#-quick-start)
- [🔥 Zero-Backend Store Lookup](#-zero-backend-store-lookup)
- [🧱 Declarative `UpdateGate` Widget](#-declarative-updategate-widget)
- [⏸️ Smart Snooze & Skip Version](#️-smart-snooze--skip-version)
- [📑 JSON Configuration Schema](#-json-configuration-schema)
- [🎨 Presentation Layouts](#-presentation-layouts)
  - [1. Classic & Adaptive Cupertino Dialog](#1-classic--adaptive-cupertino-dialog)
  - [2. Modal Bottom Sheet](#2-modal-bottom-sheet)
  - [3. Full-Screen Blocking Page](#3-full-screen-blocking-page)
  - [4. Top Overlay Banner](#4-top-overlay-banner)
- [🛠️ Headless Mode (Custom UI)](#️-headless-mode-custom-ui)
- [⚙️ Caching & Update Policies](#️-caching--update-policies)
- [🔄 Migration Guide (v2.x ➔ v3.x)](#-migration-guide-v2x--v3x)
- [📄 API Reference](#-api-reference)
- [🤝 Contributing & License](#-contributing--license)

---

## ✨ Features

- **⚡ 30-Second Implementation**: A single, static entry point (`CheckAppVersion.get(...)` or `CheckAppVersion.fromStores()`) handles network requests, local assets, store lookups, caching, and semver comparison.
- **🔥 Zero-Backend Store Lookup**: Query **Apple App Store** (iOS/macOS) and **Google Play Store** (Android) directly using your installed bundle/package ID — no custom backend JSON required!
- **🧱 Declarative `UpdateGate` Wrapper**: Drop `UpdateGate` around your home screen to automatically check on startup and when returning from the background (`checkOnResume: true`).
- **⏸️ Smart Snooze & Skip Version**: Built-in `snoozeDuration` ("Remind me later") and `skipVersion` ("Skip this version") that respect user preferences on soft updates while never suppressing mandatory updates.
- **🎨 4 Ready-to-Use UIs + Adaptive Cupertino**: Pre-built Dialogs (Material 3 or native iOS/macOS `CupertinoAlertDialog` via `adaptive: true`), Modal Bottom Sheets, Full-Screen Pages, and animated Overlay Banners.
- **📱 Granular Platform Isolation**: Configure isolated thresholds and flags per platform (`android`, `ios`, `macos`, `windows`, `linux`, `web`).
- **🧠 Smart In-Memory Caching**: Avoids redundant network roundtrips with configurable TTL (10-minute default) and cache invalidation methods.
- **🛡️ Resilient & Crash-Proof**: Catches format and network errors (`TypeError`, `FormatException`, timeouts) returning clean, inspectable status codes instead of throwing unhandled exceptions.

---

## 📦 Installation

Add `check_app_version` to your Flutter project:

```bash
flutter pub add check_app_version
```

Or add it directly to your `pubspec.yaml`:

```yaml
dependencies:
  check_app_version: ^3.1.0
```

---

## 🚀 Quick Start

### Step 1: Provide your Version Configuration

Host a `version.json` file on your server (CDN, S3, Firebase Hosting, GitHub Gist, or custom REST API):

```json
{
  "platforms": {
    "android": {
      "package_name": "com.example.myapp",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "latest_version": "1.6.0",
      "latest_build": 40,
      "force_update": false
    },
    "ios": {
      "bundle_id": "com.example.myapp",
      "app_store_id": "1234567890",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "latest_version": "1.6.0",
      "latest_build": 40,
      "force_update": true
    }
  }
}
```

### Step 2: Check & Display Update

Invoke the check on app startup or on a settings page:

```dart
import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/material.dart';

Future<void> checkForUpdates(BuildContext context) async {
  // 1. Evaluate current installed version against your JSON source
  final decision = await CheckAppVersion.get(
    'https://example.com/version.json',
  );

  // 2. Display one of the built-in UI components if an update is available
  if (decision.shouldUpdate && context.mounted) {
    CheckAppVersion.showUpdateDialog(
      context,
      decision: decision,
      onOpenStore: () {
        // Use url_launcher to navigate to the App Store / Play Store
      },
    );
  }
}
```

---

## 🔥 Zero-Backend Store Lookup

Don't want to host a `version.json` file? Query the **Apple App Store** (iOS/macOS) and **Google Play Store** (Android) directly using `CheckAppVersion.fromStores()` (or pass `'store'` to `CheckAppVersion.get('store')`):

```dart
final decision = await CheckAppVersion.fromStores(
  countryCode: 'us',   // Two-letter ISO store country code
  forceUpdate: false,  // Set true to treat store updates as mandatory
);

if (decision.shouldUpdate && context.mounted) {
  CheckAppVersion.showUpdateDialog(
    context,
    decision: decision,
    adaptive: true, // Native CupertinoAlertDialog on iOS/macOS!
    onOpenStore: () => openStore(),
  );
}
```

---

## 🧱 Declarative `UpdateGate` Widget

Wrap your home screen with `UpdateGate` to handle version checks declaratively on startup and automatically re-verify whenever the app resumes from the background (`checkOnResume: true`):

```dart
UpdateGate(
  source: 'https://example.com/version.json', // or 'store'
  style: UpdatePresentationStyle.dialog,      // dialog, modal, page, overlay
  checkOnResume: true,                        // Re-checks when app returns to foreground
  adaptive: true,                             // Native Cupertino dialog on iOS/macOS
  snoozeDuration: const Duration(days: 3),    // Snooze for 3 days on "Later"
  showSkipVersion: true,                      // Show "Skip this version" button
  onOpenStore: () => openStore(),
  child: const HomeScreen(),
)
```

---

## ⏸️ Smart Snooze & Skip Version

Prevent update fatigue on non-mandatory updates (`isForceUpdate == false`). Mandatory updates **always** bypass snooze and skip states.

```dart
// Automatically snooze when the user taps "Later" or "Skip this version" in UI:
CheckAppVersion.showUpdateDialog(
  context,
  decision: decision,
  snoozeDuration: const Duration(days: 3),
  showSkipVersion: true,
  onOpenStore: () => openStore(),
);

// Or control Snooze & Skip programmatically in headless mode:
CheckAppVersion.snooze(const Duration(days: 2));
CheckAppVersion.skipVersion('1.6.0');
CheckAppVersion.clearSnooze();
```

---

## 📑 JSON Configuration Schema

The configuration supports granular multi-platform control. You can configure only the platforms your app targets:

```json
{
  "app_id": "com.example.myapp",
  "config_version": 1,
  "platforms": {
    "android": {
      "package_name": "com.example.myapp",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "latest_version": "1.6.0",
      "latest_build": 40,
      "force_update": false
    },
    "ios": {
      "bundle_id": "com.example.myapp",
      "app_store_id": "1234567890",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "latest_version": "1.6.0",
      "latest_build": 40,
      "force_update": false
    },
    "macos": {
      "bundle_id": "com.example.myapp.macos",
      "app_store_id": "1234567890",
      "min_required_version": "1.4.0",
      "min_required_build": 30,
      "latest_version": "1.5.0",
      "latest_build": 35,
      "force_update": false
    },
    "windows": {
      "package_name": "example",
      "product_id": "9NBLGGH4R315",
      "min_required_version": "1.0.0",
      "min_required_build": 2,
      "latest_version": "1.1.0",
      "latest_build": 5,
      "force_update": true
    },
    "linux": {
      "package_name": "example",
      "min_required_version": "1.3.0",
      "min_required_build": 25,
      "latest_version": "1.4.0",
      "latest_build": 28,
      "force_update": false
    },
    "web": {
      "package_name": "example",
      "min_required_version": "1.0.0",
      "min_required_build": 0,
      "latest_version": "1.0.0",
      "latest_build": 0,
      "force_update": false
    }
  }
}
```

### Schema Field Reference

| Key | Type | Description |
|---|---|---|
| `min_required_version` | `String` | Lowest semver string permitted without triggering a mandatory update (e.g. `"1.5.0"`). |
| `min_required_build` | `int` | Lowest build number permitted without triggering a mandatory update (e.g. `36`). |
| `latest_version` | `String?` | Most recent release available on the store. Triggers a **soft update** prompt if installed version is lower. |
| `latest_build` | `int?` | Most recent build number. Triggers a **soft update** prompt if installed build is lower. |
| `force_update` | `bool` | When `true` and the installed app is below minimum requirements, marks `decision.isForceUpdate = true`. |
| `app_store_id` | `String?` | Apple App Store identifier for iOS/macOS store links. |
| `product_id` | `String?` | Microsoft Store product ID for Windows store links. |

> [!NOTE]
> **Priority Rule**: Hard minimums (`min_required_build` & `min_required_version`) take precedence over soft targets (`latest_build` & `latest_version`). If an app falls below the minimum requirement and `force_update: true`, it is classified as a mandatory update.

---

## 🎨 Presentation Layouts

Choose between four pre-designed presentation styles according to your user experience needs:

### 1. Classic & Adaptive Cupertino Dialog

A clean Material 3 popup card (or native iOS/macOS `CupertinoAlertDialog` when `adaptive: true`) overlaying your app content.

```dart
CheckAppVersion.showUpdateDialog(
  context,
  decision: decision,
  onOpenStore: () => openStore(),
  onLater: () => print('User clicked later'), // Optional callback
  title: 'Update Available',                 // Optional custom title
  message: 'A new version is waiting for you!', // Optional custom message
  updateLabel: 'Update Now',
  laterLabel: 'Later',
  popAfterPressed: true, // Automatically dismisses dialog on update tap
  adaptive: true,        // Renders CupertinoAlertDialog on iOS/macOS
  snoozeDuration: const Duration(days: 3),
  showSkipVersion: true,
);
```

### 2. Modal Bottom Sheet

An elegant, swipe-friendly sheet sliding up from the bottom. Great for non-blocking soft updates.

```dart
CheckAppVersion.showUpdateModal(
  context,
  decision: decision,
  onOpenStore: () => openStore(),
  title: 'New Features Available',
  popAfterPressed: true,
);
```

### 3. Full-Screen Blocking Page

An immersive, full-screen view preventing user interaction until updated. Perfect for critical, breaking changes.

```dart
CheckAppVersion.showUpdatePage(
  context,
  decision: decision,
  onOpenStore: () => openStore(),
  title: 'Mandatory Update Required',
  icon: Icons.system_update_rounded,
  popAfterPressed: false,
);
```

### 4. Top Overlay Banner

A non-intrusive animated banner placed at the top of your screen (e.g. inside a `Stack`).

```dart
Stack(
  children: [
    YourMainWidget(),
    if (showBanner && decision.shouldUpdate)
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: UpdateOverlay(
            decision: decision,
            onOpenStore: () => openStore(),
            onDismiss: () => setState(() => showBanner = false),
          ),
        ),
      ),
  ],
)
```

> [!TIP]
> **Automatic Dismissal (`popAfterPressed`)**: All modal and dialog helpers default to `popAfterPressed: true`, automatically dismissing the popup when the user taps the update button.

---

## 🛠️ Headless Mode (Custom UI)

If you prefer to design your own UI from scratch, use `CheckAppVersion.get(...)` headlessly and inspect the `UpdateDecision` entity:

```dart
final decision = await CheckAppVersion.get(
  'https://example.com/version.json',
);

if (decision.shouldUpdate) {
  if (decision.isForceUpdate) {
    // Show your custom blocking screen or route
  } else {
    // Show your custom banner or snackbar
  }
}
```

### Properties of `UpdateDecision`

| Property | Type | Description |
|---|---|---|
| `shouldUpdate` | `bool` | `true` if the app should be updated (either mandatory or soft). |
| `isForceUpdate` | `bool` | `true` if the update is strictly required (`force_update: true` & below minimum). |
| `reason` | `UpdateReason` | Enum explaining why the decision was produced (see below). |
| `installedVersion` | `String` | Currently installed version (e.g. `"1.4.2"`). |
| `installedBuild` | `int` | Currently installed build number (e.g. `32`). |
| `requiredMinVersion` | `String` | Server-defined minimum required version. |
| `requiredMinBuild` | `int` | Server-defined minimum required build number. |
| `latestVersion` | `String?` | Server-defined latest version. |
| `latestBuild` | `int?` | Server-defined latest build number. |
| `appStoreId` | `String?` | iOS/macOS App Store ID (if configured). |
| `productId` | `String?` | Windows Store product ID (if configured). |

### `UpdateReason` Enum

- `UpdateReason.upToDate`: Installed version satisfies all thresholds.
- `UpdateReason.belowMinimum`: Installed version or build is below minimum required threshold.
- `UpdateReason.belowLatest`: Installed version or build is below latest release (eligible for soft update).
- `UpdateReason.cached`: Decision served from in-memory cache.
- `UpdateReason.snoozed`: Soft update prompt was suppressed because the user snoozed it.
- `UpdateReason.skippedVersion`: Soft update prompt was suppressed because the user skipped this version.
- `UpdateReason.networkError`: Network request failed or HTTP status code != 200.
- `UpdateReason.parseError`: Payload could not be parsed as valid JSON.
- `UpdateReason.platformUnsupported`: Current platform is missing from the `platforms` node in JSON.

---

## ⚙️ Caching & Update Policies

By default, every successful check is cached in memory for **10 minutes**. You can fine-tune this with `UpdatePolicy`:

```dart
final decision = await CheckAppVersion.get(
  'https://example.com/version.json',
  policy: const UpdatePolicy(
    cacheTtl: Duration(minutes: 30),        // Custom cache lifetime
    forceRefresh: true,                     // Ignore cache and force HTTP request
    httpTimeout: Duration(seconds: 4),      // Custom HTTP timeout
    debugMode: true,                        // Output diagnostics via dart:developer
    platform: SupportedPlatform.android,    // Override platform (useful for testing)
    snoozeDuration: Duration(days: 3),      // Optional default snooze duration
    respectSnooze: true,                    // Respect snoozed/skipped soft updates
  ),
);
```

### Cache Control APIs

```dart
// Invalidate all cached decisions across your app
CheckAppVersion.clearCache();

// Invalidate a specific source cache entry
CheckAppVersion.invalidateCache(cacheKey);
```

---

## 🔄 Migration Guide (v2.x ➔ v3.x)

### 1. JSON Schema Upgrade

In v2.x, configuration was flat and shared across platforms. In v3.x, each platform has dedicated, isolated rules:

| Legacy v2.x Schema | Modern v3.x Schema |
|---|---|
| Flat keys (`android_package`, `new_app_version`) | Nested under `platforms.<platform_name>` |
| Same version enforced on all platforms | Independent min & latest thresholds per platform |

```json
// Modern v3.x Schema
{
  "platforms": {
    "android": {
      "package_name": "com.example.app",
      "min_required_version": "1.2.0",
      "min_required_build": 15,
      "latest_version": "1.3.0",
      "latest_build": 20,
      "force_update": false
    }
  }
}
```

### 2. Dart API Migration

#### Before (v2.x)
```dart
final dialog = AppVersionDialog(
  jsonUrl: 'https://example.com/version.json',
  context: context,
  title: 'New Update Available',
  onPressConfirm: () => openStore(),
);
await dialog.show();
```

#### Now (v3.x)
```dart
// 1. Evaluate logic
final decision = await CheckAppVersion.get('https://example.com/version.json');

// 2. Render UI
if (decision.shouldUpdate && context.mounted) {
  CheckAppVersion.showUpdateDialog(
    context,
    decision: decision,
    onOpenStore: () => openStore(),
  );
}
```

---

## 📄 API Reference

### `CheckAppVersion` Static Methods

| Method | Return Type | Description |
|---|---|---|
| `get(source, {policy})` | `Future<UpdateDecision>` | Evaluates app version against a remote URL, local asset, raw JSON string, or `'store'`. |
| `fromStores({...})` | `Future<UpdateDecision>` | Queries Apple App Store (iOS/macOS) or Google Play Store (Android) directly. |
| `showUpdateDialog(context, ...)` | `Future<void>` | Shows a Material 3 AlertDialog or adaptive `CupertinoAlertDialog`. |
| `showUpdateModal(context, ...)` | `Future<void>` | Shows a themed Modal Bottom Sheet. |
| `showUpdatePage(context, ...)` | `Future<T?>` | Navigates to a full-screen blocking update page. |
| `snooze(duration)` | `void` | Snoozes soft update notifications for the specified `Duration`. |
| `skipVersion(version)` | `void` | Marks a specific version string as skipped for soft updates. |
| `clearSnooze()` | `void` | Resets active snooze timers and skipped versions. |
| `clearCache()` | `void` | Flushes all entries from in-memory cache. |
| `invalidateCache(key)` | `void` | Removes a specific entry from cache. |

---

## 🤝 Contributing & License

Contributions, feature requests, and issues are always welcome! Feel free to check the [Issues](https://github.com/enzo-desimone/check_app_version/issues) page.

Released under the [MIT License](https://opensource.org/licenses/MIT).
