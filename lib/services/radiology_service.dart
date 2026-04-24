import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/radiology_result.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class RadiologyService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  static const _timeout = Duration(seconds: 10);

  Future<List<RadiologyOrder>> getRadiologyHistory({
    bool refresh = false,
  }) async {
    const cacheKey = 'radiology_history';

    if (!refresh) {
      final cached = await _cacheService.getList<RadiologyOrder>(
        cacheKey,
        (json) => RadiologyOrder.fromJson(json),
      );
      if (cached != null) return cached;
    }

    try {
      final token = await _storageService.getToken();
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.radiologyResults}'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> listJson = data['data'];
          final results = listJson
              .map((json) => RadiologyOrder.fromJson(json))
              .toList();

          await _cacheService.setList(cacheKey, listJson);
          return results;
        }
      }
      throw Exception('Gagal memuat riwayat radiologi');
    } catch (e) {
      throw Exception('Koneksi ke server gagal: $e');
    }
  }

  Future<List<RadiologyResult>> getRadiologyDetail(String noRawat) async {
    try {
      final token = await _storageService.getToken();
      final encodedNoRawat = Uri.encodeComponent(noRawat);
      final url =
          '${ApiConfig.baseUrl}${ApiConfig.radiologyResults}/$encodedNoRawat';

      final response = await http
          .get(Uri.parse(url), headers: ApiConfig.headers(token: token))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> listJson = data['data'];
          return listJson
              .map((json) => RadiologyResult.fromJson(json))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat detail radiologi');
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Koneksi ke server gagal: $e');
    }
  }
}
