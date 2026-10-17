import 'dart:convert';

import 'package:check_app_version/check_app_version.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    CheckAppVersion.clearCache();
    CheckAppVersion.clearSnooze();
  });

  group('StoreDataSource - Apple App Store (iOS & macOS)', () {
    test('parses iTunes Lookup API response by bundleId', () async {
      Uri? requestedUri;
      final mockClient = MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          json.encode({
            'resultCount': 1,
            'results': [
              {
                'version': '2.4.1',
                'trackId': 987654321,
                'bundleId': 'com.example.iosapp',
              },
            ],
          }),
          200,
        );
      });

      final source = StoreDataSource(
        platform: SupportedPlatform.ios,
        bundleId: 'com.example.iosapp',
        countryCode: 'it',
        httpClient: mockClient,
      );

      final result = await source.load();
      expect(requestedUri.toString(), contains('bundleId=com.example.iosapp'));
      expect(requestedUri.toString(), contains('country=it'));

      final platforms = result['platforms'] as Map<String, dynamic>;
      final ios = platforms['ios'] as Map<String, dynamic>;
      expect(ios['latest_version'], '2.4.1');
      expect(ios['min_required_version'], '0.0.0');
      expect(ios['app_store_id'], '987654321');
      expect(ios['force_update'], isFalse);
    });

    test('uses appStoreId and macSoftware entity on macOS', () async {
      Uri? requestedUri;
      final mockClient = MockClient((request) async {
        requestedUri = request.url;
        return http.Response(
          json.encode({
            'resultCount': 1,
            'results': [
              {'version': '3.0.0', 'trackId': 112233},
            ],
          }),
          200,
        );
      });

      final source = StoreDataSource(
        platform: SupportedPlatform.macos,
        bundleId: 'com.example.macapp',
        appStoreId: '112233',
        forceUpdate: true,
        httpClient: mockClient,
      );

      final result = await source.load();
      expect(requestedUri.toString(), contains('id=112233'));
      expect(requestedUri.toString(), contains('entity=macSoftware'));

      final platforms = result['platforms'] as Map<String, dynamic>;
      final macos = platforms['macos'] as Map<String, dynamic>;
      expect(macos['latest_version'], '3.0.0');
      expect(macos['min_required_version'], '3.0.0');
      expect(macos['force_update'], isTrue);
    });

    test(
      'returns empty platforms map when app is not found on store',
      () async {
        final mockClient = MockClient((_) async {
          return http.Response(
            json.encode({'resultCount': 0, 'results': <dynamic>[]}),
            200,
          );
        });

        final source = StoreDataSource(
          platform: SupportedPlatform.ios,
          bundleId: 'com.unknown.app',
          httpClient: mockClient,
        );

        final result = await source.load();
        final platforms = result['platforms'] as Map<String, dynamic>;
        expect(platforms, isEmpty);
      },
    );
  });

  group('StoreDataSource - Google Play Store (Android)', () {
    test(
      'extracts version from Play Store AF_initDataCallback script',
      () async {
        const sampleHtml = '''
        <html><body>
        <script>AF_initDataCallback({key: 'ds:5', data:[[["1.8.4"]]]});</script>
        </body></html>
      ''';

        final mockClient = MockClient(
          (_) async => http.Response(sampleHtml, 200),
        );
        final source = StoreDataSource(
          platform: SupportedPlatform.android,
          bundleId: 'com.example.android',
          httpClient: mockClient,
        );

        final result = await source.load();
        final platforms = result['platforms'] as Map<String, dynamic>;
        final android = platforms['android'] as Map<String, dynamic>;
        expect(android['latest_version'], '1.8.4');
        expect(android['force_update'], isFalse);
      },
    );

    test('extracts version from JSON-LD softwareVersion attribute', () {
      const html = '{"@type":"MobileApplication","softwareVersion":"4.2.10"}';
      expect(StoreDataSource.extractPlayStoreVersion(html), '4.2.10');
    });

    test(
      'throws FormatException when Play Store HTML has no version',
      () async {
        final mockClient = MockClient(
          (_) async => http.Response('<html>No version here</html>', 200),
        );
        final source = StoreDataSource(
          platform: SupportedPlatform.android,
          bundleId: 'com.example.android',
          httpClient: mockClient,
        );

        expect(source.load, throwsFormatException);
      },
    );
  });

  group('CheckAppVersion.fromStores end-to-end', () {
    test('evaluates store version against installed PackageInfo', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      PackageInfo.setMockInitialValues(
        appName: 'Demo',
        packageName: 'com.example.demo',
        version: '1.2.0',
        buildNumber: '10',
        buildSignature: '',
      );

      final mockClient = MockClient((_) async {
        return http.Response(
          json.encode({
            'resultCount': 1,
            'results': [
              {'version': '1.5.0', 'trackId': 555666},
            ],
          }),
          200,
        );
      });

      final decision = await CheckAppVersion.fromStores(
        policy: const UpdatePolicy(
          platform: SupportedPlatform.ios,
          forceRefresh: true,
        ),
        httpClient: mockClient,
      );

      expect(decision.shouldUpdate, isTrue);
      expect(decision.isForceUpdate, isFalse);
      expect(decision.reason, UpdateReason.belowLatest);
      expect(decision.installedVersion, '1.2.0');
      expect(decision.latestVersion, '1.5.0');
      expect(decision.appStoreId, '555666');
    });
  });
}
