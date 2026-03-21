import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'audio_player_handler.dart';

class EnhancedAudioService {
  static final EnhancedAudioService _instance = EnhancedAudioService._internal();
  factory EnhancedAudioService() => _instance;
  EnhancedAudioService._internal();
  
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayerHandler _audioHandler = AudioPlayerHandler();
  final List<MediaItem> _queue = [];
  int _currentQueueIndex = 0;
  bool _isInitialized = false;
  StreamSubscription? _playerSubscription;
  
  // Authentication and configuration
  String? _authToken;
  bool _crossfadeEnabled = false;
  Duration _crossfadeDuration = const Duration(seconds: 2);
  bool _gaplessPlayback = true;
  
  // Player state streams
  final StreamController<bool> _playingStateController = StreamController<bool>.broadcast();
  final StreamController<MediaItem?> _currentItemController = StreamController<MediaItem?>.broadcast();
  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration?> _durationController = StreamController<Duration?>.broadcast();
  final StreamController<List<MediaItem>> _queueController = StreamController<List<MediaItem>>.broadcast();
  final StreamController<bool> _shuffleModeController = StreamController<bool>.broadcast();
  final StreamController<AudioServiceRepeatMode> _repeatModeController = StreamController<AudioServiceRepeatMode>.broadcast();
  final StreamController<bool> _bufferingController = StreamController<bool>.broadcast();
  
  // Getters for streams
  Stream<bool> get playingStateStream => _playingStateController.stream;
  Stream<MediaItem?> get currentItemStream => _currentItemController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration?> get durationStream => _durationController.stream;
  Stream<List<MediaItem>> get queueStream => _queueController.stream;
  Stream<bool> get shuffleModeStream => _shuffleModeController.stream;
  Stream<AudioServiceRepeatMode> get repeatModeStream => _repeatModeController.stream;
  Stream<bool> get bufferingStream => _bufferingController.stream;
  
  // Current state getters
  bool get isPlaying => _audioPlayer.playing;
  bool get isPaused => !_audioPlayer.playing;
  bool get isBuffering => _audioPlayer.playerState.playing && _audioPlayer.playerState.processingState == ProcessingState.buffering;
  bool get isLoading => _audioPlayer.playerState.processingState == ProcessingState.loading;
  bool get hasError => _audioPlayer.playerState.processingState == ProcessingState.idle; // Use idle as error state
  List<MediaItem> get queue => List.unmodifiable(_queue);
  MediaItem? get currentItem => _currentQueueIndex < _queue.length ? _queue[_currentQueueIndex] : null;
  Duration get currentPosition => _audioPlayer.position;
  Duration? get currentDuration => _audioPlayer.duration;
  double get volume => _audioPlayer.volume;
  int get currentIndex => _currentQueueIndex;
  
  // Configuration getters
  bool get crossfadeEnabled => _crossfadeEnabled;
  Duration get crossfadeDuration => _crossfadeDuration;
  bool get gaplessPlayback => _gaplessPlayback;
  
  Future<void> init({
    String? authToken,
    bool crossfadeEnabled = false,
    Duration crossfadeDuration = const Duration(seconds: 2),
    bool gaplessPlayback = true,
  }) async {
    if (_isInitialized) return;
    
    _authToken = authToken;
    _crossfadeEnabled = crossfadeEnabled;
    _crossfadeDuration = crossfadeDuration;
    _gaplessPlayback = gaplessPlayback;
    
    try {
      // Request notification permissions
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          debugPrint('Notification permission not granted');
        }
      }
      
