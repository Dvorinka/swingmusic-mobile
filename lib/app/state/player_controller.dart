import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/music_models.dart';
import '../models/offline_models.dart';
import '../services/local_cache_service.dart';
import '../services/offline_manager.dart';
import '../services/swing_api_client.dart';
import 'session_controller.dart';

class LyricsCue {
  const LyricsCue({required this.text, this.timeMs});

  final String text;
  final int? timeMs;
}

class PlayerController extends ChangeNotifier {
  PlayerController({
    required SwingApiClient api,
    required SessionController session,
    required OfflineManager offline,
    required LocalCacheService cache,
  })  : _api = api,
        _session = session,
        _offline = offline,
        _cache = cache {
    _player = AudioPlayer();
    _bindPlayerStreams();
  }

  final SwingApiClient _api;
  final SessionController _session;
  final OfflineManager _offline;
  final LocalCacheService _cache;
  late final AudioPlayer _player;

  MusicTrack? _currentTrack;
  List<MusicTrack> _queue = const [];
  int _currentIndex = -1;
  String _source = 'mobile';

  bool _buffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  String? _error;

  bool _lyricsLoading = false;
  List<String> _lyricsLines = const [];
  List<LyricsCue> _lyricsCues = const [];
  bool _lyricsSynced = false;

  DateTime? _trackStartAt;
  int _playedSeconds = 0;
  Timer? _playTimer;
  bool _disposed = false;

  MusicTrack? get currentTrack => _currentTrack;
  List<MusicTrack> get queue => _queue;
  int get currentIndex => _currentIndex;
  bool get hasQueue => _queue.isNotEmpty;
  bool get isPlaying => _isPlaying;
  bool get buffering => _buffering;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get error => _error;
  bool get lyricsLoading => _lyricsLoading;
  List<String> get lyricsLines => _lyricsLines;
  List<LyricsCue> get lyricsCues => _lyricsCues;
  bool get lyricsSynced => _lyricsSynced;

