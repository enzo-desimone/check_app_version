import 'package:check_app_version/src/domain/entities/supported_platform.dart';

/// Configuration that controls how a single version
/// check call behaves.
class UpdatePolicy {
  /// Creates an [UpdatePolicy].
  const UpdatePolicy({
    this.platform,
    this.cacheTtl = const Duration(minutes: 10),
    this.forceRefresh = false,
    this.httpTimeout = const Duration(seconds: 5),
    this.debugMode = false,
  });

  /// Override the auto-detected platform.
  ///
  /// When `null`, the current platform is detected
  /// automatically at runtime.
  final SupportedPlatform? platform;

  /// How long a cached result stays valid.
  /// Defaults to 10 minutes.
  final Duration cacheTtl;

  /// If `true`, bypass the cache and fetch fresh data.
  final bool forceRefresh;

  /// HTTP request timeout (endpoint source only).
  /// Defaults to 5 seconds.
  final Duration httpTimeout;

  /// When `true`, exceptions are logged with full stack
  /// traces via `dart:developer`. Defaults to `false`.
  final bool debugMode;

  /// Returns a copy with the given fields replaced.
  UpdatePolicy copyWith({
    SupportedPlatform? platform,
    Duration? cacheTtl,
    bool? forceRefresh,
    Duration? httpTimeout,
    bool? debugMode,
  }) {
    return UpdatePolicy(
      platform: platform ?? this.platform,
      cacheTtl: cacheTtl ?? this.cacheTtl,
      forceRefresh: forceRefresh ?? this.forceRefresh,
      httpTimeout: httpTimeout ?? this.httpTimeout,
      debugMode: debugMode ?? this.debugMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatePolicy &&
          runtimeType == other.runtimeType &&
          platform == other.platform &&
          cacheTtl == other.cacheTtl &&
          forceRefresh == other.forceRefresh &&
          httpTimeout == other.httpTimeout &&
          debugMode == other.debugMode;

  @override
  int get hashCode => Object.hash(
        platform,
        cacheTtl,
        forceRefresh,
        httpTimeout,
        debugMode,
      );

  @override
  String toString() => 'UpdatePolicy('
      'platform: $platform, '
      'cacheTtl: $cacheTtl, '
      'forceRefresh: $forceRefresh, '
      'httpTimeout: $httpTimeout, '
      'debugMode: $debugMode)';
}
