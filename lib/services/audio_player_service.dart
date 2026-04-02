import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'audio_player_handler.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler();
  final List<MediaItem> _queue = [];
  int _currentQueueIndex = 0;
  bool _isInitialized = false;
  StreamSubscription? _playerSubscription;

  // Authentication token for API requests
  String? _authToken;

  // Player state streams
  final StreamController<bool> _playingStateController =
      StreamController<bool>.broadcast();
  final StreamController<MediaItem?> _currentItemController =
      StreamController<MediaItem?>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController =
      StreamController<Duration?>.broadcast();
  final StreamController<List<MediaItem>> _queueController =
      StreamController<List<MediaItem>>.broadcast();
  final StreamController<bool> _shuffleModeController =
      StreamController<bool>.broadcast();
  final StreamController<AudioServiceRepeatMode> _repeatModeController =
      StreamController<AudioServiceRepeatMode>.broadcast();

  // Getters for streams
  Stream<bool> get playingStateStream => _playingStateController.stream;
  Stream<MediaItem?> get currentItemStream => _currentItemController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<List<MediaItem>> get queueStream => _queueController.stream;
  Stream<bool> get shuffleModeStream => _shuffleModeController.stream;
  Stream<AudioServiceRepeatMode> get repeatModeStream =>
      _repeatModeController.stream;

  // Current state getters
  bool get isPlaying => _audioPlayer.playing;
  bool get isPaused => !_audioPlayer.playing;
  List<MediaItem> get queue => List.unmodifiable(_queue);
  MediaItem? get currentItem =>
      _currentQueueIndex < _queue.length ? _queue[_currentQueueIndex] : null;
  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;

  Future<void> init({String? authToken}) async {
    if (_isInitialized) return;

    _authToken = authToken;

    try {
      // Request notification permissions
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          debugPrint('Notification permission not granted');
        }
      }

      // Initialize audio service with enhanced configuration
      await AudioService.init(
        builder: () => AudioPlayerHandler(),
        config: AudioServiceConfig(
          androidNotificationChannelName: 'SwingMusic',
          androidNotificationChannelDescription: 'SwingMusic playback controls',
          androidNotificationIcon: 'mipmap/ic_launcher',
          androidStopForegroundOnPause: false,
          androidNotificationOngoing: true,
          preloadArtwork: true,
          fastForwardInterval: const Duration(seconds: 30),
          rewindInterval: const Duration(seconds: 10),
        ),
      );

      // Set up player listeners
      _setupPlayerListeners();

      _isInitialized = true;
      debugPrint('AudioPlayerService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize AudioPlayerService: $e');
    }
  }

  void _setupPlayerListeners() {
    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      _playingStateController.add(state.playing);
    });

    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer.durationStream.listen((duration) {
      _durationController.add(duration);
    });
  }

  Future<void> play() async {
    try {
      await _audioHandler.play();
    } catch (e) {
      await _audioPlayer.play();
    }
  }

  Future<void> pause() async {
    try {
      await _audioHandler.pause();
    } catch (e) {
      await _audioPlayer.pause();
    }
  }

  Future<void> stop() async {
    try {
      await _audioHandler.stop();
    } catch (e) {
      await _audioPlayer.stop();
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioHandler.seek(position);
    } catch (e) {
      await _audioPlayer.seek(position);
    }
  }

  Future<void> setVolume(double volume) async {
    await _audioPlayer.setVolume(volume);
  }

  Future<void> setShuffleMode(bool enabled) async {
    try {
      await _audioHandler.setShuffleMode(
          enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
      _shuffleModeController.add(enabled);
    } catch (e) {
      // Fallback to local shuffle
      _shuffleModeController.add(enabled);
    }
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    try {
      await _audioHandler.setRepeatMode(mode);
      _repeatModeController.add(mode);
    } catch (e) {
      // Fallback to local repeat mode
      _repeatModeController.add(mode);
    }
  }

  Future<void> loadTrack(Map<String, dynamic> metadata) async {
    try {
      final mediaItem = MediaItem(
        id: metadata['id'].toString(),
        album: metadata['album']?.toString() ?? '',
        artist: metadata['artist']?.toString() ?? '',
        title: metadata['title']?.toString() ?? '',
        duration: Duration(milliseconds: metadata['duration']?.toInt() ?? 0),
        artUri: Uri.parse(metadata['image']?.toString() ?? ''),
        extras: {
          'url': metadata['url']?.toString() ?? '',
          'trackId': metadata['id'].toString(),
          ...metadata,
        },
      );

      // Add to queue if not already present
      if (!_queue.any((item) => item.id == mediaItem.id)) {
        _queue.add(mediaItem);
        _queueController.add(_queue);
      }

      _currentQueueIndex = _queue.indexWhere((item) => item.id == mediaItem.id);
      _currentItemController.add(mediaItem);

      // Load with authentication
      final headers =
          _authToken != null ? {'Authorization': 'Bearer $_authToken'} : null;

      if (metadata['url'] != null) {
        await _audioPlayer.setUrl(
          metadata['url'],
          headers: headers,
        );
        await play();
      }

      // Update AudioService
      try {
        await _audioHandler.updateMediaItem(mediaItem);
      } catch (e) {
        debugPrint('Failed to update AudioService media item: $e');
      }
    } catch (e) {
      debugPrint('Failed to load track: $e');
    }
  }

  Future<void> setQueue(List<Map<String, dynamic>> tracks) async {
    try {
      final mediaItems = tracks.map((track) {
        return MediaItem(
          id: track['id'].toString(),
          album: track['album']?.toString() ?? '',
          artist: track['artist']?.toString() ?? '',
          title: track['title']?.toString() ?? '',
          duration: Duration(milliseconds: track['duration']?.toInt() ?? 0),
          artUri: Uri.parse(track['image']?.toString() ?? ''),
          extras: {
            'url': track['url']?.toString() ?? '',
            'trackId': track['id'].toString(),
            ...track,
          },
        );
      }).toList();

      _queue.clear();
      _queue.addAll(mediaItems);
      _currentQueueIndex = 0;

      _queueController.add(_queue);

      // Update AudioService
      try {
        await _audioHandler.updateQueue(mediaItems);
      } catch (e) {
        debugPrint('Failed to update AudioService queue: $e');
      }
    } catch (e) {
      debugPrint('Failed to set queue: $e');
    }
  }

  Future<void> playNext() async {
    try {
      if (_currentQueueIndex < _queue.length - 1) {
        _currentQueueIndex++;
        final nextItem = _queue[_currentQueueIndex];
        await loadTrack(nextItem.extras ?? {});
      } else {
        // Handle repeat mode
        final repeatMode = await _repeatModeController.stream.first;
        if (repeatMode == AudioServiceRepeatMode.all) {
          _currentQueueIndex = 0;
          final firstItem = _queue[_currentQueueIndex];
          await loadTrack(firstItem.extras ?? {});
        }
      }
    } catch (e) {
      debugPrint('Failed to play next: $e');
    }
  }

  Future<void> playPrevious() async {
    try {
      if (_currentQueueIndex > 0) {
        _currentQueueIndex--;
        final prevItem = _queue[_currentQueueIndex];
        await loadTrack(prevItem.extras ?? {});
      }
    } catch (e) {
      debugPrint('Failed to play previous: $e');
    }
  }

  Future<void> dispose() async {
    _playerSubscription?.cancel();
    await _audioPlayer.dispose();

    await _playingStateController.close();
    await _currentItemController.close();
    await _positionController.close();
    await _durationController.close();
    await _queueController.close();
    await _shuffleModeController.close();
    await _repeatModeController.close();
  }

  // Enhanced methods for authentication and token management
  void updateAuthToken(String? token) {
    _authToken = token;
    // Could reinitialize current track with new token
  }

  // Queue management
  Future<void> addToQueue(Map<String, dynamic> track) async {
    final mediaItem = MediaItem(
      id: track['id'].toString(),
      album: track['album']?.toString() ?? '',
      artist: track['artist']?.toString() ?? '',
      title: track['title']?.toString() ?? '',
      duration: Duration(milliseconds: track['duration']?.toInt() ?? 0),
      artUri: Uri.parse(track['image']?.toString() ?? ''),
      extras: {
        'url': track['url']?.toString() ?? '',
        'trackId': track['id'].toString(),
        ...track,
      },
    );

    _queue.add(mediaItem);
    _queueController.add(_queue);

    try {
      await _audioHandler.addQueueItem(mediaItem);
    } catch (e) {
      debugPrint('Failed to add to AudioService queue: $e');
    }
  }

  Future<void> removeFromQueue(String trackId) async {
    _queue.removeWhere((item) => item.id == trackId);
    _queueController.add(_queue);

    try {
      final itemToRemove = _queue.firstWhere((item) => item.id == trackId);
      await _audioHandler.removeQueueItem(itemToRemove);
    } catch (e) {
      debugPrint('Failed to remove from AudioService queue: $e');
    }
  }

  // Legacy getters for compatibility
  bool get isLoading => false;
  Stream<MediaItem?> get currentMediaItemStream =>
      _currentItemController.stream;
  Stream<CustomQueueState> get queueStateStream => _queueController.stream
      .map((queue) => CustomQueueState(queue, queue.firstOrNull));
  Stream<double> get volumeStream => _audioPlayer.volumeStream;
}

// Custom QueueState class for compatibility
class CustomQueueState {
  final List<MediaItem> queue;
  final MediaItem? mediaItem;

  CustomQueueState(this.queue, this.mediaItem);

  String? get queueTitle => null;
}
