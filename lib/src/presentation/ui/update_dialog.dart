import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/material.dart';

/// Shows a themed [AlertDialog] informing the user about
/// an available update.
///
/// Uses `Theme.of(context)` for styling.
/// - [decision] — the result of the version check.
/// - [onOpenStore] — callback to open the store page.
/// - [onLater] — callback when user taps "Later"
///   (only shown if not a force update).
/// - [title] — dialog title override.
/// - [message] — dialog message override.
/// - [updateLabel] — text for the update button.
/// - [laterLabel] — text for the later button.
Future<void> showUpdateDialog(
  BuildContext context, {
  required UpdateDecision decision,
  required VoidCallback onOpenStore,
  VoidCallback? onLater,
  String title = 'Update Available',
  String? message,
  String updateLabel = 'Update',
  String laterLabel = 'Later',
}) {
  final theme = Theme.of(context);
  final body = message ??
      (decision.isForceUpdate
          ? 'A required update (v${decision.requiredMinVersion}) '
              'is available. Please update to continue.'
          : 'A new version'
              '${decision.latestVersion != null ? " (v${decision.latestVersion})" : ""} '
              'is available.');

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
            if (!decision.isForceUpdate)
              TextButton(
                onPressed: onLater ?? () => Navigator.of(ctx).pop(),
                child: Text(laterLabel),
              ),
            FilledButton(
              onPressed: onOpenStore,
              child: Text(updateLabel),
            ),
          ],
        ),
      );
    },
  );
}
