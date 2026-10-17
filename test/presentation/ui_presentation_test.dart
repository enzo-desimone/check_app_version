import 'package:check_app_version/check_app_version.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    CheckAppVersion.clearCache();
    CheckAppVersion.clearSnooze();
  });

  const softDecision = UpdateDecision(
    shouldUpdate: true,
    isForceUpdate: false,
    reason: UpdateReason.belowLatest,
    installedVersion: '1.0.0',
    installedBuild: 1,
    requiredMinVersion: '1.0.0',
    requiredMinBuild: 1,
    latestVersion: '1.4.0',
    latestBuild: 4,
  );

  group('Adaptive Dialogs (Cupertino vs Material 3)', () {
    testWidgets('renders CupertinoAlertDialog when adaptive: true on iOS', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  CheckAppVersion.showUpdateDialog(
                    context,
                    decision: softDecision,
                    adaptive: true,
                    showSkipVersion: true,
                    onOpenStore: () {},
                  );
                },
                child: const Text('Check'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Skip this version'), findsOneWidget);

      // Tap Skip this version
      await tester.tap(find.text('Skip this version'));
      await tester.pumpAndSettle();

      expect(CheckAppVersion.isVersionSkipped('1.4.0'), isTrue);
    });

    testWidgets('renders Material AlertDialog when adaptive: true on Android', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  CheckAppVersion.showUpdateDialog(
                    context,
                    decision: softDecision,
                    adaptive: true,
                    snoozeDuration: const Duration(days: 3),
                    onOpenStore: () {},
                  );
                },
                child: const Text('Check'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);

      // Tap Later -> triggers snooze
      await tester.tap(find.text('Later'));
      await tester.pumpAndSettle();

      expect(CheckAppVersion.isSnoozed, isTrue);
    });
  });

  group('UpdateGate declarative widget', () {
    testWidgets(
      'automatically shows dialog on mount and re-checks on app resume',
      (tester) async {
        var checkCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: UpdateGate(
              source: 'unused-when-customChecker-provided',
              style: UpdatePresentationStyle.dialog,
              checkOnResume: true,
              customChecker: () async {
                checkCount++;
                return softDecision;
              },
              onOpenStore: () {},
              child: const Scaffold(body: Text('Home Content')),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(checkCount, 1);
        expect(find.byType(AlertDialog), findsOneWidget);

        // Dismiss the dialog
        await tester.tap(find.text('Later'));
        await tester.pumpAndSettle();
        expect(find.byType(AlertDialog), findsNothing);

        // Simulate app returning from background to foreground
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(checkCount, 2);
        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );

    testWidgets('renders non-blocking UpdateOverlay when style is overlay', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UpdateGate(
            source: 'custom',
            style: UpdatePresentationStyle.overlay,
            snoozeDuration: const Duration(hours: 12),
            customChecker: () async => softDecision,
            onOpenStore: () {},
            child: const Scaffold(body: Text('Main App')),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(UpdateOverlay), findsOneWidget);
      expect(find.text('Main App'), findsOneWidget);

      // Dismiss overlay via close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.byType(UpdateOverlay), findsNothing);
      expect(CheckAppVersion.isSnoozed, isTrue);
    });
  });
}
