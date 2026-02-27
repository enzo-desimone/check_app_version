import 'package:check_app_version/src/domain/entities/version_info.dart';
import 'package:check_app_version/src/domain/repositories/version_repository.dart';

/// Repository implementation that delegates to a
/// loader function.
///
/// The factory method [CheckAppVersion.get] wires in the concrete
/// datasources at a higher level.
class VersionRepositoryImpl implements VersionRepository {
  /// Creates a [VersionRepositoryImpl].
  ///
  /// [loader] fetches the raw JSON map.
  VersionRepositoryImpl({
    required Future<Map<String, dynamic>> Function() loader,
  }) : _loader = loader;

  final Future<Map<String, dynamic>> Function() _loader;

  @override
  Future<VersionInfo> getVersionInfo() async {
    final json = await _loader();
    return VersionInfo.fromJson(json);
  }
}
