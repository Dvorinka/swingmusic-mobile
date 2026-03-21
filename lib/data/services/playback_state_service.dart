import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/track_model.dart';
import '../../core/enums/playback_mode.dart';

class PlaybackStateService {
  static const String _keyQueue = 'playback_queue';
  static const String _keyCurrentIndex = 'playback_current_index';
  static const String _keyCurrentTrackHash = 'playback_current_track_hash';
  static const String _keyPosition = 'playback_position';
  static const String _keyRepeatMode = 'playback_repeat_mode';
  static const String _keyShuffleMode = 'playback_shuffle_mode';
  static const String _keyVolume = 'playback_volume';
  static const String _keyLastSaved = 'playback_last_saved';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveQueue(List<TrackModel> queue) async {
    try {
      final prefs = await _prefs;
      final queueJson = queue.map((track) => track.toJson()).toList();
      await prefs.setString(_keyQueue, jsonEncode(queueJson));
      
      if (kDebugMode) {
        debugPrint('Saved queue with ${queue.length} tracks');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save queue: $e');
      }
    }
  }

  Future<void> saveCurrentIndex(int index) async {
    try {
      final prefs = await _prefs;
      await prefs.setInt(_keyCurrentIndex, index);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save current index: $e');
      }
    }
  }

  Future<void> saveCurrentTrack(String trackHash) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyCurrentTrackHash, trackHash);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save current track: $e');
      }
    }
  }

  Future<void> savePosition(Duration position) async {
    try {
      final prefs = await _prefs;
      await prefs.setInt(_keyPosition, position.inMilliseconds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save position: $e');
      }
    }
  }

  Future<void> saveRepeatMode(RepeatMode mode) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyRepeatMode, mode.toString());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save repeat mode: $e');
      }
    }
  }

  Future<void> saveShuffleMode(ShuffleMode mode) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_keyShuffleMode, mode.toString());
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save shuffle mode: $e');
      }
    }
  }

  Future<void> saveVolume(double volume) async {
    try {
      final prefs = await _prefs;
      await prefs.setDouble(_keyVolume, volume);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save volume: $e');
      }
    }
  }

  Future<void> savePlaybackState({
    required List<TrackModel> queue,
    required int currentIndex,
    required String currentTrackHash,
    required Duration position,
    required RepeatMode repeatMode,
    required ShuffleMode shuffleMode,
    required double volume,
  }) async {
    try {
      final prefs = await _prefs;
      
      // Save all state in batch
      final queueJson = queue.map((track) => track.toJson()).toList();
      
      await Future.wait([
        prefs.setString(_keyQueue, jsonEncode(queueJson)),
        prefs.setInt(_keyCurrentIndex, currentIndex),
        prefs.setString(_keyCurrentTrackHash, currentTrackHash),
        prefs.setInt(_keyPosition, position.inMilliseconds),
        prefs.setString(_keyRepeatMode, repeatMode.toString()),
        prefs.setString(_keyShuffleMode, shuffleMode.toString()),
        prefs.setDouble(_keyVolume, volume),
        prefs.setInt(_keyLastSaved, DateTime.now().millisecondsSinceEpoch),
      ]);
      
      if (kDebugMode) {
        debugPrint('Saved complete playback state');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to save playback state: $e');
      }
    }
  }

  Future<List<TrackModel>> loadQueue() async {
    try {
      final prefs = await _prefs;
      final queueStr = prefs.getString(_keyQueue);
      
      if (queueStr == null) return [];
      
      final queueJson = jsonDecode(queueStr) as List<dynamic>;
      return queueJson.map((json) => TrackModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load queue: $e');
      }
      return [];
    }
  }

  Future<int> loadCurrentIndex() async {
    try {
      final prefs = await _prefs;
      return prefs.getInt(_keyCurrentIndex) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<String?> loadCurrentTrackHash() async {
    try {
      final prefs = await _prefs;
      return prefs.getString(_keyCurrentTrackHash);
    } catch (e) {
      return null;
    }
  }

  Future<Duration> loadPosition() async {
    try {
      final prefs = await _prefs;
      final ms = prefs.getInt(_keyPosition) ?? 0;
      return Duration(milliseconds: ms);
    } catch (e) {
      return Duration.zero;
    }
  }

  Future<RepeatMode> loadRepeatMode() async {
    try {
      final prefs = await _prefs;
      final modeStr = prefs.getString(_keyRepeatMode);
      
      if (modeStr == null) return RepeatMode.off;
      
      return RepeatMode.values.firstWhere(
        (mode) => mode.toString() == modeStr,
        orElse: () => RepeatMode.off,
      );
    } catch (e) {
      return RepeatMode.off;
    }
  }

  Future<ShuffleMode> loadShuffleMode() async {
    try {
      final prefs = await _prefs;
      final modeStr = prefs.getString(_keyShuffleMode);
      
      if (modeStr == null) return ShuffleMode.off;
      
      return ShuffleMode.values.firstWhere(
        (mode) => mode.toString() == modeStr,
        orElse: () => ShuffleMode.off,
      );
    } catch (e) {
      return ShuffleMode.off;
    }
  }

  Future<double> loadVolume() async {
    try {
      final prefs = await _prefs;
      return prefs.getDouble(_keyVolume) ?? 1.0;
    } catch (e) {
      return 1.0;
    }
  }

  Future<PlaybackState?> loadPlaybackState() async {
    try {
      final queue = await loadQueue();
      if (queue.isEmpty) return null;
      
      return PlaybackState(
        queue: queue,
        currentIndex: await loadCurrentIndex(),
        currentTrackHash: await loadCurrentTrackHash(),
        position: await loadPosition(),
        repeatMode: await loadRepeatMode(),
        shuffleMode: await loadShuffleMode(),
        volume: await loadVolume(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load playback state: $e');
      }
      return null;
    }
  }

  Future<void> clearPlaybackState() async {
    try {
      final prefs = await _prefs;
      await Future.wait([
        prefs.remove(_keyQueue),
        prefs.remove(_keyCurrentIndex),
        prefs.remove(_keyCurrentTrackHash),
        prefs.remove(_keyPosition),
        prefs.remove(_keyRepeatMode),
        prefs.remove(_keyShuffleMode),
        prefs.remove(_keyVolume),
        prefs.remove(_keyLastSaved),
      ]);
      
      if (kDebugMode) {
        debugPrint('Cleared playback state');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to clear playback state: $e');
      }
    }
  }

  Future<DateTime?> getLastSavedTime() async {
    try {
      final prefs = await _prefs;
      final ms = prefs.getInt(_keyLastSaved);
      return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasSavedState() async {
    try {
      final prefs = await _prefs;
      return prefs.containsKey(_keyQueue) && prefs.containsKey(_keyCurrentTrackHash);
    } catch (e) {
      return false;
    }
  }
}

class PlaybackState {
  final List<TrackModel> queue;
  final int currentIndex;
  final String? currentTrackHash;
  final Duration position;
  final RepeatMode repeatMode;
  final ShuffleMode shuffleMode;
  final double volume;

  PlaybackState({
    required this.queue,
    required this.currentIndex,
    this.currentTrackHash,
    required this.position,
    required this.repeatMode,
    required this.shuffleMode,
    required this.volume,
  });

  TrackModel? get currentTrack {
    if (queue.isEmpty || currentIndex < 0 || currentIndex >= queue.length) {
      return null;
    }
    return queue[currentIndex];
  }
}
