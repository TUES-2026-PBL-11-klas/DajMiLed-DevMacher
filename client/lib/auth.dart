import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _storage = FlutterSecureStorage(
  aOptions: const AndroidOptions(encryptedSharedPreferences: true),
);

bool loggedIn = false;

Future<void> init() async {
  loggedIn = await _storage.read(key: 'token') != null;
}

Future<void> logout() async {
  await _storage.delete(key: 'token');
  loggedIn = false;
}

Future<String?> readToken() => _storage.read(key: 'token');

Future<String?> login(String email, String password) async {
  loggedIn = true;
  return null;
}

Future<String?> register(
  String email,
  String firstName,
  String lastName,
  String password,
  List<String> ownTags,
) async {
  loggedIn = true;
  return null;
}
