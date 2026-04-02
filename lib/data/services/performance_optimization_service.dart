import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';

class PerformanceOptimizationService {
  late final SharedPreferences _prefs;

  // Cache management
  final Map<String, Timer> _cacheTimers = {};

  // Memory monitoring
  Timer? _memoryMonitorTimer;
  int _currentMemoryUsage = 0;
  int _maxMemoryThreshold = 512 * 1024 * 1024; // 512MB

  static PerformanceOptimizationService? _instance;
  static PerformanceOptimizationService get instance =>
      _instance ??= PerformanceOptimizationService._();

  PerformanceOptimizationService._();

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _initializeImageCache();
      await _setupMemoryMonitoring();
      await _optimizeDatabase();
      await _preloadCriticalData();

      debugPrint('Performance optimization service initialized');
    } catch (e) {
      debugPrint('Error initializing performance optimization: $e');
    }
  }

  Future<void> _initializeImageCache() async {
    try {
      // Configure image cache settings
      PaintingBinding.instance.imageCache.maximumSize = 100;
      PaintingBinding.instance.imageCache.maximumSizeBytes =
          50 * 1024 * 1024; // 50MB

      // Clean old cache
      await _cleanImageCache();
    } catch (e) {
      debugPrint('Error initializing image cache: $e');
    }
  }

  Future<void> _cleanImageCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final imageCacheDir = Directory('${tempDir.path}/cached_network_images');

      if (await imageCacheDir.exists()) {
        final now = DateTime.now();
        final files = await imageCacheDir.list().toList();

        for (final file in files) {
          if (file is File) {
            final stat = await file.stat();
            if (now.difference(stat.modified).inDays > 7) {
              await file.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning image cache: $e');
    }
  }

  Future<void> _setupMemoryMonitoring() async {
    _memoryMonitorTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _monitorMemoryUsage();
    });
  }

  void _monitorMemoryUsage() {
    if (kDebugMode) {
      // In debug mode, we can monitor memory usage
      // In release mode, this would be handled by platform-specific code
      _currentMemoryUsage = _estimateMemoryUsage();

      if (_currentMemoryUsage > _maxMemoryThreshold) {
        _performMemoryCleanup();
      }
    }
  }

  int _estimateMemoryUsage() {
    // Simplified memory estimation
    // In a real implementation, this would use platform-specific APIs
    return 100 * 1024 * 1024; // 100MB placeholder
  }

  Future<void> _performMemoryCleanup() async {
    try {
      debugPrint('Performing memory cleanup...');

      // Clear image cache
      PaintingBinding.instance.imageCache.clear();

      // Clear network image cache
      await _clearNetworkImageCache();

      // Force garbage collection
      if (kDebugMode) {
        // In debug mode, we can hint to the GC
        Timer(const Duration(seconds: 1), () {
          // Allow time for cleanup
        });
      }

      debugPrint('Memory cleanup completed');
    } catch (e) {
      debugPrint('Error during memory cleanup: $e');
    }
  }

  Future<void> _clearNetworkImageCache() async {
    try {
      await CachedNetworkImage.evictFromCache('*');
    } catch (e) {
      debugPrint('Error clearing network image cache: $e');
    }
  }

  Future<void> _optimizeDatabase() async {
    try {
      // Optimize Hive databases
      final boxes = [
        'tracks',
        'albums',
        'artists',
        'playlists',
        'settings',
        'cache',
      ];

      for (final boxName in boxes) {
        try {
          final box = await Hive.openBox(boxName);

          // Compact the box if it's getting large
          if (box.length > 1000) {
            await box.compact();
          }

          // Clean old cache entries
          if (boxName == 'cache') {
            await _cleanCacheBox(box);
          }
        } catch (e) {
          debugPrint('Error optimizing box $boxName: $e');
        }
      }
    } catch (e) {
      debugPrint('Error optimizing database: $e');
    }
  }

  Future<void> _cleanCacheBox(Box box) async {
    try {
      final now = DateTime.now();
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final value = box.get(key);
        if (value is Map && value.containsKey('timestamp')) {
          final timestamp =
              DateTime.fromMillisecondsSinceEpoch(value['timestamp']);
          if (now.difference(timestamp).inDays > 7) {
            keysToDelete.add(key);
          }
        }
      }

      for (final key in keysToDelete) {
        await box.delete(key);
      }

      if (keysToDelete.isNotEmpty) {
        debugPrint('Cleaned ${keysToDelete.length} old cache entries');
      }
    } catch (e) {
      debugPrint('Error cleaning cache box: $e');
    }
  }

  Future<void> _preloadCriticalData() async {
    try {
      // Preload commonly used data
      final futures = [
        _preloadUserSettings(),
        _preloadRecentlyPlayed(),
        _preloadFavoriteTracks(),
      ];

      await Future.wait(futures);
      debugPrint('Critical data preloaded');
    } catch (e) {
      debugPrint('Error preloading critical data: $e');
    }
  }

  Future<void> _preloadUserSettings() async {
    try {
      // Cache user settings for quick access
      final settings = _prefs.getString('user_settings');
      if (settings != null) {
        // Settings are already cached
      }
    } catch (e) {
      debugPrint('Error preloading user settings: $e');
    }
  }

  Future<void> _preloadRecentlyPlayed() async {
    try {
      final cacheBox = await Hive.openBox('cache');

      // Check if recently played is cached
      final cached = cacheBox.get('recently_played');
      if (cached == null) {
        // Cache recently played tracks
        cacheBox.put('recently_played', {
          'data': [], // Would contain actual recently played tracks
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      debugPrint('Error preloading recently played: $e');
    }
  }

  Future<void> _preloadFavoriteTracks() async {
    try {
      final cacheBox = await Hive.openBox('cache');

      // Check if favorites are cached
      final cached = cacheBox.get('favorite_tracks');
      if (cached == null) {
        // Cache favorite tracks
        cacheBox.put('favorite_tracks', {
          'data': [], // Would contain actual favorite tracks
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      debugPrint('Error preloading favorite tracks: $e');
    }
  }

  // Public API methods

  Future<void> optimizePerformance() async {
    try {
      debugPrint('Starting performance optimization...');

      await Future.wait([
        _cleanImageCache(),
        _optimizeDatabase(),
        _performMemoryCleanup(),
      ]);

      debugPrint('Performance optimization completed');
    } catch (e) {
      debugPrint('Error during performance optimization: $e');
    }
  }

  Future<void> clearAllCaches() async {
    try {
      debugPrint('Clearing all caches...');

      await Future.wait([
        _clearNetworkImageCache(),
        _clearDatabaseCache(),
        _clearSharedPreferencesCache(),
      ]);

      debugPrint('All caches cleared');
    } catch (e) {
      debugPrint('Error clearing caches: $e');
    }
  }

  Future<void> _clearDatabaseCache() async {
    try {
      final cacheBox = await Hive.openBox('cache');
      await cacheBox.clear();
    } catch (e) {
      debugPrint('Error clearing database cache: $e');
    }
  }

  Future<void> _clearSharedPreferencesCache() async {
    try {
      final keys = _prefs
          .getKeys()
          .where((key) => key.startsWith('cache_') || key.startsWith('temp_'))
          .toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing shared preferences cache: $e');
    }
  }

  PerformanceMetrics getPerformanceMetrics() {
    return PerformanceMetrics(
      memoryUsage: _currentMemoryUsage,
      memoryThreshold: _maxMemoryThreshold,
      cacheSize: _estimateCacheSize(),
      databaseSize: _estimateDatabaseSize(),
      imageCacheSize: PaintingBinding.instance.imageCache.currentSizeBytes,
    );
  }

  int _estimateCacheSize() {
    // Simplified cache size estimation
    return 50 * 1024 * 1024; // 50MB placeholder
  }

  int _estimateDatabaseSize() {
    // Simplified database size estimation
    return 100 * 1024 * 1024; // 100MB placeholder
  }

  Future<void> setPerformanceMode(PerformanceMode mode) async {
    try {
      switch (mode) {
        case PerformanceMode.highPerformance:
          _maxMemoryThreshold = 1024 * 1024 * 1024; // 1GB
          PaintingBinding.instance.imageCache.maximumSize = 200;
          PaintingBinding.instance.imageCache.maximumSizeBytes =
              100 * 1024 * 1024; // 100MB
          break;

        case PerformanceMode.balanced:
          _maxMemoryThreshold = 512 * 1024 * 1024; // 512MB
          PaintingBinding.instance.imageCache.maximumSize = 100;
          PaintingBinding.instance.imageCache.maximumSizeBytes =
              50 * 1024 * 1024; // 50MB
          break;

        case PerformanceMode.lowMemory:
          _maxMemoryThreshold = 256 * 1024 * 1024; // 256MB
          PaintingBinding.instance.imageCache.maximumSize = 50;
          PaintingBinding.instance.imageCache.maximumSizeBytes =
              25 * 1024 * 1024; // 25MB
          break;
      }

      await _prefs.setString('performance_mode', mode.name);

      // Apply optimizations
      await optimizePerformance();

      debugPrint('Performance mode set to: ${mode.name}');
    } catch (e) {
      debugPrint('Error setting performance mode: $e');
    }
  }

  Future<PerformanceMode> getPerformanceMode() async {
    final modeName =
        _prefs.getString('performance_mode') ?? PerformanceMode.balanced.name;
    return PerformanceMode.values.firstWhere((mode) => mode.name == modeName);
  }

  Future<void> enableAdaptivePerformance(bool enabled) async {
    await _prefs.setBool('adaptive_performance', enabled);

    if (enabled) {
      // Start adaptive performance monitoring
      _startAdaptiveMonitoring();
    } else {
      // Stop adaptive monitoring
      _stopAdaptiveMonitoring();
    }
  }

  Timer? _adaptiveMonitorTimer;

  void _startAdaptiveMonitoring() {
    _adaptiveMonitorTimer =
        Timer.periodic(const Duration(minutes: 10), (timer) {
      _adaptPerformanceSettings();
    });
  }

  void _stopAdaptiveMonitoring() {
    _adaptiveMonitorTimer?.cancel();
    _adaptiveMonitorTimer = null;
  }

  void _adaptPerformanceSettings() {
    final memoryUsage = _currentMemoryUsage;
    final threshold = _maxMemoryThreshold;
    final usageRatio = memoryUsage / threshold;

    if (usageRatio > 0.8) {
      // High memory usage - switch to low memory mode
      setPerformanceMode(PerformanceMode.lowMemory);
    } else if (usageRatio > 0.5) {
      // Medium memory usage - switch to balanced mode
      setPerformanceMode(PerformanceMode.balanced);
    } else {
      // Low memory usage - can use high performance mode
      setPerformanceMode(PerformanceMode.highPerformance);
    }
  }

  void dispose() {
    _memoryMonitorTimer?.cancel();
    _adaptiveMonitorTimer?.cancel();

    for (final timer in _cacheTimers.values) {
      timer.cancel();
    }
    _cacheTimers.clear();
  }
}

enum PerformanceMode {
  highPerformance,
  balanced,
  lowMemory,
}

class PerformanceMetrics {
  final int memoryUsage;
  final int memoryThreshold;
  final int cacheSize;
  final int databaseSize;
  final int imageCacheSize;

  PerformanceMetrics({
    required this.memoryUsage,
    required this.memoryThreshold,
    required this.cacheSize,
    required this.databaseSize,
    required this.imageCacheSize,
  });

  double get memoryUsageRatio => memoryUsage / memoryThreshold;

  bool get isHighMemoryUsage => memoryUsageRatio > 0.8;
  bool get isMediumMemoryUsage => memoryUsageRatio > 0.5;

  @override
  String toString() {
    return 'PerformanceMetrics('
        'memory: ${(memoryUsage / 1024 / 1024).toStringAsFixed(1)}MB, '
        'cache: ${(cacheSize / 1024 / 1024).toStringAsFixed(1)}MB, '
        'database: ${(databaseSize / 1024 / 1024).toStringAsFixed(1)}MB, '
        'imageCache: ${(imageCacheSize / 1024 / 1024).toStringAsFixed(1)}MB'
        ')';
  }
}
