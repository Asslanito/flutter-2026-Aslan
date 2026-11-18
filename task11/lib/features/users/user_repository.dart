import 'package:http/http.dart' as http;

import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final r = await _api.get('/users');
    return _parse('users', r, (body) {
      if (body is! List) throw const FormatException('expected a JSON list');
      return [for (final e in body) User.fromJson(e as Map<String, dynamic>)];
    });
  }

  Future<User> getById(int id) async {
    final r = await _api.get('/users/$id');
    return _parse('users/$id', r, (body) {
      return User.fromJson(body as Map<String, dynamic>);
    });
  }

  Future<User> create(User draft) async {
    final r = await _api.post('/users', draft.toJson());
    if (r.statusCode != 201) {
      throw BadResponseException('users: expected 201, got ${r.statusCode}');
    }
    return _parse('users', r, (body) {
      return User.fromJson(body as Map<String, dynamic>);
    });
  }

  T _parse<T>(String where, http.Response r, T Function(dynamic) build) {
    final body = _api.decode(r);
    try {
      return build(body);
    } on TypeError catch (e) {
      throw BadResponseException('$where: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$where: $e');
    }
  }
}
