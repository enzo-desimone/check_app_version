import 'dart:convert';

import 'package:check_app_version/src/data/datasources/installed_app_info.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// Reads the installed application version on Web and WASM
/// (`dart.library.js_interop`) without importing `dart:io`.
///
/// Inspects Flutter Web's generated `version.json` via `http` or
/// `rootBundle`.
Future<InstalledAppInfo> getInstalledAppInfo() async {
  Map<String, dynamic>? versionMap;

  try {
    final uri = Uri.base.resolve(
      'version.json?cachebuster=${DateTime.now().millisecondsSinceEpoch}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        versionMap = decoded;
      }
    }
  } catch (_) {
    // Fallback to asset bundle if HTTP fetch fails.
  }

  if (versionMap == null) {
    try {
      final assetStr = await rootBundle.loadString('version.json');
      final decoded = jsonDecode(assetStr);
      if (decoded is Map<String, dynamic>) {
        versionMap = decoded;
      }
    } catch (_) {
      // Fallback to empty defaults.
    }
  }

  return InstalledAppInfo(
    version: (versionMap?['version'] as String?) ?? '0.0.0',
    buildNumber: (versionMap?['build_number']?.toString()) ?? '0',
    packageName: (versionMap?['package_name'] as String?) ?? '',
  );
}
