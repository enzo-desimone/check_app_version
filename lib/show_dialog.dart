import 'dart:core';
import 'dart:io' show Platform;
import 'package:check_app_version/repository/check_app_version.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Cav = CheckAppVersion;

class ShowDialog {
  /// App code id
  late String _appCode;

  /// App version id
  late String _appVersion;

  /// App package name
  String? _appPackage;

  /// JSON http link
  String jsonUrl;

  /// the message dialog border radius value
  double dialogRadius;

  /// the message dialog background color
  Color backgroundColor;

  /// the dialog message title
  String title;

  /// the dialog message title color
  Color? titleColor;

  /// the dialog message body
  String? body;

  /// the dialog message body color
  Color? bodyColor;

  /// if is TRUE you can dismiss the message
  /// dialog by tapping the modal barrier (default: TRUE)
  bool barrierDismissible;

  /// if is TRUE you can use Android Style for Android
  /// Cupertino IOS style for iOS
  bool cupertinoDialog;

  /// if is TRUE the message dialog it
  /// will disappear using only the action keys (default: TRUE)
  bool onWillPop;

  /// if is TRUE the message dialog it
  /// will disappear on flutter web app version (default: TRUE)
  bool? showWeb;

  /// the update button text
  String updateButtonText;

  /// the update button text color
  Color? updateButtonTextColor;

  /// the update button color
  Color? updateButtonColor;

  /// the update button text border radius value
  double? updateButtonRadius;

  /// the later button text
  String laterButtonText;

  /// the later button color
  Color? laterButtonColor;

  /// if is FALSE the later button is not visible (default: FALSE)
  bool? laterButtonEnable;

  /// Function when press Decline button
  Function()? onPressDecline;

  /// Function when press Confirm button
  Function()? onPressConfirm;

  /// Context
  BuildContext context;

  ShowDialog(
      {required this.jsonUrl,
      required this.context,
      this.onPressConfirm,
      this.onPressDecline,
      this.cupertinoDialog = true,
      this.title = 'New version',
      this.body,
      this.updateButtonText = 'update',
      this.laterButtonText = 'later',
      this.laterButtonEnable = true,
      this.barrierDismissible = true,
      this.onWillPop = true,
      this.updateButtonRadius = 10,
      this.updateButtonTextColor,
      this.updateButtonColor,
      this.laterButtonColor,
      this.dialogRadius = 10,
      this.titleColor,
      this.bodyColor,
      this.backgroundColor = Colors.white,
      this.showWeb});

  Future<void> checkVersion() async {
    await _getAppInfo();
    if (await Cav().getJsonFile(jsonUrl)) {
      if (Cav().appFile.androidPackage == _appPackage ||
          Cav().appFile.iOSPackage == _appPackage ||
          Cav().appFile.windowsPackage == _appPackage ||
          Cav().appFile.linuxPackage == _appPackage ||
          Cav().appFile.macOSPackage == _appPackage ||
          Cav().appFile.webPackage == _appPackage) {
        var upd = await _getAppVersion();
        if (showWeb ?? true && upd) {
          if (kIsWeb) {
            updateGenericDialog(context);
            return;
          }
          if (!(cupertinoDialog)) {
            updateGenericDialog(context);
          } else {
            if (Platform.isIOS || Platform.isMacOS) {
              updateDialogIos(context);
            } else {
              updateGenericDialog(context);
            }
          }
        }
      }
    }
  }

  Future<Widget?> updateDialogIos(context) {
    return showCupertinoDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              _onWillPopState(context);
            },
            child: CupertinoAlertDialog(
              title: Text(
                title,
                style: TextStyle(color: titleColor ?? Colors.black),
              ),
              content: Text(body ?? 'A new version of the app is available ' + CheckAppVersion().appFile.newAppVersion!,
                  style: TextStyle(color: bodyColor ?? Colors.black54)),
              actions: (laterButtonEnable ?? true)
                  ? <Widget>[
                      CupertinoDialogAction(
                        onPressed: onPressDecline ?? () => Navigator.of(context).pop(),
                        child: Text(laterButtonText, style: TextStyle(color: laterButtonColor ?? Colors.black)),
                      ),
                      CupertinoDialogAction(
                        onPressed: onPressConfirm ?? () => Navigator.of(context).pop(),
                        child: Text(
                          updateButtonText,
                          style: TextStyle(color: updateButtonTextColor, fontWeight: FontWeight.bold),
                        ),
                      )
                    ]
                  : <Widget>[
                      CupertinoDialogAction(
                        onPressed: onPressConfirm ?? () => Navigator.of(context).pop(),
                        child: Text(
                          updateButtonText,
                          style: TextStyle(color: updateButtonTextColor, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
            ),
          );
        });
  }

  Future<Widget?> updateGenericDialog(context) {
    return showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }
              _onWillPopState(context);
            },
            child: AlertDialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
              title: Text(
                title,
                style: TextStyle(color: titleColor ?? Colors.black),
              ),
              content: Text(body ?? 'A new version of the app is available ' + CheckAppVersion().appFile.newAppVersion!,
                  style: TextStyle(color: bodyColor ?? Colors.black54)),
              actions: <Widget>[
                Visibility(
                  visible: laterButtonEnable ?? true,
                  child: TextButton(
                    onPressed: onPressDecline ?? () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: updateButtonColor ?? Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(updateButtonRadius ?? 10),
                        )),
                    child: new Text(laterButtonText, style: TextStyle(color: laterButtonColor ?? Colors.black)),
                  ),
                ),
                ElevatedButton(
                  onPressed: onPressConfirm ?? () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(updateButtonRadius ?? 10),
                    ),
                    backgroundColor: updateButtonColor ?? Colors.blue,
                  ),
                  child: Text(
                    updateButtonText,
                    style: TextStyle(color: updateButtonTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _getAppInfo() async {
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
      _appPackage = packageInfo.packageName;
    } on PlatformException {
      _appPackage = 'Failed to get app ID.';
    }
  }

  Future<bool> _getAppVersion() async {
    bool flag = false;
    if (_appVersion.length == 0) {
      _appVersion = '0';
    }
    String tempOldCode = '$_appCode.$_appVersion';
    String tempNewCode = '${Cav().appFile.newAppVersion!}.${Cav().appFile.newAppCode!}';

    var regEx = RegExp(r'^\d{1,2}', multiLine: true);

    for (int i = 0; i < 4; i++) {
      String oldNumber = regEx.allMatches(tempOldCode).map((m) => m[0]).toString();

      final startIndex = oldNumber.indexOf('(');
      final endIndex = oldNumber.indexOf(')', startIndex + '('.length);

      String newNumber = regEx.allMatches(tempNewCode).map((m) => m[0]).toString();

      final startNewIndex = newNumber.indexOf('(');
      final endNewIndex = newNumber.indexOf(')', startNewIndex + '('.length);

      tempOldCode = tempOldCode.replaceFirst(oldNumber.substring(startIndex + '('.length, endIndex), '');
      tempOldCode = tempOldCode.replaceFirst('.', '');
      tempNewCode = tempNewCode.replaceFirst(newNumber.substring(startNewIndex + '('.length, endNewIndex), '');
      tempNewCode = tempNewCode.replaceFirst('.', '');

      if (int.parse(oldNumber.substring(startIndex + '('.length, endIndex)) <
          int.parse(newNumber.substring(startNewIndex + '('.length, endNewIndex))) {
        flag = true;
        break;
      }
    }
    return flag;
  }

  Future<bool> _onWillPopState(context) async {
    if (!onWillPop) Navigator.pop(context);
    return false;
  }
}
