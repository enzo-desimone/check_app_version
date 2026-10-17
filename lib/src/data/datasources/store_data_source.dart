import 'dart:convert';

import 'package:check_app_version/src/data/datasources/endpoint_json_data_source.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:http/http.dart' as http;

/// Zero-backend data source that queries official public app stores
/// (Apple App Store / macOS App Store via iTunes Search API, and
/// Google Play Store for Android) and synthesizes a normalized
/// version configuration map.
class StoreDataSource {
  /// Creates a [StoreDataSource].
  StoreDataSource({
    required this.platform,
    required this.bundleId,
    this.appStoreId,
    this.countryCode = 'us',
    this.forceUpdate = false,
    this.timeout = const Duration(seconds: 5),
    http.Client? httpClient,
  }) : _client = httpClient;

  /// Target platform to query.
  final SupportedPlatform platform;

  /// Application bundle ID (iOS/macOS) or package name (Android).
  final String bundleId;

  /// Optional Apple App Store numeric track ID.
  final String? appStoreId;

  /// Two-letter ISO country code for store lookup (defaults to `'us'`).
  final String countryCode;

  /// Whether updates found on the store should be treated as mandatory.
  ///
  /// When `true`, the store's published version is mapped to
  /// `min_required_version` with `force_update: true`.
  /// When `false` (default), it is mapped to `latest_version` (soft update).
  final bool forceUpdate;

  /// HTTP request timeout.
  final Duration timeout;

  final http.Client? _client;

  /// Queries the appropriate store and returns a standard `VersionInfo`
  /// JSON map compatible with `VersionInfo.fromJson`.
  Future<Map<String, dynamic>> load() async {
    return switch (platform) {
      SupportedPlatform.ios || SupportedPlatform.macos => _loadFromAppleStore(),
      SupportedPlatform.android => _loadFromPlayStore(),
      _ => Future.value(<String, dynamic>{
        'app_id': bundleId,
        'platforms': <String, dynamic>{},
      }),
    };
  }

  Future<Map<String, dynamic>> _loadFromAppleStore() async {
    final client = _client ?? http.Client();
    try {
      final entity = platform == SupportedPlatform.macos
          ? '&entity=macSoftware'
          : '';
      final queryParam = (appStoreId != null && appStoreId!.trim().isNotEmpty)
          ? 'id=${Uri.encodeQueryComponent(appStoreId!.trim())}'
          : 'bundleId=${Uri.encodeQueryComponent(bundleId)}';
      final url =
          'https://itunes.apple.com/lookup?'
          '$queryParam&country=${Uri.encodeQueryComponent(countryCode)}$entity';

      final response = await client.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', url: url);
      }

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException(
          'StoreDataSource: iTunes response is not a JSON object.',
        );
      }

      final results = decoded['results'];
      if (results is! List || results.isEmpty) {
        return <String, dynamic>{
          'app_id': bundleId,
          'platforms': <String, dynamic>{},
        };
      }

      final first = results.first as Map<String, dynamic>;
      final storeVersion = (first['version'] as String?)?.trim();
      final resolvedTrackId = first['trackId']?.toString() ?? appStoreId;

      if (storeVersion == null || storeVersion.isEmpty) {
        throw const FormatException(
          'StoreDataSource: missing version in iTunes lookup result.',
        );
      }

      return _buildNormalizedJson(
        storeVersion: storeVersion,
        resolvedAppStoreId: resolvedTrackId,
      );
    } finally {
      if (_client == null) client.close();
    }
  }

  Future<Map<String, dynamic>> _loadFromPlayStore() async {
    final client = _client ?? http.Client();
    try {
      final url =
          'https://play.google.com/store/apps/details'
          '?id=${Uri.encodeQueryComponent(bundleId)}'
          '&hl=en&gl=${Uri.encodeQueryComponent(countryCode)}';

      final response = await client.get(Uri.parse(url)).timeout(timeout);
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}', url: url);
      }

      final storeVersion = extractPlayStoreVersion(response.body);
      if (storeVersion == null || storeVersion.isEmpty) {
        throw const FormatException(
          'StoreDataSource: could not extract version from Google Play page.',
        );
      }

      return _buildNormalizedJson(storeVersion: storeVersion);
    } finally {
      if (_client == null) client.close();
    }
  }

  /// Extracts the version string from Google Play Store HTML content.
  static String? extractPlayStoreVersion(String html) {
    final patterns = <RegExp>[
      RegExp(r'\[\[\["(\d+(?:\.\d+)+[a-zA-Z0-9._-]*)"\]\]'),
      RegExp(r'"softwareVersion"\s*:\s*"(\d+(?:\.\d+)+[^"]*)"'),
      RegExp(r'Current Version.*?>(\d+(?:\.\d+)+[^<]*)<', dotAll: true),
    ];

    for (final regex in patterns) {
      final match = regex.firstMatch(html);
      if (match != null && match.groupCount >= 1) {
        final candidate = match.group(1)?.trim();
        if (candidate != null && candidate.isNotEmpty) {
          return candidate;
        }
      }
    }
    return null;
  }

  Map<String, dynamic> _buildNormalizedJson({
    required String storeVersion,
    String? resolvedAppStoreId,
  }) {
    return <String, dynamic>{
      'app_id': bundleId,
      'config_version': 1,
      'platforms': <String, dynamic>{
        platform.name: <String, dynamic>{
          'bundle_id': bundleId,
          'app_store_id': ?resolvedAppStoreId,
          'min_required_version': forceUpdate ? storeVersion : '0.0.0',
          'min_required_build': 0,
          'latest_version': storeVersion,
          'force_update': forceUpdate,
        },
      },
    };
  }
}
