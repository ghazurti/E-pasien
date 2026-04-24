import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/antrian.dart';
import 'storage_service.dart';

class AntrianService {
  final StorageService _storageService = StorageService();
  static const _timeout = Duration(seconds: 10);

  Future<AntrianStatus?> getAntrianStatus() async {
    final token = await _storageService.getToken();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.antrian}'),
          headers: ApiConfig.headers(token: token),
        )
        .timeout(_timeout);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      if (data['data'] == null) return null;
      return AntrianStatus.fromJson(data['data']);
    } else {
      throw Exception(data['message'] ?? 'Gagal memuat status antrian');
    }
  }
}
