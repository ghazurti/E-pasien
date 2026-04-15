import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/rekam_medis.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class RekamMedisService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  Future<List<RekamMedis>> getRekamMedisHistory({bool refresh = false}) async {
    // Try cache first if not refreshing
    if (!refresh) {
      final cached = await _cacheService.getList<RekamMedis>(
        'rekam_medis_history',
        (json) => RekamMedis.fromJson(json),
      );
      if (cached != null) return cached;
    }

    final token = await _storageService.getToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/rekam-medis/history'),
      headers: ApiConfig.headers(token: token),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> items = data['data'];
        final results = items.map((item) => RekamMedis.fromJson(item)).toList();

        // Cache the results
        await _cacheService.setList('rekam_medis_history', items);

        return results;
      } else {
        throw Exception(data['message'] ?? 'Gagal memuat rekam medis');
      }
    } else {
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
