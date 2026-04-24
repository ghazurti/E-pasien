import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/riwayat_obat.dart';
import 'storage_service.dart';

class RiwayatObatService {
  final StorageService _storageService = StorageService();
  static const _timeout = Duration(seconds: 10);

  Future<List<Resep>> getRiwayatObat() async {
    final token = await _storageService.getToken();

    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.riwayatObat}'),
          headers: ApiConfig.headers(token: token),
        )
        .timeout(_timeout);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      final List<dynamic> listJson = data['data'];
      return listJson
          .map((json) => Resep.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception(data['message'] ?? 'Gagal memuat riwayat obat');
    }
  }
}
