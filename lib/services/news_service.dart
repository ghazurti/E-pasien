import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/news.dart';
import 'cache_service.dart';

class NewsService {
  final http.Client _client;
  final CacheService _cacheService = CacheService();

  NewsService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<News>> fetchNews() async {
    // Try cache first
    final cached = await _cacheService.getList<News>(
      'news_list',
      (json) => News.fromJson(json),
    );
    if (cached != null) return cached;

    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.news}'),
        headers: ApiConfig.headers(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> newsJson = data['data'];
          final results = newsJson.map((json) => News.fromJson(json)).toList();

          // Cache the results
          await _cacheService.setList('news_list', newsJson);

          return results;
        } else {
          throw Exception(data['message'] ?? 'Gagal mengambil berita');
        }
      } else {
        throw Exception('Gagal menghubungi server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }
}
