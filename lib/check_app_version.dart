import 'dart:developer' as developer;

import 'package:check_app_version/src/data/cache/in_memory_version_cache.dart';
import 'package:check_app_version/src/data/datasources/endpoint_json_data_source.dart';
import 'package:check_app_version/src/data/datasources/file_json_data_source.dart';
import 'package:check_app_version/src/data/repositories/version_repository_impl.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:check_app_version/src/domain/entities/update_policy.dart';
import 'package:check_app_version/src/domain/usecases/check_for_update.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';

export 'src/domain/entities/supported_platform.dart';
export 'src/domain/entities/update_decision.dart';
export 'src/domain/entities/update_policy.dart';
// Note: UI components (UpdateDialog, UpdateModal, etc.)
// are no longer exported globally. Access them via
// CheckAppVersion.showUpdateDialog(), etc. Let's keep
// the Overlay and Page exported if users want to use them directly
// or we can add static methods for them too.
export 'src/presentation/ui/update_overlay.dart';
export 'src/presentation/ui/update_page.dart';

import 'package:check_app_version/src/presentation/ui/update_dialog.dart'
    as ui_dialog;
import 'package:check_app_version/src/presentation/ui/update_modal.dart'
    as ui_modal;
import 'package:check_app_version/src/presentation/ui/update_page.dart'
    as ui_page;
import 'package:flutter/material.dart';

/// Log name used when [UpdatePolicy.debugMode] is on.
const _logName = 'check_app_version';

/// Global singleton cache shared across all calls.
final InMemoryVersionCache _globalCache = InMemoryVersionCache();

/// Public facade for the check_app_version package.
///
/// Provides a single static entry point:
/// - [CheckAppVersion.get] automatically detects whether the source
/// is an HTTP endpoint or a raw JSON string/file.
///
/// Returns a `Future<UpdateDecision>`.
class CheckAppVersion {
  CheckAppVersion._();

  /// Checks for updates using a unified source.
  ///
  /// [source] can be an HTTP URL (starts with http) or a raw JSON string.
  /// [policy] controls caching, platform override, and debug logging.
  static Future<UpdateDecision> get(
    String source, {
    UpdatePolicy policy = const UpdatePolicy(),
  }) async {
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
        return cached.copyWith(reason: UpdateReason.cached);
      }
    }

    try {
      final loader = isEndpoint
          ? EndpointJsonDataSource(
              url: source,
              timeout: policy.httpTimeout,
            ).load
          : FileJsonDataSource(source).load;

      final repo = VersionRepositoryImpl(
        loader: loader,
      );

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

      _globalCache.put(
        cacheKey,
        decision,
        ttl: policy.cacheTtl,
      );
      return decision;
    } on Exception catch (e, stackTrace) {
      _debugError(policy, 'get($source)', e, stackTrace);
      return UpdateDecision.error(
        e is FormatException
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

  static Future<PackageInfo> _getInstalledInfo() => PackageInfo.fromPlatform();

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

  /// Shows a themed [AlertDialog] informing the user about
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
        ),
      ),
    );
  }
}
