import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../data/services/audio_service.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/track_model.dart';
import '../../../core/enums/playback_mode.dart';

/// Enum representing the source of the playback queue.
/// Matches Android's QueueSource for logging purposes.
enum QueueSource {
  album,
  artist,
  folder,
  playlist,
  search,
  favorite,
  unknown,
}

class MediaControllerProvider extends ChangeNotifier {
  final AudioService _audioService;
  final EnhancedApiService _apiService;
  
  MediaControllerProvider({
    required AudioService audioService,
    required EnhancedApiService apiService,
  })  : _audioService = audioService,
        _apiService = apiService {
    _initializeListeners();
  }
  
  // Player state
  bool _isPlaying = false;
  final bool _isLoading = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  TrackModel? _currentTrack;
  String? _errorMessage;
  
  // Playback modes
  RepeatMode _repeatMode = RepeatMode.off;
  ShuffleMode _shuffleMode = ShuffleMode.off;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  
  // Queue
  List<TrackModel> _queue = [];
  final int _currentIndex = 0;
  
  // Playback logging state
  TrackModel? _trackToLog;
  DateTime? _trackStartTime;
  Duration _accumulatedPlayDuration = Duration.zero;
  QueueSource _queueSource = QueueSource.unknown;
  String? _sourceIdentifier; // albumhash, artisthash, folder path, playlist id, etc.
  Timer? _playDurationTimer;
  
  /// Minimum play duration in seconds before logging (matches Android: 5 seconds)
  static const int _minPlayDurationSeconds = 5;
  
  // Getters
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  TrackModel? get currentTrack => _currentTrack;
  String? get errorMessage => _errorMessage;
  RepeatMode get repeatMode => _repeatMode;
  ShuffleMode get shuffleMode => _shuffleMode;
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  List<TrackModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  
  bool get hasError => _errorMessage != null;
  bool get canPlay => _currentTrack != null && !hasError;
  bool get canPause => _isPlaying && !hasError;
  bool get canGoNext => _queue.isNotEmpty && _currentIndex < _queue.length - 1;
  bool get canGoPrevious => _queue.isNotEmpty && _currentIndex > 0;
  
  String get positionFormatted {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  String get durationFormatted {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }
  
  void _initializeListeners() {
    // Initialize audio service
    _audioService.init();
    
    // Listen to audio service streams
    _audioService.playingStateStream.listen((playing) {
      final wasPlaying = _isPlaying;
      _isPlaying = playing;
      
      // Handle play duration tracking
      if (playing && !wasPlaying) {
        _startPlayDurationTimer();
      } else if (!playing && wasPlaying) {
        _stopPlayDurationTimer();
      }
      
      notifyListeners();
    });
    
    _audioService.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });
    
    _audioService.durationStream.listen((duration) {
      _duration = duration;
      notifyListeners();
    });
    
    _audioService.currentTrackStream.listen((track) {
      // Log previous track before switching
      if (_trackToLog != null && _trackToLog != track) {
        _logTrackPlay(reason: 'track_changed');
      }
      
      _currentTrack = track;
      _trackToLog = track;
      _trackStartTime = DateTime.now();
      _accumulatedPlayDuration = Duration.zero;
      
      notifyListeners();
    });
    
    _audioService.queueStream.listen((queue) {
      _queue = queue;
      notifyListeners();
    });
    
    _audioService.bufferingStream.listen((buffering) {
      _isBuffering = buffering;
      notifyListeners();
    });
    
    _audioService.errorStream.listen((error) {
      _errorMessage = error;
      notifyListeners();
    });
    
    _audioService.repeatModeStream.listen((mode) {
      _repeatMode = mode;
      notifyListeners();
    });
    
