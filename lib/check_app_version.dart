/// Flutter in-app update and version checker supporting App Store,
/// Google Play Store, remote HTTP endpoints, and local JSON sources.
library;

import 'dart:developer' as developer;

import 'package:check_app_version/src/data/cache/in_memory_version_cache.dart';
import 'package:check_app_version/src/data/cache/snooze_manager.dart';
import 'package:check_app_version/src/data/datasources/endpoint_json_data_source.dart';
import 'package:check_app_version/src/data/datasources/file_json_data_source.dart';
import 'package:check_app_version/src/data/datasources/installed_app_info.dart';
import 'package:check_app_version/src/data/datasources/installed_app_info_io.dart'
    if (dart.library.js_interop) 'package:check_app_version/src/data/datasources/installed_app_info_web.dart';
import 'package:check_app_version/src/data/datasources/store_data_source.dart';
import 'package:check_app_version/src/data/repositories/version_repository_impl.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:check_app_version/src/domain/entities/update_policy.dart';
import 'package:check_app_version/src/domain/usecases/check_for_update.dart';
import 'package:check_app_version/src/presentation/ui/update_dialog.dart'
    as ui_dialog;
import 'package:check_app_version/src/presentation/ui/update_modal.dart'
    as ui_modal;
import 'package:check_app_version/src/presentation/ui/update_page.dart'
    as ui_page;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

export 'src/data/datasources/store_data_source.dart' show StoreDataSource;
export 'src/domain/entities/supported_platform.dart';
export 'src/domain/entities/update_decision.dart';
export 'src/domain/entities/update_policy.dart';
export 'src/presentation/ui/update_gate.dart';
export 'src/presentation/ui/update_overlay.dart';
export 'src/presentation/ui/update_page.dart';

/// Log name used when [UpdatePolicy.debugMode] is on.
const _logName = 'check_app_version';

/// Global singleton cache shared across all calls.
final InMemoryVersionCache _globalCache = InMemoryVersionCache();

/// Public facade for the check_app_version package.
///
/// Provides static entry points:
/// - [CheckAppVersion.get] automatically detects whether the source
///   is an HTTP endpoint, local asset, raw JSON string, or `'store'`.
/// - [CheckAppVersion.fromStores] queries Apple App Store or Google Play
///   directly without requiring a custom backend JSON file.
///
/// Returns a `Future<UpdateDecision>`.
class CheckAppVersion {
  CheckAppVersion._();

  /// Checks for updates using a unified source.
  ///
  /// [source] can be an HTTP URL (starts with `http`), a local asset path,
  /// a raw JSON string, or `'store'` to query official app stores directly.
  /// [policy] controls caching, platform override, snooze, and debug logging.
  static Future<UpdateDecision> get(
    String source, {
    UpdatePolicy policy = const UpdatePolicy(),
  }) async {
    final trimmed = source.trim();
    if (trimmed == 'store' || trimmed.startsWith('store://')) {
      return fromStores(policy: policy);
    }

    final isEndpoint =
        source.startsWith('http://') || source.startsWith('https://');
    final sourceType = isEndpoint ? 'endpoint' : 'file';

    final platform = policy.platform ?? _detectPlatform();
    final cacheKey = InMemoryVersionCache.buildKey(
      sourceType: sourceType,
      path: source.length > 120 ? source.hashCode.toString() : source,
      platform: platform.name,
    );

    // Cache hit.
    if (!policy.forceRefresh) {
      final cached = _globalCache.get(cacheKey);
      if (cached != null) {
        _debug(policy, 'Cache hit for key: $cacheKey');
        final cachedDecision = cached.copyWith(reason: UpdateReason.cached);
        return policy.respectSnooze
            ? SnoozeManager.instance.apply(cachedDecision)
            : cachedDecision;
      }
    }

    try {
      final loader = isEndpoint
          ? EndpointJsonDataSource(
              url: source,
              timeout: policy.httpTimeout,
            ).load
          : FileJsonDataSource(source).load;

      final repo = VersionRepositoryImpl(loader: loader);

      final info = await _getInstalledInfo();
      _debug(
        policy,
        'Installed: ${info.version}+${info.buildNumber} '
        'on ${platform.name}',
      );

      final decision = await CheckForUpdate(repo).call(
        platform: platform,
        installedVersion: info.version,
        installedBuild: int.tryParse(info.buildNumber) ?? 0,
      );

      _debug(policy, 'Decision: ${decision.reason.name}');

      _globalCache.put(cacheKey, decision, ttl: policy.cacheTtl);
      return policy.respectSnooze
          ? SnoozeManager.instance.apply(decision)
          : decision;
    } catch (e, stackTrace) {
      _debugError(policy, 'get($source)', e, stackTrace);
      return UpdateDecision.error(
        (e is FormatException || e is TypeError)
            ? UpdateReason.parseError
            : UpdateReason.networkError,
      );
    }
  }

