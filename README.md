# check_app_version

A beautiful, Clean Architecture Flutter package to elegantly handle app version checks and mandatory updates.
Out of the box, it provides a unified and simplified API, customizable caching, and ready-to-use modern UI components.

**Platforms:** Android · iOS · Web · macOS · Windows · Linux

---

## 🚀 Quick Start

The package uses a **single, unified entry point**: `CheckAppVersion.get()`.
It automatically detects whether you are passing an HTTP URL or a raw JSON string.

```dart
import 'package:check_app_version/check_app_version.dart';

// The source can be an HTTP Endpoint OR a raw JSON string.
final decision = await CheckAppVersion.get(
  'https://example.com/version.json',
);

if (decision.shouldUpdate) {
  print('Update available! Reason: ${decision.reason.name}');
  
  if (decision.isForceUpdate) {
    print('This update is mandatory.');
  }
}
```

---

## 🎨 UI Components

Ready-to-use, modern UI presentations are exposed directly as static methods on `CheckAppVersion`.

### Dialog
```dart
CheckAppVersion.showUpdateDialog(
  context,
  decision: decision,
  onOpenStore: () => launchUrl(storeUri),
);
```

### Modal Bottom Sheet
```dart
CheckAppVersion.showUpdateModal(
  context,
  decision: decision,
  onOpenStore: () => launchUrl(storeUri),
);
```

### Full-Screen Page
```dart
CheckAppVersion.showUpdatePage(
  context,
  decision: decision,
  onOpenStore: () => launchUrl(storeUri),
);
```

### Overlay
You can also use the `UpdateOverlay` widget inside a `Stack` to display an in-app banner snippet.

---

## 📦 JSON Schema

The package strictly enforces the following JSON specification for simplicity and robustness:

```json
{
  "app_id": "com.example.myapp",
  "config_version": 1,
  "platforms": {
    "android": {
      "bundle_id": "com.example.myapp",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "latest_version": "1.6.0",
      "latest_build": 40,
      "force_update": false
    },
    "ios": {
      "bundle_id": "com.example.myapp",
      "min_required_version": "1.5.0",
      "min_required_build": 36,
      "force_update": true
    }
  }
}
```

*Note: `latest_*` fields are optional (useful for soft-updates). If `force_update` is missing, it defaults to `false`.*

---

## ⚙️ Caching & Policies

Results are cached in-memory with a **10-minute TTL** by default. Control the behavior via `UpdatePolicy`.

```dart
final decision = await CheckAppVersion.get(
  url,
  policy: const UpdatePolicy(
    forceRefresh: true, // Bypass cache
    debugMode: true,    // Log detailed steps
    cacheTtl: Duration(minutes: 5),
  ),
);

// Clear all cache manually
CheckAppVersion.clearCache();
```

---

## 🔄 Migration Guide (v1.x to v2.x)

The package has been completely revamped to offer better Developer Experience (DX) and a cleaner namespace.

### What Improved?
- **Unified API:** No more separate `.endpoint()` or `.file()` methods. Just `.get()`.
- **Cleaner Namespace:** UI functions like `showUpdateDialog` no longer pollute the global namespace. They belong directly to the `CheckAppVersion` class.
- **Strict Parsing:** Removed `customMapper` to rely on a solid, guaranteed JSON structure.

### How to Migrate

**1. Renamed Class**
- **Old:** `VersionCheck`
- **New:** `CheckAppVersion`

**2. Unified Fetching**
- **Old:** `VersionCheck.endpoint('https...')` or `VersionCheck.file('{"json"...}')`
- **New:** `CheckAppVersion.get('https...')` (Auto-detects URL vs JSON String)

**3. UI Helpers**
- **Old:** `showUpdateDialog(context, ...)`
- **New:** `CheckAppVersion.showUpdateDialog(context, ...)`
- **Old:** `showUpdateModal(context, ...)`
- **New:** `CheckAppVersion.showUpdateModal(context, ...)`
- **Old:** `Navigator.push(context, builder: (_) => UpdatePage(...))`
- **New:** `CheckAppVersion.showUpdatePage(context, ...)`

**4. Custom Mappers (Removed)**
- **Old:** `UpdatePolicy(customMapper: ...)`
- **New:** Ensure your remote JSON strictly matches the default schema. `customMapper` was removed to enforce a standard structure.

