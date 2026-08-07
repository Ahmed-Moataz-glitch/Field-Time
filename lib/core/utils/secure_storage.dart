import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class SecureStorage {
  static const _flutterSecureStorage = FlutterSecureStorage();
  static const _token = "token";

  static Future<void> saveToken(String token) async {
    await _flutterSecureStorage.write(key: _token, value: token);
  }

  static Future<String?> getToken() async {
    return await _flutterSecureStorage.read(key: _token);
  }

  static Future<void> deleteToken() async {
    await _flutterSecureStorage.delete(key: _token);
  }
}
