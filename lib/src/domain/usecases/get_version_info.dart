import 'package:check_app_version/src/domain/entities/version_info.dart';
import 'package:check_app_version/src/domain/repositories/version_repository.dart';

/// Use case that simply retrieves the raw [VersionInfo]
/// from a [VersionRepository].
class GetVersionInfo {
  /// Creates a [GetVersionInfo] use case.
  const GetVersionInfo(this._repository);

  final VersionRepository _repository;

  /// Fetches the [VersionInfo].
  Future<VersionInfo> call() => _repository.getVersionInfo();
}
