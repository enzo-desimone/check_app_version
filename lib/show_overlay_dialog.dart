import 'dart:core';
import 'package:check_app_version/repository/check_app_version.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

typedef Cav = CheckAppVersion;

/*
// example
      ShowOverlayDialog(
        jsonUrl: chkver,
        context: context,
        showWeb: true,
        dialogBuilder: (context, overlayEntry) => AlertDialog(
          title: const Text(
            'New Version Available',
          ),
          content: const Text('Download Now?'),
          actions: <Widget>[
            TextButton(
              child: Text('cancel'),
              onPressed: () {
                overlayEntry?.remove();
              },
            ),
            ElevatedButton(
              child: Text('download'),
              onPressed: () {
                launchUrl(uri);
                overlayEntry?.remove();
              },
            ),
          ],
        ),
      ).checkVersion();

*/

class ShowOverlayDialog {
  /// App code id
  late String _appCode;

  /// App version id
  late String _appVersion;

  /// App package name
  String? _appPackage;

  /// JSON http link
  String jsonUrl;

  /// if is TRUE the message dialog it
  /// will disappear on flutter web app version (default: TRUE)
  bool? showWeb;

  /// Context
  BuildContext context;

  /// if is TRUE you can dismiss the message
  /// dialog by tapping the modal barrier (default: TRUE)
  bool barrierDismissible;

  /// Custom Dialog Builder for use your custom dialog
  Widget Function(BuildContext, OverlayEntry?) dialogBuilder;

  /// current overlay entry
  late OverlayEntry overlayEntry;

  ShowOverlayDialog(
      {required this.jsonUrl,
      required this.context,
      required this.dialogBuilder,
      this.showWeb,
      this.barrierDismissible = true});

  // is exists a new version?
  Future<bool> checkVersion() async {
    bool upd = false;
    await _getAppInfo();
    if (await Cav().getJsonFile(jsonUrl)) {
      if (Cav().appFile.androidPackage == _appPackage ||
          Cav().appFile.iOSPackage == _appPackage ||
          Cav().appFile.windowsPackage == _appPackage ||
          Cav().appFile.linuxPackage == _appPackage ||
          Cav().appFile.macOSPackage == _appPackage ||
          Cav().appFile.webPackage == _appPackage) {
        upd = await _getAppVersion();
        if (showWeb ?? true && upd) {
          overlayEntry = OverlayEntry(
              builder: (BuildContext context) =>
                  dialogBuilder(context, overlayEntry));
          // entry.remove();
          Overlay.of(context).insert(overlayEntry);
        }
      }
    }
    return upd;
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
    String tempNewCode =
        '${Cav().appFile.newAppVersion!}.${Cav().appFile.newAppCode!}';

    var regEx = RegExp(r'^\d{1,2}', multiLine: true);

    for (int i = 0; i < 4; i++) {
      String oldNumber =
          regEx.allMatches(tempOldCode).map((m) => m[0]).toString();

      final startIndex = oldNumber.indexOf('(');
      final endIndex = oldNumber.indexOf(')', startIndex + '('.length);

      String newNumber =
          regEx.allMatches(tempNewCode).map((m) => m[0]).toString();

      final startNewIndex = newNumber.indexOf('(');
      final endNewIndex = newNumber.indexOf(')', startNewIndex + '('.length);

      tempOldCode = tempOldCode.replaceFirst(
          oldNumber.substring(startIndex + '('.length, endIndex), '');
      tempOldCode = tempOldCode.replaceFirst('.', '');
      tempNewCode = tempNewCode.replaceFirst(
          newNumber.substring(startNewIndex + '('.length, endNewIndex), '');
      tempNewCode = tempNewCode.replaceFirst('.', '');

      if (int.parse(oldNumber.substring(startIndex + '('.length, endIndex)) <
          int.parse(
              newNumber.substring(startNewIndex + '('.length, endNewIndex))) {
        flag = true;
        break;
      }
    }
    return flag;
  }
}
