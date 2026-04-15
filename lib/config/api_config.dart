class ApiConfig {
  // Base URL - menggunakan IP lokal untuk akses dari HP
  static const String baseUrl = 'https://api.simrsrsudbaubau.online/api';

  // Endpoints
  static const String login = '/login';
  static const String changePassword = '/pasien/change-password';
  static const String jadwal = '/jadwal';
  static const String booking = '/booking';
  static const String bookingHistory = '/booking/history';
  static const String checkIn = '/booking/checkin';
  static const String cancelBooking = '/booking/cancel';
  static const String news = '/news';
  static const String radiologyResults = '/radiology-results';

  // Headers
  static Map<String, String> headers({String? token}) {
    final Map<String, String> defaultHeaders = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      defaultHeaders['Authorization'] = 'Bearer $token';
    }

    return defaultHeaders;
  }
}
