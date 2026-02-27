import 'package:check_app_version/src/data/repositories/version_repository_impl.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:check_app_version/src/domain/usecases/check_for_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Error handling', () {
    test('network error throws to caller', () async {
      final repo = VersionRepositoryImpl(
        loader: () async => throw Exception('timeout'),
      );

      final useCase = CheckForUpdate(repo);
      expect(
        () => useCase.call(
          platform: SupportedPlatform.android,
          installedVersion: '1.0.0',
          installedBuild: 1,
        ),
        throwsException,
      );
    });

    test('invalid JSON throws FormatException', () async {
      final repo = VersionRepositoryImpl(
        loader: () async => throw const FormatException('bad json'),
      );

      final useCase = CheckForUpdate(repo);
      expect(
        () => useCase.call(
          platform: SupportedPlatform.android,
          installedVersion: '1.0.0',
          installedBuild: 1,
        ),
        throwsFormatException,
      );
    });

    test(
      'missing platform returns platformUnsupported',
      () async {
        final repo = VersionRepositoryImpl(
          loader: () async => const {
            'platforms': {
              'ios': {
                'bundle_id': 'com.example.app',
                'min_required_version': '1.0.0',
                'min_required_build': 1,
              },
            },
          },
        );

        final useCase = CheckForUpdate(repo);
        final result = await useCase.call(
          platform: SupportedPlatform.android,
          installedVersion: '1.0.0',
          installedBuild: 1,
        );

        expect(result.shouldUpdate, isFalse);
        expect(
          result.reason,
          UpdateReason.platformUnsupported,
        );
      },
    );
  });

  group('UpdateDecision model', () {
    test('copyWith works correctly', () {
      const d = UpdateDecision(
        shouldUpdate: false,
        isForceUpdate: false,
        reason: UpdateReason.upToDate,
      );
      final copy = d.copyWith(shouldUpdate: true);
      expect(copy.shouldUpdate, isTrue);
      expect(copy.reason, UpdateReason.upToDate);
    });

    test('equality', () {
      const a = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: false,
        reason: UpdateReason.belowLatest,
      );
      const b = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: false,
        reason: UpdateReason.belowLatest,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('fromJson / toJson round trip', () {
      const original = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: true,
        reason: UpdateReason.belowMinimum,
        installedVersion: '1.0.0',
        installedBuild: 10,
        requiredMinVersion: '2.0.0',
        requiredMinBuild: 20,
        latestVersion: '2.1.0',
        latestBuild: 25,
        appStoreId: '123',
        productId: 'ABC',
      );
      final json = original.toJson();
      final restored = UpdateDecision.fromJson(json);
      expect(restored, equals(original));
    });

    test('toString contains key fields', () {
      const d = UpdateDecision.error(
        UpdateReason.networkError,
      );
      expect(d.toString(), contains('networkError'));
    });
  });
}
