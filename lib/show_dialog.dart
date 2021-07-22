import 'dart:async';
import 'dart:core';
import 'dart:io' show Platform;
import 'package:app_installer/app_installer.dart';
import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

class ShowDialog {
  /// App code id
  late String _appCode;

  /// App version id
  late String _appVersion;

  /// App package name android
  String? _appPackageName;

  /// JSON http link
  String? _jsonUrl;

  /// the message dialog border radius value
  double? _dialogRadius;

  /// the message dialog background color
  Color? _backgroundColor;

  /// the dialog message title
  String? _title;

  /// the dialog message title color
  Color? _titleColor;

  /// the dialog message body
  String? _body;

  /// the dialog message body color
  Color? _bodyColor;

  /// if is TRUE you can dismiss the message
  /// dialog by tapping the modal barrier
  bool? _barrierDismissible;

  /// if is TRUE you can use Android Style for Android
  /// Cupertino IOS style for iOS
  bool? _cupertinoDialog;

  /// if is TRUE the message dialog it
  /// will disappear using only the action keys (default: TRUE)
  bool? _onWillPop;

  /// the update button text
  String? _updateButtonText;

  /// the update button text color
  Color? _updateButtonTextColor;

  /// the update button color
  Color? _updateButtonColor;

  /// the update button text border radius value
  double? _updateButtonRadius;

  /// the later button text
  String? _laterButtonText;

  /// the later button color
  Color? _laterButtonColor;

  /// if is FALSE the later button is not visible (default: FALSE)
  bool? _laterButtonEnable;

  /// Context
  BuildContext? _context;

  ShowDialog(
      {jsonUrl,
      title,
      body,
      barrierDismissible,
      onWillPop,
      updateButtonText,
      laterButtonText,
      laterButtonEnable,
      updateButtonRadius,
      updateButtonTextColor,
      updateButtonColor,
      laterButtonColor,
      dialogRadius,
      titleColor,
      bodyColor,
      backgroundColor,
      cupertinoDialog,
      context}) {
    _jsonUrl = jsonUrl;
    _title = title;
    _cupertinoDialog = cupertinoDialog;
    _body = body;
    _updateButtonText = updateButtonText;
    _laterButtonText = laterButtonText;
    _laterButtonEnable = laterButtonEnable;
    _updateButtonRadius = updateButtonRadius;
    _updateButtonTextColor = updateButtonTextColor;
    _updateButtonColor = updateButtonColor;
    _laterButtonColor = laterButtonColor;
    _dialogRadius = dialogRadius;
    _titleColor = titleColor;
    _bodyColor = bodyColor;
    _backgroundColor = backgroundColor;
    _context = context;
  }

  Future<void> checkVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

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
      _appPackageName = packageInfo.packageName;
    } on PlatformException {
      _appPackageName = 'Failed to get app ID.';
    }

    if (await CheckAppVersion().getJsonFile(_jsonUrl!)) {
      if (CheckAppVersion().appFile.appPackage == _appPackageName ||
          CheckAppVersion().appFile.bundleId == _appPackageName) {
        bool flag = false;
        if (_appVersion.length == 0) _appVersion = '0';
        String tempOldCode = _appCode + '.' + _appVersion;

        String tempNewCode = CheckAppVersion().appFile.newAppVersion! +
            '.' +
            CheckAppVersion().appFile.newAppCode!;

        var regEx = RegExp(r'^\d{1,2}', multiLine: true);

        for (int i = 0; i < 4; i++) {
          String oldNumber =
              regEx.allMatches(tempOldCode).map((m) => m[0]).toString();

          final startIndex = oldNumber.indexOf('(');
          final endIndex = oldNumber.indexOf(')', startIndex + '('.length);

          String newNumber =
              regEx.allMatches(tempNewCode).map((m) => m[0]).toString();

          final startNewIndex = newNumber.indexOf('(');
          final endNewIndex =
              newNumber.indexOf(')', startNewIndex + '('.length);

          tempOldCode = tempOldCode.replaceFirst(
              oldNumber.substring(startIndex + '('.length, endIndex), '');
          tempOldCode = tempOldCode.replaceFirst('.', '');
          tempNewCode = tempNewCode.replaceFirst(
              newNumber.substring(startNewIndex + '('.length, endNewIndex), '');
          tempNewCode = tempNewCode.replaceFirst('.', '');

          if (int.parse(
                  oldNumber.substring(startIndex + '('.length, endIndex)) <
              int.parse(newNumber.substring(
                  startNewIndex + '('.length, endNewIndex))) {
            flag = true;
            break;
          }
        }
        if (flag) {
          if (_cupertinoDialog != null && !_cupertinoDialog!)
            updateDialogAndroid(_context);
          else if (Platform.isAndroid)
            updateDialogAndroid(_context);
          else if (Platform.isIOS) updateDialogIos(_context);
        }
      }
    }
  }

  Future<Widget?> updateDialogIos(context) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: _barrierDismissible ?? true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _onWillPopState(context),
            child: CupertinoAlertDialog(
              title: Text(
                _title ?? 'Update App',
                style: TextStyle(color: _titleColor ?? Colors.black),
              ),
              content: Text(
                  _body ??
                      'A new version of the app is available ' +
                          CheckAppVersion().appFile.newAppVersion!,
                  style: TextStyle(color: _bodyColor ?? Colors.black54)),
              actions: <Widget>[
                Visibility(
                  visible: _laterButtonEnable ?? true,
                  child: CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_laterButtonText ?? 'Later',
                        style: TextStyle(
                            color: _laterButtonColor ?? Colors.black)),
                  ),
                ),
                CupertinoDialogAction(
                  onPressed: () {
                    AppInstaller.goStore(CheckAppVersion().appFile.appPackage!,
                        CheckAppVersion().appFile.appPackage!);
                  },
                  child: Text(
                    _updateButtonText ?? "Update",
                    style: TextStyle(
                        color: _updateButtonTextColor,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        });
  }

  Future<Widget?> updateDialogAndroid(context) {
    return showDialog(
        context: context,
        barrierDismissible: _barrierDismissible ?? true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _onWillPopState(context),
            child: AlertDialog(
              backgroundColor: _backgroundColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_dialogRadius ?? 12.0)),
              title: Text(
                _title ?? 'Update App',
                style: TextStyle(color: _titleColor ?? Colors.black),
              ),
              content: Text(
                  _body ??
                      'A new version of the app is available ' +
                          CheckAppVersion().appFile.newAppVersion!,
                  style: TextStyle(color: _bodyColor ?? Colors.black54)),
              actions: <Widget>[
                Visibility(
                  visible: _laterButtonEnable ?? true,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(_updateButtonRadius ?? 10),
                        ),
                        onPrimary: _updateButtonColor ?? Colors.blue),
                    onPressed: () => Navigator.pop(context),
                    child: new Text(_laterButtonText ?? 'Later',
                        style: TextStyle(
                            color: _laterButtonColor ?? Colors.black)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    AppInstaller.goStore(CheckAppVersion().appFile.appPackage!,
                        CheckAppVersion().appFile.appPackage!);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(_updateButtonRadius ?? 10),
                    ),
                    primary: _updateButtonColor ?? Colors.blue,
                  ),
                  child: Text(
                    _updateButtonText ?? "Update",
                    style: TextStyle(
                        color: _updateButtonTextColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<bool> _onWillPopState(context) async {
    if (_onWillPop != null && !_onWillPop!) Navigator.pop(context);
    return false;
  }
}