  /// Zero-backend version check that queries the official Apple App Store
  /// (iOS/macOS) or Google Play Store (Android) directly.
  ///
  /// - [bundleId] / [packageName]: overrides the auto-detected package name
  ///   from `PackageInfo.fromPlatform()`.
  /// - [appStoreId]: optional numeric Apple App Store ID for faster lookup.
  /// - [countryCode]: two-letter ISO store country code (defaults to `'us'`).
  /// - [forceUpdate]: when `true`, treats store updates as mandatory.
  /// - [policy]: controls caching, timeouts, snooze, and platform override.
  /// - [httpClient]: optional custom HTTP client (useful for testing).
  static Future<UpdateDecision> fromStores({
    String? bundleId,
    String? packageName,
    String? appStoreId,
    String countryCode = 'us',
    bool forceUpdate = false,
    UpdatePolicy policy = const UpdatePolicy(),
    http.Client? httpClient,
  }) async {
    final platform = policy.platform ?? _detectPlatform();

    try {
      final info = await _getInstalledInfo();
      final resolvedBundleId = bundleId ?? packageName ?? info.packageName;

      final cacheKey = InMemoryVersionCache.buildKey(
        sourceType: 'store',
        path: '$resolvedBundleId:$countryCode:$forceUpdate',
        platform: platform.name,
      );

      if (!policy.forceRefresh) {
        final cached = _globalCache.get(cacheKey);
        if (cached != null) {
          _debug(policy, 'Store cache hit for key: $cacheKey');
          final cachedDecision = cached.copyWith(reason: UpdateReason.cached);
          return policy.respectSnooze
              ? SnoozeManager.instance.apply(cachedDecision)
              : cachedDecision;
        }
      }

      final storeSource = StoreDataSource(
        platform: platform,
        bundleId: resolvedBundleId,
        appStoreId: appStoreId,
        countryCode: countryCode,
        forceUpdate: forceUpdate,
        timeout: policy.httpTimeout,
        httpClient: httpClient,
      );

      final repo = VersionRepositoryImpl(loader: storeSource.load);
      final decision = await CheckForUpdate(repo).call(
        platform: platform,
        installedVersion: info.version,
        installedBuild: int.tryParse(info.buildNumber) ?? 0,
      );

      _globalCache.put(cacheKey, decision, ttl: policy.cacheTtl);
      return policy.respectSnooze
          ? SnoozeManager.instance.apply(decision)
          : decision;
    } catch (e, stackTrace) {
      _debugError(policy, 'fromStores()', e, stackTrace);
      return UpdateDecision.error(
        (e is FormatException || e is TypeError)
            ? UpdateReason.parseError
            : UpdateReason.networkError,
      );
    }
  }

  // ─── Cache management ──────────────────────────────

  /// Clears all cached results.
  static void clearCache() => _globalCache.clear();

  /// Invalidates a single cache entry.
  static void invalidateCache(String key) => _globalCache.invalidate(key);

  // ─── Smart Snooze & Skip Version ───────────────────

  /// Snoozes non-mandatory update prompts for the given [duration].
  static void snooze(Duration duration) =>
      SnoozeManager.instance.snooze(duration);

  /// Marks a specific [version] (e.g. `"1.6.0"`) as skipped so soft
  /// update prompts won't trigger for that version again.
  static void skipVersion(String version) =>
      SnoozeManager.instance.skipVersion(version);

  /// Whether soft updates are currently snoozed.
  static bool get isSnoozed => SnoozeManager.instance.isSnoozed;

  /// Whether [version] has been explicitly skipped by the user.
  static bool isVersionSkipped(String version) =>
      SnoozeManager.instance.isVersionSkipped(version);

  /// Clears active snooze timers and all skipped versions.
  static void clearSnooze() => SnoozeManager.instance.clear();

