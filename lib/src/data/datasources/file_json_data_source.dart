import 'dart:convert';

import 'package:check_app_version/src/data/datasources/endpoint_json_data_source.dart'
    show EndpointJsonDataSource;
import 'package:flutter/services.dart' show rootBundle;

/// Data source that loads raw JSON from a non-network
/// source: Flutter asset or a raw JSON string.
///
/// For HTTP/cloud-hosted JSON, use
/// [EndpointJsonDataSource] instead.
class FileJsonDataSource {
  /// Creates a [FileJsonDataSource].
  ///
  /// [input] can be:
  /// - An asset path (e.g. `assets/version.json`)
  /// - A raw JSON string already obtained externally
  const FileJsonDataSource(this.input);

  /// The asset path or raw JSON string.
  final String input;

  /// Loads and decodes the JSON, returning the resulting
  /// map. Tries raw JSON first, then asset.
  Future<Map<String, dynamic>> load() async {
    // 1. Try as raw JSON string first (cheapest check).
    final rawResult = _tryDecodeJson(input);
    if (rawResult != null) return rawResult;

    // 2. Try as Flutter asset.
    try {
      final assetStr = await rootBundle.loadString(input);
      final decoded = json.decode(assetStr);
      if (decoded is Map<String, dynamic>) return decoded;
    } on Exception {
      // Not an asset — fall through.
    }

    throw const FormatException(
      'FileJsonDataSource: input is not valid JSON '
      'or a recognized asset path.',
    );
  }

  static Map<String, dynamic>? _tryDecodeJson(String s) {
    try {
      final decoded = json.decode(s);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // Not valid JSON.
    }
    return null;
  }
}
