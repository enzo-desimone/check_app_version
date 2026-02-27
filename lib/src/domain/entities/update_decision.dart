/// The reason for the update decision.
enum UpdateReason {
  /// The installed version meets or exceeds all thresholds.
  upToDate,

  /// The installed version is below the minimum required.
  belowMinimum,

  /// The installed version is below the latest but above
  /// the minimum — eligible for soft update prompt.
  belowLatest,

  /// A network error occurred while fetching version info.
  networkError,

  /// The JSON could not be parsed.
  parseError,

  /// The current platform is not present in the config.
  platformUnsupported,

  /// The result was served from cache.
  cached,
}

/// The result of a version check operation.
class UpdateDecision {
  /// Creates an [UpdateDecision].
  const UpdateDecision({
    required this.shouldUpdate,
    required this.isForceUpdate,
    required this.reason,
    this.installedVersion = '',
    this.installedBuild = 0,
    this.requiredMinVersion = '',
    this.requiredMinBuild = 0,
    this.latestVersion,
    this.latestBuild,
    this.appStoreId,
    this.productId,
  });

  /// Creates an [UpdateDecision] from a JSON map.
  factory UpdateDecision.fromJson(Map<String, dynamic> json) {
    return UpdateDecision(
      shouldUpdate: json['should_update'] as bool? ?? false,
      isForceUpdate: json['is_force_update'] as bool? ?? false,
      reason: UpdateReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => UpdateReason.parseError,
      ),
      installedVersion: json['installed_version'] as String? ?? '',
      installedBuild: json['installed_build'] as int? ?? 0,
      requiredMinVersion: json['required_min_version'] as String? ?? '',
      requiredMinBuild: json['required_min_build'] as int? ?? 0,
      latestVersion: json['latest_version'] as String?,
      latestBuild: json['latest_build'] as int?,
      appStoreId: json['app_store_id'] as String?,
      productId: json['product_id'] as String?,
    );
  }

  /// Convenience constructor for error / edge-case results.
  const UpdateDecision.error(UpdateReason errorReason)
      : this(
          shouldUpdate: false,
          isForceUpdate: false,
          reason: errorReason,
        );

  /// Whether an update is available.
  final bool shouldUpdate;

  /// Whether the update is mandatory (force update).
  final bool isForceUpdate;

  /// The reason classification.
  final UpdateReason reason;

  /// Currently installed version string.
  final String installedVersion;

  /// Currently installed build number.
  final int installedBuild;

  /// Minimum required version from config.
  final String requiredMinVersion;

  /// Minimum required build from config.
  final int requiredMinBuild;

  /// Latest available version (optional).
  final String? latestVersion;

  /// Latest available build (optional).
  final int? latestBuild;

  /// iOS / macOS App Store ID (metadata only).
  final String? appStoreId;

  /// Windows Store product ID (metadata only).
  final String? productId;

  /// Serializes to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'should_update': shouldUpdate,
        'is_force_update': isForceUpdate,
        'reason': reason.name,
        'installed_version': installedVersion,
        'installed_build': installedBuild,
        'required_min_version': requiredMinVersion,
        'required_min_build': requiredMinBuild,
        if (latestVersion != null) 'latest_version': latestVersion,
        if (latestBuild != null) 'latest_build': latestBuild,
        if (appStoreId != null) 'app_store_id': appStoreId,
        if (productId != null) 'product_id': productId,
      };

  /// Returns a copy with the given fields replaced.
  UpdateDecision copyWith({
    bool? shouldUpdate,
    bool? isForceUpdate,
    UpdateReason? reason,
    String? installedVersion,
    int? installedBuild,
    String? requiredMinVersion,
    int? requiredMinBuild,
    String? latestVersion,
    int? latestBuild,
    String? appStoreId,
    String? productId,
  }) {
    return UpdateDecision(
      shouldUpdate: shouldUpdate ?? this.shouldUpdate,
      isForceUpdate: isForceUpdate ?? this.isForceUpdate,
      reason: reason ?? this.reason,
      installedVersion: installedVersion ?? this.installedVersion,
      installedBuild: installedBuild ?? this.installedBuild,
      requiredMinVersion: requiredMinVersion ?? this.requiredMinVersion,
      requiredMinBuild: requiredMinBuild ?? this.requiredMinBuild,
      latestVersion: latestVersion ?? this.latestVersion,
      latestBuild: latestBuild ?? this.latestBuild,
      appStoreId: appStoreId ?? this.appStoreId,
      productId: productId ?? this.productId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateDecision &&
          runtimeType == other.runtimeType &&
          shouldUpdate == other.shouldUpdate &&
          isForceUpdate == other.isForceUpdate &&
          reason == other.reason &&
          installedVersion == other.installedVersion &&
          installedBuild == other.installedBuild &&
          requiredMinVersion == other.requiredMinVersion &&
          requiredMinBuild == other.requiredMinBuild &&
          latestVersion == other.latestVersion &&
          latestBuild == other.latestBuild &&
          appStoreId == other.appStoreId &&
          productId == other.productId;

  @override
  int get hashCode => Object.hash(
        shouldUpdate,
        isForceUpdate,
        reason,
        installedVersion,
        installedBuild,
        requiredMinVersion,
        requiredMinBuild,
        latestVersion,
        latestBuild,
        appStoreId,
        productId,
      );

  @override
  String toString() => 'UpdateDecision('
      'shouldUpdate: $shouldUpdate, '
      'isForceUpdate: $isForceUpdate, '
      'reason: $reason, '
      'installedVersion: $installedVersion, '
      'installedBuild: $installedBuild, '
      'requiredMinVersion: $requiredMinVersion, '
      'requiredMinBuild: $requiredMinBuild, '
      'latestVersion: $latestVersion, '
      'latestBuild: $latestBuild, '
      'appStoreId: $appStoreId, '
      'productId: $productId)';
}
