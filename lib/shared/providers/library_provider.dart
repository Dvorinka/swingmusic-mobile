import 'package:flutter/foundation.dart';
import '../../data/services/enhanced_api_service.dart';
import '../../data/models/track_model.dart';
import '../../data/models/album_model.dart';
import '../../data/models/artist_model.dart' as artist;
import '../../data/models/playlist_model.dart';

class LibraryProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;

  // State
  List<TrackModel> _tracks = [];
  List<AlbumModel> _albums = [];
  List<artist.ArtistModel> _artists = [];
  List<PlaylistModel> _playlists = [];
  List<dynamic> _folders = [];
  Map<String, dynamic> _userInfo = {};
  Map<String, dynamic> _userPreferences = {};
  Map<String, dynamic> _statistics = {};
  List<TrackModel> _favoriteTracks = [];
  List<AlbumModel> _favoriteAlbums = [];
  List<artist.ArtistModel> _favoriteArtists = [];
  List<TrackModel> _queue = [];
  List<dynamic> _downloads = [];
  Map<String, dynamic> _downloadSettings = {};

  // Loading states
  bool _isLoadingTracks = false;
  bool _isLoadingAlbums = false;
  bool _isLoadingArtists = false;
  bool _isLoadingPlaylists = false;
  bool _isLoadingFolders = false;
  bool _isLoadingUserInfo = false;
  bool _isLoadingStatistics = false;
  bool _isLoadingFavorites = false;
  bool _isLoadingQueue = false;
  bool _isLoadingDownloads = false;

  // Error states
  String? _error;

  LibraryProvider({EnhancedApiService? apiService}) 
      : _apiService = apiService ?? EnhancedApiService();

  // Getters
  List<TrackModel> get tracks => _tracks;
  List<AlbumModel> get albums => _albums;
  List<artist.ArtistModel> get artists => _artists;
  List<PlaylistModel> get playlists => _playlists;
  List<dynamic> get folders => _folders;
  Map<String, dynamic> get userInfo => _userInfo;
  Map<String, dynamic> get userPreferences => _userPreferences;
  Map<String, dynamic> get statistics => _statistics;
  List<TrackModel> get favoriteTracks => _favoriteTracks;
  List<AlbumModel> get favoriteAlbums => _favoriteAlbums;
  List<artist.ArtistModel> get favoriteArtists => _favoriteArtists;
  List<TrackModel> get queue => _queue;
  List<dynamic> get downloads => _downloads;
  Map<String, dynamic> get downloadSettings => _downloadSettings;

  bool get isLoadingTracks => _isLoadingTracks;
  bool get isLoadingAlbums => _isLoadingAlbums;
  bool get isLoadingArtists => _isLoadingArtists;
  bool get isLoadingPlaylists => _isLoadingPlaylists;
  bool get isLoadingFolders => _isLoadingFolders;
  bool get isLoadingUserInfo => _isLoadingUserInfo;
  bool get isLoadingStatistics => _isLoadingStatistics;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isLoadingQueue => _isLoadingQueue;
  bool get isLoadingDownloads => _isLoadingDownloads;

  String? get error => _error;
  bool get hasError => _error != null;

  // Initialize data
  Future<void> initialize() async {
    await loadUserInfo();
    await loadStatistics();
  }

  // Track methods
  Future<void> loadTracks({String? search, String? artist, String? album, String? folder, int? limit}) async {
    _setLoadingTracks(true);
    _clearError();
    
    try {
      _tracks = await _apiService.getTracks(
        search: search,
        artist: artist,
        album: album,
        folder: folder,
        limit: limit ?? 50,
      );
      _setLoadingTracks(false);
    } catch (e) {
      _setError('Failed to load tracks: $e');
      _setLoadingTracks(false);
    }
  }

  Future<void> refreshTracks() async {
    await loadTracks();
  }

  Future<void> loadTrack(String trackHash) async {
    try {
      final track = await _apiService.getTrack(trackHash);
      if (track != null) {
        // Update track in current list if exists
        final index = _tracks.indexWhere((t) => t.trackhash == trackHash);
        if (index != -1) {
          _tracks[index] = track;
        }
      }
    } catch (e) {
      _setError('Failed to load track: $e');
    }
  }

  Future<void> toggleFavoriteTrack(String trackHash) async {
    try {
      await _apiService.toggleFavoriteTrack(trackHash);
      
      // Update track in local list
      final index = _tracks.indexWhere((t) => t.trackhash == trackHash);
      if (index != -1) {
        final track = _tracks[index];
        _tracks[index] = track.copyWith(isFavorite: !track.isFavorite);
      }
      
      // Update in favorites list
      final favIndex = _favoriteTracks.indexWhere((t) => t.trackhash == trackHash);
      if (favIndex != -1) {
        _favoriteTracks[favIndex] = _favoriteTracks[favIndex].copyWith(isFavorite: !_favoriteTracks[favIndex].isFavorite);
      } else {
        _favoriteTracks.add(_tracks.firstWhere((t) => t.trackhash == trackHash));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite: $e');
    }
  }

  // Album methods
  Future<void> loadAlbums({String? search, String? artist, int? limit}) async {
    _setLoadingAlbums(true);
    _clearError();
    
    try {
      _albums = await _apiService.getAlbums(search: search, artist: artist, limit: limit ?? 50);
      _setLoadingAlbums(false);
    } catch (e) {
      _setError('Failed to load albums: $e');
    }
  }

  Future<void> refreshAlbums() async {
    await loadAlbums();
  }

  Future<void> loadAlbum(String albumHash) async {
    try {
      final album = await _apiService.getAlbum(albumHash);
      if (album != null) {
        // Update album in current list if exists
        final index = _albums.indexWhere((a) => a.albumhash == albumHash);
        if (index != -1) {
          _albums[index] = album;
        }
      }
    } catch (e) {
      _setError('Failed to load album: $e');
    }
  }

  Future<void> loadAlbumTracks(String albumHash) async {
    _setLoadingTracks(true);
    _clearError();
    
    try {
      final tracks = await _apiService.getAlbumTracks(albumHash);
      _tracks = tracks;
      _setLoadingTracks(false);
    } catch (e) {
      _setError('Failed to load album tracks: $e');
    }
  }

  Future<void> toggleFavoriteAlbum(String albumHash) async {
    try {
      await _apiService.toggleFavoriteAlbum(albumHash);
      
      // Update album in local list
      final index = _albums.indexWhere((a) => a.albumhash == albumHash);
      if (index != -1) {
        final album = _albums[index];
        _albums[index] = album.copyWith(isFavorite: !album.isFavorite);
      }
      
      // Update in favorites list
      final favIndex = _favoriteAlbums.indexWhere((a) => a.albumhash == albumHash);
      if (favIndex != -1) {
        _favoriteAlbums[favIndex] = _favoriteAlbums[favIndex].copyWith(isFavorite: !_favoriteAlbums[favIndex].isFavorite);
      } else {
        _favoriteAlbums.add(_albums.firstWhere((a) => a.albumhash == albumHash));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite album: $e');
    }
  }

  // Artist methods
  Future<void> loadArtists({String? search, int? limit}) async {
    _setLoadingArtists(true);
    _clearError();
    
    try {
      final artistsData = await _apiService.getArtists(search: search, limit: limit ?? 50);
      _artists = artistsData.cast<artist.ArtistModel>();
      _setLoadingArtists(false);
    } catch (e) {
      _setError('Failed to load artists: $e');
    }
  }

  Future<void> refreshArtists() async {
    await loadArtists();
  }

  Future<void> loadArtist(String artistHash) async {
    try {
      final artist = await _apiService.getArtist(artistHash);
      if (artist != null) {
        // Update artist in current list if exists
        final index = _artists.indexWhere((a) => a.artisthash == artistHash);
        if (index != -1) {
          _artists[index] = artist;
        }
      }
    } catch (e) {
      _setError('Failed to load artist: $e');
    }
  }

  Future<void> loadArtistAlbums(String artistHash) async {
    _setLoadingAlbums(true);
    _clearError();
    
    try {
      final albums = await _apiService.getArtistAlbums(artistHash);
      _albums = albums;
      _setLoadingAlbums(false);
    } catch (e) {
      _setError('Failed to load artist albums: $e');
    }
  }

  Future<void> loadArtistTracks(String artistHash) async {
    _setLoadingTracks(true);
    _clearError();
    
    try {
      final tracks = await _apiService.getArtistTracks(artistHash);
      _tracks = tracks;
      _setLoadingTracks(false);
    } catch (e) {
      _setError('Failed to load artist tracks: $e');
    }
  }

  Future<void> toggleFavoriteArtist(String artistHash) async {
    try {
      await _apiService.toggleFavoriteArtist(artistHash);
      
      // Update artist in local list
      final index = _artists.indexWhere((a) => a.artisthash == artistHash);
      if (index != -1) {
        final artist = _artists[index];
        _artists[index] = artist.copyWith(isFavorite: !artist.isFavorite);
      }
      
      // Update in favorites list
      final favIndex = _favoriteArtists.indexWhere((a) => a.artisthash == artistHash);
      if (favIndex != -1) {
        _favoriteArtists[favIndex] = _favoriteArtists[favIndex].copyWith(isFavorite: !_favoriteArtists[favIndex].isFavorite);
      } else {
        _favoriteArtists.add(_artists.firstWhere((a) => a.artisthash == artistHash));
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to toggle favorite artist: $e');
    }
  }

  // Playlist methods
  Future<void> loadPlaylists() async {
    _setLoadingPlaylists(true);
    _clearError();
    
    try {
      _playlists = await _apiService.getPlaylists();
      _setLoadingPlaylists(false);
    } catch (e) {
      _setError('Failed to load playlists: $e');
    }
  }

  Future<void> refreshPlaylists() async {
    await loadPlaylists();
  }

  Future<void> loadPlaylist(String playlistId) async {
    try {
      final playlist = await _apiService.getPlaylist(playlistId);
      if (playlist != null) {
        // Update playlist in current list if exists
        final index = _playlists.indexWhere((p) => p.id == playlistId);
        if (index != -1) {
          _playlists[index] = playlist;
        }
      }
    } catch (e) {
      _setError('Failed to load playlist: $e');
    }
  }

  Future<void> createPlaylist(String name, String description) async {
    _setLoadingPlaylists(true);
    _clearError();
    
    try {
      final newPlaylist = await _apiService.createPlaylist(name, description);
      _playlists.insert(0, newPlaylist);
      _setLoadingPlaylists(false);
    } catch (e) {
      _setError('Failed to create playlist: $e');
    }
  }

  Future<void> addToPlaylist(String playlistId, String trackHash) async {
    try {
      await _apiService.addToPlaylist(playlistId, trackHash);
    } catch (e) {
      _setError('Failed to add to playlist: $e');
    }
  }

  Future<void> removeFromPlaylist(String playlistId, String trackHash) async {
    try {
      await _apiService.removeFromPlaylist(playlistId, trackHash);
    } catch (e) {
      _setError('Failed to remove from playlist: $e');
    }
  }

  // Folder methods
  Future<void> loadFolders() async {
    _setLoadingFolders(true);
    _clearError();
    
    try {
      _folders = await _apiService.getFolders();
      _setLoadingFolders(false);
    } catch (e) {
      _setError('Failed to load folders: $e');
    }
  }

  Future<void> loadFolderTracks(String folderHash) async {
    _setLoadingTracks(true);
    _clearError();
    
    try {
      final tracks = await _apiService.getFolderTracks(folderHash);
      _tracks = tracks;
      _setLoadingTracks(false);
    } catch (e) {
      _setError('Failed to load folder tracks: $e');
    }
  }

  // Favorites methods
  Future<void> loadFavoriteTracks() async {
    _setLoadingFavorites(true);
    _clearError();
    
    try {
      _favoriteTracks = await _apiService.getFavoriteTracks();
      _setLoadingFavorites(false);
    } catch (e) {
      _setError('Failed to load favorite tracks: $e');
    }
  }

  Future<void> loadFavoriteAlbums() async {
    _setLoadingFavorites(true);
    _clearError();
    
    try {
      _favoriteAlbums = await _apiService.getFavoriteAlbums();
      _setLoadingFavorites(false);
    } catch (e) {
      _setError('Failed to load favorite albums: $e');
    }
  }

  Future<void> loadFavoriteArtists() async {
    _setLoadingFavorites(true);
    _clearError();
    
    try {
      final artistsData = await _apiService.getFavoriteArtists();
      _favoriteArtists = artistsData.cast<artist.ArtistModel>();
      _setLoadingFavorites(false);
    } catch (e) {
      _setError('Failed to load favorite artists: $e');
    }
  }

  // User methods
  Future<void> loadUserInfo() async {
    _setLoadingUserInfo(true);
    _clearError();
    
    try {
      _userInfo = await _apiService.getUserInfo();
      _setLoadingUserInfo(false);
    } catch (e) {
      _setError('Failed to load user info: $e');
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    try {
      await _apiService.updateUserPreferences(preferences);
      _userPreferences = preferences;
    } catch (e) {
      _setError('Failed to update preferences: $e');
    }
  }

  Future<void> loadUserPreferences() async {
    _setLoadingUserInfo(true);
    _clearError();
    
    try {
      _userPreferences = await _apiService.getUserPreferences();
      _setLoadingUserInfo(false);
    } catch (e) {
      _setError('Failed to load preferences: $e');
    }
  }

  // Statistics methods
  Future<void> loadStatistics() async {
    _setLoadingStatistics(true);
    _clearError();
    
    try {
      _statistics = await _apiService.getStatistics();
      _setLoadingStatistics(false);
    } catch (e) {
      _setError('Failed to load statistics: $e');
    }
  }

  // Download methods
  Future<void> loadDownloads() async {
    _setLoadingDownloads(true);
    _clearError();
    
    try {
      _downloads = await _apiService.getDownloads();
      _setLoadingDownloads(false);
    } catch (e) {
      _downloads = [];
      _setError('Failed to load downloads: $e');
      _setLoadingDownloads(false);
    }
  }

  Future<void> loadDownloadSettings() async {
    _setLoadingUserInfo(true);
    _clearError();
    
    try {
      _downloadSettings = await _apiService.getDownloadSettings();
      _setLoadingUserInfo(false);
    } catch (e) {
      _downloadSettings = {};
      _setError('Failed to load download settings: $e');
      _setLoadingUserInfo(false);
    }
  }

  Future<void> updateDownloadSettings(Map<String, dynamic> settings) async {
    try {
      await _apiService.updateDownloadSettings(settings);
      _downloadSettings.addAll(settings);
      notifyListeners();
    } catch (e) {
      _setError('Failed to update download settings: $e');
    }
  }

  Future<void> pauseDownload(String downloadId) async {
    try {
      await _apiService.pauseDownload(downloadId);
      final index = _downloads.indexWhere((d) => d['downloadId'] == downloadId);
      if (index != -1) {
        _downloads[index] = {..._downloads[index], 'status': 'paused'};
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to pause download: $e');
    }
  }

  Future<void> resumeDownload(String downloadId) async {
    try {
      await _apiService.resumeDownload(downloadId);
      final index = _downloads.indexWhere((d) => d['downloadId'] == downloadId);
      if (index != -1) {
        _downloads[index] = {..._downloads[index], 'status': 'downloading'};
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to resume download: $e');
    }
  }

  Future<void> cancelDownload(String downloadId) async {
    try {
      await _apiService.cancelDownload(downloadId);
      _downloads.removeWhere((d) => d['downloadId'] == downloadId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to cancel download: $e');
    }
  }

  Future<void> retryDownload(String downloadId) async {
    try {
      await _apiService.retryDownload(downloadId);
      final index = _downloads.indexWhere((d) => d['downloadId'] == downloadId);
      if (index != -1) {
        _downloads[index] = {..._downloads[index], 'status': 'downloading'};
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to retry download: $e');
    }
  }

  Future<void> deleteDownload(String downloadId) async {
    try {
      await _apiService.deleteDownload(downloadId);
      _downloads.removeWhere((d) => d['downloadId'] == downloadId);
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete download: $e');
    }
  }
  Future<void> loadQueue() async {
    _setLoadingQueue(true);
    _clearError();
    
    try {
      _queue = await _apiService.getQueue();
      _setLoadingQueue(false);
    } catch (e) {
      _setError('Failed to load queue: $e');
    }
  }

  Future<void> addToQueue(String trackHash) async {
    try {
      await _apiService.addToQueue(trackHash);
      
      // Add to queue from tracks if available
      final track = _tracks.where((t) => t.trackhash == trackHash).firstOrNull;
      if (track != null && !_queue.any((q) => q.trackhash == trackHash)) {
        _queue.add(track);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to add to queue: $e');
    }
  }

  Future<void> removeFromQueue(String trackHash) async {
    try {
      await _apiService.removeFromQueue(trackHash);
      _queue.removeWhere((track) => track.trackhash == trackHash);
      notifyListeners();
    } catch (e) {
      _setError('Failed to remove from queue: $e');
    }
  }

  Future<void> clearQueue() async {
    try {
      await _apiService.clearQueue();
      _queue.clear();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear queue: $e');
    }
  }

  Future<void> reorderQueue(List<String> trackHashes) async {
    try {
      await _apiService.reorderQueue(trackHashes);
      
      // Reorder local queue
      final reorderedQueue = <TrackModel>[];
      for (final hash in trackHashes) {
        final track = _queue.firstWhere((t) => t.trackhash == hash);
        if (track.trackhash.isNotEmpty) {
          reorderedQueue.add(track);
        }
      }
      _queue = reorderedQueue;
      notifyListeners();
    } catch (e) {
      _setError('Failed to reorder queue: $e');
    }
  }

  // Private helper methods
  void _setLoadingTracks(bool loading) {
    _isLoadingTracks = loading;
    notifyListeners();
  }

  void _setLoadingAlbums(bool loading) {
    _isLoadingAlbums = loading;
    notifyListeners();
  }

  void _setLoadingArtists(bool loading) {
    _isLoadingArtists = loading;
    notifyListeners();
  }

  void _setLoadingPlaylists(bool loading) {
    _isLoadingPlaylists = loading;
    notifyListeners();
  }

  void _setLoadingFolders(bool loading) {
    _isLoadingFolders = loading;
    notifyListeners();
  }

  void _setLoadingUserInfo(bool loading) {
    _isLoadingUserInfo = loading;
    notifyListeners();
  }

  void _setLoadingStatistics(bool loading) {
    _isLoadingStatistics = loading;
    notifyListeners();
  }

  void _setLoadingFavorites(bool loading) {
    _isLoadingFavorites = loading;
    notifyListeners();
  }

  void _setLoadingQueue(bool loading) {
    _isLoadingQueue = loading;
    notifyListeners();
  }

  void _setLoadingDownloads(bool loading) {
    _isLoadingDownloads = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
