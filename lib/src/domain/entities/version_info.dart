import 'package:check_app_version/src/domain/entities/platform_version_config.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';

/// Top-level version configuration document parsed from
/// a JSON source.
class VersionInfo {
  /// Creates a [VersionInfo].
  const VersionInfo({
    this.appId,
    this.configVersion,
    this.platforms = const {},
  });

  /// Creates a [VersionInfo] from a JSON map using the
  /// default schema.
  ///
  /// Platform keys in the JSON (e.g. `"android"`,
  /// `"ios"`) are parsed into [SupportedPlatform] values.
  /// Unknown platform keys are silently ignored.
  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    final platformsJson = json['platforms'] as Map<String, dynamic>? ?? {};

    final platforms = <SupportedPlatform, PlatformVersionConfig>{};
    for (final entry in platformsJson.entries) {
      final platform = SupportedPlatform.tryParse(entry.key);
      if (platform != null) {
        platforms[platform] = PlatformVersionConfig.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    return VersionInfo(
      appId: json['app_id'] as String?,
      configVersion: json['config_version'] as int?,
      platforms: platforms,
    );
  }

  /// Application identifier from the config document.
  final String? appId;

  /// Schema version of the config document.
  final int? configVersion;

  /// Per-platform configurations keyed by
  /// [SupportedPlatform].
  final Map<SupportedPlatform, PlatformVersionConfig> platforms;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        if (appId != null) 'app_id': appId,
        if (configVersion != null) 'config_version': configVersion,
        'platforms': platforms.map(
          (key, value) => MapEntry(key.name, value.toJson()),
        ),
      };

  /// Returns a copy with the given fields replaced.
  VersionInfo copyWith({
    String? appId,
    int? configVersion,
    Map<SupportedPlatform, PlatformVersionConfig>? platforms,
  }) {
    return VersionInfo(
      appId: appId ?? this.appId,
      configVersion: configVersion ?? this.configVersion,
      platforms: platforms ?? this.platforms,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersionInfo &&
          runtimeType == other.runtimeType &&
          appId == other.appId &&
          configVersion == other.configVersion &&
          _mapsEqual(platforms, other.platforms);

  @override
  int get hashCode => Object.hash(
        appId,
        configVersion,
        Object.hashAll(platforms.entries),
      );

  @override
  String toString() => 'VersionInfo('
      'appId: $appId, '
      'configVersion: $configVersion, '
      'platforms: $platforms)';

  static bool _mapsEqual(
    Map<SupportedPlatform, PlatformVersionConfig> a,
    Map<SupportedPlatform, PlatformVersionConfig> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