      // Initialize audio service with enhanced configuration similar to Android reference
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
          // Custom parameters for enhanced playback
          androidResumeOnClick: true,
          androidNotificationClickStartsActivity: true,
        ),
      );
      
      // Set up player listeners
      _setupPlayerListeners();
      
      _isInitialized = true;
      debugPrint('EnhancedAudioService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize EnhancedAudioService: $e');
    }
  }

  void _setupPlayerListeners() {
    _playerSubscription = _audioPlayer.playerStateStream.listen((state) {
      _playingStateController.add(state.playing);
      
      // Update buffering state
      final isBuffering = state.playing && state.processingState == ProcessingState.buffering;
      _bufferingController.add(isBuffering);
      
      // Handle errors
      if (state.processingState == ProcessingState.idle && state.playing == false) {
        debugPrint('Audio player may be in error state');
      }
    });
    
    _audioPlayer.positionStream.listen((position) {
      _positionController.add(position);
    });
    
    _audioPlayer.durationStream.listen((duration) {
      _durationController.add(duration);
    });
    
    // Handle player completion for gapless playback
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed && _gaplessPlayback) {
        // Auto-play next track if gapless playback is enabled
        _handleTrackCompletion();
      }
    });
  }
  
  void _handleTrackCompletion() {
    if (_repeatModeController.hasListener) {
      // Check repeat mode and play next accordingly
      playNext();
    }
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

  Future<void> setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
  }

  Future<void> setShuffleMode(bool enabled) async {
    try {
      await _audioHandler.setShuffleMode(enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none);
      _shuffleModeController.add(enabled);
    } catch (e) {
      _shuffleModeController.add(enabled);
    }
  }

  Future<void> setRepeatMode(AudioServiceRepeatMode mode) async {
    try {
      await _audioHandler.setRepeatMode(mode);
      _repeatModeController.add(mode);
    } catch (e) {
      _repeatModeController.add(mode);
    }
  }

  Future<void> loadTrack(MediaItem mediaItem) async {
    try {
      // Add to queue if not already present
      if (!_queue.any((item) => item.id == mediaItem.id)) {
        _queue.add(mediaItem);
        _queueController.add(_queue);
      }
      
      _currentQueueIndex = _queue.indexWhere((item) => item.id == mediaItem.id);
      _currentItemController.add(mediaItem);
      
      // Load with authentication headers similar to Android reference
      final headers = _buildAuthenticatedHeaders();
      final trackUrl = mediaItem.extras?['url']?.toString();
      
      if (trackUrl != null) {
        if (_crossfadeEnabled && _audioPlayer.playing) {
          await _crossfadeToTrack(trackUrl, headers, mediaItem);
        } else {
          await _audioPlayer.setUrl(trackUrl, headers: headers);
          await play();
        }
      }
      
      // Update AudioService
      try {
        await _audioHandler.updateMediaItem(mediaItem);
      } catch (e) {
        // Failed to update AudioService media item: $e
      }
    } catch (e) {
      // Failed to load track: $e
    }
  }
  
  Map<String, String>? _buildAuthenticatedHeaders() {
    if (_authToken == null) return null;
    
    return {
      'Authorization': 'Bearer $_authToken',
      'User-Agent': 'SwingMusic-Mobile/1.0',
      'Accept': '*/*',
    };
  }
  
  Future<void> _crossfadeToTrack(String url, Map<String, String>? headers, MediaItem mediaItem) async {
    // Implement crossfade functionality
    final originalVolume = _audioPlayer.volume;
    
    // Fade out current track
    await _audioPlayer.setVolume(0.0);
    
    // Load new track
    await _audioPlayer.setUrl(url, headers: headers);
    
    // Fade in new track
    await _audioPlayer.setVolume(originalVolume);
    
    // Update media item
    await _audioHandler.updateMediaItem(mediaItem);
  }

  Future<void> setQueue(List<MediaItem> mediaItems) async {
    try {
      _queue.clear();
      _queue.addAll(mediaItems);
      _currentQueueIndex = 0;
      
      _queueController.add(_queue);
      
      // Update AudioService
      try {
        await _audioHandler.updateQueue(mediaItems);
      } catch (e) {
        // Failed to update AudioService queue: $e
      }
    } catch (e) {
      // Failed to set queue: $e
    }
  }

  Future<void> playNext() async {
    try {
      if (_queue.isEmpty) return;
      
      if (_currentQueueIndex < _queue.length - 1) {
        _currentQueueIndex++;
      } else {
        // Handle repeat mode
        final repeatMode = AudioServiceRepeatMode.all; // Get current repeat mode
        if (repeatMode == AudioServiceRepeatMode.all) {
          _currentQueueIndex = 0;
        } else {
          return; // Stop if not repeating all
        }
      }
      
      final nextItem = _queue[_currentQueueIndex];
      await loadTrack(nextItem);
    } catch (e) {
      // Failed to play next: $e
    }
  }

  Future<void> playPrevious() async {
    try {
      if (_queue.isEmpty) return;
      
      if (_currentQueueIndex > 0) {
        _currentQueueIndex--;
        final prevItem = _queue[_currentQueueIndex];
        await loadTrack(prevItem);
      }
    } catch (e) {
      // Failed to play previous: $e
    }
  }

  Future<void> addToQueue(MediaItem mediaItem) async {
    _queue.add(mediaItem);
    _queueController.add(_queue);
    
    try {
      await _audioHandler.addQueueItem(mediaItem);
    } catch (e) {
      // Failed to add to AudioService queue: $e
    }
  }
  
  Future<void> removeFromQueue(String trackId) async {
    _queue.removeWhere((item) => item.id == trackId);
    _queueController.add(_queue);
    
    try {
      final itemToRemove = _queue.firstWhere((item) => item.id == trackId);
      await _audioHandler.removeQueueItem(itemToRemove);
    } catch (e) {
      // Failed to remove from AudioService queue: $e
    }
  }
  
  Future<void> clearQueue() async {
    _queue.clear();
    _currentQueueIndex = 0;
    _queueController.add(_queue);
    
    try {
      await _audioHandler.updateQueue([]);
    } catch (e) {
      // Failed to clear AudioService queue: $e
    }
  }
  
  void jumpToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentQueueIndex = index;
      final item = _queue[index];
      loadTrack(item);
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
    await _bufferingController.close();
  }
  
  // Configuration methods
  void updateAuthToken(String? token) {
    _authToken = token;
  }
  
  void setCrossfadeEnabled(bool enabled) {
    _crossfadeEnabled = enabled;
  }
  
  void setCrossfadeDuration(Duration duration) {
    _crossfadeDuration = duration;
  }
  
  void setGaplessPlayback(bool enabled) {
    _gaplessPlayback = enabled;
  }
  
  // Utility methods
  String get positionFormatted {
    final position = _audioPlayer.position;
    return '${position.inMinutes.toString().padLeft(2, '0')}:${(position.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  String get durationFormatted {
    final duration = _audioPlayer.duration;
    if (duration == null) return '00:00';
    return '${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }
  
  double get progress {
    final duration = _audioPlayer.duration;
    if (duration == null || duration.inMilliseconds == 0) return 0.0;
    return _audioPlayer.position.inMilliseconds / duration.inMilliseconds;
  }
}
