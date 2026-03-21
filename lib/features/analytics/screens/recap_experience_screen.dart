import 'package:flutter/material.dart';
import '../../../data/services/enhanced_api_service.dart';
import '../../../data/services/analytics_service.dart';
import '../../../core/constants/app_spacing.dart';

class RecapExperienceScreen extends StatefulWidget {
  const RecapExperienceScreen({super.key});

  @override
  State<RecapExperienceScreen> createState() => _RecapExperienceScreenState();
}

class _RecapExperienceScreenState extends State<RecapExperienceScreen> {
  late final EnhancedApiService _apiService;
  late final AnalyticsService _analyticsService;
  
  Map<String, dynamic> _yearlyStats = {};
  List<Map<String, dynamic>> _topTracks = [];
  List<Map<String, dynamic>> _topArtists = [];
  Map<String, dynamic> _listeningPatterns = {};
  bool _isLoading = true;
  int _currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _apiService = EnhancedApiService();
    _analyticsService = AnalyticsService(_apiService);
    _loadRecapData();
  }

  Future<void> _loadRecapData() async {
    try {
      final statsFuture = _analyticsService.getAnalyticsData('year');
      final tracksFuture = _analyticsService.getTopTracks(limit: 10);
      final artistsFuture = _analyticsService.getTopArtists(limit: 10);

      final results = await Future.wait([statsFuture, tracksFuture, artistsFuture]);

      if (mounted) {
        setState(() {
          _yearlyStats = results[0] as Map<String, dynamic>;
          _topTracks = results[1] as List<Map<String, dynamic>>;
          _topArtists = results[2] as List<Map<String, dynamic>>;
          _listeningPatterns = _generateListeningPatterns();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _generateListeningPatterns() {
    // Generate mock listening patterns data
    return {
      'mostActiveDay': 'Friday',
      'peakHour': 20,
      'favoriteMonth': 'December',
      'listeningStreak': 42,
      'totalGenres': 15,
      'newDiscoveries': 127,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Preparing your 2024 Recap...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(),
        onPageChanged: (index) {
          setState(() {
            _currentSlide = index;
          });
        },
        itemCount: _getRecapSlides().length,
        itemBuilder: (context, index) {
          return _getRecapSlides()[index];
        },
      ),
      bottomNavigationBar: _buildProgressBar(),
    );
  }

  List<Widget> _getRecapSlides() {
    return [
      _buildWelcomeSlide(),
      _buildListeningTimeSlide(),
      _buildTopTracksSlide(),
      _buildTopArtistsSlide(),
      _buildListeningPatternsSlide(),
      _buildDiscoveriesSlide(),
      _buildThankYouSlide(),
    ];
  }

  Widget _buildWelcomeSlide() {
    return _RecapSlide(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '2024',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Your Year in Music',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Icon(
            Icons.music_note,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Let\'s dive into your musical journey',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildListeningTimeSlide() {
    final totalMinutes = _yearlyStats['totalListeningTime'] ?? 0;
    final totalHours = (totalMinutes / 60).round();
    final totalDays = (totalHours / 24).round();

    return _RecapSlide(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '$totalHours',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'hours of music',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'That\'s $totalDays full days!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopTracksSlide() {
    return _RecapSlide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Top Tracks',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.builder(
              itemCount: _topTracks.take(5).length,
              itemBuilder: (context, index) {
                final track = _topTracks[index];
                return _TopTrackItem(
                  rank: index + 1,
                  track: track,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopArtistsSlide() {
    return _RecapSlide(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Top Artists',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ListView.builder(
              itemCount: _topArtists.take(5).length,
              itemBuilder: (context, index) {
                final artist = _topArtists[index];
                return _TopArtistItem(
                  rank: index + 1,
                  artist: artist,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningPatternsSlide() {
    return _RecapSlide(
      child: Column(
        children: [
          Text(
            'Your Listening Patterns',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PatternItem(
            icon: Icons.calendar_today,
            label: 'Most Active Day',
            value: _listeningPatterns['mostActiveDay'] ?? 'Friday',
          ),
          const SizedBox(height: AppSpacing.lg),
          _PatternItem(
            icon: Icons.schedule,
            label: 'Peak Listening Hour',
            value: '${_listeningPatterns['peakHour'] ?? 8}:00',
          ),
          const SizedBox(height: AppSpacing.lg),
          _PatternItem(
            icon: Icons.trending_up,
            label: 'Listening Streak',
            value: '${_listeningPatterns['listeningStreak'] ?? 0} days',
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveriesSlide() {
    return _RecapSlide(
      child: Column(
        children: [
          Icon(
            Icons.explore,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '${_listeningPatterns['newDiscoveries'] ?? 0}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'new discoveries',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'You explored ${_listeningPatterns['totalGenres'] ?? 0} different genres',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouSlide() {
    return _RecapSlide(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Thank You',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'for an amazing year of music',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: const Text('Share Your Recap'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final totalSlides = _getRecapSlides().length;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalSlides,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index == _currentSlide
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white24,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecapSlide extends StatelessWidget {
  final Widget child;

  const _RecapSlide({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: child,
    );
  }
}

class _TopTrackItem extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> track;

  const _TopTrackItem({
    required this.rank,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            '$rank',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track['title'] ?? 'Unknown Track',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  track['artist'] ?? 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          if (track['playcount'] != null)
            Text(
              '${track['playcount']} plays',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
            ),
        ],
      ),
    );
  }
}

class _TopArtistItem extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> artist;

  const _TopArtistItem({
    required this.rank,
    required this.artist,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Text(
            '$rank',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          ClipOval(
            child: Image.network(
              artist['image'] ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: Colors.white24,
                  child: Icon(
                    Icons.person,
                    color: Colors.white54,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist['name'] ?? 'Unknown Artist',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (artist['playcount'] != null)
                  Text(
                    '${artist['playcount']} plays',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _PatternItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 30,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