    _audioService.shuffleModeStream.listen((mode) {
      _shuffleMode = mode;
      notifyListeners();
    });
  }
  
  /// Start timer to track play duration
  void _startPlayDurationTimer() {
    _trackStartTime ??= DateTime.now();
    _playDurationTimer?.cancel();
    _playDurationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying && !_isBuffering) {
        _accumulatedPlayDuration += const Duration(seconds: 1);
      }
    });
  }
  
  /// Stop play duration timer
  void _stopPlayDurationTimer() {
    _playDurationTimer?.cancel();
    _playDurationTimer = null;
  }
  
  /// Build source string for logging (matches Android format)
  String _buildSourceString() {
    switch (_queueSource) {
      case QueueSource.album:
        return 'al:${_sourceIdentifier ?? ''}';
      case QueueSource.artist:
        return 'ar:${_sourceIdentifier ?? ''}';
      case QueueSource.folder:
        return 'fo:${_sourceIdentifier ?? ''}';
      case QueueSource.playlist:
        return 'pl:${_sourceIdentifier ?? ''}';
      case QueueSource.search:
        return 'q:query';
      case QueueSource.favorite:
        return 'favorite';
      case QueueSource.unknown:
        return '';
    }
  }
  
  /// Log track play to server
  /// Called when track changes, playback stops, or app goes to background
  Future<void> _logTrackPlay({String? reason}) async {
    final track = _trackToLog;
    if (track == null) return;
    
    final playDurationSeconds = _accumulatedPlayDuration.inSeconds;
    
    if (playDurationSeconds < _minPlayDurationSeconds) {
      debugPrint('LOG: [$reason] Track NOT logged -> ${track.title}, duration: ${playDurationSeconds}s too short');
      return;
    }
    
    final source = _buildSourceString();
    
    debugPrint('LOG: [$reason] Logging track -> ${track.title}, duration: ${playDurationSeconds}s, source: $source');
    
    await _apiService.logTrackPlay(
      trackhash: track.trackhash,
      durationSeconds: playDurationSeconds,
      source: source,
    );
    
    // Reset accumulated duration after logging
    _accumulatedPlayDuration = Duration.zero;
  }
  
  /// Set the queue source for logging purposes
  void setQueueSource(QueueSource source, {String? identifier}) {
    _queueSource = source;
    _sourceIdentifier = identifier;
  }
  
  Future<void> play() async {
    try {
      await _audioService.play();
    } catch (e) {
      _setError('Failed to play: $e');
    }
  }
  
  Future<void> pause() async {
    try {
      await _audioService.pause();
    } catch (e) {
      _setError('Failed to pause: $e');
    }
  }
  
  Future<void> stop() async {
    try {
      await _audioService.stop();
    } catch (e) {
      _setError('Failed to stop: $e');
    }
  }
  
  Future<void> playNext() async {
    try {
      await _audioService.playNext();
    } catch (e) {
      _setError('Failed to play next: $e');
    }
  }
  
  Future<void> playPrevious() async {
    try {
      await _audioService.playPrevious();
    } catch (e) {
      _setError('Failed to play previous: $e');
    }
  }
  
  Future<void> seekTo(Duration position) async {
    try {
      await _audioService.seekTo(position);
    } catch (e) {
      _setError('Failed to seek: $e');
    }
  }
  
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioService.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set volume: $e');
    }
  }
  
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      _playbackSpeed = speed.clamp(0.5, 2.0);
      await _audioService.setSpeed(_playbackSpeed);
      notifyListeners();
    } catch (e) {
      _setError('Failed to set playback speed: $e');
    }
  }
  
  void toggleShuffle() {
    _audioService.toggleShuffle();
  }
  
  void toggleRepeat() {
    _audioService.toggleRepeat();
  }
  
  void setQueue(List<TrackModel> tracks) {
    _audioService.setQueue(tracks);
  }
  
  void addToQueue(TrackModel track) {
    _audioService.addToQueue(track);
  }
  
  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
  }
  
  void clearQueue() {
    _audioService.clearQueue();
  }
  
  void reorderQueue(int oldIndex, int newIndex) {
    _audioService.reorderQueue(oldIndex, newIndex);
  }
  
  void jumpToIndex(int index) {
    _audioService.jumpToIndex(index);
  }
  
  void _setError(String error) {
    _errorMessage = error;
    if (kDebugMode) {
      debugPrint('MediaController Error: $error');
    }
    notifyListeners();
  }
  
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  @override
  void dispose() {
    // Log final track before disposing
    _logTrackPlay(reason: 'app_dispose');
    _playDurationTimer?.cancel();
    // Don't dispose the audio service here as it's shared
    super.dispose();
  }
}
