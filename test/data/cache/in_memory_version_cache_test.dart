import 'package:check_app_version/src/data/cache/in_memory_version_cache.dart';
import 'package:check_app_version/src/domain/entities/update_decision.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemoryVersionCache cache;

  const decision = UpdateDecision(
    shouldUpdate: true,
    isForceUpdate: false,
    reason: UpdateReason.belowLatest,
    installedVersion: '1.0.0',
    installedBuild: 1,
    requiredMinVersion: '1.0.0',
    requiredMinBuild: 1,
  );

  setUp(() {
    cache = InMemoryVersionCache();
  });

  group('InMemoryVersionCache', () {
    test('put and get within TTL returns cached value', () {
      cache.put('key1', decision);
      final result = cache.get('key1');
      expect(result, equals(decision));
    });

    test('get after TTL returns null', () {
      // Use a 0-duration TTL so entry expires immediately.
      cache.put(
        'key1',
        decision,
        ttl: Duration.zero,
      );
      // Give time for the TTL to expire.
      final result = cache.get('key1');
      expect(result, isNull);
    });

    test('isValid returns true for non-expired entry', () {
      cache.put('key1', decision);
      expect(cache.isValid('key1'), isTrue);
    });

    test('isValid returns false for expired entry', () {
      cache.put('key1', decision, ttl: Duration.zero);
      expect(cache.isValid('key1'), isFalse);
    });

    test('isValid returns false for missing key', () {
      expect(cache.isValid('missing'), isFalse);
    });

    test('invalidate removes a specific entry', () {
      cache.put('key1', decision);
      cache.put('key2', decision);
      cache.invalidate('key1');
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNotNull);
    });

    test('clear removes all entries', () {
      cache.put('key1', decision);
      cache.put('key2', decision);
      cache.clear();
      expect(cache.get('key1'), isNull);
      expect(cache.get('key2'), isNull);
    });

    test('buildKey produces consistent composite keys', () {
      final key = InMemoryVersionCache.buildKey(
        sourceType: 'file',
        path: 'assets/version.json',
        platform: 'android',
      );
      expect(key, 'file:assets/version.json:android');
    });
  });
}
