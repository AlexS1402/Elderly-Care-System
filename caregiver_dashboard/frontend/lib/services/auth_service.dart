import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'jwt', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'jwt');
  }

  static Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'userRole', value: role);
  }

  static Future<String?> getUserRole() async {
    return await _storage.read(key: 'userRole');
  }

  static Future<void> saveUserId(int userId) async {
    await _storage.write(key: 'userId', value: userId.toString());
  }

  static Future<int?> getUserId() async {
    String? userIdStr = await _storage.read(key: 'userId');
    return userIdStr != null ? int.parse(userIdStr) : null;
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