  // ─── Helpers ───────────────────────────────────────

  /// Detects the current platform using Flutter's
  /// [defaultTargetPlatform] and [kIsWeb].
  ///
  /// Works on all platforms including web (no dart:io).
  static SupportedPlatform _detectPlatform() {
    if (kIsWeb) return SupportedPlatform.web;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => SupportedPlatform.android,
      TargetPlatform.iOS => SupportedPlatform.ios,
      TargetPlatform.macOS => SupportedPlatform.macos,
      TargetPlatform.windows => SupportedPlatform.windows,
      TargetPlatform.linux => SupportedPlatform.linux,
      TargetPlatform.fuchsia => SupportedPlatform.android,
    };
  }

  static Future<InstalledAppInfo> _getInstalledInfo() => getInstalledAppInfo();

  /// Logs an informational message when debug mode is on.
  static void _debug(UpdatePolicy policy, String msg) {
    if (policy.debugMode) {
      developer.log(msg, name: _logName);
    }
  }

  /// Logs an error with full stack trace when debug mode
  /// is on.
  static void _debugError(
    UpdatePolicy policy,
    String context,
    Object error,
    StackTrace stackTrace,
  ) {
    if (policy.debugMode) {
      developer.log(
        '[$context] $error',
        name: _logName,
        error: error,
        stackTrace: stackTrace,
        level: 1000,
      );
    }
  }

  // ─── UI Presentation Helpers ─────────────────────────

  /// Shows a themed [AlertDialog] (or native `CupertinoAlertDialog`
  /// when [adaptive] is `true` on iOS/macOS) informing the user about
  /// an available update.
  static Future<void> showUpdateDialog(
    BuildContext context, {
    required UpdateDecision decision,
    required VoidCallback onOpenStore,
    VoidCallback? onLater,
    String title = 'Update Available',
    String? message,
    String updateLabel = 'Update',
    String laterLabel = 'Later',
    bool popAfterPressed = true,
    bool adaptive = false,
    Duration? snoozeDuration,
    bool showSkipVersion = false,
    String skipLabel = 'Skip this version',
    VoidCallback? onSkipVersion,
  }) {
    return ui_dialog.showUpdateDialog(
      context,
      decision: decision,
      onOpenStore: onOpenStore,
      onLater: onLater,
      title: title,
      message: message,
      updateLabel: updateLabel,
      laterLabel: laterLabel,
      popAfterPressed: popAfterPressed,
      adaptive: adaptive,
      snoozeDuration: snoozeDuration,
      showSkipVersion: showSkipVersion,
      skipLabel: skipLabel,
      onSkipVersion: onSkipVersion,
    );
  }

  /// Shows a modal bottom sheet for update prompts.
  static Future<void> showUpdateModal(
    BuildContext context, {
    required UpdateDecision decision,
    required VoidCallback onOpenStore,
    VoidCallback? onLater,
    String title = 'Update Required',
    String? message,
    String updateLabel = 'Update Now',
    String laterLabel = 'Later',
    bool popAfterPressed = true,
    Duration? snoozeDuration,
    bool showSkipVersion = false,
    String skipLabel = 'Skip this version',
    VoidCallback? onSkipVersion,
  }) {
    return ui_modal.showUpdateModal(
      context,
      decision: decision,
      onOpenStore: onOpenStore,
      onLater: onLater,
      title: title,
      message: message,
      updateLabel: updateLabel,
      laterLabel: laterLabel,
      popAfterPressed: popAfterPressed,
      snoozeDuration: snoozeDuration,
      showSkipVersion: showSkipVersion,
      skipLabel: skipLabel,
      onSkipVersion: onSkipVersion,
    );
  }

  /// Navigates to a full-screen MaterialPageRoute informing the user
  /// about a mandatory update.
  static Future<T?> showUpdatePage<T extends Object?>(
    BuildContext context, {
    required UpdateDecision decision,
    required VoidCallback onOpenStore,
    String title = 'Update Required',
    String? message,
    String updateLabel = 'Update Now',
    IconData icon = Icons.system_update,
    bool popAfterPressed = true,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) => ui_page.UpdatePage(
          decision: decision,
          onOpenStore: onOpenStore,
          title: title,
          message: message,
          updateLabel: updateLabel,
          icon: icon,
          popAfterPressed: popAfterPressed,
        ),
      ),
    );
  }
}
