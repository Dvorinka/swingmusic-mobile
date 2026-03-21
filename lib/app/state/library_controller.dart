import 'package:flutter/foundation.dart';

import '../models/music_models.dart';
import '../services/offline_manager.dart';
import '../services/swing_api_client.dart';
import 'session_controller.dart';

class LibraryController extends ChangeNotifier {
  LibraryController({
    required SwingApiClient api,
    required SessionController session,
    required OfflineManager offline,
  }) : _api = api,
       _session = session,
       _offline = offline;

  final SwingApiClient _api;
  final SessionController _session;
  final OfflineManager _offline;

  bool _loadingHome = false;
  bool _loadingLibrary = false;
  bool _searching = false;
  String? _error;

  List<Map<String, dynamic>> _recentlyAdded = const [];
  List<Map<String, dynamic>> _recentlyPlayed = const [];
  List<MusicArtist> _recommendedArtists = const [];

  String _currentFolder = r'$home';
  List<FolderEntry> _folders = const [];
  List<MusicTrack> _folderTracks = const [];

  List<MusicPlaylist> _playlists = const [];
  final Map<String, List<MusicTrack>> _playlistTracks =
      <String, List<MusicTrack>>{};

  List<MusicTrack> _favoriteTracks = const [];
  List<MusicAlbum> _favoriteAlbums = const [];
  List<MusicArtist> _favoriteArtists = const [];

  String _searchQuery = '';
  List<MusicTrack> _searchTracks = const [];
  List<MusicAlbum> _searchAlbums = const [];
  List<MusicArtist> _searchArtists = const [];
  List<MusicPlaylist> _searchPlaylists = const [];

  Map<String, dynamic> _catalogArtist = const {};
  List<MusicTrack> _catalogArtistTopTracks = const [];
  List<MusicTrack> _catalogArtistRadio = const [];
  List<MusicTrack> _catalogArtistThisIs = const [];
  List<MusicAlbum> _catalogArtistAlbums = const [];

  Map<String, dynamic> _catalogAlbum = const {};
  List<MusicTrack> _catalogAlbumTracks = const [];

  bool get loadingHome => _loadingHome;
  bool get loadingLibrary => _loadingLibrary;
  bool get searching => _searching;
  String? get error => _error;

  List<Map<String, dynamic>> get recentlyAdded => _recentlyAdded;
  List<Map<String, dynamic>> get recentlyPlayed => _recentlyPlayed;
  List<MusicArtist> get recommendedArtists => _recommendedArtists;

  String get currentFolder => _currentFolder;
  List<FolderEntry> get folders => _folders;
  List<MusicTrack> get folderTracks => _folderTracks;

  List<MusicPlaylist> get playlists => _playlists;
  List<MusicTrack> tracksForPlaylist(String playlistId) =>
      _playlistTracks[playlistId] ?? const [];

  List<MusicTrack> get favoriteTracks => _favoriteTracks;
  List<MusicAlbum> get favoriteAlbums => _favoriteAlbums;
  List<MusicArtist> get favoriteArtists => _favoriteArtists;

  String get searchQuery => _searchQuery;
  List<MusicTrack> get searchTracks => _searchTracks;
  List<MusicAlbum> get searchAlbums => _searchAlbums;
  List<MusicArtist> get searchArtists => _searchArtists;
  List<MusicPlaylist> get searchPlaylists => _searchPlaylists;

  Map<String, dynamic> get catalogArtist => _catalogArtist;
  List<MusicTrack> get catalogArtistTopTracks => _catalogArtistTopTracks;
  List<MusicTrack> get catalogArtistRadio => _catalogArtistRadio;
  List<MusicTrack> get catalogArtistThisIs => _catalogArtistThisIs;
  List<MusicAlbum> get catalogArtistAlbums => _catalogArtistAlbums;

  Map<String, dynamic> get catalogAlbum => _catalogAlbum;
  List<MusicTrack> get catalogAlbumTracks => _catalogAlbumTracks;

  Future<void> bootstrap() async {
    if (!_session.isAuthenticated) return;

    _error = null;
    await Future.wait([
      loadHome(),
      loadFolder(r'$home'),
      loadPlaylists(),
      loadFavorites(),
    ]);
  }

  Future<void> loadHome() async {
    _loadingHome = true;
    _error = null;
    notifyListeners();

    try {
      final added = await _api.getHomeRecentAdded(limit: 18);
      final played = await _api.getHomeRecentPlayed(limit: 18);
      final recs = await _api.getHomeRecommendations();

      _recentlyAdded = _listOfMap(added['items']);
      _recentlyPlayed = _listOfMap(played['items']);
      _recommendedArtists = _listOfMap(
        recs['artists'],
      ).map(_artistFromHomeRecommendation).toList(growable: false);
    } catch (error) {
      _error = 'Failed to load home: $error';
    } finally {
      _loadingHome = false;
      notifyListeners();
    }
  }

