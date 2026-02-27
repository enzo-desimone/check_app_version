import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/material.dart';

/// A full-screen page shown when a mandatory update is
/// required.
///
/// Blocks navigation and forces the user to update.
class UpdatePage extends StatelessWidget {
  /// Creates an [UpdatePage].
  const UpdatePage({
    required this.decision,
    required this.onOpenStore,
    this.title = 'Update Required',
    this.message,
    this.updateLabel = 'Update Now',
    this.icon = Icons.system_update,
    super.key,
  });

  /// The update decision result.
  final UpdateDecision decision;

  /// Invoked when the user taps the update button.
  final VoidCallback onOpenStore;

  /// Page title.
  final String title;

  /// Optional body message.
  final String? message;

  /// Label for the update button.
  final String updateLabel;

  /// Icon displayed above the title.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = message ??
        'Your current version '
            '(${decision.installedVersion}) is no longer '
            'supported.\n\n'
            'Please update to version '
            '${decision.requiredMinVersion} or later to '
            'continue using this app.';

    return PopScope(
      canPop: !decision.isForceUpdate,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 80,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    body,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: onOpenStore,
                      child: Text(updateLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
