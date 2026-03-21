import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/offline_models.dart';

class LocalCacheService {
  Future<List<OfflineTrack>> getOfflineTracks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kOfflineTracks);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => OfflineTrack.fromMap(item))
        .toList(growable: false);
  }

  Future<void> saveOfflineTracks(List<OfflineTrack> tracks) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = tracks
        .map((track) => track.toMap())
        .toList(growable: false);
    await prefs.setString(_kOfflineTracks, jsonEncode(payload));
  }

  Future<void> upsertOfflineTrack(OfflineTrack track) async {
    final tracks = (await getOfflineTracks()).toList(growable: true);
    final index = tracks.indexWhere(
      (entry) => entry.trackhash == track.trackhash,
    );

    if (index == -1) {
      tracks.add(track);
    } else {
      tracks[index] = track;
    }

    await saveOfflineTracks(tracks);
  }

  Future<void> removeOfflineTrack(String trackhash) async {
    final tracks = (await getOfflineTracks())
        .where((entry) => entry.trackhash != trackhash)
        .toList(growable: false);
    await saveOfflineTracks(tracks);
  }

  Future<List<PendingScrobble>> getPendingScrobbles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPendingScrobbles);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => PendingScrobble.fromMap(item))
        .toList(growable: false);
  }

  Future<void> savePendingScrobbles(List<PendingScrobble> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = entries
        .map((entry) => entry.toMap())
        .toList(growable: false);
    await prefs.setString(_kPendingScrobbles, jsonEncode(payload));
  }

  Future<void> addPendingScrobble(PendingScrobble scrobble) async {
    final items = (await getPendingScrobbles()).toList(growable: true);
    items.add(scrobble);
    await savePendingScrobbles(items);
  }

  Future<void> removePendingScrobble(String id) async {
    final items = (await getPendingScrobbles())
        .where((entry) => entry.id != id)
        .toList(growable: false);
    await savePendingScrobbles(items);
  }

  Future<List<PendingAction>> getPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPendingActions);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      return const [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => PendingAction.fromMap(item))
        .toList(growable: false);
  }

  Future<void> savePendingActions(List<PendingAction> actions) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = actions
        .map((entry) => entry.toMap())
        .toList(growable: false);
    await prefs.setString(_kPendingActions, jsonEncode(payload));
  }

  Future<void> addPendingAction(PendingAction action) async {
    final items = (await getPendingActions()).toList(growable: true);
    items.add(action);
    await savePendingActions(items);
  }

  Future<void> removePendingAction(String id) async {
    final items = (await getPendingActions())
        .where((entry) => entry.id != id)
        .toList(growable: false);
    await savePendingActions(items);
  }
}

const _kOfflineTracks = 'offline.tracks';
const _kPendingScrobbles = 'offline.pending_scrobbles';
const _kPendingActions = 'offline.pending_actions';
