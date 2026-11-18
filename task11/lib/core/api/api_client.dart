import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Knows http. Throws only [ApiException]s.
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  /// Composition-root helper so main.dart does not import package:http.
  factory ApiClient.live() => ApiClient(http.Client());

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.https(host, path, query);
    final r = await _send(() => _client.get(uri, headers: _headers));
    _log('GET', uri, r);
    _check(r);
    return r;
  }

  Future<http.Response> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final r = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _log('POST', uri, r);
    _check(r);
    return r;
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call().timeout(const Duration(seconds: 10));
    } on SocketException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    }
  }

  // Status first, body second — always.
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s < 200 || s >= 300) throw BadResponseException('HTTP $s');
  }

  dynamic decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException('not JSON: ${e.message}');
    }
  }

  void _log(String method, Uri uri, http.Response r) {
    // assert bodies are stripped in release builds => debug only
    assert(() {
      log('$method $uri -> ${r.statusCode} (${r.bodyBytes.length} B)',
          name: 'api');
      return true;
    }());
  }
}
