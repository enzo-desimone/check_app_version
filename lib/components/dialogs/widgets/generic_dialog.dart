part of '../app_version_dialog.dart';

class _GenericDialog extends StatelessWidget {
  const _GenericDialog({
    required this.onWillPop,
    required this.title,
    required this.updateButtonText,
    required this.laterButtonText,
    this.backgroundColor,
    this.dialogRadius = 20,
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
  final Color? backgroundColor;
  final double dialogRadius;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPopState(context);
      },
      child: AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        title: Text(
          title,
          style: TextStyle(color: titleColor ?? Colors.black),
        ),
        content: Text(
          body ?? 'A new version of the app is available ${CheckAppVersion().appFile.newAppVersion!}',
          style: TextStyle(color: bodyColor ?? Colors.black54),
        ),
        actions: [
          if (laterButtonEnable ?? true)
            TextButton(
              onPressed: onPressDecline ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                foregroundColor: updateButtonColor ?? Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(updateButtonRadius ?? 10),
                ),
              ),
              child: Text(
                laterButtonText,
                style: TextStyle(color: laterButtonColor ?? Colors.black),
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
