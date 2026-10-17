import 'package:check_app_version/src/domain/entities/update_decision.dart';

/// Manages "Remind me later" (snooze) and "Skip this version" state
/// for non-mandatory updates.
///
/// Mandatory updates (`decision.isForceUpdate == true`) are never
/// suppressed by snooze or skip rules.
class SnoozeManager {
  /// Global shared instance used by [CheckAppVersion] and UI helpers.
  static final SnoozeManager instance = SnoozeManager();

  DateTime? _snoozedUntil;
  final Set<String> _skippedVersions = <String>{};

  /// The timestamp until which soft updates are snoozed, if any.
  DateTime? get snoozedUntil => _snoozedUntil;

  /// Unmodifiable view of versions explicitly skipped by the user.
  Set<String> get skippedVersions => Set.unmodifiable(_skippedVersions);

  /// Whether soft updates are currently snoozed.
  bool get isSnoozed {
    final until = _snoozedUntil;
    if (until == null) return false;
    if (DateTime.now().isBefore(until)) return true;
    _snoozedUntil = null;
    return false;
  }

  /// Snoozes soft update notifications for the given [duration].
  void snooze(Duration duration) {
    _snoozedUntil = DateTime.now().add(duration);
  }

  /// Marks a specific [version] (e.g. `"1.6.0"`) as skipped so soft
  /// update prompts won't trigger for that version again.
  void skipVersion(String version) {
    if (version.trim().isNotEmpty) {
      _skippedVersions.add(version.trim());
    }
  }

  /// Returns `true` if [version] has been explicitly skipped.
  bool isVersionSkipped(String version) =>
      _skippedVersions.contains(version.trim());

  /// Clears both active snooze timers and all skipped versions.
  void clear() {
    _snoozedUntil = null;
    _skippedVersions.clear();
  }

  /// Evaluates [decision] against current snooze and skipped-version
  /// state.
  ///
  /// If [decision] is a soft update (`shouldUpdate && !isForceUpdate`),
  /// returns a modified [UpdateDecision] with `shouldUpdate: false`
  /// and [UpdateReason.snoozed] or [UpdateReason.skippedVersion] when
  /// applicable.
  UpdateDecision apply(UpdateDecision decision) {
    if (!decision.shouldUpdate || decision.isForceUpdate) {
      return decision;
    }

    final targetVersion = decision.latestVersion?.trim();
    if (targetVersion != null &&
        targetVersion.isNotEmpty &&
        isVersionSkipped(targetVersion)) {
      return decision.copyWith(
        shouldUpdate: false,
        reason: UpdateReason.skippedVersion,
      );
    }

    if (isSnoozed) {
      return decision.copyWith(
        shouldUpdate: false,
        reason: UpdateReason.snoozed,
      );
    }

    return decision;
  }
}
