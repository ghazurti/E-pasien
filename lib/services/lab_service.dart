import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/lab_result.dart';
import '../config/api_config.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class LabService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  Future<List<LabOrder>> getLabOrders({bool refresh = false}) async {
    // Try cache first if not refreshing
    if (!refresh) {
      final cached = await _cacheService.getList<LabOrder>(
        'lab_orders',
        (json) => LabOrder.fromJson(json),
      );
      if (cached != null) return cached;
    }

    // Cache miss - fetch from API
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/lab-results'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> ordersJson = data['data'];
        final orders = ordersJson
            .map((json) => LabOrder.fromJson(json))
            .toList();

        // Cache the results
        await _cacheService.setList('lab_orders', ordersJson);

        return orders;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data lab');
      }
    } else {
      throw Exception('Gagal terhubung ke server (${response.statusCode})');
    }
  }

  Future<List<LabResult>> getLabResults(
    String noRawat, {
    bool refresh = false,
  }) async {
    // Try cache first if not refreshing
    final cacheKey = 'lab_results_$noRawat';
    if (!refresh) {
      final cached = await _cacheService.getList<LabResult>(
        cacheKey,
        (json) => LabResult.fromJson(json),
      );
      if (cached != null) return cached;
    }

    // Cache miss - fetch from API
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    // URL encode no_rawat to handle slashes
    final encodedNoRawat = Uri.encodeComponent(noRawat);

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/lab-results/$encodedNoRawat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> resultsJson = data['data'];
        final results = resultsJson
            .map((json) => LabResult.fromJson(json))
            .toList();

        // Cache the results
        await _cacheService.setList(cacheKey, resultsJson);

        return results;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil hasil lab');
      }
    } else {
      print('Lab detail error: ${response.statusCode} - ${response.body}');
      throw Exception('Gagal terhubung ke server (${response.statusCode})');
    }
  }
}
