import 'dart:convert';

import 'package:http/http.dart' as http;

/// Data source that loads raw JSON from an HTTP endpoint.
class EndpointJsonDataSource {
  /// Creates an [EndpointJsonDataSource].
  ///
  /// [url] — the full URL to GET.
  /// [timeout] — request timeout (default 5 s).
  /// [httpClient] — injectable for testing.
  EndpointJsonDataSource({
    required this.url,
    this.timeout = const Duration(seconds: 5),
    http.Client? httpClient,
  }) : _client = httpClient;

  /// The endpoint URL.
  final String url;

  /// HTTP request timeout.
  final Duration timeout;

  final http.Client? _client;

  /// Fetches and decodes the JSON document.
  Future<Map<String, dynamic>> load() async {
    final client = _client ?? http.Client();
    try {
      final response = await client.get(Uri.parse(url)).timeout(timeout);

      if (response.statusCode != 200) {
        throw HttpException(
          'HTTP ${response.statusCode}',
          url: url,
        );
      }

      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;

      throw const FormatException(
        'EndpointJsonDataSource: '
        'response is not a JSON object.',
      );
    } finally {
      // Only close if we created the client ourselves.
      if (_client == null) client.close();
    }
  }
}

/// Simple exception for HTTP errors.
class HttpException implements Exception {
  /// Creates an [HttpException].
  const HttpException(this.message, {this.url});

  /// Error message.
  final String message;

  /// Target URL.
  final String? url;

  @override
  String toString() => 'HttpException: $message (url: $url)';
}
