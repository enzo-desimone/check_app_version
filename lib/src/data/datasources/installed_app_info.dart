/// Lightweight, platform-agnostic representation of the currently
/// installed application's version metadata.
class InstalledAppInfo {
  /// Creates an [InstalledAppInfo].
  const InstalledAppInfo({
    required this.version,
    required this.buildNumber,
    required this.packageName,
  });

  /// Semantic version string (e.g. `"1.2.0"`).
  final String version;

  /// Build number string (e.g. `"10"`).
  final String buildNumber;

  /// Application bundle ID or package name.
  final String packageName;
}
