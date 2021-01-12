import 'dart:async';

import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_version/get_version.dart';

class ShowDialog {
  String _platformVersion;
  String _appCode;
  String _appVersion;
  String _appPackageName;

  String _jsonUrl;
  String _title;
  String _body;
  bool _barrierDismissible;
  bool _onWillPop;
  String _updateButtonText;
  String _laterButtonText;
  bool _laterButtonEnable;
  double _updateButtonRadius;
  Color _updateButtonTextColor;
  Color _updateButtonColor;
  Color _laterButtonColor;
  double _dialogRadius;
  Color _titleColor;
  Color _bodyColor;
  Color _backgroundColor;
  BuildContext _context;

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
        context}) {
    _jsonUrl = jsonUrl;
    _title = title;
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
    try {
      _platformVersion = await GetVersion.platformVersion;
    } on PlatformException {
      _platformVersion = 'Failed to get platform version.';
    }

    try {
      _appCode = await GetVersion.projectVersion;
    } on PlatformException {
      _appCode = 'Failed to get project version.';
    }

    try {
      _appVersion = await GetVersion.projectCode;
    } on PlatformException {
      _appVersion = 'Failed to get build number.';
    }

    try {
      _appPackageName = await GetVersion.appID;
    } on PlatformException {
      _appPackageName = 'Failed to get app ID.';
    }

    if (await CheckAppVersion().getJsonFile(_jsonUrl)) {
      if (CheckAppVersion().appFile.appPackage == _appPackageName) {
        bool flag = false;
        if (_appVersion.length == 0) _appVersion = '0';
        String tempOldCode = _appCode + '.' + _appVersion;

        String tempNewCode = CheckAppVersion().appFile.newAppVersion +
            '.' +
            CheckAppVersion().appFile.newAppCode;

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

        if (flag) updateDialog(_context);
      }
    }
  }

  Future<Widget> updateDialog(context) {
    return showDialog(
        context: context,
        barrierDismissible: _barrierDismissible ?? true,
        builder: (BuildContext context) {
          return WillPopScope(
            onWillPop: () => _onWillPopState(context),
            child: new AlertDialog(
              backgroundColor: _backgroundColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_dialogRadius ?? 12.0)),
              title: new Text(
                _title ?? 'Update App',
                style: TextStyle(color: _titleColor ?? Colors.black),
              ),
              content: new Text(
                  _body ??
                      'A new version of the app is available ' +
                          CheckAppVersion().appFile.newAppVersion,
                  style: TextStyle(color: _bodyColor ?? Colors.black54)),
              actions: <Widget>[
                Visibility(
                  visible: _laterButtonEnable ?? true,
                  child: FlatButton(
                    onPressed: () => SystemChannels.platform
                        .invokeMethod<void>('SystemNavigator.pop'),
                    child: new Text(_laterButtonText ?? 'Later',
                        style: TextStyle(
                            color: _laterButtonColor ?? Colors.black)),
                  ),
                ),
                RaisedButton(
                  onPressed: () async => Navigator.pop(context),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(_updateButtonRadius ?? 10),
                  ),
                  color: _updateButtonColor ?? Colors.blue,
                  child: new Text(
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
    if (_onWillPop != null && !_onWillPop) Navigator.pop(context);
    return false;
  }

  String get appPackageName => _appPackageName;

  String get appVersion => _appVersion;

  String get appCode => _appCode;

  String get platformVersion => _platformVersion;
}
