import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _noRmKey = 'no_rm';
  static const String _namaPasienKey = 'nama_pasien';
  static const String _alamatKey = 'alamat';
  
  // Token operations
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
  
  // User data operations
  Future<void> saveUserData({
    required String noRm,
    required String namaPasien,
    String? alamat,
  }) async {
    await _storage.write(key: _noRmKey, value: noRm);
    await _storage.write(key: _namaPasienKey, value: namaPasien);
    if (alamat != null) {
      await _storage.write(key: _alamatKey, value: alamat);
    }
  }
  
  Future<Map<String, String?>> getUserData() async {
    return {
      'no_rm': await _storage.read(key: _noRmKey),
      'nama_pasien': await _storage.read(key: _namaPasienKey),
      'alamat': await _storage.read(key: _alamatKey),
    };
  }
  
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
