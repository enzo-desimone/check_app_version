class JsonFile {
  String _appName;
  String _newAppVersion;
  String _newAppCode;
  String _playStoreUrl;
  String _appStoreUrl;
  String _appPackage;

  JsonFile(
      {appName,
        newAppVersion,
        newAppCode,
        playStoreUrl,
        appStoreUrl,
        appPackage}) {
    _appName = appName;
    _newAppVersion = newAppVersion;
    _newAppCode = newAppCode;
    _playStoreUrl = playStoreUrl;
    _appStoreUrl = appStoreUrl;
    _appPackage = appPackage;
  }

  factory JsonFile.fromJson(dynamic json) {
    return JsonFile(
        appName: json['app_name'] as String,
        newAppVersion: json['new_app_version'] as String,
        newAppCode: json['new_app_code'] as String,
        playStoreUrl: json['play_store_url'] as String,
        appStoreUrl: json['app_store_url'] as String,
        appPackage: json['app_package'] as String);
  }

  @override
  String toString() {
    return '{${this._appName}, ${this._newAppVersion}, ${this._newAppCode}, ${this._playStoreUrl}, ${this._appStoreUrl}, ${this._appPackage}}';
  }

  String get appName => _appName;

  String get appStoreUrl => _appStoreUrl;

  String get playStoreUrl => _playStoreUrl;

  String get appPackage => _appPackage;

  String get newAppCode => _newAppCode;

  String get newAppVersion => _newAppVersion;
}
