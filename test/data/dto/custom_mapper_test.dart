import 'package:check_app_version/src/domain/entities/platform_version_config.dart';
import 'package:check_app_version/src/domain/entities/supported_platform.dart';
import 'package:check_app_version/src/domain/entities/version_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Custom mapper', () {
    test('custom mapper receives raw JSON and returns domain entity', () {
      const rawJson = {
        'version': '2.0.0',
        'build': 50,
        'min_version': '1.5.0',
        'min_build': 30,
      };

      VersionInfo customMapper(Map<String, dynamic> json) {
        return VersionInfo(
          appId: 'custom_app',
          platforms: {
            SupportedPlatform.android: PlatformVersionConfig(
              bundleId: 'com.custom.app',
              minRequiredVersion: json['min_version'] as String,
              minRequiredBuild: json['min_build'] as int,
              latestVersion: json['version'] as String?,
              latestBuild: json['build'] as int?,
            ),
          },
        );
      }

      final info = customMapper(rawJson);
      expect(info.appId, 'custom_app');
      final android = info.platforms[SupportedPlatform.android]!;
      expect(android.minRequiredVersion, '1.5.0');
      expect(android.minRequiredBuild, 30);
      expect(android.latestVersion, '2.0.0');
      expect(android.latestBuild, 50);
    });

    test('custom mapper throwing returns error', () {
      VersionInfo throwingMapper(Map<String, dynamic> json) {
        throw const FormatException('bad data');
      }

      expect(
        () => throwingMapper(const {}),
        throwsA(isA<FormatException>()),
      );
    });

    test('custom mapper with completely different schema', () {
      const oddJson = {
        'data': {
          'minimum': '3.0.0',
          'minimum_code': 100,
        },
      };

      VersionInfo oddMapper(Map<String, dynamic> json) {
        final data = json['data'] as Map<String, dynamic>;
        return VersionInfo(
          platforms: {
            SupportedPlatform.ios: PlatformVersionConfig(
              bundleId: 'com.odd.app',
              minRequiredVersion: data['minimum'] as String,
              minRequiredBuild: data['minimum_code'] as int,
            ),
          },
        );
      }

      final info = oddMapper(oddJson);
      final ios = info.platforms[SupportedPlatform.ios]!;
      expect(ios.minRequiredVersion, '3.0.0');
      expect(ios.minRequiredBuild, 100);
    });
  });
}
