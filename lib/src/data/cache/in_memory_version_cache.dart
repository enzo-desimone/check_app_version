import 'package:check_app_version/src/domain/entities/update_decision.dart';

/// Entry stored inside [InMemoryVersionCache].
class _CacheEntry {
  _CacheEntry(this.decision, this.expiry);

  final UpdateDecision decision;
  final DateTime expiry;

  bool get isValid => DateTime.now().isBefore(expiry);
}

/// Simple in-memory, TTL-based cache for
/// [UpdateDecision] results.
///
/// Cache key format: `<sourceType>:<path>:<platform>`.
class InMemoryVersionCache {
  final Map<String, _CacheEntry> _store = {};

  /// Returns a cached [UpdateDecision] if the entry
  /// exists and has not expired, otherwise `null`.
  UpdateDecision? get(String key) {
    final entry = _store[key];
    if (entry == null || !entry.isValid) {
      _store.remove(key);
      return null;
    }
    return entry.decision;
  }

  /// Stores a result under [key] with the given [ttl].
  void put(
    String key,
    UpdateDecision decision, {
    Duration ttl = const Duration(minutes: 10),
  }) {
    _store[key] = _CacheEntry(
      decision,
      DateTime.now().add(ttl),
    );
  }

  /// Removes a single entry.
  void invalidate(String key) => _store.remove(key);

  /// Removes all entries.
  void clear() => _store.clear();

  /// Whether the cache currently holds a valid entry
  /// for [key].
  bool isValid(String key) {
    final entry = _store[key];
    return entry != null && entry.isValid;
  }

  /// Builds a cache key from its components.
  static String buildKey({
    required String sourceType,
    required String path,
    required String platform,
  }) =>
      '$sourceType:$path:$platform';
}
