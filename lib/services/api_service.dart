import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/jadwal.dart';
import '../models/booking.dart';
import '../models/kamar.dart';
import 'storage_service.dart';
import 'cache_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();
  final CacheService _cacheService = CacheService();

  static const _timeout = Duration(seconds: 10);

  // Get Jadwal Dokter
  Future<List<Jadwal>> getJadwal({bool refresh = false}) async {
    // Try cache first if not refreshing
    if (!refresh) {
      final cached = await _cacheService.getList<Jadwal>(
        'jadwal_dokter',
        (json) => Jadwal.fromJson(json),
      );
      if (cached != null) return cached;
    }

    try {
      final token = await _storageService.getToken();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.jadwal}'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> listJson = data['data'];
          final results = listJson
              .map((json) => Jadwal.fromJson(json))
              .toList();

          // Cache the results
          await _cacheService.setList('jadwal_dokter', listJson);

          return results;
        }
      }
      throw Exception('Gagal memuat jadwal dokter');
    } catch (e) {
      throw Exception('Koneksi ke server gagal: $e');
    }
  }

  // Create Booking
  Future<Map<String, dynamic>> createBooking(
    CreateBookingRequest request,
  ) async {
    try {
      final token = await _storageService.getToken();

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.booking}'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  // Get Booking History
  Future<List<Booking>> getBookingHistory(
    String noRm, {
    bool refresh = false,
  }) async {
    // Try cache first if not refreshing
    final cacheKey = 'booking_history_$noRm';
    if (!refresh) {
      final cached = await _cacheService.getList<Booking>(
        cacheKey,
        (json) => Booking.fromJson(json),
      );
      if (cached != null) return cached;
    }

    try {
      final token = await _storageService.getToken();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingHistory}'),
            headers: ApiConfig.headers(token: token),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> listJson = data['data'];
          final results = listJson
              .map((json) => Booking.fromJson(json))
              .toList();

          // Cache the results
          await _cacheService.setList(cacheKey, listJson);

          return results;
        }
      }
      throw Exception('Gagal memuat riwayat booking');
    } catch (e) {
      throw Exception('Koneksi ke server gagal: $e');
    }
  }

  // Check In Booking
  // Match backend CheckInRequest: no_rkm_medis, tanggal_periksa, kd_dokter, kd_poli
  Future<Map<String, dynamic>> checkInBooking(Booking booking) async {
    try {
      final token = await _storageService.getToken();

      final checkInPayload = {
        'no_rkm_medis': booking.noRkmMedis,
        'tanggal_periksa': booking.tanggalPeriksa,
        'kd_dokter': booking.kdDokter,
        'kd_poli': booking.kdPoli,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.checkIn}'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode(checkInPayload),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal check-in',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  // Cancel Booking
  Future<Map<String, dynamic>> cancelBooking(Booking booking) async {
    try {
      final token = await _storageService.getToken();

      final cancelPayload = {
        'no_rkm_medis': booking.noRkmMedis,
        'tanggal_periksa': booking.tanggalPeriksa,
        'kd_dokter': booking.kdDokter,
        'kd_poli': booking.kdPoli,
      };

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cancelBooking}'),
            headers: ApiConfig.headers(token: token),
            body: jsonEncode(cancelPayload),
          )
          .timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membatalkan booking',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Koneksi ke server gagal: $e'};
    }
  }

  // Get Room Availability
  Future<List<Kamar>> getKamar({bool refresh = false}) async {
    // Try cache first if not refreshing
    if (!refresh) {
      final cached = await _cacheService.getList<Kamar>(
        'ketersediaan_kamar',
        (json) => Kamar.fromJson(json),
      );
      if (cached != null) return cached;
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/kamar'),
            headers: ApiConfig.headers(),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> listJson = data['data'];
          final results = listJson.map((json) => Kamar.fromJson(json)).toList();

          // Cache the results
          await _cacheService.setList('ketersediaan_kamar', listJson);

          return results;
        } else {
          throw Exception(data['message'] ?? 'Gagal memuat ketersediaan kamar');
        }
      }
      throw Exception('Server Error: ${response.statusCode}');
    } catch (e) {
      throw Exception('Kesalahan: $e');
    }
  }
}
