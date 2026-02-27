import 'package:check_app_version/src/domain/entities/platform_version_config.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/version_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const fullJson = {
    'app_id': 'com.example.myapp',
    'config_version': 1,
    'platforms': {
      'android': {
        'bundle_id': 'com.example.myapp',
        'min_required_version': '1.5.0',
        'min_required_build': 36,
        'latest_version': '1.6.0',
        'latest_build': 40,
        'force_update': false,
      },
      'ios': {
        'bundle_id': 'com.example.myapp',
        'app_store_id': '1234567890',
        'min_required_version': '1.5.0',
        'min_required_build': 36,
        'latest_version': '1.6.0',
        'latest_build': 40,
        'force_update': false,
      },
    },
  };

  group('VersionInfo.fromJson', () {
    test('parses full valid JSON', () {
      final info = VersionInfo.fromJson(fullJson);

      expect(info.appId, 'com.example.myapp');
      expect(info.configVersion, 1);
      expect(info.platforms.length, 2);
      expect(
        info.platforms.containsKey(SupportedPlatform.android),
        isTrue,
      );
      expect(
        info.platforms.containsKey(SupportedPlatform.ios),
        isTrue,
      );
    });

    test('android platform has correct fields', () {
      final info = VersionInfo.fromJson(fullJson);
      final android = info.platforms[SupportedPlatform.android]!;

      expect(android.bundleId, 'com.example.myapp');
      expect(android.minRequiredVersion, '1.5.0');
      expect(android.minRequiredBuild, 36);
      expect(android.latestVersion, '1.6.0');
      expect(android.latestBuild, 40);
      expect(android.forceUpdate, isFalse);
      expect(android.appStoreId, isNull);
    });

    test('ios platform preserves app_store_id', () {
      final info = VersionInfo.fromJson(fullJson);
      final ios = info.platforms[SupportedPlatform.ios]!;

      expect(ios.appStoreId, '1234567890');
    });

    test('missing optional fields default gracefully', () {
      const json = {
        'platforms': {
          'linux': {
            'bundle_id': 'com.example.linux',
            'min_required_version': '1.0.0',
            'min_required_build': 1,
          },
        },
      };

      final info = VersionInfo.fromJson(json);
      expect(info.appId, isNull);
      expect(info.configVersion, isNull);
      final linux = info.platforms[SupportedPlatform.linux]!;
      expect(linux.latestVersion, isNull);
      expect(linux.latestBuild, isNull);
      expect(linux.forceUpdate, isFalse);
    });

    test('empty platforms map is valid', () {
      final info = VersionInfo.fromJson(
        const {'app_id': 'test'},
      );
      expect(info.platforms, isEmpty);
    });

    test('unknown platform keys are silently ignored', () {
      const json = {
        'platforms': {
          'fuchsia': {
            'bundle_id': 'x',
            'min_required_version': '1.0.0',
            'min_required_build': 1,
          },
          'android': {
            'bundle_id': 'y',
            'min_required_version': '2.0.0',
            'min_required_build': 2,
          },
        },
      };
      final info = VersionInfo.fromJson(json);
      expect(info.platforms.length, 1);
      expect(
        info.platforms.containsKey(SupportedPlatform.android),
        isTrue,
      );
    });
  });

  group('VersionInfo.toJson', () {
    test('round-trips through fromJson/toJson', () {
      final original = VersionInfo.fromJson(fullJson);
      final serialized = original.toJson();
      final restored = VersionInfo.fromJson(serialized);

      expect(restored.appId, original.appId);
      expect(restored.configVersion, original.configVersion);
      expect(
        restored.platforms.length,
        original.platforms.length,
      );
      expect(
        restored.platforms[SupportedPlatform.android],
        original.platforms[SupportedPlatform.android],
      );
    });
  });

  group('PlatformVersionConfig', () {
    test('fromJson parses all fields', () {
      final config = PlatformVersionConfig.fromJson(const {
        'bundle_id': 'com.example.app',
        'app_store_id': '999',
        'product_id': 'XYZ',
        'min_required_version': '2.0.0',
        'min_required_build': 50,
        'latest_version': '2.1.0',
        'latest_build': 55,
        'force_update': true,
      });

      expect(config.bundleId, 'com.example.app');
      expect(config.appStoreId, '999');
      expect(config.productId, 'XYZ');
      expect(config.minRequiredVersion, '2.0.0');
      expect(config.minRequiredBuild, 50);
      expect(config.latestVersion, '2.1.0');
      expect(config.latestBuild, 55);
      expect(config.forceUpdate, isTrue);
    });

    test('copyWith creates independent copy', () {
      const config = PlatformVersionConfig(
        bundleId: 'a',
        minRequiredVersion: '1.0.0',
        minRequiredBuild: 1,
      );
      final copy = config.copyWith(bundleId: 'b');
      expect(copy.bundleId, 'b');
      expect(config.bundleId, 'a');
    });

    test('equality works', () {
      const a = PlatformVersionConfig(
        bundleId: 'x',
        minRequiredVersion: '1.0.0',
        minRequiredBuild: 1,
      );
      const b = PlatformVersionConfig(
        bundleId: 'x',
        minRequiredVersion: '1.0.0',
        minRequiredBuild: 1,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });
  });

  group('SupportedPlatform', () {
    test('tryParse returns correct enum', () {
      expect(
        SupportedPlatform.tryParse('android'),
        SupportedPlatform.android,
      );
      expect(
        SupportedPlatform.tryParse('iOS'),
        SupportedPlatform.ios,
      );
      expect(
        SupportedPlatform.tryParse('WINDOWS'),
        SupportedPlatform.windows,
      );
    });

    test('tryParse returns null for unknown', () {
      expect(SupportedPlatform.tryParse('fuchsia'), isNull);
    });
  });
}
