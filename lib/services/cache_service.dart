import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // In-memory cache for fast access
  final Map<String, _CacheEntry> _memoryCache = {};

  // Cache duration configurations (in seconds)
  static const Map<String, int> _cacheDurations = {
    'jadwal_dokter': 3600, // 1 hour
    'lab_orders': 300, // 5 minutes
    'lab_results_': 300, // 5 minutes (prefix for per no_rawat)
    'rekam_medis_history': 300, // 5 minutes
    'surat_kontrol_list': 600, // 10 minutes
    'surat_kontrol_': 600, // 10 minutes (prefix for per no_surat)
    'user_profile': 1800, // 30 minutes
  };

  /// Get cached data
  Future<T?> get<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        print('✅ Cache HIT (memory): $key');
        return fromJson(entry.data);
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    final expiryString = prefs.getString('${key}_expiry');

    if (jsonString != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiry)) {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        // Update memory cache
        _memoryCache[key] = _CacheEntry(data, expiry);
        print('✅ Cache HIT (persistent): $key');
        return fromJson(data);
      } else {
        // Expired, remove from persistent storage
        await prefs.remove(key);
        await prefs.remove('${key}_expiry');
      }
    }

    print('❌ Cache MISS: $key');
    return null;
  }

  /// Get cached list data
  Future<List<T>?> getList<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        print('✅ Cache HIT (memory): $key');
        final list = entry.data['items'] as List;
        return list
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check persistent cache
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    final expiryString = prefs.getString('${key}_expiry');

    if (jsonString != null && expiryString != null) {
      final expiry = DateTime.parse(expiryString);
      if (DateTime.now().isBefore(expiry)) {
        final data = json.decode(jsonString) as Map<String, dynamic>;
        final list = data['items'] as List;
        // Update memory cache
        _memoryCache[key] = _CacheEntry(data, expiry);
        print('✅ Cache HIT (persistent): $key');
        return list
            .map((item) => fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        await prefs.remove(key);
        await prefs.remove('${key}_expiry');
      }
    }

    print('❌ Cache MISS: $key');
    return null;
  }

  /// Set cache data
  Future<void> set(String key, Map<String, dynamic> data) async {
    final duration = _getDuration(key);
    final expiry = DateTime.now().add(Duration(seconds: duration));

    // Save to memory cache
    _memoryCache[key] = _CacheEntry(data, expiry);

    // Save to persistent cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
    await prefs.setString('${key}_expiry', expiry.toIso8601String());

    print('💾 Cache SET: $key (expires in ${duration}s)');
  }

  /// Set cache list data
  Future<void> setList(String key, List<dynamic> items) async {
    await set(key, {'items': items});
  }

  /// Clear specific cache key
  Future<void> clear(String key) async {
    _memoryCache.remove(key);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
    await prefs.remove('${key}_expiry');
    print('🗑️ Cache CLEARED: $key');
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('🗑️ ALL Cache CLEARED');
  }

  /// Clear cache by prefix (e.g., 'lab_results_' to clear all lab results)
  Future<void> clearByPrefix(String prefix) async {
    // Clear memory cache
    _memoryCache.removeWhere((key, _) => key.startsWith(prefix));

    // Clear persistent cache
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        await prefs.remove(key);
      }
    }
    print('🗑️ Cache CLEARED by prefix: $prefix');
  }

  /// Get cache duration for a key
  int _getDuration(String key) {
    // Check exact match first
    if (_cacheDurations.containsKey(key)) {
      return _cacheDurations[key]!;
    }

    // Check prefix match
    for (final entry in _cacheDurations.entries) {
      if (key.startsWith(entry.key)) {
        return entry.value;
      }
    }

    // Default: 5 minutes
    return 300;
  }
}

class _CacheEntry {
  final Map<String, dynamic> data;
  final DateTime expiry;

  _CacheEntry(this.data, this.expiry);

  bool get isExpired => DateTime.now().isAfter(expiry);
}
