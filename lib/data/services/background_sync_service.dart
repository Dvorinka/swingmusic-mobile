import 'dart:async';
import 'package:flutter/foundation.dart';
// import 'package:workmanager/workmanager.dart';  // Temporarily disabled due to compatibility issues
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/enhanced_api_service.dart';
import '../models/sync_model.dart';

class BackgroundSyncService {
  late final EnhancedApiService _apiService;
  late final SharedPreferences _prefs;
  Timer? _syncTimer;
  bool _isSyncing = false;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  Stream<SyncStatus> get syncStatus => _statusController.stream;

  BackgroundSyncService() {
    _apiService = EnhancedApiService();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(SyncModelAdapter());
      Hive.registerAdapter(SyncTypeAdapter());
      await Hive.openBox<SyncModel>('sync_queue');
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
    }
  }

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Initialize WorkManager
      // await Workmanager().initialize(
      //   callbackDispatcher,
      // );

      // Start immediate sync if needed
      await _checkAndStartSync();

      debugPrint('Background sync service initialized');
    } catch (e) {
      debugPrint('Error initializing background sync: $e');
    }
  }

  Future<void> _checkAndStartSync() async {
    final lastSyncTime = _prefs.getInt('last_sync_time') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final syncInterval = _prefs.getInt('sync_interval_hours') ?? 6;

    if (now - lastSyncTime > syncInterval * 60 * 60 * 1000) {
      await startSync();
    }
  }

  Future<void> startSync({bool force = false}) async {
    if (_isSyncing && !force) {
      debugPrint('Sync already in progress');
      return;
    }

    try {
      _isSyncing = true;
      _statusController.add(SyncStatus(status: SyncStatusType.syncing));

      debugPrint('Starting background sync...');

      // Sync user settings
      await _syncUserSettings();

      // Sync library data
      await _syncLibraryData();

      // Sync playlists
      await _syncPlaylists();

      // Sync listening history
      await _syncListeningHistory();

      // Sync downloads
      await _syncDownloads();

      // Update last sync time
      await _prefs.setInt(
          'last_sync_time', DateTime.now().millisecondsSinceEpoch);

      _statusController.add(SyncStatus(
        status: SyncStatusType.completed,
        message: 'Sync completed successfully',
      ));

      debugPrint('Background sync completed');
    } catch (e) {
      debugPrint('Error during sync: $e');
      _statusController.add(SyncStatus(
        status: SyncStatusType.error,
        message: 'Sync failed: $e',
      ));

      // Add to retry queue
      await _addToRetryQueue();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncUserSettings() async {
    try {
      // Get local settings
      final localSettings = await _getLocalSettings();

      // Get server settings
      final serverSettings = await _apiService.getUserSettings();

      // Merge settings (server takes precedence)
      final mergedSettings = _mergeSettings(localSettings, serverSettings);

      // Update local settings if needed
      if (_shouldUpdateSettings(localSettings, serverSettings)) {
        await _updateLocalSettings(mergedSettings);
      }

      // Push local changes to server if needed
      if (_hasLocalChanges(localSettings, serverSettings)) {
        await _apiService.updateUserSettings(localSettings);
      }
    } catch (e) {
      debugPrint('Error syncing user settings: $e');
      rethrow;
    }
  }

  Future<void> _syncLibraryData() async {
    try {
      // Get last library sync timestamp
      final lastLibrarySync = _prefs.getInt('last_library_sync') ?? 0;

      // Get changes since last sync
      final libraryChanges =
          await _apiService.getLibraryChanges(lastLibrarySync);

      // Process library changes
      await _processLibraryChanges(libraryChanges);

      // Update last library sync timestamp
      await _prefs.setInt(
          'last_library_sync', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error syncing library data: $e');
      rethrow;
    }
  }

  Future<void> _syncPlaylists() async {
    try {
      // Get local playlists
      final localPlaylists = await _getLocalPlaylists();

      // Get server playlists
      final serverPlaylists = await _apiService.getPlaylists();
      final serverPlaylistsMap =
          serverPlaylists.map((playlist) => playlist.toJson()).toList();

      // Sync playlists
      await _syncPlaylistData(localPlaylists, serverPlaylistsMap);
    } catch (e) {
      debugPrint('Error syncing playlists: $e');
      rethrow;
    }
  }

  Future<void> _syncListeningHistory() async {
    try {
      // Get unsynced listening history
      final unsyncedHistory = await _getUnsyncedHistory();

      if (unsyncedHistory.isNotEmpty) {
        // Convert to List<Map<String, dynamic>> if needed
        final historyMap = unsyncedHistory.cast<Map<String, dynamic>>();

        // Send to server
        await _apiService.syncListeningHistory(historyMap);

        // Mark as synced
        await _markHistoryAsSynced(historyMap);
      }
    } catch (e) {
      debugPrint('Error syncing listening history: $e');
      rethrow;
    }
  }

  Future<void> _syncDownloads() async {
    try {
      // Sync download status
      final downloads = await _apiService.getDownloads();
      final downloadsMap = downloads.cast<Map<String, dynamic>>();
      await _updateLocalDownloads(downloadsMap);
    } catch (e) {
      debugPrint('Error syncing downloads: $e');
      rethrow;
    }
  }

  Future<void> _addToRetryQueue() async {
    try {
      final syncQueue = Hive.box<SyncModel>('sync_queue');

      final syncItem = SyncModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: SyncType.full,
        data: {},
        timestamp: DateTime.now(),
        retryCount: 0,
        maxRetries: 3,
        nextRetryTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await syncQueue.add(syncItem);
      debugPrint('Added sync item to retry queue');
    } catch (e) {
      debugPrint('Error adding to retry queue: $e');
    }
  }

  Future<void> processRetryQueue() async {
    try {
      final syncQueue = Hive.box<SyncModel>('sync_queue');
      final items = syncQueue.values
          .where((item) =>
              item.nextRetryTime.isBefore(DateTime.now()) &&
              item.retryCount < item.maxRetries)
          .toList();

      for (final item in items) {
        try {
          await _processSyncItem(item);
          await syncQueue.delete(item.id);
        } catch (e) {
          // Update retry count and next retry time
          item.retryCount++;
          item.nextRetryTime = DateTime.now().add(Duration(
            hours: item.retryCount * 2,
          ));
          await item.save();
        }
      }
    } catch (e) {
      debugPrint('Error processing retry queue: $e');
    }
  }

  Future<void> _processSyncItem(SyncModel item) async {
    switch (item.type) {
      case SyncType.full:
        await startSync(force: true);
        break;
      case SyncType.settings:
        await _syncUserSettings();
        break;
      case SyncType.library:
        await _syncLibraryData();
        break;
      case SyncType.playlists:
        await _syncPlaylists();
        break;
      case SyncType.history:
        await _syncListeningHistory();
        break;
    }
  }

  Future<void> setSyncInterval(int hours) async {
    await _prefs.setInt('sync_interval_hours', hours);

    // Reschedule periodic task with new interval
    // await Workmanager().cancelAll();
    // await _schedulePeriodicSync();
    debugPrint('Sync interval updated (workmanager unavailable)');
  }

  Future<void> enableAutoSync(bool enabled) async {
    await _prefs.setBool('auto_sync_enabled', enabled);

    if (enabled) {
      await _checkAndStartSync();
    } else {
      // await Workmanager().cancelAll();
      debugPrint('Auto sync disabled (workmanager unavailable)');
    }
  }

  Future<SyncInfo> getSyncInfo() async {
    final lastSyncTime = _prefs.getInt('last_sync_time') ?? 0;
    final lastSync = DateTime.fromMillisecondsSinceEpoch(lastSyncTime);
    final autoSyncEnabled = _prefs.getBool('auto_sync_enabled') ?? true;
    final syncInterval = _prefs.getInt('sync_interval_hours') ?? 6;

    return SyncInfo(
      lastSyncTime: lastSync,
      autoSyncEnabled: autoSyncEnabled,
      syncInterval: Duration(hours: syncInterval),
      isSyncing: _isSyncing,
      nextSyncTime: lastSync.add(Duration(hours: syncInterval)),
    );
  }

  void dispose() {
    _syncTimer?.cancel();
    _statusController.close();
  }
}

// WorkManager callback
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     try {
//       final syncService = BackgroundSyncService();
//       await syncService.startSync();
//       return true;
//     } catch (e) {
//       debugPrint('Background sync task failed: $e');
//       return false;
//     }
//   });
// }

// Models
enum SyncStatusType { idle, syncing, completed, error }

class SyncStatus {
  final SyncStatusType status;
  final String? message;
  final int? progress;

  SyncStatus({
    required this.status,
    this.message,
    this.progress,
  });
}

class SyncInfo {
  final DateTime lastSyncTime;
  final bool autoSyncEnabled;
  final Duration syncInterval;
  final bool isSyncing;
  final DateTime nextSyncTime;

  SyncInfo({
    required this.lastSyncTime,
    required this.autoSyncEnabled,
    required this.syncInterval,
    required this.isSyncing,
    required this.nextSyncTime,
  });
}

enum SyncType { full, settings, library, playlists, history }

@HiveType(typeId: 0)
class SyncModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  SyncType type;

  @HiveField(2)
  Map<String, dynamic> data;

  @HiveField(3)
  DateTime timestamp;

  @HiveField(4)
  int retryCount;

  @HiveField(5)
  int maxRetries;

  @HiveField(6)
  DateTime nextRetryTime;

  SyncModel({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.retryCount,
    required this.maxRetries,
    required this.nextRetryTime,
  });
}

// Helper methods
Future<Map<String, dynamic>> _getLocalSettings() async {
  // Implementation for getting local settings
  return {};
}

Future<void> _updateLocalSettings(Map<String, dynamic> settings) async {
  // Implementation for updating local settings
}

Map<String, dynamic> _mergeSettings(
    Map<String, dynamic> local, Map<String, dynamic> server) {
  // Implementation for merging settings
  return server;
}

bool _shouldUpdateSettings(
    Map<String, dynamic> local, Map<String, dynamic> server) {
  // Implementation for checking if settings should be updated
  return true;
}

bool _hasLocalChanges(Map<String, dynamic> local, Map<String, dynamic> server) {
  // Implementation for checking if there are local changes
  return false;
}

Future<List<Map<String, dynamic>>> _getLocalPlaylists() async {
  // Implementation for getting local playlists
  return [];
}

Future<void> _syncPlaylistData(
    List<Map<String, dynamic>> local, List<Map<String, dynamic>> server) async {
  // Implementation for syncing playlist data
}

Future<List<Map<String, dynamic>>> _getUnsyncedHistory() async {
  // Implementation for getting unsynced history
  return [];
}

Future<void> _markHistoryAsSynced(List<Map<String, dynamic>> history) async {
  // Implementation for marking history as synced
}

Future<void> _updateLocalDownloads(List<Map<String, dynamic>> downloads) async {
  // Implementation for updating local downloads
}

Future<void> _processLibraryChanges(Map<String, dynamic> changes) async {
  // Implementation for processing library changes
}