  double get progress {
    if (_duration.inMilliseconds <= 0) return 0;
    return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0, 1);
  }

  String get positionLabel {
    final minutes = _position.inMinutes;
    final seconds = _position.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get durationLabel {
    final minutes = _duration.inMinutes;
    final seconds = _duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _bindPlayerStreams() {
    _player.positionStream.listen((value) {
      _position = value;
      _safeNotify();
    });

    _player.durationStream.listen((value) {
      _duration = value ?? Duration.zero;
      _safeNotify();
    });

    _player.playerStateStream.listen((state) async {
      _isPlaying = state.playing;
      _buffering = state.processingState == ProcessingState.buffering ||
          state.processingState == ProcessingState.loading;
      _safeNotify();

      if (state.playing) {
        _startPlayTimer();
      } else {
        _stopPlayTimer();
      }

      if (state.processingState == ProcessingState.completed) {
        await playNext();
      }
    });
  }

  Future<void> setQueue(
    List<MusicTrack> tracks, {
    int startIndex = 0,
    String source = 'mobile',
  }) async {
    if (tracks.isEmpty) return;
    _queue = List<MusicTrack>.from(tracks);
    _source = source;

    final safeIndex = startIndex.clamp(0, _queue.length - 1);
    await _playIndex(safeIndex, autoPlay: true);
  }

  Future<void> playTrack(
    MusicTrack track, {
    List<MusicTrack>? queue,
    String source = 'mobile',
  }) async {
    final activeQueue = queue == null || queue.isEmpty ? [track] : queue;
    final index = activeQueue.indexWhere((item) => item.id == track.id);
    await setQueue(
      activeQueue,
      startIndex: index >= 0 ? index : 0,
      source: source,
    );
  }

  Future<void> playAt(int index, {bool autoPlay = true}) async {
    await _playIndex(index, autoPlay: autoPlay);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    if (newIndex < 0 || newIndex >= _queue.length) return;
    if (oldIndex == newIndex) return;

    final updated = List<MusicTrack>.from(_queue);
    final moving = updated.removeAt(oldIndex);
    updated.insert(newIndex, moving);
    _queue = updated;

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (oldIndex < _currentIndex && newIndex >= _currentIndex) {
      _currentIndex -= 1;
    } else if (oldIndex > _currentIndex && newIndex <= _currentIndex) {
      _currentIndex += 1;
    }

    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _currentTrack = _queue[_currentIndex];
    }
    _safeNotify();
  }

  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _queue.length) return;

    final removingCurrent = index == _currentIndex;
    final wasPlaying = _isPlaying;

    _queue = List<MusicTrack>.from(_queue)..removeAt(index);

    if (_queue.isEmpty) {
      await _clearAllQueueAndStop();
      return;
    }

    if (removingCurrent) {
      final nextIndex = index >= _queue.length ? _queue.length - 1 : index;
      await _playIndex(nextIndex, autoPlay: wasPlaying);
      return;
    }

    if (index < _currentIndex) {
      _currentIndex -= 1;
    }

    if (_currentIndex >= 0 && _currentIndex < _queue.length) {
      _currentTrack = _queue[_currentIndex];
    }
    _safeNotify();
  }

  Future<void> clearUpcomingQueue() async {
    if (_currentTrack == null) {
      await _clearAllQueueAndStop();
      return;
    }

    _queue = [_currentTrack!];
    _currentIndex = 0;
    _safeNotify();
  }

  Future<void> clearQueue() async {
    await _clearAllQueueAndStop();
  }

  Future<void> togglePlayPause() async {
    if (_currentTrack == null) return;

    try {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (error) {
      _error = 'Playback error: $error';
      _safeNotify();
    }
  }

  Future<void> seek(Duration value) async {
    try {
      await _player.seek(value);
    } catch (_) {
      // Ignore seek errors from short streams.
    }
  }

  Future<void> playNext() async {
    if (_queue.isEmpty) return;
    if (_currentIndex + 1 >= _queue.length) {
      await _finalizeScrobble();
      await _player.stop();
      return;
    }
    await _playIndex(_currentIndex + 1, autoPlay: true);
  }

  Future<void> playPrevious() async {
    if (_queue.isEmpty) return;
    if (_position.inSeconds > 5) {
      await seek(Duration.zero);
      return;
    }
    if (_currentIndex <= 0) {
      await seek(Duration.zero);
      return;
    }
    await _playIndex(_currentIndex - 1, autoPlay: true);
  }

  Future<void> stop() async {
    await _finalizeScrobble();
    await _player.stop();
    _position = Duration.zero;
    _safeNotify();
  }

  Future<void> _clearAllQueueAndStop() async {
    await _finalizeScrobble();
    await _player.stop();

    _queue = const [];
    _currentTrack = null;
    _currentIndex = -1;
    _position = Duration.zero;
    _duration = Duration.zero;
    _lyricsLines = const [];
    _lyricsCues = const [];
    _lyricsSynced = false;
    _error = null;
    _safeNotify();
  }

  Future<void> reloadLyrics() async {
    final track = _currentTrack;
    if (track == null || track.trackhash.isEmpty || track.filepath.isEmpty) {
      _lyricsLines = const [];
      _lyricsCues = const [];
      _lyricsSynced = false;
      _safeNotify();
      return;
    }

    _lyricsLoading = true;
    _safeNotify();
    try {
      final payload = await _api.getLyrics(
        trackhash: track.trackhash,
        filepath: track.filepath,
      );
      final rawLyrics = payload['lyrics'];
      final syncedHint = payload['synced'] == true;

      if (rawLyrics is List && rawLyrics.isNotEmpty) {
        final first = rawLyrics.first;

        if (first is Map) {
          final parsed = rawLyrics
              .whereType<Map>()
              .map((item) {
                final map = Map<String, dynamic>.from(item);
                final text = map['text']?.toString() ?? '';
                final timeMs = _asInt(map['time']);
                return LyricsCue(text: text, timeMs: timeMs);
              })
              .where((cue) => cue.text.trim().isNotEmpty)
              .toList(growable: false);

          _lyricsCues = parsed;
          _lyricsLines = parsed.map((cue) => cue.text).toList(growable: false);
          _lyricsSynced = syncedHint || parsed.any((cue) => cue.timeMs != null);
        } else {
          final lines = rawLyrics
              .map((item) => item.toString())
              .where((line) => line.trim().isNotEmpty)
              .toList(growable: false);
          _lyricsLines = lines;
          _lyricsCues = lines
              .map((line) => LyricsCue(text: line))
              .toList(growable: false);
          _lyricsSynced = false;
        }
      } else if (rawLyrics is String) {
        final lines = rawLyrics
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList(growable: false);
        _lyricsLines = lines;
        _lyricsCues =
            lines.map((line) => LyricsCue(text: line)).toList(growable: false);
        _lyricsSynced = false;
      } else {
        _lyricsLines = const [];
        _lyricsCues = const [];
        _lyricsSynced = false;
      }
    } catch (_) {
      _lyricsLines = const [];
      _lyricsCues = const [];
      _lyricsSynced = false;
    } finally {
      _lyricsLoading = false;
      _safeNotify();
    }
  }

  Future<void> _playIndex(int index, {required bool autoPlay}) async {
    if (index < 0 || index >= _queue.length) return;
    final nextTrack = _queue[index];

    final previous = _currentTrack;
    if (previous != null && previous.id != nextTrack.id) {
      await _finalizeScrobble();
    }

    _currentTrack = nextTrack;
    _currentIndex = index;
    _position = Duration.zero;
    _duration = Duration.zero;
    _error = null;
    _trackStartAt = DateTime.now();
    _playedSeconds = 0;
    _safeNotify();

    try {
      final source = await _createAudioSource(nextTrack);
      await _player.setAudioSource(source);
      if (autoPlay) {
        await _player.play();
      }
      unawaited(reloadLyrics());
    } catch (error) {
      _error = 'Failed to play "${nextTrack.title}": $error';
      _safeNotify();
    }
  }

  Future<AudioSource> _createAudioSource(MusicTrack track) async {
    final offline = await _lookupOfflineTrack(track.trackhash);
    if (offline != null) {
      return AudioSource.uri(Uri.file(offline.localPath));
    }

    if (_session.hasServer &&
        track.trackhash.isNotEmpty &&
        track.filepath.isNotEmpty) {
      final selectedQuality = await _session.resolveStreamingQuality();
      final container = _containerForQuality(selectedQuality);
      final url = _api.buildStreamUrl(
        trackhash: track.trackhash,
        filepath: track.filepath,
        quality: selectedQuality,
        container: container,
      );
      final token = await _session.getValidAccessToken();
      return AudioSource.uri(
        Uri.parse(url),
        headers: token == null || token.isEmpty
            ? null
            : <String, String>{
                HttpHeaders.authorizationHeader: 'Bearer $token',
              },
      );
    }

    throw ApiError('Track is not streamable on this device');
  }

  Future<OfflineTrack?> _lookupOfflineTrack(String trackhash) async {
    if (trackhash.isEmpty) return null;
    final tracks = await _cache.getOfflineTracks();
    final match = tracks.where((item) => item.trackhash == trackhash).toList();
    if (match.isEmpty) return null;

    final file = File(match.first.localPath);
    if (!file.existsSync()) {
      return null;
    }
    return match.first;
  }

  String _containerForQuality(String quality) {
    final normalized = quality.trim().toLowerCase();
    if (normalized == 'original') {
      return 'flac';
    }
    final bitrate = int.tryParse(normalized);
    if (bitrate != null && bitrate > 320) {
      return 'flac';
    }
    return 'mp3';
  }

  int? _asInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is double) return raw.round();
    if (raw is String) return int.tryParse(raw);
    return null;
  }

  Future<void> downloadCurrentTrack({
    required void Function(DownloadTask task) onProgress,
  }) async {
    final track = _currentTrack;
    if (track == null) return;
    await _offline.downloadTrackToDevice(track, onProgress: onProgress);
  }

  void _startPlayTimer() {
    _playTimer?.cancel();
    _playTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPlaying && !_buffering) {
        _playedSeconds += 1;
      }
    });
  }

  void _stopPlayTimer() {
    _playTimer?.cancel();
    _playTimer = null;
  }

  Future<void> _finalizeScrobble() async {
    final track = _currentTrack;
    if (track == null) return;
    if (_playedSeconds < 5) return;
    if (track.trackhash.isEmpty) return;

    final started = _trackStartAt ?? DateTime.now();
    final timestamp = started.millisecondsSinceEpoch ~/ 1000;

    try {
      final status = await _api.logTrackPlay(
        trackhash: track.trackhash,
        timestamp: timestamp,
        duration: _playedSeconds,
        source: _source,
      );
      if (!_api.isSuccessStatus(status)) {
        throw ApiError('Scrobble failed', statusCode: status);
      }
    } catch (_) {
      await _offline.queuePendingScrobble(
        trackhash: track.trackhash,
        timestamp: timestamp,
        durationSeconds: _playedSeconds,
        source: _source,
      );
    }
  }

  void _safeNotify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopPlayTimer();
    unawaited(_finalizeScrobble());
    unawaited(_player.dispose());
    super.dispose();
  }
}
