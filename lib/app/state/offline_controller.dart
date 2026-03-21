import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../models/music_models.dart';
import '../models/offline_models.dart';
import '../services/offline_manager.dart';

class OfflineController extends ChangeNotifier {
  OfflineController({required OfflineManager offline}) : _offline = offline {
    _syncTicker = Timer.periodic(const Duration(seconds: 45), (_) {
      unawaited(syncPending());
    });

    _connectivitySub = Connectivity().onConnectivityChanged.listen((
      dynamic state,
    ) {
      if (_hasNetwork(state)) {
        unawaited(syncPending());
      }
    });
  }

  final OfflineManager _offline;
  final Map<String, DownloadTask> _activeTasks = <String, DownloadTask>{};

  List<OfflineTrack> _offlineTracks = const [];
  bool _syncing = false;
  String? _error;
  Timer? _syncTicker;
  StreamSubscription<dynamic>? _connectivitySub;

  List<OfflineTrack> get offlineTracks => _offlineTracks;
  List<DownloadTask> get activeTasks =>
      _activeTasks.values.toList(growable: false);
  bool get syncing => _syncing;
  String? get error => _error;

  Future<void> load() async {
    _offlineTracks = await _offline.loadOfflineTracks();
    notifyListeners();
  }

  bool isDownloaded(String trackhash) =>
      _offlineTracks.any((track) => track.trackhash == trackhash);

  Future<void> downloadTrack(
    MusicTrack track, {
    String? collectionLabel,
  }) async {
    _error = null;
    notifyListeners();

    final task = await _offline.downloadTrackToDevice(
      track,
      onProgress: (nextTask) {
        _activeTasks[nextTask.id] = nextTask;
        notifyListeners();
      },
      collectionLabel: collectionLabel,
    );

    if (task.state == 'failed') {
      _error = task.error ?? 'Download failed';
    } else if (task.state == 'completed') {
      _activeTasks.remove(task.id);
      _offlineTracks = await _offline.loadOfflineTracks();
    }
    notifyListeners();
  }

  Future<void> downloadTracksBatch({
    required String label,
    required List<MusicTrack> tracks,
  }) async {
    final seen = <String>{};
    final candidates = tracks
        .where((track) {
          if (track.trackhash.isEmpty || track.filepath.isEmpty) return false;
          if (isDownloaded(track.trackhash)) return false;
          if (seen.contains(track.trackhash)) return false;
          seen.add(track.trackhash);
          return true;
        })
        .toList(growable: false);

    if (candidates.isEmpty) {
      _error = 'No downloadable local tracks available for $label.';
      notifyListeners();
      return;
    }

    _error = null;
    notifyListeners();

    var failed = 0;
    for (final track in candidates) {
      final task = await _offline.downloadTrackToDevice(
        track,
        onProgress: (nextTask) {
          _activeTasks[nextTask.id] = nextTask;
          notifyListeners();
        },
        collectionLabel: label,
      );

      _activeTasks.remove(task.id);
      if (task.state == 'failed') {
        failed += 1;
      }
    }

    _offlineTracks = await _offline.loadOfflineTracks();
    if (failed > 0) {
      _error = 'Completed with $failed failed download(s).';
    }
    notifyListeners();
  }

  Future<void> removeDownload(String trackhash) async {
    await _offline.removeOfflineTrack(trackhash);
    _offlineTracks = await _offline.loadOfflineTracks();
    notifyListeners();
  }

  Future<void> syncPending() async {
    if (_syncing) return;
    _syncing = true;
    notifyListeners();

    try {
      await _offline.syncPendingData();
    } catch (_) {
      // Keep silent; pending sync is best-effort.
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _syncTicker?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  bool _hasNetwork(dynamic state) {
    if (state is ConnectivityResult) {
      return state != ConnectivityResult.none;
    }

    if (state is List<ConnectivityResult>) {
      return state.any((entry) => entry != ConnectivityResult.none);
    }

    return true;
  }
}
