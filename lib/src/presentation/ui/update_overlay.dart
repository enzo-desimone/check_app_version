import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/material.dart';

/// A non-blocking overlay banner widget that notifies the
/// user about an available update.
///
/// Place this at the top of your widget tree (e.g. inside
/// a [Stack]) to show a dismissible banner.
class UpdateOverlay extends StatefulWidget {
  /// Creates an [UpdateOverlay].
  const UpdateOverlay({
    required this.decision,
    required this.onOpenStore,
    this.onDismiss,
    this.message,
    this.updateLabel = 'Update',
    super.key,
  });

  /// The update decision result.
  final UpdateDecision decision;

  /// Invoked when the user taps the update action.
  final VoidCallback onOpenStore;

  /// Invoked when the user dismisses the banner.
  final VoidCallback? onDismiss;

  /// Optional custom message.
  final String? message;

  /// Label for the update action.
  final String updateLabel;

  @override
  State<UpdateOverlay> createState() => _UpdateOverlayState();
}

class _UpdateOverlayState extends State<UpdateOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = widget.message ??
        'A new version is available'
            '${widget.decision.latestVersion != null ? " (v${widget.decision.latestVersion})" : ""}.';

    return SlideTransition(
      position: _slideAnimation,
      child: Material(
        elevation: 4,
        color: theme.colorScheme.primaryContainer,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onOpenStore,
                  child: Text(widget.updateLabel),
                ),
                if (!widget.decision.isForceUpdate)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _dismiss,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
