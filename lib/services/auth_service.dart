import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/pasien.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.login}'),
        headers: ApiConfig.headers(),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        // Save token and user data
        await _storageService.saveToken(data['token']);
        final pasien = Pasien.fromJson(data['data']);
        await _storageService.saveUserData(
          noRm: pasien.noRkmMedis,
          namaPasien: pasien.nmPasien,
          alamat: pasien.alamat,
        );

        return {'success': true, 'pasien': pasien, 'token': data['token']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    ChangePasswordRequest request,
  ) async {
    try {
      final token = await _storageService.getToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.changePassword}'),
        headers: ApiConfig.headers(token: token),
        body: jsonEncode(request.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengubah password',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    await _cacheService.clearAll();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storageService.getToken();
    return token != null;
  }

  Future<Pasien?> getCurrentUser() async {
    final userData = await _storageService.getUserData();
    if (userData['no_rm'] != null && userData['nama_pasien'] != null) {
      return Pasien(
        noRkmMedis: userData['no_rm']!,
        nmPasien: userData['nama_pasien']!,
        alamat: userData['alamat'],
      );
    }
    return null;
  }
}
