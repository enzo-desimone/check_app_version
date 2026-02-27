import 'package:check_app_version/src/domain/entities/platform_version_config.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:check_app_version/src/domain/services/version_comparator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VersionComparator.compare', () {
    PlatformVersionConfig config({
      String minVersion = '1.5.0',
      int minBuild = 36,
      String? latestVersion = '1.6.0',
      int? latestBuild = 40,
      bool forceUpdate = false,
    }) {
      return PlatformVersionConfig(
        bundleId: 'com.example.app',
        minRequiredVersion: minVersion,
        minRequiredBuild: minBuild,
        latestVersion: latestVersion,
        latestBuild: latestBuild,
        forceUpdate: forceUpdate,
      );
    }

    test('up to date when equal to latest', () {
      final result = VersionComparator.compare(
        config: config(),
        installedVersion: '1.6.0',
        installedBuild: 40,
      );
      expect(result.shouldUpdate, isFalse);
      expect(result.reason, UpdateReason.upToDate);
    });

    test('up to date when above latest', () {
      final result = VersionComparator.compare(
        config: config(),
        installedVersion: '1.7.0',
        installedBuild: 42,
      );
      expect(result.shouldUpdate, isFalse);
      expect(result.reason, UpdateReason.upToDate);
    });

    test('below minimum by build number', () {
      final result = VersionComparator.compare(
        config: config(),
        installedVersion: '1.5.0',
        installedBuild: 30,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
      expect(result.isForceUpdate, isFalse);
    });

    test('below minimum by build with force update', () {
      final result = VersionComparator.compare(
        config: config(forceUpdate: true),
        installedVersion: '1.5.0',
        installedBuild: 30,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
      expect(result.isForceUpdate, isTrue);
    });

    test('below minimum by semver', () {
      final result = VersionComparator.compare(
        config: config(),
        installedVersion: '1.4.0',
        installedBuild: 36,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
    });

    test('below latest (soft update) by build', () {
      final result = VersionComparator.compare(
        config: config(),
        installedVersion: '1.5.0',
        installedBuild: 38,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowLatest);
      expect(result.isForceUpdate, isFalse);
    });

    test('below latest by version', () {
      final result = VersionComparator.compare(
        config: config(latestBuild: null, latestVersion: '2.0.0'),
        installedVersion: '1.5.0',
        installedBuild: 36,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowLatest);
    });

    test('build takes precedence over version for minimum', () {
      // Version is fine but build is below minimum.
      final result = VersionComparator.compare(
        config: config(minVersion: '1.0.0', minBuild: 50),
        installedVersion: '1.5.0',
        installedBuild: 40,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
    });

    test('zero build number is handled', () {
      final result = VersionComparator.compare(
        config: config(minBuild: 0, latestBuild: 0),
        installedVersion: '1.6.0',
        installedBuild: 0,
      );
      expect(result.shouldUpdate, isFalse);
      expect(result.reason, UpdateReason.upToDate);
    });

    test('no latest fields means no soft update', () {
      final result = VersionComparator.compare(
        config: config(latestVersion: null, latestBuild: null),
        installedVersion: '1.5.0',
        installedBuild: 36,
      );
      expect(result.shouldUpdate, isFalse);
      expect(result.reason, UpdateReason.upToDate);
    });

    test('multi-segment version comparison', () {
      final result = VersionComparator.compare(
        config: config(minVersion: '1.5.1'),
        installedVersion: '1.5.0',
        installedBuild: 36,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
    });

    test('four-segment version strings', () {
      final result = VersionComparator.compare(
        config: config(
          minVersion: '1.0.0.1',
          minBuild: 0,
          latestVersion: null,
          latestBuild: null,
        ),
        installedVersion: '1.0.0.0',
        installedBuild: 0,
      );
      expect(result.shouldUpdate, isTrue);
      expect(result.reason, UpdateReason.belowMinimum);
    });

    test('preserves store identifiers', () {
      const cfg = PlatformVersionConfig(
        bundleId: 'com.example.app',
        appStoreId: '123456',
        productId: 'ABC',
        minRequiredVersion: '1.0.0',
        minRequiredBuild: 1,
      );
      final result = VersionComparator.compare(
        config: cfg,
        installedVersion: '1.0.0',
        installedBuild: 1,
      );
      expect(result.appStoreId, '123456');
      expect(result.productId, 'ABC');
    });
  });
}
