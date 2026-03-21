import 'package:flutter/foundation.dart';
import '../../data/models/track_model.dart';
import '../../data/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService;
  
  // Overview stats
  String _selectedPeriod = 'month';
  String get selectedPeriod => _selectedPeriod;
  
  // Analytics data properties
  Map<String, dynamic>? _analyticsData;
  
  // Getters for analytics data
  int get totalPlays => _analyticsData?['totalPlays'] ?? 0;
  int get totalListeningTime => _analyticsData?['totalListeningTime'] ?? 0;
  int get uniqueTracksPlayed => _analyticsData?['uniqueTracksPlayed'] ?? 0;
  int get averageSessionLength => _analyticsData?['averageSessionLength'] ?? 0;
  String get mostActiveDay => _analyticsData?['mostActiveDay'] ?? 'Unknown';
  int get peakHour => _analyticsData?['peakHour'] ?? 0;
  String get favoriteGenre => _analyticsData?['favoriteGenre'] ?? 'Unknown';
  List<dynamic> get topArtists => _analyticsData?['topArtists'] ?? [];
  List<TrackModel> get topTracks => _analyticsData?['topTracks'] ?? [];
  List<TrackModel> get newDiscoveries => _analyticsData?['newDiscoveries'] ?? [];

  AnalyticsProvider(this._analyticsService);

  Future<void> loadAnalyticsData() async {
    try {
      _analyticsData = await _analyticsService.getAnalyticsData(_selectedPeriod);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading analytics data: $e');
    }
  }

  void setTimePeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    loadAnalyticsData();
  }
}
