import 'package:check_app_version/src/domain/entities/platform_version_config.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';

/// Pure, stateless service that compares installed
/// version / build against a [PlatformVersionConfig].
///
/// **Comparison strategy (deterministic precedence)**:
///
/// 1. If [installedBuild] < [config.minRequiredBuild]
///    → `belowMinimum`.
/// 2. Else if semantic version of [installedVersion] <
///    [config.minRequiredVersion] → `belowMinimum`.
/// 3. If latest fields are present and the installed
///    version/build is below them → `belowLatest`
///    (soft update).
/// 4. Otherwise → `upToDate`.
///
/// When `config.forceUpdate` is `true` **and** the
/// decision is `belowMinimum`, `isForceUpdate` is set.
class VersionComparator {
  const VersionComparator._();

  /// Compares the installed app version against the
  /// remote [config] and returns an [UpdateDecision].
  static UpdateDecision compare({
    required PlatformVersionConfig config,
    required String installedVersion,
    required int installedBuild,
  }) {
    final base = UpdateDecision(
      shouldUpdate: false,
      isForceUpdate: false,
      reason: UpdateReason.upToDate,
      installedVersion: installedVersion,
      installedBuild: installedBuild,
      requiredMinVersion: config.minRequiredVersion,
      requiredMinBuild: config.minRequiredBuild,
      latestVersion: config.latestVersion,
      latestBuild: config.latestBuild,
      appStoreId: config.appStoreId,
      productId: config.productId,
    );

    // ── 1. Build-number check (hard minimum) ──
    if (installedBuild < config.minRequiredBuild) {
      return base.copyWith(
        shouldUpdate: true,
        isForceUpdate: config.forceUpdate,
        reason: UpdateReason.belowMinimum,
      );
    }

    // ── 2. Semantic version check (hard minimum) ──
    if (_compareSemver(
          installedVersion,
          config.minRequiredVersion,
        ) <
        0) {
      return base.copyWith(
        shouldUpdate: true,
        isForceUpdate: config.forceUpdate,
        reason: UpdateReason.belowMinimum,
      );
    }

    // ── 3. Soft-update check (latest) ──
    if (config.latestBuild != null && installedBuild < config.latestBuild!) {
      return base.copyWith(
        shouldUpdate: true,
        reason: UpdateReason.belowLatest,
      );
    }

    if (config.latestVersion != null &&
        _compareSemver(
              installedVersion,
              config.latestVersion!,
            ) <
            0) {
      return base.copyWith(
        shouldUpdate: true,
        reason: UpdateReason.belowLatest,
      );
    }

    // ── 4. Up to date ──
    return base;
  }

  /// Compares two semantic version strings.
  ///
  /// Returns negative if [a] < [b], zero if equal,
  /// positive if [a] > [b].
  ///
  /// Supports versions with any number of dot-separated
  /// numeric segments (e.g. `1.0`, `1.2.3`, `1.2.3.4`).
  /// Non-numeric segments are treated as `0`.
  static int _compareSemver(String a, String b) {
    final aParts = _parseSegments(a);
    final bParts = _parseSegments(b);
    final length =
        aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < length; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av < bv) return -1;
      if (av > bv) return 1;
    }
    return 0;
  }

  static List<int> _parseSegments(String version) {
    return version.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }
}
