import 'package:check_app_version/src/data/cache/snooze_manager.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a themed [AlertDialog] (or [CupertinoAlertDialog] when
/// [adaptive] is `true` on iOS/macOS) informing the user about an
/// available update.
///
/// - [decision] — the result of the version check.
/// - [onOpenStore] — callback to open the store page.
/// - [onLater] — callback when user taps "Later"
///   (only shown if not a force update).
/// - [title] — dialog title override.
/// - [message] — dialog message override.
/// - [updateLabel] — text for the update button.
/// - [laterLabel] — text for the later button.
/// - [popAfterPressed] — automatically dismisses dialog on update tap.
/// - [adaptive] — renders a native `CupertinoAlertDialog` on iOS/macOS.
/// - [snoozeDuration] — automatically snoozes soft updates when "Later" is tapped.
/// - [showSkipVersion] — shows a "Skip this version" action for soft updates.
/// - [skipLabel] — text for the skip version button.
/// - [onSkipVersion] — optional callback when the user skips the version.
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateDecision decision,
  required VoidCallback onOpenStore,
  VoidCallback? onLater,
  String title = 'Update Available',
  String? message,
  String updateLabel = 'Update',
  String laterLabel = 'Later',
  bool popAfterPressed = true,
  bool adaptive = false,
  Duration? snoozeDuration,
  bool showSkipVersion = false,
  String skipLabel = 'Skip this version',
  VoidCallback? onSkipVersion,
}) {
  final theme = Theme.of(context);
  final body =
      message ??
      (decision.isForceUpdate
          ? 'A required update (v${decision.requiredMinVersion}) '
                'is available. Please update to continue.'
          : 'A new version'
                '${decision.latestVersion != null ? " (v${decision.latestVersion})" : ""} '
                'is available.');

  final canSkip =
      showSkipVersion &&
      !decision.isForceUpdate &&
      (decision.latestVersion?.trim().isNotEmpty ?? false);

  final useCupertino =
      adaptive &&
      (theme.platform == TargetPlatform.iOS ||
          theme.platform == TargetPlatform.macOS);

  void handleLater(BuildContext ctx) {
    if (snoozeDuration != null) {
      SnoozeManager.instance.snooze(snoozeDuration);
    }
    if (onLater != null) {
      onLater();
    } else {
      Navigator.of(ctx).pop();
    }
  }

  void handleSkip(BuildContext ctx) {
    final latest = decision.latestVersion?.trim();
    if (latest != null && latest.isNotEmpty) {
      SnoozeManager.instance.skipVersion(latest);
    }
    if (popAfterPressed) {
      Navigator.of(ctx).pop();
    }
    onSkipVersion?.call();
  }

  void handleUpdate(BuildContext ctx) {
    if (popAfterPressed) {
      Navigator.of(ctx).pop();
    }
    onOpenStore();
  }

  if (useCupertino) {
    return showCupertinoDialog<void>(
      context: context,
      barrierDismissible: !decision.isForceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !decision.isForceUpdate,
          child: CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(body),
            ),
            actions: [
              if (canSkip)
                CupertinoDialogAction(
                  onPressed: () => handleSkip(ctx),
                  child: Text(skipLabel),
                ),
              if (!decision.isForceUpdate)
                CupertinoDialogAction(
                  onPressed: () => handleLater(ctx),
                  child: Text(laterLabel),
                ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => handleUpdate(ctx),
                child: Text(updateLabel),
              ),
            ],
          ),
        );
      },
    );
  }

  return showDialog<void>(
    context: context,
    barrierDismissible: !decision.isForceUpdate,
    builder: (ctx) {
      return PopScope(
        canPop: !decision.isForceUpdate,
        child: AlertDialog(
          title: Text(title, style: theme.textTheme.titleLarge),
          content: Text(body, style: theme.textTheme.bodyMedium),
          actions: [
            if (canSkip)
              TextButton(
                onPressed: () => handleSkip(ctx),
                child: Text(skipLabel),
              ),
            if (!decision.isForceUpdate)
              TextButton(
                onPressed: () => handleLater(ctx),
                child: Text(laterLabel),
              ),
            FilledButton(
              onPressed: () => handleUpdate(ctx),
              child: Text(updateLabel),
            ),
          ],
        ),
      );
    },
  );
}
