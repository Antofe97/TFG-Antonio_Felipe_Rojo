import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserSecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyPassword = 'password';
  
  static Future<String?> setLoginParameters(email, password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }
  
  static Future<String?> getEmail() async =>
    await _storage.read(key: _keyEmail);

  static Future<String?> getPassword() async =>
    await _storage.read(key: _keyPassword);

  static Future deleteAll() async =>
    await _storage.deleteAll();
    
}