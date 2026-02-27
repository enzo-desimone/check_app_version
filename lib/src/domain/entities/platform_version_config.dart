/// Per-platform version configuration extracted from the
/// remote/local JSON document.
class PlatformVersionConfig {
  /// Creates a [PlatformVersionConfig].
  const PlatformVersionConfig({
    required this.bundleId,
    required this.minRequiredVersion,
    required this.minRequiredBuild,
    this.appStoreId,
    this.productId,
    this.latestVersion,
    this.latestBuild,
    this.forceUpdate = false,
  });

  /// Creates a [PlatformVersionConfig] from a JSON map.
  ///
  /// Accepts both `bundle_id` and `package_name` as the
  /// application identifier (falls back to the other).
  factory PlatformVersionConfig.fromJson(Map<String, dynamic> json) {
    return PlatformVersionConfig(
      bundleId:
          json['bundle_id'] as String? ?? json['package_name'] as String? ?? '',
      appStoreId: json['app_store_id'] as String?,
      productId: json['product_id'] as String?,
      minRequiredVersion: json['min_required_version'] as String? ?? '0.0.0',
      minRequiredBuild: json['min_required_build'] as int? ?? 0,
      latestVersion: json['latest_version'] as String?,
      latestBuild: json['latest_build'] as int?,
      forceUpdate: json['force_update'] as bool? ?? false,
    );
  }

  /// The application bundle identifier for this platform.
  final String bundleId;

  /// iOS / macOS App Store identifier (optional).
  final String? appStoreId;

  /// Windows Store product identifier (optional).
  final String? productId;

  /// The minimum version the user **must** have installed.
  final String minRequiredVersion;

  /// The minimum build number the user **must** have installed.
  final int minRequiredBuild;

  /// The latest available version (optional, for soft-update UX).
  final String? latestVersion;

  /// The latest available build number (optional).
  final int? latestBuild;

  /// Whether the server mandates a forced update.
  final bool forceUpdate;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'bundle_id': bundleId,
        if (appStoreId != null) 'app_store_id': appStoreId,
        if (productId != null) 'product_id': productId,
        'min_required_version': minRequiredVersion,
        'min_required_build': minRequiredBuild,
        if (latestVersion != null) 'latest_version': latestVersion,
        if (latestBuild != null) 'latest_build': latestBuild,
        'force_update': forceUpdate,
      };

  /// Returns a copy with the given fields replaced.
  PlatformVersionConfig copyWith({
    String? bundleId,
    String? appStoreId,
    String? productId,
    String? minRequiredVersion,
    int? minRequiredBuild,
    String? latestVersion,
    int? latestBuild,
    bool? forceUpdate,
  }) {
    return PlatformVersionConfig(
      bundleId: bundleId ?? this.bundleId,
      appStoreId: appStoreId ?? this.appStoreId,
      productId: productId ?? this.productId,
      minRequiredVersion: minRequiredVersion ?? this.minRequiredVersion,
      minRequiredBuild: minRequiredBuild ?? this.minRequiredBuild,
      latestVersion: latestVersion ?? this.latestVersion,
      latestBuild: latestBuild ?? this.latestBuild,
      forceUpdate: forceUpdate ?? this.forceUpdate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlatformVersionConfig &&
          runtimeType == other.runtimeType &&
          bundleId == other.bundleId &&
          appStoreId == other.appStoreId &&
          productId == other.productId &&
          minRequiredVersion == other.minRequiredVersion &&
          minRequiredBuild == other.minRequiredBuild &&
          latestVersion == other.latestVersion &&
          latestBuild == other.latestBuild &&
          forceUpdate == other.forceUpdate;

  @override
  int get hashCode => Object.hash(
        bundleId,
        appStoreId,
        productId,
        minRequiredVersion,
        minRequiredBuild,
        latestVersion,
        latestBuild,
        forceUpdate,
      );

  @override
  String toString() => 'PlatformVersionConfig('
      'bundleId: $bundleId, '
      'appStoreId: $appStoreId, '
      'productId: $productId, '
      'minRequiredVersion: $minRequiredVersion, '
      'minRequiredBuild: $minRequiredBuild, '
      'latestVersion: $latestVersion, '
      'latestBuild: $latestBuild, '
      'forceUpdate: $forceUpdate)';
}
