import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import '../models/track_model.dart';
import '../../core/enums/playback_mode.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  late AudioPlayer _audioPlayer;
  late AudioSession _audioSession;

  // Playback state
  TrackModel? _currentTrack;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final double _volume = 1.0;

  // Playback modes
  RepeatMode _repeatMode = RepeatMode.off;
  ShuffleMode _shuffleMode = ShuffleMode.off;
  final double _playbackSpeed = 1.0;

  // Playlist
  List<TrackModel> _queue = [];
  int _currentIndex = 0;
  final bool _isShuffleMode = false;
  final bool _isRepeatMode = false;

  // Error handling
  String? _errorMessage;

  void _setError(String error) {
    _errorMessage = error;
    _errorController.add(_errorMessage);
    debugPrint('Audio Error: $error');
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _errorController.add(_errorMessage);
    }
  }

  // Stream controllers
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _playingStateController = StreamController<bool>.broadcast();
  final _currentTrackController = StreamController<TrackModel?>.broadcast();
  final _queueController = StreamController<List<TrackModel>>.broadcast();
  final _bufferingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String?>.broadcast();
  final _repeatModeController = StreamController<RepeatMode>.broadcast();
  final _shuffleModeController = StreamController<ShuffleMode>.broadcast();

  // Getters
  TrackModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;
  bool get isPaused => !_isPlaying && _currentTrack != null;
  bool get isLoading => _isLoading;
  bool get isBuffering => _isBuffering;
  Duration get position => _position;
  Duration get duration => _duration;
  double get volume => _volume;
  List<TrackModel> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get isShuffleMode => _isShuffleMode;
  bool get isRepeatMode => _isRepeatMode;
  RepeatMode get repeatMode => _repeatMode;
  ShuffleMode get shuffleMode => _shuffleMode;
  double get playbackSpeed => _playbackSpeed;
  String? get errorMessage => _errorMessage;

  // Playback state helpers
  bool get hasError => _errorMessage != null;
  bool get canPlay => _currentTrack != null && !hasError;
  bool get canPause => _isPlaying && !hasError;
  bool get canGoNext => _queue.isNotEmpty && _currentIndex < _queue.length - 1;
  bool get canGoPrevious => _queue.isNotEmpty && _currentIndex > 0;

  // Streams
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStateStream => _playingStateController.stream;
  Stream<TrackModel?> get currentTrackStream => _currentTrackController.stream;
  Stream<List<TrackModel>> get queueStream => _queueController.stream;
  Stream<bool> get bufferingStream => _bufferingController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<RepeatMode> get repeatModeStream => _repeatModeController.stream;
  Stream<ShuffleMode> get shuffleModeStream => _shuffleModeController.stream;

  Future<void> init() async {
    try {
      _audioPlayer = AudioPlayer();
      _audioSession = await AudioSession.instance;

      // Configure audio session
      await _audioSession.configure(const AudioSessionConfiguration.music());

      // Set up listeners
      _audioPlayer.positionStream.listen((position) {
        _position = position;
        _positionController.add(position);
      });

      _audioPlayer.durationStream.listen((duration) {
        _duration = duration ?? Duration.zero;
        _durationController.add(_duration);
      });

      _audioPlayer.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        _playingStateController.add(_isPlaying);
      });

      // Handle player completion
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _playNext();
        }

        // Handle buffering state
        _isBuffering = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        _bufferingController.add(_isBuffering);
      });

      // Handle player errors
      _audioPlayer.playerStateStream.listen((state) {
        if (state.playing && _errorMessage != null) {
          _clearError();
        }
      });

      debugPrint('Audio service initialized successfully');
    } catch (e) {
      throw Exception('Failed to initialize audio service: $e');
    }
  }

  Future<void> loadTrack(TrackModel track) async {
    try {
      _clearError();
      _isLoading = true;
      _isBuffering = true;
      _currentTrack = track;
      _currentTrackController.add(_currentTrack);
      _bufferingController.add(_isBuffering);

      // Create audio source from track filepath
      final uri = Uri.parse(track.filepath);
      await _audioPlayer.setAudioSource(AudioSource.uri(uri));

      _isLoading = false;
      _isBuffering = false;
      _bufferingController.add(_isBuffering);
      debugPrint('Track loaded: ${track.title}');
    } catch (e) {
      _isLoading = false;
      _isBuffering = false;
      _bufferingController.add(_isBuffering);
      _setError('Failed to load track: $e');
      throw Exception('Failed to load track: $e');
    }
  }

  Future<void> play() async {
    try {
      _clearError();
      if (_currentTrack != null && !hasError) {
        await _audioPlayer.play();
        _isPlaying = true;
        _playingStateController.add(_isPlaying);
        debugPrint('Playing: ${_currentTrack?.title}');
      }
    } catch (e) {
      _setError('Failed to play: $e');
      throw Exception('Failed to play: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;
      _playingStateController.add(_isPlaying);
      debugPrint('Paused: ${_currentTrack?.title}');
    } catch (e) {
      _setError('Failed to pause: $e');
      throw Exception('Failed to pause: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _position = Duration.zero;
      _playingStateController.add(_isPlaying);
      _positionController.add(_position);
      _clearError();
      debugPrint('Stopped: ${_currentTrack?.title}');
    } catch (e) {
      _setError('Failed to stop: $e');
      throw Exception('Failed to stop: $e');
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _position = position;
      _positionController.add(_position);
    } catch (e) {
      throw Exception('Failed to seek: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      throw Exception('Failed to set volume: $e');
    }
  }

  Future<void> setSpeed(double speed) async {
    try {
      await _audioPlayer.setSpeed(speed);
    } catch (e) {
      throw Exception('Failed to set speed: $e');
    }
  }

  // Queue management
  void setQueue(List<TrackModel> tracks) {
    _queue = List.from(tracks);
    _currentIndex = 0;
    _queueController.add(_queue);

    if (_queue.isNotEmpty && _currentTrack == null) {
      loadTrack(_queue[_currentIndex]);
    }
  }

  void addToQueue(TrackModel track) {
    _queue.add(track);
    _queueController.add(_queue);
  }

  void removeFromQueue(int index) {
    if (index < _queue.length) {
      _queue.removeAt(index);
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        if (_currentIndex >= _queue.length) {
          _currentIndex = _queue.length - 1;
        }
        loadTrack(_queue[_currentIndex]);
      }
      _queueController.add(_queue);
    }
  }

  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    _queueController.add(_queue);
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < _queue.length && newIndex < _queue.length) {
      final track = _queue.removeAt(oldIndex);
      _queue.insert(newIndex, track);

      // Update current index if needed
      if (_currentIndex == oldIndex) {
        _currentIndex = newIndex;
      } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
        _currentIndex--;
      } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
        _currentIndex++;
      }

      _queueController.add(_queue);
    }
  }

  Future<void> playNext() async {
    if (_queue.isNotEmpty) {
      _playNext();
    }
  }

  Future<void> playPrevious() async {
    if (_queue.isNotEmpty) {
      if (_currentIndex > 0) {
        _currentIndex--;
        await loadTrack(_queue[_currentIndex]);
        await play();
      } else if (_repeatMode == RepeatMode.all) {
        // Loop to last track
        _currentIndex = _queue.length - 1;
        await loadTrack(_queue[_currentIndex]);
        await play();
      } else {
        // Restart current track if at beginning
        await seekTo(Duration.zero);
        await play();
      }
    }
  }

  void _playNext() {
    if (_repeatMode == RepeatMode.one) {
      // Repeat current track
      loadTrack(_queue[_currentIndex]);
      play();
    } else if (_shuffleMode == ShuffleMode.on) {
      // Play random track
      if (_queue.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % _queue.length;
        loadTrack(_queue[_currentIndex]);
        play();
      }
    } else {
      // Play next track in order
      if (_currentIndex < _queue.length - 1) {
        _currentIndex++;
        loadTrack(_queue[_currentIndex]);
        play();
      } else if (_repeatMode == RepeatMode.all) {
        // Loop back to first track
        _currentIndex = 0;
        loadTrack(_queue[_currentIndex]);
        play();
      } else {
        // End of queue
        stop();
      }
    }
  }

  void jumpToIndex(int index) {
    if (index >= 0 && index < _queue.length) {
      _currentIndex = index;
      loadTrack(_queue[_currentIndex]);
    }
  }

  // Playback modes
  void toggleShuffle() {
    _shuffleMode = _shuffleMode.toggle();
    _shuffleModeController.add(_shuffleMode);

    if (_shuffleMode == ShuffleMode.on && _queue.isNotEmpty) {
      // Shuffle the queue while maintaining current track
      final currentTrack = _queue[_currentIndex];
      _queue.shuffle();
      _currentIndex = _queue.indexOf(currentTrack);
      _queueController.add(_queue);
    }
  }

  void toggleRepeat() {
    _repeatMode = _repeatMode.next();
    _repeatModeController.add(_repeatMode);
  }

  void setShuffleMode(bool enabled) {
    _shuffleMode = enabled ? ShuffleMode.on : ShuffleMode.off;
    _shuffleModeController.add(_shuffleMode);

    if (_shuffleMode == ShuffleMode.on && _queue.isNotEmpty) {
      // Shuffle the queue while maintaining current track
      final currentTrack = _queue[_currentIndex];
      _queue.shuffle();
      _currentIndex = _queue.indexOf(currentTrack);
      _queueController.add(_queue);
    }
  }

  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    _repeatModeController.add(_repeatMode);
  }

  // Utility methods
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

  Future<void> dispose() async {
    await _positionController.close();
    await _durationController.close();
    await _playingStateController.close();
    await _currentTrackController.close();
    await _queueController.close();
    await _audioPlayer.dispose();
  }
}
