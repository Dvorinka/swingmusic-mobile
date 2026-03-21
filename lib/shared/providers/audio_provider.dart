import 'package:flutter/foundation.dart';
import '../../data/services/audio_service.dart';
import '../../data/models/track_model.dart';
import '../../core/enums/playback_mode.dart';

class AudioProvider extends ChangeNotifier {
  final AudioService _audioService = AudioService();

  // Getters for audio state
  TrackModel? get currentTrack => _audioService.currentTrack;
  bool get isPlaying => _audioService.isPlaying;
  bool get isPaused => _audioService.isPaused;
  bool get isLoading => _audioService.isLoading;
  bool get isBuffering => _audioService.isBuffering;
  bool get hasError => _audioService.hasError;
  String? get errorMessage => _audioService.errorMessage;
  Duration get position => _audioService.position;
  Duration get duration => _audioService.duration;
  double get volume => _audioService.volume;
  List<TrackModel> get queue => _audioService.queue;
  int get currentIndex => _audioService.currentIndex;
  bool get isShuffleMode => _audioService.isShuffleMode;
  bool get isRepeatMode => _audioService.isRepeatMode;
  RepeatMode get repeatMode => _audioService.repeatMode;
  ShuffleMode get shuffleMode => _audioService.shuffleMode;
  double get playbackSpeed => _audioService.playbackSpeed;

  // Streams
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration> get durationStream => _audioService.durationStream;
  Stream<bool> get playingStateStream => _audioService.playingStateStream;
  Stream<TrackModel?> get currentTrackStream => _audioService.currentTrackStream;
  Stream<List<TrackModel>> get queueStream => _audioService.queueStream;
  Stream<bool> get bufferingStream => _audioService.bufferingStream;
  Stream<String?> get errorStream => _audioService.errorStream;
  Stream<RepeatMode> get repeatModeStream => _audioService.repeatModeStream;
  Stream<ShuffleMode> get shuffleModeStream => _audioService.shuffleModeStream;

  // Audio controls
  Future<void> initialize() async {
    await _audioService.init();
    notifyListeners();
  }

  Future<void> loadTrack(TrackModel track) async {
    await _audioService.loadTrack(track);
    notifyListeners();
  }

  Future<void> play() async {
    await _audioService.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioService.stop();
    notifyListeners();
  }

  Future<void> seekTo(Duration position) async {
    await _audioService.seekTo(position);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
    notifyListeners();
  }

  // Queue management
  void setQueue(List<TrackModel> tracks) {
    _audioService.setQueue(tracks);
    notifyListeners();
  }

  void addToQueue(TrackModel track) {
    _audioService.addToQueue(track);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
    notifyListeners();
  }

  void clearQueue() {
    _audioService.clearQueue();
    notifyListeners();
  }

  Future<void> playNext() async {
    await _audioService.playNext();
    notifyListeners();
  }

  Future<void> playPrevious() async {
    await _audioService.playPrevious();
    notifyListeners();
  }

  void jumpToIndex(int index) {
    _audioService.jumpToIndex(index);
    notifyListeners();
  }

  // Playback modes
  void toggleShuffle() {
    _audioService.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    _audioService.toggleRepeat();
    notifyListeners();
  }

  void setShuffleMode(ShuffleMode mode) {
    _audioService.setShuffleMode(mode == ShuffleMode.on);
    notifyListeners();
  }

  void setRepeatMode(RepeatMode mode) {
    _audioService.setRepeatMode(mode);
    notifyListeners();
  }

  // Utility methods
  String get positionFormatted => _audioService.positionFormatted;
  String get durationFormatted => _audioService.durationFormatted;
  double get progress => _audioService.progress;

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
