import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api.dart';

final _storage = FlutterSecureStorage(
  aOptions: const AndroidOptions(encryptedSharedPreferences: true),
);

bool loggedIn = false;
int? currentUserId;

Future<void> init() async {
  loggedIn = await _storage.read(key: 'token') != null;
}

Future<void> logout() async {
  await _storage.delete(key: 'token');
  loggedIn = false;
  currentUserId = null;
}

Future<String?> readToken() => _storage.read(key: 'token');

Future<String?> login(String email, String password) async {
  try {
    final res = await ApiClient.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      await _storage.write(key: 'token', value: body['token'] as String);
      loggedIn = true;
      currentUserId = (body['user'] as Map<String, dynamic>?)?['id'] as int?;
      return null;
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['message'] as String? ?? 'Invalid email or password';
  } catch (_) {
    return 'Could not connect to server';
  }
}

Future<String?> register(
  String email,
  String firstName,
  String lastName,
  String password,
) async {
  try {
    final res = await ApiClient.post('/api/auth/register', {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
    });
    if (res.statusCode == 201) {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      await _storage.write(key: 'token', value: body['token'] as String);
      loggedIn = true;
      currentUserId = (body['user'] as Map<String, dynamic>?)?['id'] as int?;
      return null;
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['message'] as String? ?? 'Registration failed';
  } catch (_) {
    return 'Could not connect to server';
  }
}