  Future<void> loadFolder(String folderPath) async {
    _loadingLibrary = true;
    _error = null;
    notifyListeners();

    try {
      final payload = await _api.getFolder(folder: folderPath, limit: 200);
      _currentFolder = folderPath;
      _folders = _listOfMap(
        payload['folders'],
      ).map(FolderEntry.fromJson).toList(growable: false);
      _folderTracks = _listOfMap(payload['tracks'])
          .map(_trackFromAny)
          .where((track) => track.trackhash.isNotEmpty)
          .toList(growable: false);
    } catch (error) {
      _error = 'Failed to load folder: $error';
    } finally {
      _loadingLibrary = false;
      notifyListeners();
    }
  }

  Future<void> loadPlaylists() async {
    try {
      final payload = await _api.getPlaylists(noImages: false);
      _playlists = _listOfMap(
        payload['data'],
      ).map(MusicPlaylist.fromLibraryJson).toList(growable: false);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to load playlists: $error';
      notifyListeners();
    }
  }

  Future<void> loadPlaylistTracks(String playlistId) async {
    try {
      final payload = await _api.getPlaylist(playlistId, start: 0, limit: 500);
      _playlistTracks[playlistId] = _listOfMap(
        payload['tracks'],
      ).map(_trackFromAny).toList(growable: false);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to load playlist: $error';
      notifyListeners();
    }
  }

  Future<void> createPlaylist(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    try {
      final response = await _api.createPlaylist(trimmed);
      final status = response['status'];
      if (status == 409) {
        _error = 'Playlist already exists';
      }
      await loadPlaylists();
    } catch (error) {
      _error = 'Failed to create playlist: $error';
      notifyListeners();
    }
  }

