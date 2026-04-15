import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/surat_kontrol.dart';
import '../config/api_config.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class SuratKontrolService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  Future<List<SuratKontrol>> getSuratKontrolList({bool refresh = false}) async {
    // Try cache first if not refreshing
    if (!refresh) {
      final cached = await _cacheService.getList<SuratKontrol>(
        'surat_kontrol_list',
        (json) => SuratKontrol.fromJson(json),
      );
      if (cached != null) return cached;
    }

    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/surat-kontrol'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final List<dynamic> listJson = data['data'];
        final results = listJson
            .map((json) => SuratKontrol.fromJson(json))
            .toList();

        // Cache the list
        await _cacheService.setList('surat_kontrol_list', listJson);

        return results;
      } else {
        throw Exception(data['message'] ?? 'Gagal mengambil data');
      }
    } else {
      throw Exception('Gagal terhubung ke server');
    }
  }

  Future<String> downloadSuratKontrolPdf(String noSurat) async {
    final token = await _storageService.getToken();
    if (token == null) {
      throw Exception('Token tidak ditemukan');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/surat-kontrol/$noSurat/pdf'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      // Save PDF to device
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/surat_kontrol_$noSurat.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Gagal mendownload PDF');
    }
  }
}
