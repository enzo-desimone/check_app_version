import 'dart:io';

import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'widgets/generic_dialog.dart';
part 'widgets/ios_dialog.dart';

class AppVersionDialog extends AccessoryCheckUpdate {
  AppVersionDialog({
    required super.jsonUrl,
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
    this.showWeb,
  });

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
  void Function()? onPressDecline;

  /// Function when press Confirm button
  void Function()? onPressConfirm;

  /// Context
  BuildContext context;

  /// Checks if it is necessary to show an app update.
  ///
  /// This method performs the following operations:
  /// 1. Retrieves the app information.
  /// 2. Checks if the JSON file containing the app information is available.
  /// 3. Verifies if the app package matches any of the known packages (Android, iOS, Windows, Linux, macOS, Web).
  /// 4. Checks if a new version of the app is available.
  /// 5. Displays an update dialog if necessary.
  ///
  /// Returns a `Future<bool>` indicating if the update dialog was shown.
  ///
  /// Returns:
  /// - `true` if the update dialog was shown.
  /// - `false` otherwise.
  Future<bool> show() async {
    final upd = await checkUpdated();

    if (!(showWeb ?? true) || !upd) return upd;


    if (kIsWeb) {
      _updateGenericDialog(context);
    } else if (cupertinoDialog && (Platform.isIOS || Platform.isMacOS)) {
      print(cupertinoDialog);
      _updateDialogIos(context);
    } else {
      _updateGenericDialog(context);
    }

    return upd;
  }

  Future<Widget?> _updateDialogIos(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return _iOSDialog(
          onWillPop: onWillPop,
          title: title,
          titleColor: titleColor,
          body: body,
          bodyColor: bodyColor,
          updateButtonColor: updateButtonColor,
          updateButtonText: updateButtonText,
          updateButtonRadius: updateButtonRadius,
          laterButtonColor: laterButtonColor,
          laterButtonEnable: laterButtonEnable,
          laterButtonText: laterButtonText,
          onPressConfirm: onPressConfirm,
          onPressDecline: onPressDecline,
          updateButtonTextColor: updateButtonTextColor,
        );
      },
    );
  }

  Future<Widget?> _updateGenericDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return _GenericDialog(
          onWillPop: onWillPop,
          backgroundColor: backgroundColor,
          dialogRadius: dialogRadius,
          title: title,
          titleColor: titleColor,
          body: body,
          bodyColor: bodyColor,
          updateButtonColor: updateButtonColor,
          updateButtonText: updateButtonText,
          updateButtonRadius: updateButtonRadius,
          laterButtonColor: laterButtonColor,
          laterButtonEnable: laterButtonEnable,
          laterButtonText: laterButtonText,
          onPressConfirm: onPressConfirm,
          onPressDecline: onPressDecline,
          updateButtonTextColor: updateButtonTextColor,
        );
      },
    );
  }
}
