// Level 3 check without a screen:  dart run tool/smoke.dart
import 'package:http/http.dart' as http;
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

Future<void> main() async {
  final repo = UserRepository(ApiClient(http.Client()));
  final all = await repo.getAll();
  print(all.map((u) => u.name).join(', '));
  try {
    await repo.getById(999);
  } on NotFoundException {
    print('not found');
  }
  final created = await repo.create(User.fromJson(all.first.toJson()));
  print('server assigned id ${created.id}');
}
