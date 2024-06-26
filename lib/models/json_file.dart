class JsonFile {
  JsonFile({
    required this.appName,
    required this.newAppVersion,
    required this.newAppCode,
    required this.androidPackage,
    required this.iOSPackage,
    required this.windowsPackage,
    required this.linuxPackage,
    required this.macOSPackage,
    required this.webPackage,
    required this.iOSAppId,
  });

  factory JsonFile.fromJson(dynamic json) {
    return JsonFile(
      appName: json['app_name'] as String?,
      newAppVersion: json['new_app_version'] as String?,
      newAppCode: json['new_app_code'] as String?,
      androidPackage: json['android_package'] as String?,
      iOSPackage: json['ios_package'] as String?,
      windowsPackage: json['windows_package'] as String?,
      linuxPackage: json['linux_package'] as String?,
      macOSPackage: json['macos_package'] as String?,
      webPackage: json['web_package'] as String?,
      iOSAppId: json['ios_app_id'] as String?,
    );
  }

  final String? appName;
  final String? newAppVersion;
  final String? newAppCode;
  final String? androidPackage;
  final String? iOSPackage;
  final String? windowsPackage;
  final String? linuxPackage;
  final String? macOSPackage;
  final String? webPackage;
  final String? iOSAppId;

  @override
  String toString() {
    return '{$appName, $newAppVersion, $newAppCode, $iOSAppId, $androidPackage, $iOSPackage, $windowsPackage, $linuxPackage, $macOSPackage, $webPackage';
  }
}
