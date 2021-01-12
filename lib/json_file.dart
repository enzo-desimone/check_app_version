class JsonFile {
  String _appName;
  String _newAppVersion;
  String _newAppCode;
  String _appPackage;
  String _iosAppId;

  JsonFile({appName, newAppVersion, newAppCode, appPackage, iosAppId}) {
    _appName = appName;
    _newAppVersion = newAppVersion;
    _newAppCode = newAppCode;

    _appPackage = appPackage;
    _iosAppId = iosAppId;
  }

  factory JsonFile.fromJson(dynamic json) {
    return JsonFile(
        appName: json['app_name'] as String,
        newAppVersion: json['new_app_version'] as String,
        newAppCode: json['new_app_code'] as String,
        appPackage: json['app_package'] as String,
        iosAppId: json['ios_app_id'] as String);
  }

  @override
  String toString() {
    return '{${this._appName}, ${this._newAppVersion}, ${this._newAppCode},  ${this._appPackage}, , ${this._iosAppId}}';
  }

  String get appName => _appName;

  String get appPackage => _appPackage;

  String get newAppCode => _newAppCode;

  String get newAppVersion => _newAppVersion;

  String get iosAppId => _iosAppId;
}
