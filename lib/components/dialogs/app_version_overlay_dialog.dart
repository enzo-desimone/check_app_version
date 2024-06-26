import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/material.dart';

class AppVersionOverlayDialog extends AccessoryCheckUpdate {
  AppVersionOverlayDialog({
    required super.jsonUrl,
    required this.context,
    required this.dialogBuilder,
    this.showWeb,
    this.barrierDismissible = true,
  });

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
    if (showWeb ?? true && upd) {
      overlayEntry = OverlayEntry(
        builder: (BuildContext context) => dialogBuilder(context, overlayEntry),
      );

      Overlay.of(context).insert(overlayEntry);
    }
    return upd;
  }
}
