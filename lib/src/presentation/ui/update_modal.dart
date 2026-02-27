import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/material.dart';

/// Shows a modal bottom sheet for update prompts.
///
/// Non-dismissible when [decision.isForceUpdate] is true.
Future<void> showUpdateModal(
  BuildContext context, {
  required UpdateDecision decision,
  required VoidCallback onOpenStore,
  VoidCallback? onLater,
  String title = 'Update Required',
  String? message,
  String updateLabel = 'Update Now',
  String laterLabel = 'Later',
}) {
  final theme = Theme.of(context);
  final body = message ??
      (decision.isForceUpdate
          ? 'Version ${decision.requiredMinVersion} or later '
              'is required. Please update to continue '
              'using this app.'
          : 'A new version'
              '${decision.latestVersion != null ? " (v${decision.latestVersion})" : ""} '
              'is available. Would you like to update?');

  return showModalBottomSheet<void>(
    context: context,
    isDismissible: !decision.isForceUpdate,
    enableDrag: !decision.isForceUpdate,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (ctx) {
      return PopScope(
        canPop: !decision.isForceUpdate,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              24,
              24,
              32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Icon(
                  Icons.system_update,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onOpenStore,
                    child: Text(updateLabel),
                  ),
                ),
                if (!decision.isForceUpdate) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: onLater ?? () => Navigator.of(ctx).pop(),
                      child: Text(laterLabel),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}
