import 'package:check_app_version/src/data/datasources/installed_app_info.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Reads the installed application version on native (`dart.library.io`)
/// platforms via `package_info_plus`.
Future<InstalledAppInfo> getInstalledAppInfo() async {
  final info = await PackageInfo.fromPlatform();
  return InstalledAppInfo(
    version: info.version,
    buildNumber: info.buildNumber,
    packageName: info.packageName,
  );
}
