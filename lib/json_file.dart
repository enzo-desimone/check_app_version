class JsonFile {
  String? _appName;
  String? _newAppVersion;
  String? _newAppCode;
  String? _bundleId;
  String? _appPackage;
  String? _iOSAppId;

  JsonFile(
      {appName, newAppVersion, newAppCode, bundleId, appPackage, iOSAppId}) {
    _appName = appName;
    _newAppVersion = newAppVersion;
    _newAppCode = newAppCode;
    _bundleId = bundleId;
    _appPackage = appPackage;
    _iOSAppId = iOSAppId;
  }

  factory JsonFile.fromJson(dynamic json) {
    return JsonFile(
        appName: json['app_name'] as String?,
        newAppVersion: json['new_app_version'] as String?,
        newAppCode: json['new_app_code'] as String?,
        bundleId: json['bundle_id_ios'] as String?,
        appPackage: json['app_package'] as String?,
        iOSAppId: json['ios_app_id'] as String?);
  }

  @override
  String toString() {
    return '{${this._appName}, ${this._newAppVersion}, ${this._newAppCode}, ${this._bundleId}, ${this._appPackage}, ${this._iOSAppId}}';
  }

  String? get appName => _appName;

  String? get bundleId => _bundleId;

  String? get newAppCode => _newAppCode;

  String? get newAppVersion => _newAppVersion;

  String? get appPackage => _appPackage;

  String? get iOSAppId => _iOSAppId;
}
