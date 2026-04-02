import 'package:flutter/foundation.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/models/album_model.dart';

/// Home data model matching Android HomeData
class HomeData {
  final HomeStats stats;
  final List<AlbumModel> recentlyAdded;

  HomeData({
    required this.stats,
    required this.recentlyAdded,
  });
}

/// Home statistics matching Android HomeStats
class HomeStats {
  final int totalTracks;
  final int totalAlbums;
  final int totalArtists;
  final int totalPlaytime; // in seconds

  HomeStats({
    required this.totalTracks,
    required this.totalAlbums,
    required this.totalArtists,
    required this.totalPlaytime,
  });

  factory HomeStats.empty() => HomeStats(
        totalTracks: 0,
        totalAlbums: 0,
        totalArtists: 0,
        totalPlaytime: 0,
      );

  /// Format total playtime as human-readable string
  String get formattedPlaytime {
    final hours = totalPlaytime ~/ 3600;
    final days = hours ~/ 24;
    final remainingHours = hours % 24;

    if (days > 0) {
      return '$days days, $remainingHours hours';
    } else if (hours > 0) {
      return '$hours hours';
    } else {
      final minutes = (totalPlaytime % 3600) ~/ 60;
      return '$minutes minutes';
    }
  }
}

/// Home provider matching Android HomeViewModel
class HomeProvider extends ChangeNotifier {
  final EnhancedApiService _apiService;

  // State
  HomeData? _homeData;
  bool _isLoading = false;
  String? _error;

  HomeProvider({EnhancedApiService? apiService})
      : _apiService = apiService ?? EnhancedApiService();

  // Getters
  HomeData? get homeData => _homeData;
  HomeStats get stats => _homeData?.stats ?? HomeStats.empty();
  List<AlbumModel> get recentlyAdded => _homeData?.recentlyAdded ?? [];
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;

  /// Load home data (stats + recently added albums)
  /// Matches Android: HomeViewModel.onEvent(HomeUiEvent.LoadHomeData)
  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load statistics and recently added albums in parallel
      final results = await Future.wait([
        _loadStatistics(),
        _loadRecentlyAddedAlbums(),
      ]);

      _homeData = HomeData(
        stats: results[0] as HomeStats,
        recentlyAdded: results[1] as List<AlbumModel>,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load home data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load statistics from API
  Future<HomeStats> _loadStatistics() async {
    try {
      final statsData = await _apiService.getStatistics();

      return HomeStats(
        totalTracks: statsData['total_tracks'] ?? statsData['tracks'] ?? 0,
        totalAlbums: statsData['total_albums'] ?? statsData['albums'] ?? 0,
        totalArtists: statsData['total_artists'] ?? statsData['artists'] ?? 0,
        totalPlaytime:
            statsData['total_playtime'] ?? statsData['playtime'] ?? 0,
      );
    } catch (e) {
      debugPrint('Failed to load statistics: $e');
      return HomeStats.empty();
    }
  }

  /// Load recently added albums
  Future<List<AlbumModel>> _loadRecentlyAddedAlbums() async {
    try {
      // Get albums sorted by creation date (newest first)
      final albums = await _apiService.getAlbums(
        limit: 10,
        sortBy: 'created',
        sortOrder: 'desc',
      );

      return albums;
    } catch (e) {
      debugPrint('Failed to load recently added albums: $e');
      return [];
    }
  }

  /// Refresh home data
  Future<void> refresh() async {
    await loadHomeData();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
