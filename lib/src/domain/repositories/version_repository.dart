import 'package:check_app_version/src/domain/entities/version_info.dart';

/// Contract for fetching version configuration data.
///
/// Implementations decide the concrete data source
/// (file, endpoint, etc.).
abstract class VersionRepository {
  /// Fetches the [VersionInfo] from the underlying source.
  Future<VersionInfo> getVersionInfo();
}
