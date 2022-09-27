class JsonFile {
  String? _appName;
  String? _newAppVersion;
  String? _newAppCode;
  String? _androidPackage;
  String? _iOSPackage;
  String? _windowsPackage;
  String? _linuxPackage;
  String? _macOSPackage;
  String? _webPackage;
  String? _iOSAppId;

  JsonFile({
    appName,
    newAppVersion,
    newAppCode,
    androidPackage,
    iOSPackage,
    windowsPackage,
    linuxPackage,
    macOSPackage,
    webPackage,
    iOSAppId,
  }) {
    _appName = appName;
    _newAppVersion = newAppVersion;
    _newAppCode = newAppCode;
    _androidPackage = androidPackage;
    _iOSPackage = iOSPackage;
    _windowsPackage = windowsPackage;
    _linuxPackage = linuxPackage;
    _macOSPackage = macOSPackage;
    _webPackage = webPackage;
    _iOSAppId = iOSAppId;
  }

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
        iOSAppId: json['ios_app_id'] as String?);
  }

  @override
  String toString() {
    return '{${this._appName}, ${this._newAppVersion}, ${this._newAppCode}, ${this._iOSAppId}, ${this._androidPackage}, ${this._iOSPackage}, ${this._windowsPackage}, ${this._linuxPackage}, ${this._macOSPackage}, ${this._webPackage}';
  }

  String? get appName => _appName;

  String? get newAppCode => _newAppCode;

  String? get newAppVersion => _newAppVersion;

  String? get androidPackage => _androidPackage;

  String? get iOSPackage => _iOSPackage;

  String? get windowsPackage => _windowsPackage;

  String? get linuxPackage => _linuxPackage;

  String? get macOSPackage => _macOSPackage;

  String? get webPackage => _webPackage;

  String? get iOSAppId => _iOSAppId;
}
