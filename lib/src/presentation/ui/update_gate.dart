import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/material.dart';

/// Presentation style used by [UpdateGate] when an update is available.
enum UpdatePresentationStyle {
  /// Classic Material 3 [AlertDialog] (or adaptive Cupertino dialog).
  dialog,

  /// Swipeable Material 3 modal bottom sheet.
  modal,

  /// Full-screen blocking update page.
  page,

  /// Non-blocking animated top overlay banner inside a [Stack].
  overlay,
}

/// A declarative wrapper widget that automatically checks for app
/// updates on mount and (optionally) whenever the app resumes from
/// the background.
class UpdateGate extends StatefulWidget {
  /// Creates an [UpdateGate].
  const UpdateGate({
    required this.source,
    required this.onOpenStore,
    required this.child,
    this.policy = const UpdatePolicy(),
    this.style = UpdatePresentationStyle.dialog,
    this.checkOnResume = true,
    this.adaptive = false,
    this.snoozeDuration,
    this.showSkipVersion = false,
    this.title,
    this.message,
    this.updateLabel,
    this.laterLabel,
    this.skipLabel,
    this.onLater,
    this.onSkipVersion,
    this.onDecision,
    this.customChecker,
    super.key,
  });

  /// Version source: HTTP/HTTPS URL, asset path, raw JSON string,
  /// or `'store'` for zero-backend store lookup.
  final String source;

  /// Callback invoked when the user taps the update button.
  final VoidCallback onOpenStore;

  /// The main content widget wrapped by this gate.
  final Widget child;

  /// Policy controlling caching, platform override, and snooze behavior.
  final UpdatePolicy policy;

  /// Which UI layout to present when an update is available.
  final UpdatePresentationStyle style;

  /// Whether to re-run the version check when the app returns to the
  /// foreground (`AppLifecycleState.resumed`). Defaults to `true`.
  final bool checkOnResume;

  /// When `true` and [style] is [UpdatePresentationStyle.dialog],
  /// renders a native `CupertinoAlertDialog` on iOS and macOS.
  final bool adaptive;

  /// Optional snooze duration applied when the user taps "Later" or
  /// dismisses the overlay. Falls back to [UpdatePolicy.snoozeDuration].
  final Duration? snoozeDuration;

  /// Whether to display a "Skip this version" button on soft updates.
  final bool showSkipVersion;

  /// Optional custom title for the dialog, modal, or page.
  final String? title;

  /// Optional custom message body.
  final String? message;

  /// Optional custom label for the primary update button.
  final String? updateLabel;

  /// Optional custom label for the "Later" button.
  final String? laterLabel;

  /// Optional custom label for the "Skip this version" button.
  final String? skipLabel;

  /// Optional callback when the user taps "Later".
  final VoidCallback? onLater;

  /// Optional callback when the user taps "Skip this version".
  final VoidCallback? onSkipVersion;

  /// Optional listener invoked every time a version check completes.
  final ValueChanged<UpdateDecision>? onDecision;

  /// Optional custom check function (useful for testing or custom pipelines).
  final Future<UpdateDecision> Function()? customChecker;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> with WidgetsBindingObserver {
  UpdateDecision? _overlayDecision;
  bool _isPromptActive = false;

  Duration? get _effectiveSnooze =>
      widget.snoozeDuration ?? widget.policy.snoozeDuration;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateVersion();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.checkOnResume) {
      _evaluateVersion();
    }
  }

  Future<void> _evaluateVersion() async {
    if (!mounted || _isPromptActive) return;

    final decision = widget.customChecker != null
        ? await widget.customChecker!()
        : await CheckAppVersion.get(widget.source, policy: widget.policy);

    if (!mounted) return;
    widget.onDecision?.call(decision);

    if (!decision.shouldUpdate) {
      if (_overlayDecision != null) {
        setState(() => _overlayDecision = null);
      }
      return;
    }

    if (widget.style == UpdatePresentationStyle.overlay) {
      setState(() => _overlayDecision = decision);
      return;
    }

    _isPromptActive = true;
    try {
      switch (widget.style) {
        case UpdatePresentationStyle.dialog:
          await CheckAppVersion.showUpdateDialog(
            context,
            decision: decision,
            onOpenStore: widget.onOpenStore,
            onLater: widget.onLater,
            title: widget.title ?? 'Update Available',
            message: widget.message,
            updateLabel: widget.updateLabel ?? 'Update',
            laterLabel: widget.laterLabel ?? 'Later',
            adaptive: widget.adaptive,
            snoozeDuration: _effectiveSnooze,
            showSkipVersion: widget.showSkipVersion,
            skipLabel: widget.skipLabel ?? 'Skip this version',
            onSkipVersion: widget.onSkipVersion,
          );
        case UpdatePresentationStyle.modal:
          await CheckAppVersion.showUpdateModal(
            context,
            decision: decision,
            onOpenStore: widget.onOpenStore,
            onLater: widget.onLater,
            title: widget.title ?? 'Update Required',
            message: widget.message,
            updateLabel: widget.updateLabel ?? 'Update Now',
            laterLabel: widget.laterLabel ?? 'Later',
            snoozeDuration: _effectiveSnooze,
            showSkipVersion: widget.showSkipVersion,
            skipLabel: widget.skipLabel ?? 'Skip this version',
            onSkipVersion: widget.onSkipVersion,
          );
        case UpdatePresentationStyle.page:
          await CheckAppVersion.showUpdatePage<void>(
            context,
            decision: decision,
            onOpenStore: widget.onOpenStore,
            title: widget.title ?? 'Update Required',
            message: widget.message,
            updateLabel: widget.updateLabel ?? 'Update Now',
          );
        case UpdatePresentationStyle.overlay:
          break;
      }
    } finally {
      _isPromptActive = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayDecision = _overlayDecision;
    if (widget.style != UpdatePresentationStyle.overlay ||
        overlayDecision == null ||
        !overlayDecision.shouldUpdate) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: UpdateOverlay(
            decision: overlayDecision,
            onOpenStore: widget.onOpenStore,
            message: widget.message,
            updateLabel: widget.updateLabel ?? 'Update',
            snoozeDuration: _effectiveSnooze,
            onDismiss: () {
              if (mounted) {
                setState(() => _overlayDecision = null);
              }
              widget.onLater?.call();
            },
          ),
        ),
      ],
    );
  }
}
