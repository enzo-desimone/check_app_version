part of '../app_version_dialog.dart';

class _iOSDialog extends StatelessWidget {
  const _iOSDialog({
    required this.onWillPop,
    required this.title,
    required this.updateButtonText,
    required this.laterButtonText,
    this.titleColor,
    this.body,
    this.bodyColor,
    this.updateButtonColor,
    this.updateButtonRadius,
    this.laterButtonColor,
    this.laterButtonEnable,
    this.onPressConfirm,
    this.onPressDecline,
    this.updateButtonTextColor,
  });

  final bool onWillPop;
  final String title;
  final Color? titleColor;
  final String? body;
  final Color? bodyColor;
  final String updateButtonText;
  final Color? updateButtonTextColor;
  final Color? updateButtonColor;
  final double? updateButtonRadius;
  final String laterButtonText;
  final Color? laterButtonColor;
  final bool? laterButtonEnable;
  final void Function()? onPressDecline;
  final void Function()? onPressConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPopState(context);
      },
      child: CupertinoAlertDialog(
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? Colors.black),
        ),
        content: Text(
          body ??
              'A new version of the app is available ${CheckAppVersion().appFile.newAppVersion!}',
          style: TextStyle(color: bodyColor ?? Colors.black54),
        ),
        actions: [
          if (laterButtonEnable ?? true)
            CupertinoDialogAction(
              onPressed: onPressDecline ?? () => Navigator.of(context).pop(),
              child: Text(
                laterButtonText,
                style: TextStyle(color: laterButtonColor ?? Colors.black),
              ),
            ),
          CupertinoDialogAction(
            onPressed: onPressConfirm ?? () => Navigator.of(context).pop(),
            child: Text(
              updateButtonText,
              style: TextStyle(
                color: updateButtonTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPopState(BuildContext context) async {
    if (!onWillPop) Navigator.pop(context);
    return false;
  }
}
