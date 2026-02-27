import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter/foundation.dart';

/// The state of a version check operation.
sealed class UpdateState {
  const UpdateState();
}

/// No check has been performed yet.
class UpdateStateIdle extends UpdateState {
  const UpdateStateIdle();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UpdateStateIdle;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UpdateStateIdle()';
}

/// A check is currently in progress.
class UpdateStateLoading extends UpdateState {
  const UpdateStateLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UpdateStateLoading;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'UpdateStateLoading()';
}

/// A check completed with a result.
class UpdateStateLoaded extends UpdateState {
  /// Creates an [UpdateStateLoaded].
  const UpdateStateLoaded(this.decision);

  /// The result of the check.
  final UpdateDecision decision;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateStateLoaded && decision == other.decision;

  @override
  int get hashCode => decision.hashCode;

  @override
  String toString() => 'UpdateStateLoaded(decision: $decision)';
}

/// A check failed with an error.
class UpdateStateError extends UpdateState {
  /// Creates an [UpdateStateError].
  const UpdateStateError(this.error, [this.stackTrace]);

  /// The error object.
  final Object error;

  /// Optional stack trace.
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateStateError && error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'UpdateStateError(error: $error)';
}

/// Controller that wraps version-check logic in a
/// [ValueNotifier]-based state machine.
///
/// Usage:
/// ```dart
/// final controller = VersionCheckController(
///   checkCallback: () => VersionCheck.file(...),
/// );
/// controller.check();
/// ```
class VersionCheckController extends ValueNotifier<UpdateState> {
  /// Creates a [VersionCheckController].
  ///
  /// [checkCallback] is the function that performs the
  /// actual version check and returns an [UpdateDecision].
  VersionCheckController({
    required Future<UpdateDecision> Function() checkCallback,
  })  : _checkCallback = checkCallback,
        super(const UpdateStateIdle());

  final Future<UpdateDecision> Function() _checkCallback;

  /// Triggers a version check.
  Future<void> check() async {
    value = const UpdateStateLoading();
    try {
      final decision = await _checkCallback();
      value = UpdateStateLoaded(decision);
    } on Exception catch (e, s) {
      value = UpdateStateError(e, s);
    }
  }
}
