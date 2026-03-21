import 'package:dio/dio.dart';

/// DragonflyDB cache statistics
class DragonflyStats {
  final bool connected;
  final double latencyMs;
  final String memoryUsed;
  final String memoryPeak;
  final int totalKeys;
  final int uptimeSeconds;

  DragonflyStats({
    required this.connected,
    required this.latencyMs,
    required this.memoryUsed,
    required this.memoryPeak,
    required this.totalKeys,
    required this.uptimeSeconds,
  });

  factory DragonflyStats.fromJson(Map<String, dynamic> json) {
    return DragonflyStats(
      connected: json['connected'] ?? false,
      latencyMs: (json['latency_ms'] ?? 0).toDouble(),
      memoryUsed: json['memory_used'] ?? '0B',
      memoryPeak: json['memory_peak'] ?? '0B',
      totalKeys: json['total_keys'] ?? 0,
      uptimeSeconds: json['uptime_seconds'] ?? 0,
    );
  }

  String get statusText {
    if (!connected) return 'Disconnected';
    if (latencyMs > 100) return 'Slow';
    return 'Healthy';
  }

  String get uptimeFormatted {
    final days = uptimeSeconds ~/ 86400;
    final hours = (uptimeSeconds % 86400) ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;

    if (days > 0) return '${days}d ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

/// Cache service statistics
class CacheService {
  final String name;
  final int keyCount;
  final double hitRate;

  CacheService({
    required this.name,
    required this.keyCount,
    required this.hitRate,
  });

  factory CacheService.fromJson(Map<String, dynamic> json) {
    return CacheService(
      name: json['name'] ?? '',
      keyCount: json['key_count'] ?? 0,
      hitRate: (json['hit_rate'] ?? 0).toDouble(),
    );
  }
}

/// Key namespace count
class KeyNamespace {
  final String namespace;
  final int count;

  KeyNamespace({
    required this.namespace,
    required this.count,
  });

  factory KeyNamespace.fromJson(Map<String, dynamic> json) {
    return KeyNamespace(
      namespace: json['namespace'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

/// Service for interacting with DragonflyDB cache endpoints
class DragonflyService {
  final Dio _dio;
  final String baseUrl;

  DragonflyService({
    required this.baseUrl,
    required String authToken,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ));

  /// Update auth token
  void updateAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Get DragonflyDB health and connection status
  Future<Map<String, dynamic>> getHealth() async {
    try {
      final response = await _dio.get('/dragonfly/health');
      return response.data;
    } catch (e) {
      return {'connected': false, 'latency_ms': 0, 'message': 'Connection failed'};
    }
  }

  /// Get DragonflyDB statistics
  Future<DragonflyStats> getStats() async {
    try {
      final healthResponse = await _dio.get('/dragonfly/health');
      final statsResponse = await _dio.get('/dragonfly/stats');

      final health = healthResponse.data;
      final stats = statsResponse.data;

      return DragonflyStats(
        connected: health['connected'] ?? false,
        latencyMs: (health['latency_ms'] ?? 0).toDouble(),
        memoryUsed: stats['memory']?['used_memory_human'] ?? '0B',
        memoryPeak: stats['memory']?['used_memory_peak_human'] ?? '0B',
        totalKeys: stats['keyspace']?['db0']?['keys'] ?? 0,
        uptimeSeconds: stats['server']?['uptime_in_seconds'] ?? 0,
      );
    } catch (e) {
      return DragonflyStats(
        connected: false,
        latencyMs: 0,
        memoryUsed: '0B',
        memoryPeak: '0B',
        totalKeys: 0,
        uptimeSeconds: 0,
      );
    }
  }

  /// Get cache services statistics
  Future<List<CacheService>> getServices() async {
    try {
      final response = await _dio.get('/dragonfly/services');
      final services = response.data['services'] as List?;
      
      return services?.map((s) => CacheService.fromJson(s)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Get key counts by namespace
  Future<List<KeyNamespace>> getKeys() async {
    try {
      final response = await _dio.get('/dragonfly/keys');
      final keys = response.data['keys'] as List?;
      
      return keys?.map((k) => KeyNamespace.fromJson(k)).toList() ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Clear a specific cache namespace
  Future<bool> clearNamespace(String namespace) async {
    try {
      await _dio.post('/dragonfly/clear/$namespace');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all caches
  Future<bool> clearAll() async {
    try {
      await _dio.post('/dragonfly/clear-all');
      return true;
    } catch (e) {
      return false;
    }
  }
}
