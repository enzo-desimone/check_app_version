/// Enumerates the platforms supported by the version
/// check configuration.
///
/// Used as type-safe keys in
/// `VersionInfo.platforms` to identify each platform's
/// config block.
enum SupportedPlatform {
  /// Google Android.
  android,

  /// Apple iOS.
  ios,

  /// Apple macOS.
  macos,

  /// Microsoft Windows.
  windows,

  /// GNU/Linux.
  linux,

  /// Web (browser).
  web;

  /// Attempts to parse a [SupportedPlatform] from a
  /// case-insensitive string. Returns `null` if the
  /// string does not match any known platform.
  static SupportedPlatform? tryParse(String value) {
    final lower = value.toLowerCase();
    for (final p in values) {
      if (p.name == lower) return p;
    }
    return null;
  }
}
