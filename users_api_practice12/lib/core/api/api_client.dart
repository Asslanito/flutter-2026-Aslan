import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../storage/secure_store.dart';
import 'api_exception.dart';

/// Knows http. Throws only [ApiException]s. Adds the Authorization header itself.
class ApiClient {
  ApiClient(this._client, this._store,
      {this.host = 'jsonplaceholder.typicode.com'});

  /// Composition-root helper so main.dart does not import package:http.
  factory ApiClient.live(SecureStore store) => ApiClient(http.Client(), store);

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> _headers() async => {
        'Accept': 'application/json',
        if (await _store.readToken() case final t?) 'Authorization': 'Bearer $t',
      };

  Future<http.Response> get(String path, {Map<String, String>? query}) async {
    final uri = Uri.https(host, path, query);
    final headers = await _headers();
    final r = await _send(() => _client.get(uri, headers: headers));
    _log('GET', uri, r);
    _check(r);
    return r;
  }

  Future<http.Response> post(String path, Object body) async {
    final uri = Uri.https(host, path);
    final base = await _headers();
    final headers = {...base, 'Content-Type': 'application/json'};
    final r = await _send(
      () => _client.post(uri, headers: headers, body: jsonEncode(body)),
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
    // The token is never logged. assert => debug builds only.
    assert(() {
      log('$method $uri -> ${r.statusCode} (${r.bodyBytes.length} B)',
          name: 'api');
      return true;
    }());
  }
}
