import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:check_app_version/src/domain/repositories/version_repository.dart';
import 'package:check_app_version/src/domain/services/version_comparator.dart';

/// Use case that fetches version info from a
/// [VersionRepository], selects the platform config,
/// and returns an [UpdateDecision].
///
/// Exceptions from the repository are **not** caught
/// here — they propagate to the caller (the facade)
/// where debug logging can capture the full stack trace.
class CheckForUpdate {
  /// Creates a [CheckForUpdate] use case.
  const CheckForUpdate(this._repository);

  final VersionRepository _repository;

  /// Executes the check.
  ///
  /// [platform] — the [SupportedPlatform] to look up.
  /// [installedVersion] — currently installed version.
  /// [installedBuild] — currently installed build.
  ///
  /// Throws if the repository fails (network, parse,
  /// etc.). The caller is responsible for catching.
  Future<UpdateDecision> call({
    required SupportedPlatform platform,
    required String installedVersion,
    required int installedBuild,
  }) async {
    final info = await _repository.getVersionInfo();

    final config = info.platforms[platform];
    if (config == null) {
      return UpdateDecision(
        shouldUpdate: false,
        isForceUpdate: false,
        reason: UpdateReason.platformUnsupported,
        installedVersion: installedVersion,
        installedBuild: installedBuild,
      );
    }

    return VersionComparator.compare(
      config: config,
      installedVersion: installedVersion,
      installedBuild: installedBuild,
    );
  }
}
