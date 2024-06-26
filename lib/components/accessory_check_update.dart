import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

export 'dialogs/app_version_custom_dialog.dart';
export 'dialogs/app_version_dialog.dart';
export 'dialogs/app_version_overlay_dialog.dart';

abstract class AccessoryCheckUpdate  {
  AccessoryCheckUpdate({
    required this.jsonUrl,
  });

  /// App code id
  late String _appCode;

  /// App version id
  late String _appVersion;

  /// App package name
  String? _appPackage;

  /// JSON http link
  String jsonUrl;

  Future<bool> checkUpdated() async {
    await getAppInfo();
    var upd = false;

    if (!await Cav.instance.getJsonFile(jsonUrl)) return upd;

    final appFile = Cav.instance.appFile;
    final packages = [
      appFile.androidPackage,
      appFile.iOSPackage,
      appFile.windowsPackage,
      appFile.linuxPackage,
      appFile.macOSPackage,
      appFile.webPackage,
    ];

    if (!packages.contains(_appPackage)) return upd;

    upd = await getAppVersion();

    return upd;
  }

  Future<void> getAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    try {
      _appCode = packageInfo.version;
    } on PlatformException {
      _appCode = 'Failed to get project version.';
    }

    try {
      _appVersion = packageInfo.buildNumber;
    } on PlatformException {
      _appVersion = 'Failed to get build number.';
    }

    try {
      _appPackage = packageInfo.packageName;
    } on PlatformException {
      _appPackage = 'Failed to get app ID.';
    }
  }

  Future<bool> getAppVersion() async {
    if (_appVersion.isEmpty) {
      _appVersion = '0';
    }

    final oldCode = '$_appCode.$_appVersion';
    final newCode =
        '${Cav.instance.appFile.newAppCode!}.${Cav.instance.appFile.newAppVersion!}';

    final oldVersionParts = oldCode.split('.').map(int.parse).toList();
    final newVersionParts = newCode.split('.').map(int.parse).toList();

    for (var i = 0; i < oldVersionParts.length; i++) {
      if (oldVersionParts[i] < newVersionParts[i]) {
        return true;
      } else if (oldVersionParts[i] > newVersionParts[i]) {
        return false;
      }
    }

    return false;
  }
}