  Future<void> addTrackToPlaylist({
    required String playlistId,
    required MusicTrack track,
  }) async {
    if (track.trackhash.isEmpty) return;

    try {
      final status = await _api.addTrackToPlaylist(
        playlistId: playlistId,
        trackhash: track.trackhash,
      );
      if (!_api.isSuccessStatus(status)) {
        _error = 'Could not add track to playlist.';
      }
      await loadPlaylistTracks(playlistId);
    } catch (error) {
      _error = 'Failed to add to playlist: $error';
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    try {
      final payload = await _api.getFavorites();
      _favoriteTracks = _listOfMap(payload['tracks'])
          .map((raw) => _trackFromAny(raw).copyWith(isFavorite: true))
          .toList(growable: false);
      _favoriteAlbums = _listOfMap(
        payload['albums'],
      ).map(MusicAlbum.fromLibraryJson).toList(growable: false);
      _favoriteArtists = _listOfMap(
        payload['artists'],
      ).map(MusicArtist.fromLibraryJson).toList(growable: false);
      notifyListeners();
    } catch (error) {
      _error = 'Failed to load favorites: $error';
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteTrack(MusicTrack track) async {
    if (track.trackhash.isEmpty) return;

    final exists = _favoriteTracks.any(
      (entry) => entry.trackhash == track.trackhash,
    );

    try {
      final status = exists
          ? await _api.removeFavorite(hash: track.trackhash, type: 'track')
          : await _api.addFavorite(hash: track.trackhash, type: 'track');

      if (!_api.isSuccessStatus(status)) {
        throw ApiError(
          'Favorite endpoint returned status $status',
          statusCode: status,
        );
      }
    } catch (_) {
      await _offline.queuePendingFavorite(
        action: exists ? 'favorite.remove' : 'favorite.add',
        hash: track.trackhash,
        type: 'track',
      );
    }

    if (exists) {
      _favoriteTracks = _favoriteTracks
          .where((entry) => entry.trackhash != track.trackhash)
          .toList(growable: false);
    } else {
      _favoriteTracks = [track.copyWith(isFavorite: true), ..._favoriteTracks];
    }
    notifyListeners();
  }

  Future<void> search(String query) async {
    final normalized = query.trim();
    _searchQuery = normalized;

    if (normalized.isEmpty) {
      _searchTracks = const [];
      _searchAlbums = const [];
      _searchArtists = const [];
      _searchPlaylists = const [];
      notifyListeners();
      return;
    }

    _searching = true;
    _error = null;
    notifyListeners();

    try {
      final top = await _api.searchTop(normalized, limit: 8);
      final global = await _api.searchCatalog(
        query: normalized,
        type: 'all',
        limit: 35,
      );

      final topTracks = _listOfMap(top['tracks']).map(_trackFromAny);
      final catalogTracks = _listOfMap(global['tracks']).map(_trackFromAny);

      final mergedTracks = <String, MusicTrack>{};
      for (final track in [...topTracks, ...catalogTracks]) {
        final key = track.id;
        if (key.isEmpty) continue;
        mergedTracks[key] = track;
      }

      _searchTracks = mergedTracks.values.toList(growable: false);
      _searchAlbums = _listOfMap(
        global['albums'],
      ).map(MusicAlbum.fromCatalogJson).toList(growable: false);
      _searchArtists = _listOfMap(
        global['artists'],
      ).map(MusicArtist.fromCatalogJson).toList(growable: false);
      _searchPlaylists = _listOfMap(
        global['playlists'],
      ).map(MusicPlaylist.fromCatalogJson).toList(growable: false);
    } catch (error) {
      _error = 'Search failed: $error';
    } finally {
      _searching = false;
      notifyListeners();
    }
  }

  Future<void> loadCatalogArtist(String artistId) async {
    _error = null;
    notifyListeners();

    try {
      final payload = await _api.getCatalogArtist(artistId);
      _catalogArtist = payload;
      _catalogArtistTopTracks = _listOfMap(
        payload['top_tracks'],
      ).map(_trackFromAny).toList(growable: false);
      _catalogArtistRadio = _listOfMap(
        payload['artist_radio'],
      ).map(_trackFromAny).toList(growable: false);
      _catalogArtistThisIs = _listOfMap(
        payload['this_is_artist'],
      ).map(_trackFromAny).toList(growable: false);
      _catalogArtistAlbums = _listOfMap(
        payload['albums'],
      ).map(MusicAlbum.fromCatalogJson).toList(growable: false);
    } catch (error) {
      _error = 'Failed to load artist: $error';
    }

    notifyListeners();
  }

  Future<void> loadCatalogAlbum(String albumId) async {
    _error = null;
    notifyListeners();

    try {
      final payload = await _api.getCatalogAlbum(albumId);
      _catalogAlbum = payload;
      _catalogAlbumTracks = _listOfMap(
        payload['tracks'],
      ).map(_trackFromAny).toList(growable: false);
    } catch (error) {
      _error = 'Failed to load album: $error';
    }

    notifyListeners();
  }

  Future<void> queueServerDownloadForTrack(MusicTrack track) async {
    try {
      final payload = await _api.createDownloadJob(
        sourceUrl: track.spotifyId == null || track.spotifyId!.isEmpty
            ? null
            : 'https://open.spotify.com/track/${track.spotifyId}',
        trackhash: track.trackhash.isEmpty ? null : track.trackhash,
        title: track.title,
        artist: track.artist,
        album: track.album,
        itemType: 'track',
        quality: _session.downloadQuality,
      );

      if (payload['success'] != true) {
        _error = 'Could not queue download on server.';
        notifyListeners();
      }
    } catch (error) {
      _error = 'Failed to queue server download: $error';
      notifyListeners();
    }
  }

  Future<void> queueServerDownloadsForTracks(List<MusicTrack> tracks) async {
    for (final track in tracks) {
      if (track.filepath.isNotEmpty) continue;
      await queueServerDownloadForTrack(track);
    }
  }

  Future<void> syncPendingData() {
    return _offline.syncPendingData();
  }

  MusicTrack _trackFromAny(Map<String, dynamic> raw) {
    final hasCatalogShape =
        raw.containsKey('spotify_id') ||
        raw['item_type'] == 'track' ||
        raw.containsKey('duration_ms');
    if (hasCatalogShape) {
      return MusicTrack.fromCatalogJson(raw);
    }
    return MusicTrack.fromLibraryJson(raw);
  }

  MusicArtist _artistFromHomeRecommendation(Map<String, dynamic> raw) {
    if (raw.containsKey('spotify_id')) {
      return MusicArtist.fromCatalogJson(raw);
    }

    return MusicArtist(
      id:
          raw['id']?.toString() ??
          raw['hash']?.toString() ??
          raw['name']?.toString() ??
          '',
      name: raw['title']?.toString() ?? raw['name']?.toString() ?? '',
      imageUrl: raw['image_url']?.toString() ?? raw['image']?.toString(),
      artisthash: raw['hash']?.toString(),
    );
  }

  List<Map<String, dynamic>> _listOfMap(dynamic value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
