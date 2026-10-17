import 'dart:convert';

import 'package:check_app_version/check_app_version.dart';
import 'package:check_app_version/src/data/cache/snooze_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    CheckAppVersion.clearCache();
    CheckAppVersion.clearSnooze();
  });

  group('SnoozeManager unit tests', () {
    test('suppresses soft update when snoozed', () {
      final manager = SnoozeManager();
      manager.snooze(const Duration(hours: 2));

      const softDecision = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: false,
        reason: UpdateReason.belowLatest,
        latestVersion: '1.5.0',
      );

      final applied = manager.apply(softDecision);
      expect(applied.shouldUpdate, isFalse);
      expect(applied.reason, UpdateReason.snoozed);
    });

    test('expires snooze when duration has elapsed', () async {
      final manager = SnoozeManager();
      manager.snooze(const Duration(milliseconds: 20));
      expect(manager.isSnoozed, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(manager.isSnoozed, isFalse);
    });

    test('suppresses soft update when target version is skipped', () {
      final manager = SnoozeManager();
      manager.skipVersion('1.5.0');

      const decision150 = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: false,
        reason: UpdateReason.belowLatest,
        latestVersion: '1.5.0',
      );
      const decision160 = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: false,
        reason: UpdateReason.belowLatest,
        latestVersion: '1.6.0',
      );

      final applied150 = manager.apply(decision150);
      expect(applied150.shouldUpdate, isFalse);
      expect(applied150.reason, UpdateReason.skippedVersion);

      // Newer version 1.6.0 is NOT skipped!
      final applied160 = manager.apply(decision160);
      expect(applied160.shouldUpdate, isTrue);
      expect(applied160.reason, UpdateReason.belowLatest);
    });

    test('never suppresses mandatory (force) updates', () {
      final manager = SnoozeManager();
      manager.snooze(const Duration(days: 7));
      manager.skipVersion('2.0.0');

      const forceDecision = UpdateDecision(
        shouldUpdate: true,
        isForceUpdate: true,
        reason: UpdateReason.belowMinimum,
        requiredMinVersion: '2.0.0',
        latestVersion: '2.0.0',
      );

      final applied = manager.apply(forceDecision);
      expect(applied.shouldUpdate, isTrue);
      expect(applied.isForceUpdate, isTrue);
      expect(applied.reason, UpdateReason.belowMinimum);
    });
  });

  group('CheckAppVersion snooze & skip integration', () {
    test('CheckAppVersion.get respects snooze and skipVersion', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      PackageInfo.setMockInitialValues(
        appName: 'App',
        packageName: 'com.example.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      final rawJson = json.encode({
        'platforms': {
          'android': {
            'package_name': 'com.example.app',
            'min_required_version': '1.0.0',
            'min_required_build': 1,
            'latest_version': '1.2.0',
            'latest_build': 5,
            'force_update': false,
          },
        },
      });

      const policy = UpdatePolicy(platform: SupportedPlatform.android);

      // 1. Initial check prompts soft update
      final first = await CheckAppVersion.get(rawJson, policy: policy);
      expect(first.shouldUpdate, isTrue);
      expect(first.reason, UpdateReason.belowLatest);

      // 2. Snooze for 1 day -> even cached decision is suppressed
      CheckAppVersion.snooze(const Duration(days: 1));
      expect(CheckAppVersion.isSnoozed, isTrue);

      final second = await CheckAppVersion.get(rawJson, policy: policy);
      expect(second.shouldUpdate, isFalse);
      expect(second.reason, UpdateReason.snoozed);

      // 3. Bypass snooze via UpdatePolicy(respectSnooze: false)
      final bypassed = await CheckAppVersion.get(
        rawJson,
        policy: policy.copyWith(respectSnooze: false),
      );
      expect(bypassed.shouldUpdate, isTrue);

      // 4. Clear snooze and skip 1.2.0 specifically
      CheckAppVersion.clearSnooze();
      CheckAppVersion.skipVersion('1.2.0');
      expect(CheckAppVersion.isVersionSkipped('1.2.0'), isTrue);

      final skipped = await CheckAppVersion.get(rawJson, policy: policy);
      expect(skipped.shouldUpdate, isFalse);
      expect(skipped.reason, UpdateReason.skippedVersion);
    });
  });
}
